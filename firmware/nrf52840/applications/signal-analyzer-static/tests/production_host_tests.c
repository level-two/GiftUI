#include "../src/production_host.c"

#include <assert.h>
#include <string.h>

static uint8_t profile_region[39696];
static uint8_t capture_region[115392];
static uint8_t raster_region[3840];
static uint8_t coverage_region[240];
static uint32_t revision;
static uint32_t frame_count;
static uint32_t poll_count;
static uint32_t drain_count;
static uint32_t touch_revision;
static uint32_t teardown_count;
static uint32_t dirty;
static uint64_t delay = UINT64_MAX;
static int refuse_initial;
static int refuse_next;
static int pen_result;

void k_busy_wait(uint32_t duration) { (void)duration; }
int ads7846_initialize(void) { return 0; }
int ads7846_shutdown(void) { return 0; }
int ads7846_pen_is_down(void) { return pen_result; }
int ads7846_read_raw(struct ads7846_raw_sample *sample)
{
    (void)sample;
    return -EIO;
}
int ili9486_initialize(void) { return 0; }
int ili9486_shutdown(void) { return 0; }
int ili9486_write_rgb565(uint16_t x, uint16_t y, uint16_t width,
                          uint16_t height, const uint8_t *pixels,
                          size_t byte_count)
{
    (void)x; (void)y; (void)width; (void)height;
    (void)pixels; (void)byte_count;
    return 0;
}
int giftui_signal_analyzer_storage_regions(struct giftui_static_host_storage *regions)
{
    *regions = (struct giftui_static_host_storage) {
        .profile = profile_region, .profile_bytes = sizeof(profile_region),
        .capture = capture_region, .capture_bytes = sizeof(capture_region),
        .raster = raster_region, .raster_bytes = sizeof(raster_region),
        .coverage = coverage_region, .coverage_bytes = sizeof(coverage_region),
    };
    return 0;
}
int32_t giftui_signal_analyzer_input_initialize(uint16_t source)
{
    assert(source == 1U);
    return 0;
}
int32_t giftui_signal_analyzer_input_install_presentation(uint32_t next)
{
    assert(next == 1U);
    return 0;
}
uint16_t giftui_signal_analyzer_input_pending_count(void) { return 0U; }
void giftui_signal_analyzer_input_quiesce(void) { teardown_count++; }
int giftui_static_touch_pipeline_initialize(
    struct giftui_static_touch_pipeline *pipeline,
    const struct giftui_touch_calibration *calibration, uint32_t next)
{
    assert(calibration->logical_width == 480U);
    pipeline->valid = 1U;
    touch_revision = next;
    return 0;
}
int giftui_static_touch_pipeline_present(
    struct giftui_static_touch_pipeline *pipeline, uint32_t next)
{
    assert(pipeline->valid == 1U);
    assert(next == touch_revision + 1U);
    touch_revision = next;
    return 0;
}
enum giftui_static_touch_pipeline_result giftui_static_touch_pipeline_update(
    struct giftui_static_touch_pipeline *pipeline, uint8_t touching,
    const struct ads7846_raw_sample *sample, int32_t *outcome)
{
    (void)pipeline; (void)touching; (void)sample; (void)outcome;
    return GIFTUI_STATIC_TOUCH_PIPELINE_NONE;
}
void giftui_static_touch_pipeline_transport_reset(
    struct giftui_static_touch_pipeline *pipeline)
{
    pipeline->valid = 0U;
}
uint32_t giftui_signal_analyzer_present_initial(
    void *profile, uint32_t profile_bytes, void *capture, uint32_t capture_bytes,
    void *raster, uint32_t raster_bytes, void *coverage, uint32_t coverage_bytes,
    int (*write)(uint16_t, uint16_t, uint16_t, uint16_t,
                 const uint8_t *, size_t))
{
    (void)profile; (void)profile_bytes; (void)capture; (void)capture_bytes;
    (void)raster; (void)raster_bytes; (void)coverage; (void)coverage_bytes;
    assert(write == ili9486_write_rgb565);
    if (refuse_initial != 0) { return 0U; }
    revision = 1U;
    frame_count++;
    return 1U;
}
uint32_t giftui_signal_analyzer_present_next(
    void *profile, uint32_t profile_bytes, void *capture, uint32_t capture_bytes,
    void *raster, uint32_t raster_bytes, void *coverage, uint32_t coverage_bytes,
    int (*write)(uint16_t, uint16_t, uint16_t, uint16_t,
                 const uint8_t *, size_t))
{
    (void)profile; (void)profile_bytes; (void)capture; (void)capture_bytes;
    (void)raster; (void)raster_bytes; (void)coverage; (void)coverage_bytes;
    assert(write == ili9486_write_rgb565);
    if (refuse_next != 0) { return 0U; }
    revision++;
    frame_count++;
    dirty = 0U;
    return 1U;
}
uint32_t giftui_signal_analyzer_drain_initial_input(
    void *profile, uint32_t profile_bytes, void *capture, uint32_t capture_bytes)
{
    (void)profile; (void)profile_bytes; (void)capture; (void)capture_bytes;
    drain_count++;
    if (drain_count == 1U) {
        delay = 80000U;
        dirty = 1U;
        return 2U;
    }
    return 1U;
}
uint32_t giftui_signal_analyzer_poll_scheduled_due(
    void *profile, uint32_t profile_bytes, void *capture, uint32_t capture_bytes)
{
    (void)profile; (void)profile_bytes; (void)capture; (void)capture_bytes;
    poll_count++;
    dirty = 1U;
    return 1U;
}
uint32_t giftui_signal_analyzer_needs_presentation(void) { return dirty; }
uint32_t giftui_signal_analyzer_current_revision(void) { return revision; }
uint64_t giftui_signal_analyzer_next_delay_microseconds(void) { return delay; }
void giftui_signal_analyzer_retire_initial(void) { teardown_count++; }
int giftui_static_host_clock_now(uint64_t *timestamp)
{
    *timestamp = 0U;
    return 0;
}
int giftui_static_host_run(
    const struct giftui_static_host_lifecycle_hal *hal,
    const struct giftui_static_host_application *application)
{
    (void)hal; (void)application;
    return 0;
}

int main(void)
{
    uint64_t deadline = 0U;
    int stop = 0;
    assert(validate(&production) == 0);
    assert(activate(&production) == 0);
    assert(revision == 1U && touch_revision == 1U && frame_count == 1U);
    assert(touch_poll() == 0);
    assert(service(&production, 100000U, &deadline, &stop) == 0);
    assert(deadline == 110000U && stop == 0);
    assert(frame_count == 2U && touch_revision == 2U && poll_count == 0U);
    assert(service(&production, 180000U, &deadline, &stop) == 0);
    assert(deadline == 190000U);
    assert(frame_count == 3U && touch_revision == 3U && poll_count == 1U);
    delay = UINT64_MAX;
    production.next_transition_deadline = 0U;
    dirty = 1U;
    refuse_next = 1;
    assert(service(&production, 200000U, &deadline, &stop) == -EIO);
    refuse_next = 0;
    pen_result = -EIO;
    assert(touch_poll() == -EIO);
    pen_result = 0;
    assert(teardown(&production) == 0);
    assert(teardown_count == 2U && production.touch.valid == 0U);
    refuse_initial = 1;
    assert(activate(&production) == -EIO);
    assert(teardown(&production) == 0);
    return 0;
}
