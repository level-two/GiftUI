#ifndef GIFTUI_SPI_TFT_H
#define GIFTUI_SPI_TFT_H

#include <stddef.h>
#include <stdint.h>

#define GIFTUI_SPI_TFT_WIDTH 320U
#define GIFTUI_SPI_TFT_HEIGHT 240U
#define GIFTUI_SPI_TFT_BYTES_PER_PIXEL 2U
#define GIFTUI_SPI_TFT_TILE_HEIGHT 4U
#define GIFTUI_SPI_TFT_SPI_SEGMENT_BYTES 2560U
#define GIFTUI_SPI_TFT_MAX_TRANSFER_BYTES                                  \
    (GIFTUI_SPI_TFT_WIDTH * GIFTUI_SPI_TFT_TILE_HEIGHT *                  \
     GIFTUI_SPI_TFT_BYTES_PER_PIXEL)

#ifndef GIFTUI_DRIVER_ENTRY
#define GIFTUI_DRIVER_ENTRY __attribute__((used, retain))
#endif

GIFTUI_DRIVER_ENTRY int spi_tft_initialize(void);
GIFTUI_DRIVER_ENTRY int spi_tft_shutdown(void);
uint16_t spi_tft_tile_height(void);
size_t spi_tft_spi_segment_bytes(void);
GIFTUI_DRIVER_ENTRY int spi_tft_write_rgb565(uint16_t x,
                         uint16_t y,
                         uint16_t width,
                         uint16_t height,
                         const uint8_t *pixels,
                         size_t byte_count);
GIFTUI_DRIVER_ENTRY int spi_tft_fill_rgb565(uint16_t x,
                        uint16_t y,
                        uint16_t width,
                        uint16_t height,
                        uint16_t pixel);
GIFTUI_DRIVER_ENTRY int spi_tft_render_color_bars(void);

#endif
