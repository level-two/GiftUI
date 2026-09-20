#ifndef GIFTUI_ILI9486_H
#define GIFTUI_ILI9486_H

#include <stddef.h>
#include <stdint.h>

#define GIFTUI_ILI9486_WIDTH 480U
#define GIFTUI_ILI9486_HEIGHT 320U
#define GIFTUI_ILI9486_BYTES_PER_PIXEL 2U
#define GIFTUI_ILI9486_TILE_HEIGHT 4U
#define GIFTUI_ILI9486_SPI_SEGMENT_BYTES 3840U
#define GIFTUI_ILI9486_MAX_TRANSFER_BYTES                                  \
    (GIFTUI_ILI9486_WIDTH * GIFTUI_ILI9486_TILE_HEIGHT *                  \
     GIFTUI_ILI9486_BYTES_PER_PIXEL)

#ifndef GIFTUI_DRIVER_ENTRY
#define GIFTUI_DRIVER_ENTRY __attribute__((used, retain))
#endif

GIFTUI_DRIVER_ENTRY int ili9486_initialize(void);
GIFTUI_DRIVER_ENTRY int ili9486_shutdown(void);
uint16_t ili9486_tile_height(void);
size_t ili9486_spi_segment_bytes(void);
GIFTUI_DRIVER_ENTRY int ili9486_write_rgb565(uint16_t x,
                         uint16_t y,
                         uint16_t width,
                         uint16_t height,
                         const uint8_t *pixels,
                         size_t byte_count);
GIFTUI_DRIVER_ENTRY int ili9486_fill_rgb565(uint16_t x,
                        uint16_t y,
                        uint16_t width,
                        uint16_t height,
                        uint16_t pixel);
GIFTUI_DRIVER_ENTRY int ili9486_render_color_bars(void);

#endif
