#include "production_host.h"

#include "ads7846.h"
#include "ili9486.h"
#include "static_host_clock.h"
#include "static_host_lifecycle.h"
#include "static_host_storage.h"
#include "static_input_bridge.h"
#include "static_touch_pipeline.h"

#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <zephyr/kernel.h>

#define GIFTUI_INPUT_POLL_MICROSECONDS 10000U

extern uint32_t giftui_signal_analyzer_present_initial(
    void *, uint32_t, void *, uint32_t, void *, uint32_t, void *, uint32_t,
    int (*)(uint16_t, uint16_t, uint16_t, uint16_t, const uint8_t *, size_t));
extern uint32_t giftui_signal_analyzer_present_next(
    void *, uint32_t, void *, uint32_t, void *, uint32_t, void *, uint32_t,
    int (*)(uint16_t, uint16_t, uint16_t, uint16_t, const uint8_t *, size_t));
extern uint32_t giftui_signal_analyzer_drain_initial_input(
    void *, uint32_t, void *, uint32_t);
extern uint32_t giftui_signal_analyzer_poll_scheduled_due(
    void *, uint32_t, void *, uint32_t);
extern uint32_t giftui_signal_analyzer_needs_presentation(void);
extern uint32_t giftui_signal_analyzer_current_revision(void);
extern uint64_t giftui_signal_analyzer_next_delay_microseconds(void);
extern void giftui_signal_analyzer_retire_initial(void);

struct giftui_production_context {
    struct giftui_static_host_storage regions;
    struct giftui_static_touch_pipeline touch;
    uint64_t next_transition_deadline;
};

static struct giftui_production_context production;

/* Full ADC range is the hardware-free default; connected calibration remains
 * a separately measured device setting. */
static const struct giftui_touch_calibration touch_calibration = {
    .horizontal_minimum = 0U,
    .horizontal_maximum = 4095U,
    .vertical_minimum = 0U,
    .vertical_maximum = 4095U,
    .logical_width = 480U,
    .logical_height = 320U,
    .swap_axes = 0U,
    .invert_horizontal = 0U,
    .invert_vertical = 0U,
};

static int validate(void *opaque)
{
    struct giftui_production_context *context = opaque;
    if (giftui_signal_analyzer_storage_regions(&context->regions) != 0 ||
        context->regions.profile_bytes != 39696U ||
        context->regions.capture_bytes != 115392U ||
        context->regions.raster_bytes != 3840U ||
        context->regions.coverage_bytes != 240U) {
        return -EINVAL;
    }
    return 0;
}

static int activate(void *opaque)
{
    struct giftui_production_context *context = opaque;
    const struct giftui_static_host_storage *regions = &context->regions;
    if (giftui_signal_analyzer_input_initialize(1U) != 0 ||
        giftui_signal_analyzer_present_initial(
            regions->profile, (uint32_t)regions->profile_bytes,
            regions->capture, (uint32_t)regions->capture_bytes,
            regions->raster, (uint32_t)regions->raster_bytes,
            regions->coverage, (uint32_t)regions->coverage_bytes,
            ili9486_write_rgb565) != 1U ||
        giftui_signal_analyzer_input_install_presentation(1U) != 0 ||
        giftui_static_touch_pipeline_initialize(
            &context->touch, &touch_calibration, 1U) != 0) {
        return -EIO;
    }
    context->next_transition_deadline = 0U;
    return 0;
}

static int touch_poll(void)
{
    const int pen = ads7846_pen_is_down();
    if (pen < 0) {
        giftui_static_touch_pipeline_transport_reset(&production.touch);
        return pen;
    }
    struct ads7846_raw_sample sample;
    const struct ads7846_raw_sample *observed = NULL;
    if (pen != 0) {
        const int result = ads7846_read_raw(&sample);
        if (result != 0) {
            giftui_static_touch_pipeline_transport_reset(&production.touch);
            return result;
        }
        observed = &sample;
    }
    int32_t admission_outcome = 0;
    const enum giftui_static_touch_pipeline_result result =
        giftui_static_touch_pipeline_update(
            &production.touch, pen != 0 ? 1U : 0U,
            observed, &admission_outcome);
    return result == GIFTUI_STATIC_TOUCH_PIPELINE_INVALID ? -EIO : 0;
}

static int service(void *opaque, uint64_t now,
                   uint64_t *next_deadline, int *stop)
{
    struct giftui_production_context *context = opaque;
    const struct giftui_static_host_storage *regions = &context->regions;
    *stop = 0;
    if (giftui_signal_analyzer_drain_initial_input(
            regions->profile, (uint32_t)regions->profile_bytes,
            regions->capture, (uint32_t)regions->capture_bytes) == 0U ||
        giftui_signal_analyzer_input_pending_count() != 0U) {
        return -EIO;
    }
    uint64_t delay = giftui_signal_analyzer_next_delay_microseconds();
    if (delay == UINT64_MAX) {
        context->next_transition_deadline = 0U;
    } else if (context->next_transition_deadline == 0U) {
        if (delay == 0U || delay > UINT64_MAX - now) {
            return -ERANGE;
        }
        context->next_transition_deadline = now + delay;
    }
    if (context->next_transition_deadline != 0U &&
        now >= context->next_transition_deadline) {
        if (giftui_signal_analyzer_poll_scheduled_due(
                regions->profile, (uint32_t)regions->profile_bytes,
                regions->capture, (uint32_t)regions->capture_bytes) != 1U) {
            return -EIO;
        }
        context->next_transition_deadline = 0U;
        delay = giftui_signal_analyzer_next_delay_microseconds();
        if (delay != UINT64_MAX) {
            if (delay == 0U || delay > UINT64_MAX - now) {
                return -ERANGE;
            }
            context->next_transition_deadline = now + delay;
        }
    }
    if (giftui_signal_analyzer_needs_presentation() != 0U) {
        if (giftui_signal_analyzer_present_next(
                regions->profile, (uint32_t)regions->profile_bytes,
                regions->capture, (uint32_t)regions->capture_bytes,
                regions->raster, (uint32_t)regions->raster_bytes,
                regions->coverage, (uint32_t)regions->coverage_bytes,
                ili9486_write_rgb565) != 1U ||
            giftui_static_touch_pipeline_present(
                &context->touch,
                giftui_signal_analyzer_current_revision()) != 0) {
            return -EIO;
        }
    }
    if (now > UINT64_MAX - GIFTUI_INPUT_POLL_MICROSECONDS) {
        return -ERANGE;
    }
    *next_deadline = now + GIFTUI_INPUT_POLL_MICROSECONDS;
    if (context->next_transition_deadline != 0U &&
        context->next_transition_deadline < *next_deadline) {
        *next_deadline = context->next_transition_deadline;
    }
    return 0;
}

static int teardown(void *opaque)
{
    struct giftui_production_context *context = opaque;
    giftui_signal_analyzer_input_quiesce();
    giftui_signal_analyzer_retire_initial();
    context->touch.valid = 0U;
    context->next_transition_deadline = 0U;
    return 0;
}

static void wait_microseconds(uint32_t duration)
{
    k_busy_wait(duration);
}

int giftui_production_host_run(void)
{
    const struct giftui_static_host_lifecycle_hal hal = {
        .touch_initialize = ads7846_initialize,
        .display_initialize = ili9486_initialize,
        .touch_poll = touch_poll,
        .display_shutdown = ili9486_shutdown,
        .touch_shutdown = ads7846_shutdown,
        .scheduler = {
            .now_microseconds = giftui_static_host_clock_now,
            .wait_microseconds = wait_microseconds,
            .service_watchdog = NULL,
        },
    };
    const struct giftui_static_host_application application = {
        .context = &production,
        .validate = validate,
        .activate = activate,
        .service = service,
        .teardown = teardown,
    };
    return giftui_static_host_run(&hal, &application);
}
