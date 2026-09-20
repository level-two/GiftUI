#include "device_validation.h"

#include "ads7846.h"
#include "giftui_fault.h"
#include "ili9486.h"

#include <limits.h>
#include <stdint.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

#define GIFTUI_TOUCH_POLL_COUNT 1000U
#define GIFTUI_TOUCH_POLL_MILLISECONDS 10U

static void increment_saturating(uint32_t *value)
{
    if (*value < UINT32_MAX) {
        (*value)++;
    }
}

static void report_stack_high_water(void)
{
    size_t unused = 0U;
    const int result = k_thread_stack_space_get(k_current_get(), &unused);
    if (result != 0 || unused > CONFIG_MAIN_STACK_SIZE) {
        printk("GiftUI stack measurement failed: result=%d\n", result);
        return;
    }
    printk("GiftUI main stack: used=%u unused=%u capacity=%u\n",
           (unsigned int)(CONFIG_MAIN_STACK_SIZE - unused),
           (unsigned int)unused,
           (unsigned int)CONFIG_MAIN_STACK_SIZE);
}

int giftui_device_validation_run(void)
{
    printk("GiftUI target: nrf52840dk/nrf52840 + ILI9486/ADS7846\n");
    printk("GiftUI transfer: 480x4 RGB565, segment<=%u bytes\n",
           (unsigned int)ili9486_spi_segment_bytes());

    int result = ads7846_initialize();
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_TOUCH_CONTROLLER, result);
        return result;
    }
    result = ili9486_initialize();
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_DISPLAY_CONTROLLER, result);
        return result;
    }

    const uint32_t display_started = k_uptime_get_32();
    result = ili9486_render_color_bars();
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_DISPLAY_CONTROLLER, result);
        return result;
    }
    printk("GiftUI display transfer: status=completed elapsed-ms=%u\n",
           k_uptime_get_32() - display_started);

    uint32_t contacts = 0U;
    uint32_t samples = 0U;
    for (uint32_t poll = 0U; poll < GIFTUI_TOUCH_POLL_COUNT; ++poll) {
        const int pen_state = ads7846_pen_is_down();
        if (pen_state < 0) {
            return pen_state;
        }
        if (pen_state != 0) {
            struct ads7846_raw_sample sample;
            increment_saturating(&contacts);
            result = ads7846_read_raw(&sample);
            if (result != 0) {
                return result;
            }
            increment_saturating(&samples);
        }
        k_msleep(GIFTUI_TOUCH_POLL_MILLISECONDS);
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
    return 0;
}
