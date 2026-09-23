#ifndef GIFTUI_STATIC_HOST_STORAGE_H
#define GIFTUI_STATIC_HOST_STORAGE_H

#include <stddef.h>
#include <stdint.h>

enum {
    GIFTUI_STATIC_PROFILE_BYTES = 39696,
    GIFTUI_STATIC_CAPTURE_BYTES = 115392,
    GIFTUI_STATIC_RASTER_BYTES = 3840,
    GIFTUI_STATIC_COVERAGE_BYTES = 240,
};

struct giftui_static_host_storage {
    uint8_t *profile;
    size_t profile_bytes;
    uint8_t *capture;
    size_t capture_bytes;
    uint8_t *raster;
    size_t raster_bytes;
    uint8_t *coverage;
    size_t coverage_bytes;
};

/* All regions remain address-stable for the complete firmware lifetime. */
int giftui_signal_analyzer_storage_regions(struct giftui_static_host_storage *regions);
uint32_t giftui_signal_analyzer_storage_bytes(void);

#endif
