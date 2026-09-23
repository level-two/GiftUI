#include "static_host_storage.h"

#include <assert.h>
#include <errno.h>
#include <stdint.h>

static int disjoint(const uint8_t *left, size_t left_bytes,
                    const uint8_t *right, size_t right_bytes)
{
    const uintptr_t l = (uintptr_t)left;
    const uintptr_t r = (uintptr_t)right;
    return l + left_bytes <= r || r + right_bytes <= l;
}

int main(void)
{
    struct giftui_static_host_storage regions;
    assert(giftui_signal_analyzer_storage_regions(NULL) == -EINVAL);
    assert(giftui_signal_analyzer_storage_regions(&regions) == 0);
    assert(regions.profile_bytes == GIFTUI_STATIC_PROFILE_BYTES);
    assert(regions.capture_bytes == GIFTUI_STATIC_CAPTURE_BYTES);
    assert(regions.raster_bytes == GIFTUI_STATIC_RASTER_BYTES);
    assert(regions.coverage_bytes == GIFTUI_STATIC_COVERAGE_BYTES);
    assert(giftui_signal_analyzer_storage_bytes() == 159168U);

    const uint8_t *pointers[] = {
        regions.profile, regions.capture, regions.raster, regions.coverage
    };
    const size_t sizes[] = {
        regions.profile_bytes, regions.capture_bytes,
        regions.raster_bytes, regions.coverage_bytes
    };
    for (size_t i = 0; i < 4; ++i) {
        assert(((uintptr_t)pointers[i] & 7U) == 0U);
        for (size_t j = i + 1; j < 4; ++j) {
            assert(disjoint(pointers[i], sizes[i], pointers[j], sizes[j]));
        }
    }

    regions.profile[0] = 1U;
    regions.capture[0] = 2U;
    regions.raster[0] = 3U;
    regions.coverage[0] = 4U;
    assert(regions.profile[0] == 1U);
    assert(regions.capture[0] == 2U);
    assert(regions.raster[0] == 3U);
    assert(regions.coverage[0] == 4U);
    return 0;
}
