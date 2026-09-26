#include "ads7846.h"
#include "production_host.h"
#include "static_host_storage.h"

#include <assert.h>
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

extern uint32_t giftui_signal_analyzer_initial_model_active(void);
extern uint16_t giftui_signal_analyzer_initial_committed_actions(void);
extern uint32_t giftui_signal_analyzer_current_revision(void);
extern uint32_t giftui_signal_analyzer_action_point(uint16_t);
extern uint32_t giftui_signal_analyzer_hit_point(uint16_t);
extern uint32_t giftui_signal_analyzer_capture_revision(void);
extern uint32_t giftui_signal_analyzer_capture_count(void);
extern uint32_t giftui_signal_analyzer_acquisition_state(void);
extern uint32_t giftui_signal_analyzer_visible_window(void);
extern uint64_t giftui_signal_analyzer_next_delay_microseconds(void);
extern int giftui_firmware_main(void);

static uint64_t clock_microseconds;
static unsigned touch_polls;
static unsigned display_writes;
static unsigned display_bytes;
static unsigned shutdown_order;
static unsigned paced_frame_observed;
static uint32_t touch_point;
static unsigned script_stage;
static unsigned touch_phase;
static unsigned action_index;
static uint32_t action_prior_revision;
static uint64_t action_started_at;
static uint32_t last_traced_revision;

struct scripted_action {
    uint16_t code;
    uint8_t enabled;
    uint8_t state;
    uint8_t window;
};

static const struct scripted_action actions[] = {
    {0U, 0U, 1U, 1U},
    {1U, 1U, 2U, 1U},
    {1U, 0U, 2U, 1U},
    {0U, 1U, 1U, 1U},
    {0U, 0U, 1U, 1U},
    {2U, 1U, 1U, 1U},
    {3U, 1U, 1U, 0U},
    {3U, 0U, 1U, 0U},
    {5U, 1U, 1U, 2U},
    {5U, 0U, 1U, 2U},
    {4U, 1U, 1U, 1U},
    {4U, 0U, 1U, 1U},
};

uint64_t giftui_static_host_source_clock_delay(uint64_t duration)
{
    if (duration == UINT64_MAX ||
        giftui_signal_analyzer_capture_revision() >= 2404U) {
        return UINT64_MAX;
    }
    return duration * 2998U / 20177U;
}

int ads7846_initialize(void) { return 0; }
int ads7846_pen_is_down(void)
{
    touch_polls++;
    const uint32_t revision = giftui_signal_analyzer_current_revision();
    if (revision != 0U && revision != last_traced_revision) {
        assert(revision > last_traced_revision);
        last_traced_revision = revision;
        printf("trace=frame\trevision=%u\tcapture_revision=%u"
               "\tcapture_count=%u\tstate=%u\twindow=%u"
               "\twrites=%u\tbytes=%u\n",
               revision, giftui_signal_analyzer_capture_revision(),
               giftui_signal_analyzer_capture_count(),
               giftui_signal_analyzer_acquisition_state(),
               giftui_signal_analyzer_visible_window(), display_writes,
               display_bytes);
    }
    if (script_stage == 0U) {
        if (touch_phase == 0U) {
            touch_point = giftui_signal_analyzer_action_point(0U);
            assert(touch_point != 0U);
            touch_phase = 1U;
            return 1;
        }
        if (touch_phase == 1U) {
            touch_phase = 2U;
            return 0;
        }
        if (giftui_signal_analyzer_acquisition_state() == 1U) {
            script_stage = 1U;
            touch_phase = 0U;
        }
        return 0;
    }
    if (script_stage == 1U) {
        if (clock_microseconds >= 1000000U &&
            giftui_signal_analyzer_capture_revision() < 50U) {
            fprintf(stderr, "source-stalled clock=%llu capture=%u frame=%u state=%u delay=%llu\n",
                    (unsigned long long)clock_microseconds,
                    giftui_signal_analyzer_capture_revision(),
                    giftui_signal_analyzer_current_revision(),
                    giftui_signal_analyzer_acquisition_state(),
                    (unsigned long long)giftui_signal_analyzer_next_delay_microseconds());
            return -EIO;
        }
        assert(giftui_signal_analyzer_capture_revision() <= 2404U);
        if (giftui_signal_analyzer_capture_revision() == 2404U &&
            giftui_signal_analyzer_current_revision() == 121U) {
            paced_frame_observed = 1U;
            script_stage = 2U;
            printf("workload_transitions=2400\tworkload_frames=120\n");
        }
        return 0;
    }
    if (action_index == sizeof(actions) / sizeof(actions[0])) {
        return -ECANCELED;
    }
    const struct scripted_action *action = &actions[action_index];
    if (touch_phase == 0U) {
        touch_point = giftui_signal_analyzer_hit_point(action->code);
        assert(touch_point != 0U);
        assert((giftui_signal_analyzer_action_point(action->code) != 0U) ==
               (action->enabled != 0U));
        action_prior_revision = giftui_signal_analyzer_current_revision();
        action_started_at = clock_microseconds;
        touch_phase = 1U;
        return 1;
    }
    if (touch_phase == 1U) {
        touch_phase = 2U;
        return 0;
    }
    if (action->enabled != 0U) {
        if (giftui_signal_analyzer_current_revision() ==
            action_prior_revision) {
            return 0;
        }
    } else {
        if (clock_microseconds < action_started_at + 260000U) {
            return 0;
        }
        assert(giftui_signal_analyzer_current_revision() ==
               action_prior_revision);
    }
    assert(giftui_signal_analyzer_acquisition_state() == action->state);
    assert(giftui_signal_analyzer_visible_window() == action->window);
    if (action->code == 2U) {
        assert(giftui_signal_analyzer_capture_count() == 0U);
    }
    printf("trace=action\tcode=%u\tdispatched=%u\trevision=%u"
           "\tcapture_count=%u\tstate=%u\twindow=%u\n",
           action->code, action->enabled,
           giftui_signal_analyzer_current_revision(),
           giftui_signal_analyzer_capture_count(),
           giftui_signal_analyzer_acquisition_state(),
           giftui_signal_analyzer_visible_window());
    action_index++;
    touch_phase = 0U;
    if (action_index == sizeof(actions) / sizeof(actions[0])) {
        return -ECANCELED;
    }
    return 0;
}
int ads7846_read_raw(struct ads7846_raw_sample *sample)
{
    const uint32_t point = touch_point;
    assert(point != 0U && sample != NULL);
    sample->x = (uint16_t)(((point & 0xffffU) * 4095U) / 479U);
    sample->y = (uint16_t)((((point >> 16) & 0xffffU) * 4095U) / 319U);
    sample->z1 = 1U;
    sample->z2 = 1U;
    return 0;
}
int ads7846_shutdown(void)
{
    assert(shutdown_order == 1U);
    shutdown_order = 2U;
    return 0;
}
int ili9486_initialize(void) { return 0; }
uint16_t ili9486_tile_height(void) { return 4U; }
uint32_t ili9486_spi_segment_bytes(void) { return 3840U; }
int ili9486_write_rgb565(uint16_t x, uint16_t y, uint16_t width,
                          uint16_t height, const uint8_t *pixels,
                          size_t byte_count)
{
    assert(x < 480U && y < 320U && width > 0U && height == 1U);
    assert((uint32_t)x + width <= 480U);
    assert(pixels != NULL && byte_count == (size_t)width * 2U);
    display_writes++;
    display_bytes += (unsigned)byte_count;
    return 0;
}
int ili9486_shutdown(void)
{
    assert(giftui_signal_analyzer_initial_model_active() == 0U);
    assert(shutdown_order == 0U);
    shutdown_order = 1U;
    return 0;
}
int giftui_static_host_clock_now(uint64_t *now)
{
    *now = clock_microseconds;
    return 0;
}
void k_busy_wait(uint32_t duration) { clock_microseconds += duration; }

int main(void)
{
    struct giftui_static_host_storage regions;
    assert(giftui_signal_analyzer_storage_regions(&regions) == 0);
    assert(regions.profile_bytes == 39696U);
    assert(regions.capture_bytes == 115392U);
    assert(regions.raster_bytes == 3840U);
    assert(regions.coverage_bytes == 240U);


    const int result = giftui_firmware_main();
    assert(result == -ECANCELED);
    assert(touch_polls > 2U && paced_frame_observed == 1U);
    assert(action_index == sizeof(actions) / sizeof(actions[0]));
    assert(display_writes > 0U && display_bytes > 0U);
    assert(giftui_signal_analyzer_initial_committed_actions() == 0U);
    assert(giftui_signal_analyzer_current_revision() == 0U);
    assert(shutdown_order == 2U);
    printf("status=passed\tprofile=nrf52840-static\tevidence=host-native-fixture"
           "\twrites=%u\tbytes=%u\n", display_writes, display_bytes);
    return 0;
}
