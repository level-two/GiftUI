#include "ads7846.h"
#include "production_host.h"
#include "static_host_storage.h"

#include <assert.h>
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern uint32_t giftui_signal_analyzer_initial_model_active(void);
extern uint16_t giftui_signal_analyzer_initial_committed_actions(void);
extern uint32_t giftui_signal_analyzer_current_revision(void);
extern uint32_t giftui_signal_analyzer_action_point(uint16_t);
extern uint32_t giftui_signal_analyzer_hit_point(uint16_t);
extern uint32_t giftui_signal_analyzer_capture_revision(void);
extern uint32_t giftui_signal_analyzer_capture_count(void);
extern uint32_t giftui_signal_analyzer_acquisition_state(void);
extern uint32_t giftui_signal_analyzer_visible_window(void);
extern uint32_t giftui_signal_analyzer_last_semantic_scopes(void);
extern uint32_t giftui_signal_analyzer_last_layout_scopes(void);
extern uint32_t giftui_signal_analyzer_last_drawing_strokes(void);
extern uint32_t giftui_signal_analyzer_last_drawing_points(void);
extern uint32_t giftui_signal_analyzer_last_render_operations(void);
extern uint64_t giftui_signal_analyzer_next_delay_microseconds(void);
extern uint32_t giftui_signal_analyzer_rehearsal_diagnostic(void);
extern uint32_t giftui_signal_analyzer_rehearsal_clear(void *, void *);
extern uint32_t giftui_signal_analyzer_rehearsal_maximum_diagnostic(void);
extern int giftui_firmware_main(void);
extern uint32_t giftui_signal_analyzer_rehearsal_common_owner(void *, void *, void *, void *);

static uint64_t clock_microseconds;
static uint32_t workload_last_revision;
extern uint32_t giftui_signal_analyzer_source_capture_revision(void);
static unsigned touch_polls;
static unsigned display_writes;
static unsigned first_frame_write_count;
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
static uint8_t recorded_surface[320U * 240U * 2U];
static const char *fault_mode;
static unsigned diagnostic_mode;
static unsigned cleared_mode;
static uint32_t clear_prior_revision;
static unsigned diagnostic_injected;
static unsigned touch_probe_stage;
static uint64_t touch_probe_released_at;
static uint64_t acquisition_started_at;
static unsigned touch_probe_mode;

static void capture_frame(const char *name)
{
    const char *directory = getenv("GIFTUI_REHEARSAL_RASTERS");
    if (directory == NULL) {
        return;
    }
    char path[1024];
    const int length = snprintf(path, sizeof(path), "%s/nrf-%s.rgb565",
                                directory, name);
    assert(length > 0 && (size_t)length < sizeof(path));
    FILE *file = fopen(path, "wb");
    assert(file != NULL);
    assert(fwrite(recorded_surface, 1U, sizeof(recorded_surface), file) ==
           sizeof(recorded_surface));
    assert(fclose(file) == 0);
}

static uint64_t recorded_frame_hash(void)
{
    uint64_t hash = UINT64_C(14695981039346656037);
    for (size_t index = 0U; index < sizeof(recorded_surface); index++) {
        hash = (hash ^ recorded_surface[index]) * UINT64_C(1099511628211);
    }
    return hash;
}

struct scripted_action {
    uint16_t code;
    uint8_t enabled;
    uint8_t state;
    uint8_t window;
};

static const struct scripted_action actions[] = {
    {1U, 1U, 2U, 1U},
    {0U, 1U, 1U, 1U},
    {3U, 1U, 1U, 0U},
    {3U, 0U, 1U, 0U},
    {3U, 0U, 1U, 0U},
    {4U, 1U, 1U, 1U},
    {5U, 1U, 1U, 2U},
    {5U, 0U, 1U, 2U},
    {5U, 0U, 1U, 2U},
    {4U, 1U, 1U, 1U},
    {3U, 1U, 1U, 0U},
    {4U, 1U, 1U, 1U},
};

uint64_t giftui_static_host_source_clock_delay(uint64_t duration)
{
    if (duration == UINT64_MAX ||
        giftui_signal_analyzer_source_capture_revision() >= 2404U) {
        return UINT64_MAX;
    }
    /* The live adapter batches until the paced boundary. Keep the actual
     * source delay so this substitute honors the approved 20-fact window. */
    return duration;
}

int ads7846_initialize(void)
{
    return fault_mode != NULL && fault_mode[0] == 't' ? -EIO : 0;
}
int ads7846_pen_is_down(void)
{
    touch_polls++;
    if (clock_microseconds > UINT64_C(300000000)) {
        fprintf(stderr,
                "rehearsal-stalled clock=%llu capture=%u frame=%u stage=%u action=%u\n",
                (unsigned long long)clock_microseconds,
                giftui_signal_analyzer_capture_revision(),
                giftui_signal_analyzer_current_revision(),
                script_stage, action_index);
        return -ETIMEDOUT;
    }
    const uint32_t revision = giftui_signal_analyzer_current_revision();
    if (fault_mode != NULL &&
        ((fault_mode[0] == 'i' && revision == 1U) ||
         (fault_mode[0] == 'p' && revision >= 2U))) {
        return -EIO;
    }
    if (revision != 0U && revision != last_traced_revision) {
        assert(revision > last_traced_revision);
        const uint32_t scopes = 92U;
        assert(giftui_signal_analyzer_last_semantic_scopes() == scopes);
        assert(giftui_signal_analyzer_last_layout_scopes() == scopes);
        assert(giftui_signal_analyzer_last_drawing_strokes() == 5U);
        assert(giftui_signal_analyzer_last_drawing_points() >= 32U);
        assert(giftui_signal_analyzer_last_render_operations() > 0U);
        last_traced_revision = revision;
        if (revision == 1U) {
            first_frame_write_count = display_writes;
            capture_frame("idle");
        } else if (giftui_signal_analyzer_capture_revision() == 2404U && workload_last_revision == 0U) {
            workload_last_revision = revision;
            capture_frame("running-four-traces");
        } else if (workload_last_revision != 0U && revision == workload_last_revision + 1U) {
            capture_frame("stopped");
        } else if (workload_last_revision != 0U && revision == workload_last_revision + 3U) {
            capture_frame("window-one-second");
                } else if (workload_last_revision != 0U && revision == workload_last_revision + 5U) {
            capture_frame("window-five-seconds");
        } else if (workload_last_revision != 0U && revision == workload_last_revision + 8U) {
            capture_frame("window-two-seconds");
        } else if (clear_prior_revision != 0U && revision > clear_prior_revision) {
            assert(giftui_signal_analyzer_capture_count() == 0U);
            assert(giftui_signal_analyzer_acquisition_state() == 1U);
            capture_frame("cleared");
            printf("cleared=captured\tcapture_count=0\tstate=running\tstatus=passed\n");
        } else if (diagnostic_mode != 0U && revision == 2U) {
            capture_frame("diagnostic");
        }
        printf("trace=frame\trevision=%u\tcapture_revision=%u"
               "\tcapture_count=%u\tstate=%u\twindow=%u"
               "\tsemantic_scopes=%u\tlayout_scopes=%u"
               "\tdrawing_strokes=%u\tdrawing_points=%u"
               "\trender_operations=%u\twrites=%u\tbytes=%u"
               "\tframe_hash=%llu\n",
               revision, giftui_signal_analyzer_capture_revision(),
               giftui_signal_analyzer_capture_count(),
               giftui_signal_analyzer_acquisition_state(),
               giftui_signal_analyzer_visible_window(),
               giftui_signal_analyzer_last_semantic_scopes(),
               giftui_signal_analyzer_last_layout_scopes(),
               giftui_signal_analyzer_last_drawing_strokes(),
               giftui_signal_analyzer_last_drawing_points(),
               giftui_signal_analyzer_last_render_operations(),
               display_writes, display_bytes,
               (unsigned long long)recorded_frame_hash());
    }
    if (clear_prior_revision != 0U) {
        return revision > clear_prior_revision ? -ECANCELED : 0;
    }
    if (diagnostic_mode != 0U) {
        if (revision == 1U && diagnostic_injected == 0U &&
            clock_microseconds >= 10000U) {
            assert((diagnostic_mode == 2U
                        ? giftui_signal_analyzer_rehearsal_maximum_diagnostic()
                        : giftui_signal_analyzer_rehearsal_diagnostic()) == 1U);
            diagnostic_injected = 1U;
        }
        if (revision == 2U) {
            assert(giftui_signal_analyzer_acquisition_state() == 3U);
            return -ECANCELED;
        }
        return 0;
    }
    if (script_stage == 0U) {
        if (touch_probe_mode != 0U && touch_probe_stage < 8U) {
            assert(revision == 1U);
            assert(giftui_signal_analyzer_acquisition_state() == 0U);
            switch (touch_probe_stage) {
            case 0U:
                touch_point = giftui_signal_analyzer_action_point(0U);
                assert(touch_point != 0U);
                touch_probe_stage++;
                return 1;
            case 1U:
                /* Holding the button must not dispatch before release. */
                touch_probe_stage++;
                return 1;
            case 2U:
                /* Drag into the waveform, cancelling the captured button. */
                touch_point = (220U << 16) | 120U;
                touch_probe_stage++;
                return 1;
            case 3U:
            case 6U:
                touch_probe_released_at = clock_microseconds;
                touch_probe_stage++;
                return 0;
            case 4U:
            case 7U:
                if (clock_microseconds < touch_probe_released_at + 260000U) {
                    return 0;
                }
                assert(display_writes == first_frame_write_count);
                touch_probe_stage++;
                if (touch_probe_stage == 8U) {
                    printf("trace=touch-probe\thold=cancelled\tmiss=ignored"
                           "\trevision=1\tstatus=passed\n");
                    return -ECANCELED;
                }
                return 0;
            case 5U:
                /* A complete tap on empty content must also be ignored. */
                touch_probe_stage++;
                return 1;
            default:
                assert(0);
            }
        }
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
            acquisition_started_at = clock_microseconds;
            script_stage = 1U;
            touch_phase = 0U;
        }
        return 0;
    }
    if (script_stage == 1U) {
        if (clock_microseconds >= acquisition_started_at + 1000000U &&
            giftui_signal_analyzer_capture_revision() < 5U) {
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
            giftui_signal_analyzer_current_revision() >= 809U) {
            paced_frame_observed = 1U;
            script_stage = 2U;
            printf("workload_transitions=2400\tworkload_frames=%u\tsource_clock=unscaled\n",
                   giftui_signal_analyzer_current_revision() - 2U);
        }
        return 0;
    }
    if (action_index == sizeof(actions) / sizeof(actions[0])) {
        if (cleared_mode != 0U) {
            struct giftui_static_host_storage regions;
            assert(giftui_signal_analyzer_storage_regions(&regions) == 0);
            clear_prior_revision = giftui_signal_analyzer_current_revision();
            assert(giftui_signal_analyzer_capture_count() > 0U);
            assert(giftui_signal_analyzer_rehearsal_clear(regions.profile, regions.capture) == 1U);
            return 0;
        }
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
    // The next poll either finishes or admits the separate cleared-state fixture.
    return 0;
}
int ads7846_read_raw(struct ads7846_raw_sample *sample)
{
    if (fault_mode != NULL && strcmp(fault_mode, "read-input") == 0) {
        return -EIO;
    }
    const uint32_t point = touch_point;
    assert(point != 0U && sample != NULL);
    sample->x = (uint16_t)(((point & 0xffffU) * 4095U) / 319U);
    sample->y = (uint16_t)((((point >> 16) & 0xffffU) * 4095U) / 239U);
    sample->z1 = 1U;
    sample->z2 = 1U;
    return 0;
}
int ads7846_shutdown(void)
{
    assert(shutdown_order == (fault_mode != NULL && fault_mode[0] == 'd' ? 0U : 1U));
    shutdown_order = 2U;
    return 0;
}
int spi_tft_initialize(void)
{
    return fault_mode != NULL && fault_mode[0] == 'd' ? -EIO : 0;
}
uint16_t spi_tft_tile_height(void) { return 4U; }
uint32_t spi_tft_spi_segment_bytes(void) { return 2560U; }
int spi_tft_write_rgb565(uint16_t x, uint16_t y, uint16_t width,
                          uint16_t height, const uint8_t *pixels,
                          size_t byte_count)
{
    assert(x < 320U && y < 240U && width > 0U && height == 1U);
    assert((uint32_t)x + width <= 320U);
    assert(pixels != NULL && byte_count == (size_t)width * 2U);
    if (fault_mode != NULL &&
        (strcmp(fault_mode, "write-initial") == 0 ||
         ((strcmp(fault_mode, "write-next") == 0) &&
          first_frame_write_count != 0U &&
          display_writes >= first_frame_write_count))) {
        return -EIO;
    }
    for (uint16_t column = 0U; column < width; column++) {
        const size_t destination = ((size_t)y * 320U + x + column) * 2U;
        recorded_surface[destination] = pixels[(size_t)column * 2U];
        recorded_surface[destination + 1U] = pixels[(size_t)column * 2U + 1U];
    }
    display_writes++;
    display_bytes += (unsigned)byte_count;
    return 0;
}
int spi_tft_shutdown(void)
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
    fault_mode = getenv("GIFTUI_REHEARSAL_FAULT");
    cleared_mode = getenv("GIFTUI_REHEARSAL_CLEARED") != NULL;
    const char *diagnostic = getenv("GIFTUI_REHEARSAL_DIAGNOSTIC");
    diagnostic_mode = diagnostic == NULL ? 0U : (diagnostic[0] == 'm' ? 2U : 1U);
    touch_probe_mode = getenv("GIFTUI_REHEARSAL_TOUCH_PROBE") != NULL;
    struct giftui_static_host_storage regions;
    assert(giftui_signal_analyzer_storage_regions(&regions) == 0);
    assert(regions.profile_bytes == 39696U);
    assert(regions.capture_bytes == 115392U);
    assert(regions.raster_bytes == 2560U);
    assert(regions.coverage_bytes == 160U);


    if (getenv("GIFTUI_REHEARSAL_COMMON_OWNER") != NULL) {
        setbuf(stdout, NULL);
        assert(giftui_signal_analyzer_rehearsal_common_owner(regions.profile, regions.capture, regions.raster, regions.coverage) == 1U);
        return 0;
    }
    const int result = giftui_firmware_main();
    if (touch_probe_mode != 0U) {
        assert(result == -ECANCELED && touch_probe_stage == 8U);
        assert(shutdown_order == 2U);
        assert(display_writes == first_frame_write_count);
        assert(giftui_signal_analyzer_initial_model_active() == 0U);
        assert(giftui_signal_analyzer_current_revision() == 0U);
        assert(giftui_signal_analyzer_initial_committed_actions() == 0U);
        printf("status=passed\tprofile=nrf52840-static\tevidence=raw-touch-probes\n");
        return 0;
    }
    if (diagnostic_mode != 0U) {
        assert(result == -ECANCELED);
        assert(diagnostic_injected == 1U && last_traced_revision == 2U);
        assert(shutdown_order == 2U);
        printf("diagnostic=visible\trevision=2\tframe_hash=%llu"
               "\tstatus=passed\n",
               (unsigned long long)recorded_frame_hash());
        return 0;
    }
    if (fault_mode != NULL) {
        assert(result == -EIO);
        assert(giftui_signal_analyzer_initial_model_active() == 0U);
        assert(giftui_signal_analyzer_current_revision() == 0U);
        assert(giftui_signal_analyzer_initial_committed_actions() == 0U);
        if (fault_mode[0] == 't') {
            assert(shutdown_order == 0U);
            assert(display_writes == 0U);
        } else if (fault_mode[0] == 'd') {
            assert(shutdown_order == 2U);
            assert(display_writes == 0U);
        } else {
            assert(shutdown_order == 2U);
            if (strcmp(fault_mode, "write-initial") == 0) {
                assert(display_writes == 0U);
            } else if (strcmp(fault_mode, "write-next") == 0) {
                assert(first_frame_write_count > 0U);
                assert(display_writes == first_frame_write_count);
            } else {
                assert(display_writes > 0U);
            }
        }
        printf("fault=%s\tresult=%d\tshutdown_order=%u\twrites=%u"
               "\tlast_frame_hash=%llu\tstatus=passed\n",
               fault_mode, result, shutdown_order, display_writes,
               (unsigned long long)recorded_frame_hash());
        return 0;
    }
    if (result != -ECANCELED) {
        fprintf(stderr, "host rehearsal result=%d writes=%u bytes=%u\n",
                result, display_writes, display_bytes);
    }
    assert(result == -ECANCELED);
    assert(touch_polls > 2U && paced_frame_observed == 1U);
    assert(action_index == sizeof(actions) / sizeof(actions[0]));
    assert(display_writes > 0U && display_bytes > 0U);
    assert(giftui_signal_analyzer_initial_committed_actions() == 0U);
    assert(giftui_signal_analyzer_current_revision() == 0U);
    assert(giftui_signal_analyzer_last_semantic_scopes() == 0U);
    assert(shutdown_order == 2U);
    printf("status=passed\tprofile=nrf52840-static\tevidence=host-native-fixture"
           "\twrites=%u\tbytes=%u\n", display_writes, display_bytes);
    return 0;
}
