#include "ads7846.h"
#include "giftui_fault.h"

#include <errno.h>
#include <stddef.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>

#define ADS7846_NODE DT_ALIAS(giftui_ads7846)

/* 12-bit, differential measurements; power down between conversions so the
 * active-low PENIRQ output is available while the application is idle. */
#define ADS7846_COMMAND_X 0xD0U
#define ADS7846_COMMAND_Y 0x90U
#define ADS7846_COMMAND_Z1 0xB0U
#define ADS7846_COMMAND_Z2 0xC0U

static const struct spi_dt_spec touch_spi = SPI_DT_SPEC_GET(
    ADS7846_NODE,
    SPI_OP_MODE_MASTER | SPI_WORD_SET(8) | SPI_TRANSFER_MSB);
static const struct gpio_dt_spec touch_penirq =
    GPIO_DT_SPEC_GET(ADS7846_NODE, penirq_gpios);

static int read_channel(uint8_t command, uint16_t *value)
{
    uint8_t transmit[3] = {command, 0U, 0U};
    uint8_t receive[3] = {0U, 0U, 0U};
    const struct spi_buf transmit_buffer = {
        .buf = transmit,
        .len = sizeof(transmit),
    };
    const struct spi_buf receive_buffer = {
        .buf = receive,
        .len = sizeof(receive),
    };
    const struct spi_buf_set transmit_buffers = {
        .buffers = &transmit_buffer,
        .count = 1U,
    };
    const struct spi_buf_set receive_buffers = {
        .buffers = &receive_buffer,
        .count = 1U,
    };

    const int result = spi_transceive_dt(
        &touch_spi,
        &transmit_buffers,
        &receive_buffers);
    if (result != 0) {
        giftui_fault_record(GIFTUI_FAULT_TOUCH_SPI, result);
        return result;
    }

    *value = (uint16_t)((((uint16_t)receive[1] << 8) | receive[2]) >> 3) &
             0x0FFFU;
    return 0;
}

int ads7846_initialize(void)
{
    if (!spi_is_ready_dt(&touch_spi) ||
        !gpio_is_ready_dt(&touch_penirq)) {
        return -ENODEV;
    }

    int result = 0;
    if (spi_cs_is_gpio_dt(&touch_spi)) {
        result = gpio_pin_configure_dt(
            &touch_spi.config.cs.gpio,
            GPIO_OUTPUT_INACTIVE);
        if (result != 0) {
            return result;
        }
    }

    return gpio_pin_configure_dt(
        &touch_penirq,
        GPIO_INPUT | GPIO_PULL_UP);
}

int ads7846_pen_is_down(void)
{
    const int result = gpio_pin_get_dt(&touch_penirq);
    if (result < 0) {
        giftui_fault_record(GIFTUI_FAULT_TOUCH_CONTROLLER, result);
    }
    return result;
}

int ads7846_read_raw(struct ads7846_raw_sample *sample)
{
    if (sample == NULL) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, -EINVAL);
        return -EINVAL;
    }

    int result = read_channel(ADS7846_COMMAND_X, &sample->x);
    if (result != 0) {
        return result;
    }
    result = read_channel(ADS7846_COMMAND_Y, &sample->y);
    if (result != 0) {
        return result;
    }
    result = read_channel(ADS7846_COMMAND_Z1, &sample->z1);
    if (result != 0) {
        return result;
    }
    return read_channel(ADS7846_COMMAND_Z2, &sample->z2);
}

int ads7846_read_raw_values(uint16_t *x,
                            uint16_t *y,
                            uint16_t *z1,
                            uint16_t *z2)
{
    if (x == NULL || y == NULL || z1 == NULL || z2 == NULL) {
        giftui_fault_record(GIFTUI_FAULT_CAPACITY, -EINVAL);
        return -EINVAL;
    }
    struct ads7846_raw_sample sample;
    const int result = ads7846_read_raw(&sample);
    if (result != 0) {
        return result;
    }
    *x = sample.x;
    *y = sample.y;
    *z1 = sample.z1;
    *z2 = sample.z2;
    return 0;
}
