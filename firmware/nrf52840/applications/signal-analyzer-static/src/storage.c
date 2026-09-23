#include "static_host_storage.h"

#include <errno.h>

/* Exact generated profile workspace from the nRF52840 Static preset. */
uint8_t giftui_signal_analyzer_profile_storage[GIFTUI_STATIC_PROFILE_BYTES]
    __attribute__((aligned(8)));

/* Live capture plus the one complete publication snapshot: 2 * 2,404 * 24. */
uint8_t giftui_signal_analyzer_capture_storage[GIFTUI_STATIC_CAPTURE_BYTES]
    __attribute__((aligned(8)));

/* One full-width 480 x 4 RGB565 raster/payload/in-flight slot. */
uint8_t giftui_signal_analyzer_raster_staging[GIFTUI_STATIC_RASTER_BYTES]
    __attribute__((aligned(8)));

/* One bit per pixel in the 480 x 4 tile for touched-run emission. */
uint8_t giftui_signal_analyzer_raster_coverage[GIFTUI_STATIC_COVERAGE_BYTES]
    __attribute__((aligned(8)));

__attribute__((used, retain))
int giftui_signal_analyzer_storage_regions(struct giftui_static_host_storage *regions)
{
    if (regions == NULL) {
        return -EINVAL;
    }
    *regions = (struct giftui_static_host_storage){
        .profile = giftui_signal_analyzer_profile_storage,
        .profile_bytes = sizeof(giftui_signal_analyzer_profile_storage),
        .capture = giftui_signal_analyzer_capture_storage,
        .capture_bytes = sizeof(giftui_signal_analyzer_capture_storage),
        .raster = giftui_signal_analyzer_raster_staging,
        .raster_bytes = sizeof(giftui_signal_analyzer_raster_staging),
        .coverage = giftui_signal_analyzer_raster_coverage,
        .coverage_bytes = sizeof(giftui_signal_analyzer_raster_coverage),
    };
    return 0;
}

uint32_t giftui_signal_analyzer_storage_bytes(void)
{
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_profile_storage) : "memory");
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_capture_storage) : "memory");
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_raster_staging) : "memory");
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_raster_coverage) : "memory");
    return sizeof(giftui_signal_analyzer_profile_storage) +
        sizeof(giftui_signal_analyzer_capture_storage) +
        sizeof(giftui_signal_analyzer_raster_staging) +
        sizeof(giftui_signal_analyzer_raster_coverage);
}
