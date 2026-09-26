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
extern int giftui_firmware_main(void);

static uint64_t clock_microseconds;
static unsigned touch_polls;
static unsigned display_writes;
static unsigned display_bytes;
static unsigned shutdown_order;
static unsigned paced_frame_observed;

int ads7846_initialize(void) { return 0; }
int ads7846_pen_is_down(void)
{
    touch_polls++;
    if (touch_polls == 1U) {
        return 1;
    }
    if (touch_polls == 2U) {
        return 0;
    }
    if (clock_microseconds < 250000U) {
        assert(giftui_signal_analyzer_current_revision() == 1U);
        return 0;
    }
    if (giftui_signal_analyzer_current_revision() < 2U) {
        return 0;
    }
    paced_frame_observed = 1U;
    return -ECANCELED;
}
int ads7846_read_raw(struct ads7846_raw_sample *sample)
{
    const uint32_t point = giftui_signal_analyzer_action_point(0U);
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
    assert(display_writes > 0U && display_bytes > 0U);
    assert(giftui_signal_analyzer_initial_committed_actions() == 0U);
    assert(giftui_signal_analyzer_current_revision() == 0U);
    assert(shutdown_order == 2U);
    printf("status=passed\tprofile=nrf52840-static\tevidence=host-native-fixture"
           "\twrites=%u\tbytes=%u\n", display_writes, display_bytes);
    return 0;
}
