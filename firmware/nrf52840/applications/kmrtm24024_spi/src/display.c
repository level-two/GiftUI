#include "kmrtm_display.h"

#include <errno.h>
#include <stdbool.h>
#include <zephyr/device.h>
#include <zephyr/drivers/display.h>
#include <zephyr/sys/byteorder.h>
#include <zephyr/sys/util.h>

#define KMRTM_TILE_ROWS 4U
#define KMRTM_MAX_WIDTH 240U

static const struct device *const display = DEVICE_DT_GET(DT_CHOSEN(zephyr_display));
static uint8_t solid_tile[KMRTM_MAX_WIDTH * KMRTM_TILE_ROWS * 2U];

static enum display_orientation orientation_from_degrees(uint16_t degrees)
{
    switch (degrees) {
    case 0U:
        return DISPLAY_ORIENTATION_NORMAL;
    case 90U:
        return DISPLAY_ORIENTATION_ROTATED_90;
    case 180U:
        return DISPLAY_ORIENTATION_ROTATED_180;
    case 270U:
        return DISPLAY_ORIENTATION_ROTATED_270;
    default:
        return (enum display_orientation)-1;
    }
}

int32_t kmrtm_display_initialize(uint16_t width,
                                 uint16_t height,
                                 uint16_t orientation_degrees)
{
    if (!device_is_ready(display)) {
        return -ENODEV;
    }

    struct display_capabilities capabilities;
    display_get_capabilities(display, &capabilities);
    const enum display_orientation orientation =
        orientation_from_degrees(orientation_degrees);
    if (orientation < DISPLAY_ORIENTATION_NORMAL ||
        capabilities.x_resolution != width ||
        capabilities.y_resolution != height ||
        capabilities.current_orientation != orientation ||
        capabilities.current_pixel_format != PIXEL_FORMAT_RGB_565) {
        return -ENOTSUP;
    }
    return 0;
}

int32_t kmrtm_display_set_blanked(int32_t blanked)
{
    return blanked != 0 ? display_blanking_on(display)
                        : display_blanking_off(display);
}

int32_t kmrtm_display_write_rgb565(uint16_t x,
                                   uint16_t y,
                                   uint16_t width,
                                   uint16_t height,
                                   uint16_t pitch,
                                   const void *pixels,
                                   size_t byte_count)
{
    if (width == 0U || height == 0U || pitch != width || pixels == NULL ||
        byte_count > UINT32_MAX ||
        (size_t)pitch * 2U * height > byte_count) {
        return -EINVAL;
    }
    const struct display_buffer_descriptor descriptor = {
        .buf_size = (uint32_t)byte_count,
        .width = width,
        .height = height,
        .pitch = pitch,
        .frame_incomplete = false,
    };
    return display_write(display, x, y, &descriptor, pixels);
}

int32_t kmrtm_display_fill_rgb565(uint16_t x,
                                  uint16_t y,
                                  uint16_t width,
                                  uint16_t height,
                                  uint16_t pixel)
{
    if (width == 0U || width > KMRTM_MAX_WIDTH || height == 0U) {
        return -EINVAL;
    }
    for (size_t index = 0; index < width * KMRTM_TILE_ROWS; index++) {
        sys_put_be16(pixel, &solid_tile[index * 2U]);
    }

    uint16_t row = 0U;
    while (row < height) {
        const uint16_t rows = MIN(KMRTM_TILE_ROWS, height - row);
        const size_t byte_count = (size_t)width * rows * 2U;
        const int result = kmrtm_display_write_rgb565(
            x, y + row, width, rows, width, solid_tile, byte_count);
        if (result != 0) {
            return result;
        }
        row += rows;
    }
    return 0;
}
