#include <stdint.h>

// Matched backend-owned storage in every image: a 480 x 4 RGB565 tile, one
// 480-pixel span, and one transfer buffer. This is disposable evidence.
uint16_t spike004_tile[480u * 4u];
uint16_t spike004_span[480u];
uint16_t spike004_transfer[480u * 4u];

uint32_t spike004_raster_touch(uint32_t seed) {
    spike004_tile[seed % (480u * 4u)] = (uint16_t)seed;
    spike004_span[seed % 480u] = (uint16_t)(seed >> 1);
    spike004_transfer[seed % (480u * 4u)] = (uint16_t)(seed >> 2);
    return (uint32_t)spike004_tile[seed % (480u * 4u)]
        ^ (uint32_t)spike004_span[seed % 480u]
        ^ (uint32_t)spike004_transfer[seed % (480u * 4u)];
}
