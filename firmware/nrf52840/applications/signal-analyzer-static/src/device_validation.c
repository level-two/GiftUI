#include "device_validation.h"

#include "ads7846.h"
#include "giftui_fault.h"
#include "ili9486.h"
#include "static_input_bridge.h"
#include "static_host_clock.h"

#include <stdbool.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

#define GIFTUI_TOUCH_POLL_COUNT 1000U
#define GIFTUI_TOUCH_POLL_MILLISECONDS 10U

K_THREAD_STACK_DECLARE(z_main_stack, CONFIG_MAIN_STACK_SIZE);

static void increment_saturating(uint32_t *value)
{
    if (*value < UINT32_MAX) {
        (*value)++;
    }
}

static void report_stack_high_water(void)
{
    const size_t capacity = K_THREAD_STACK_SIZEOF(z_main_stack);
    const uint8_t *const stack =
        (const uint8_t *)K_THREAD_STACK_BUFFER(z_main_stack);
    size_t unused = 0U;
    while (unused < capacity && stack[unused] == 0xaaU) {
        ++unused;
    }
    printk("GiftUI main stack: used=%u unused=%u capacity=%u\n",
           (unsigned int)(capacity - unused),
           (unsigned int)unused,
           (unsigned int)capacity);
}

int giftui_device_validation_run(void)
{
    bool touch_initialized = false;
    bool display_initialized = false;
    printk("GiftUI target: nrf52840dk/nrf52840 + ILI9486/ADS7846\n");
    printk("GiftUI transfer: 480x4 RGB565, segment<=%u bytes\n",
           (unsigned int)ili9486_spi_segment_bytes());

    int result = giftui_signal_analyzer_input_initialize(1U);
    if (result != 0 || giftui_signal_analyzer_input_pending_count() != 0U) {
        if (result == 0) {
            result = -EINVAL;
        }
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, result);
        goto cleanup;
    }

    result = ads7846_initialize();
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_TOUCH_CONTROLLER, result);
        goto cleanup;
    }
    touch_initialized = true;
    result = ili9486_initialize();
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_DISPLAY_CONTROLLER, result);
        goto cleanup;
    }
    display_initialized = true;

    uint64_t display_started = 0U;
    result = giftui_static_host_clock_now(&display_started);
    if (result != 0) {
        goto cleanup;
    }
    result = ili9486_render_color_bars();
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_DISPLAY_CONTROLLER, result);
        goto cleanup;
    }
    uint64_t display_finished = 0U;
    result = giftui_static_host_clock_now(&display_finished);
    if (result != 0) {
        goto cleanup;
    }
    if (display_finished < display_started ||
        (display_finished - display_started) / 1000U > UINT32_MAX) {
        result = -ERANGE;
        goto cleanup;
    }
    printk("GiftUI display transfer: status=completed elapsed-ms=%u\n",
           (unsigned int)((display_finished - display_started) / 1000U));
    result = giftui_signal_analyzer_input_install_presentation(0U);
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, result);
        goto cleanup;
    }

    uint32_t contacts = 0U;
    uint32_t samples = 0U;
    for (uint32_t poll = 0U; poll < GIFTUI_TOUCH_POLL_COUNT; ++poll) {
        const int pen_state = ads7846_pen_is_down();
        if (pen_state < 0) {
            result = pen_state;
            goto cleanup;
        }
        if (pen_state != 0) {
            struct ads7846_raw_sample sample;
            increment_saturating(&contacts);
            result = ads7846_read_raw(&sample);
            if (result != 0) {
                goto cleanup;
            }
            increment_saturating(&samples);
        }
        k_busy_wait(GIFTUI_TOUCH_POLL_MILLISECONDS * 1000U);
    }

    printk("GiftUI touch poll: status=completed contacts=%u samples=%u\n",
           contacts, samples);
    printk("GiftUI faults: capacity=%u display-controller=%u display-spi=%u "
           "touch-controller=%u touch-spi=%u\n",
           giftui_fault_count(GIFTUI_FAULT_CAPACITY),
           giftui_fault_count(GIFTUI_FAULT_DISPLAY_CONTROLLER),
           giftui_fault_count(GIFTUI_FAULT_DISPLAY_SPI),
           giftui_fault_count(GIFTUI_FAULT_TOUCH_CONTROLLER),
           giftui_fault_count(GIFTUI_FAULT_TOUCH_SPI));
    report_stack_high_water();

cleanup:
    giftui_signal_analyzer_input_quiesce();
    if (display_initialized) {
        const int shutdown_result = ili9486_shutdown();
        if (shutdown_result != 0) {
            giftui_fault_record(
                GIFTUI_FAULT_DISPLAY_CONTROLLER,
                shutdown_result);
        }
        if (result == 0 && shutdown_result != 0) {
            result = shutdown_result;
        }
    }
    if (touch_initialized) {
        const int shutdown_result = ads7846_shutdown();
        if (shutdown_result != 0) {
            giftui_fault_record(
                GIFTUI_FAULT_TOUCH_CONTROLLER,
                shutdown_result);
        }
        if (result == 0 && shutdown_result != 0) {
            result = shutdown_result;
        }
    }
    return result;
}
