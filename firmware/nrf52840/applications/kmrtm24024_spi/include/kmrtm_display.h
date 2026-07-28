#ifndef GIFTUI_KMRTM_DISPLAY_H
#define GIFTUI_KMRTM_DISPLAY_H

#include <stddef.h>
#include <stdint.h>

int32_t kmrtm_display_initialize(uint16_t width,
                                 uint16_t height,
                                 uint16_t orientation_degrees);
int32_t kmrtm_display_set_blanked(int32_t blanked);
int32_t kmrtm_display_write_rgb565(uint16_t x,
                                   uint16_t y,
                                   uint16_t width,
                                   uint16_t height,
                                   uint16_t pitch,
                                   const void *pixels,
                                   size_t byte_count);
int32_t kmrtm_display_fill_rgb565(uint16_t x,
                                  uint16_t y,
                                  uint16_t width,
                                  uint16_t height,
                                  uint16_t pixel);

#endif
