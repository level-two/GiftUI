#include "spi_tft.h"
#include "giftui_fault.h"

#include <errno.h>
#include <stdbool.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/util.h>

#define SPI_TFT_NODE DT_ALIAS(giftui_spi_tft)

#define SPI_TFT_SWRESET 0x01U
#define SPI_TFT_SLPOUT 0x11U
#define SPI_TFT_DISPOFF 0x28U
#define SPI_TFT_DISPON 0x29U
#define SPI_TFT_CASET 0x2AU
#define SPI_TFT_PASET 0x2BU
#define SPI_TFT_RAMWR 0x2CU
#define SPI_TFT_MADCTL 0x36U
#define SPI_TFT_PIXFMT 0x3AU

#define SPI_TFT_MAX_COMMAND_PARAMETERS 16U

#define SPI_TFT_MADCTL_BGR BIT(3)
#define SPI_TFT_RGB565_FORMAT 0x55U

static const struct spi_dt_spec display_spi = SPI_DT_SPEC_GET(
    SPI_TFT_NODE,
    SPI_OP_MODE_MASTER | SPI_WORD_SET(8) | SPI_TRANSFER_MSB);
static const struct gpio_dt_spec display_dc =
    GPIO_DT_SPEC_GET(SPI_TFT_NODE, dc_gpios);
static const struct gpio_dt_spec display_reset =
    GPIO_DT_SPEC_GET(SPI_TFT_NODE, reset_gpios);
static uint8_t pixel_scratch[
    (GIFTUI_SPI_TFT_WIDTH / 8U) * GIFTUI_SPI_TFT_TILE_HEIGHT *
    GIFTUI_SPI_TFT_BYTES_PER_PIXEL];
static bool display_initialized;

BUILD_ASSERT(GIFTUI_SPI_TFT_SPI_SEGMENT_BYTES > 0U);
BUILD_ASSERT(
    GIFTUI_SPI_TFT_SPI_SEGMENT_BYTES % GIFTUI_SPI_TFT_BYTES_PER_PIXEL == 0U);
BUILD_ASSERT(
    GIFTUI_SPI_TFT_SPI_SEGMENT_BYTES <= GIFTUI_SPI_TFT_MAX_TRANSFER_BYTES);

#if DT_NODE_HAS_PROP(SPI_TFT_NODE, backlight_gpios)
static const struct gpio_dt_spec display_backlight =
    GPIO_DT_SPEC_GET(SPI_TFT_NODE, backlight_gpios);
#endif

static int write_bytes(const uint8_t *bytes, size_t byte_count)
{
    const struct spi_buf buffer = {
        .buf = (void *)bytes,
        .len = byte_count,
    };
    const struct spi_buf_set buffers = {
        .buffers = &buffer,
        .count = 1U,
    };

    const int result = spi_write_dt(&display_spi, &buffers);
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_DISPLAY_SPI, result);
    }
    return result;
}

static int write_pixel_segments(const uint8_t *bytes, size_t byte_count)
{
    size_t offset = 0U;
    while (offset < byte_count) {
        const size_t segment_byte_count = MIN(
            (size_t)GIFTUI_SPI_TFT_SPI_SEGMENT_BYTES,
            byte_count - offset);
        const int result = write_bytes(bytes + offset, segment_byte_count);
        if (result != 0) {
            return result;
        }
        offset += segment_byte_count;
    }
    return 0;
}

static int write_command(uint8_t command,
                         const uint8_t *parameters,
                         size_t parameter_count)
{
    if (parameter_count > SPI_TFT_MAX_COMMAND_PARAMETERS ||
        (parameter_count > 0U && parameters == NULL)) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, -EMSGSIZE);
        return -EMSGSIZE;
    }
    int result = gpio_pin_set_dt(&display_dc, 0);
    if (result != 0) {
        return result;
    }
    result = write_bytes(&command, sizeof(command));
    if (result != 0 || parameter_count == 0U) {
        return result;
    }

    result = gpio_pin_set_dt(&display_dc, 1);
    if (result != 0) {
        return result;
    }
    return write_bytes(parameters, parameter_count);
}

static int configure_safe_state(void)
{
    int result;

    if (!spi_is_ready_dt(&display_spi) ||
        !gpio_is_ready_dt(&display_dc) ||
        !gpio_is_ready_dt(&display_reset)) {
        return -ENODEV;
    }

    if (spi_cs_is_gpio_dt(&display_spi)) {
        result = gpio_pin_configure_dt(
            &display_spi.config.cs.gpio,
            GPIO_OUTPUT_INACTIVE);
        if (result != 0) {
            return result;
        }
    }

    result = gpio_pin_configure_dt(&display_dc, GPIO_OUTPUT_INACTIVE);
    if (result != 0) {
        return result;
    }
    result = gpio_pin_configure_dt(&display_reset, GPIO_OUTPUT_ACTIVE);
    if (result != 0) {
        return result;
    }

#if DT_NODE_HAS_PROP(SPI_TFT_NODE, backlight_gpios)
    if (!gpio_is_ready_dt(&display_backlight)) {
        return -ENODEV;
    }
    result = gpio_pin_configure_dt(
        &display_backlight,
        GPIO_OUTPUT_INACTIVE);
    if (result != 0) {
        return result;
    }
#endif

    return 0;
}

static int set_address_window(uint16_t x,
                              uint16_t y,
                              uint16_t width,
                              uint16_t height)
{
    const uint16_t end_x = x + width - 1U;
    const uint16_t end_y = y + height - 1U;
    const uint8_t columns[] = {
        (uint8_t)(x >> 8),
        (uint8_t)x,
        (uint8_t)(end_x >> 8),
        (uint8_t)end_x,
    };
    const uint8_t pages[] = {
        (uint8_t)(y >> 8),
        (uint8_t)y,
        (uint8_t)(end_y >> 8),
        (uint8_t)end_y,
    };

    int result = write_command(SPI_TFT_CASET, columns, sizeof(columns));
    if (result != 0) {
        return result;
    }
    result = write_command(SPI_TFT_PASET, pages, sizeof(pages));
    if (result != 0) {
        return result;
    }
    return write_command(SPI_TFT_RAMWR, NULL, 0U);
}

int spi_tft_initialize(void)
{
    int result = configure_safe_state();
    if (result != 0) {
        if (result != -ENODEV) {
            (void)spi_tft_shutdown();
        }
        return result;
    }

    k_msleep(10);
    result = gpio_pin_set_dt(&display_reset, 0);
    if (result != 0) {
        goto fail;
    }
    k_msleep(120);

    result = write_command(SPI_TFT_SWRESET, NULL, 0U);
    if (result != 0) {
        goto fail;
    }
    k_msleep(120);

    result = write_command(SPI_TFT_DISPOFF, NULL, 0U);
    if (result != 0) {
        goto fail;
    }

    const uint8_t pixel_format = SPI_TFT_RGB565_FORMAT;
    result = write_command(SPI_TFT_PIXFMT, &pixel_format, 1U);
    if (result != 0) {
        goto fail;
    }

    /* Candidate portrait BGR setting; verify the controller and orientation on hardware. */
    const uint8_t memory_access = SPI_TFT_MADCTL_BGR;
    result = write_command(SPI_TFT_MADCTL, &memory_access, 1U);
    if (result != 0) {
        goto fail;
    }

    result = write_command(SPI_TFT_SLPOUT, NULL, 0U);
    if (result != 0) {
        goto fail;
    }
    k_msleep(120);

    result = write_command(SPI_TFT_DISPON, NULL, 0U);
    if (result != 0) {
        goto fail;
    }
    k_msleep(20);

#if DT_NODE_HAS_PROP(SPI_TFT_NODE, backlight_gpios)
    result = gpio_pin_set_dt(&display_backlight, 1);
    if (result != 0) {
        goto fail;
    }
#endif

    display_initialized = true;
    return 0;

fail:
    (void)spi_tft_shutdown();
    return result;
}

int spi_tft_shutdown(void)
{
    int result = 0;
    if (display_initialized) {
        result = write_command(SPI_TFT_DISPOFF, NULL, 0U);
    }
#if DT_NODE_HAS_PROP(SPI_TFT_NODE, backlight_gpios)
    const int backlight_result = gpio_pin_set_dt(&display_backlight, 0);
    if (result == 0) {
        result = backlight_result;
    }
#endif
    const int reset_result = gpio_pin_set_dt(&display_reset, 1);
    if (result == 0) {
        result = reset_result;
    }
    const int dc_result = gpio_pin_set_dt(&display_dc, 0);
    if (result == 0) {
        result = dc_result;
    }
    if (spi_cs_is_gpio_dt(&display_spi)) {
        const int chip_select_result = gpio_pin_set_dt(
            &display_spi.config.cs.gpio,
            0);
        if (result == 0) {
            result = chip_select_result;
        }
    }
    display_initialized = false;
    return result;
}

uint16_t spi_tft_tile_height(void)
{
    return GIFTUI_SPI_TFT_TILE_HEIGHT;
}

size_t spi_tft_spi_segment_bytes(void)
{
    return GIFTUI_SPI_TFT_SPI_SEGMENT_BYTES;
}

int spi_tft_write_rgb565(uint16_t x,
                         uint16_t y,
                         uint16_t width,
                         uint16_t height,
                         const uint8_t *pixels,
                         size_t byte_count)
{
    if (pixels == NULL || width == 0U || height == 0U ||
        x >= GIFTUI_SPI_TFT_WIDTH || y >= GIFTUI_SPI_TFT_HEIGHT ||
        width > GIFTUI_SPI_TFT_WIDTH - x ||
        height > GIFTUI_SPI_TFT_HEIGHT - y) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, -EINVAL);
        return -EINVAL;
    }

    const size_t expected_byte_count =
        (size_t)width * height * GIFTUI_SPI_TFT_BYTES_PER_PIXEL;
    if (byte_count != expected_byte_count ||
        byte_count > GIFTUI_SPI_TFT_MAX_TRANSFER_BYTES) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, -EMSGSIZE);
        return -EMSGSIZE;
    }

    int result = set_address_window(x, y, width, height);
    if (result != 0) {
        return result;
    }
    result = gpio_pin_set_dt(&display_dc, 1);
    if (result != 0) {
        return result;
    }
    return write_pixel_segments(pixels, byte_count);
}

int spi_tft_fill_rgb565(uint16_t x,
                        uint16_t y,
                        uint16_t width,
                        uint16_t height,
                        uint16_t pixel)
{
    if (width == 0U || height == 0U ||
        x >= GIFTUI_SPI_TFT_WIDTH || y >= GIFTUI_SPI_TFT_HEIGHT ||
        width > GIFTUI_SPI_TFT_WIDTH - x ||
        height > GIFTUI_SPI_TFT_HEIGHT - y) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, -EINVAL);
        return -EINVAL;
    }

    for (size_t index = 0U; index < sizeof(pixel_scratch); index += 2U) {
        pixel_scratch[index] = (uint8_t)(pixel >> 8);
        pixel_scratch[index + 1U] = (uint8_t)pixel;
    }

    int result = set_address_window(x, y, width, height);
    if (result != 0) {
        return result;
    }
    result = gpio_pin_set_dt(&display_dc, 1);
    if (result != 0) {
        return result;
    }

    size_t remaining =
        (size_t)width * height * GIFTUI_SPI_TFT_BYTES_PER_PIXEL;
    while (remaining > 0U) {
        const size_t byte_count = MIN(remaining, sizeof(pixel_scratch));
        result = write_pixel_segments(pixel_scratch, byte_count);
        if (result != 0) {
            return result;
        }
        remaining -= byte_count;
    }
    return 0;
}

int spi_tft_render_color_bars(void)
{
    static const uint16_t colors[] = {
        0xF800U,
        0xFFE0U,
        0x07E0U,
        0x07FFU,
        0x001FU,
        0xF81FU,
        0xFFFFU,
        0x0000U,
    };
    const uint16_t bar_width = GIFTUI_SPI_TFT_WIDTH / ARRAY_SIZE(colors);

    for (uint16_t bar = 0U; bar < ARRAY_SIZE(colors); ++bar) {
        const int result = spi_tft_fill_rgb565(
            bar * bar_width,
            0U,
            bar_width,
            GIFTUI_SPI_TFT_HEIGHT,
            colors[bar]);
        if (result != 0) {
            return result;
        }
    }

    return 0;
}
