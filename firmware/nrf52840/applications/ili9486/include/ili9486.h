#ifndef GIFTUI_ILI9486_H
#define GIFTUI_ILI9486_H

#include <stddef.h>
#include <stdint.h>

#define GIFTUI_ILI9486_WIDTH 480U
#define GIFTUI_ILI9486_HEIGHT 320U
#define GIFTUI_ILI9486_BYTES_PER_PIXEL 2U
#define GIFTUI_ILI9486_TILE_HEIGHT 16U
#define GIFTUI_ILI9486_MAX_TRANSFER_BYTES                                  \
    (GIFTUI_ILI9486_WIDTH * GIFTUI_ILI9486_TILE_HEIGHT *                  \
     GIFTUI_ILI9486_BYTES_PER_PIXEL)

int ili9486_initialize(void);
int ili9486_write_rgb565(uint16_t x,
                         uint16_t y,
                         uint16_t width,
                         uint16_t height,
                         const uint8_t *pixels,
                         size_t byte_count);
int ili9486_render_color_bars(void);

#endif
