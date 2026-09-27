#ifndef GIFTUI_TEST_ZEPHYR_SPI_H
#define GIFTUI_TEST_ZEPHYR_SPI_H

#include <stddef.h>
#include "gpio.h"

struct spi_buf { void *buf; size_t len; };
struct spi_buf_set { const struct spi_buf *buffers; size_t count; };
struct spi_dt_spec {
    struct { struct { struct gpio_dt_spec gpio; } cs; } config;
};

#define SPI_DT_SPEC_GET(node, operation) { .config.cs.gpio.pin = 3 }
#define SPI_OP_MODE_MASTER 0
#define SPI_TRANSFER_MSB 0
#define SPI_WORD_SET(bits) 0

int spi_is_ready_dt(const struct spi_dt_spec *spec);
int spi_cs_is_gpio_dt(const struct spi_dt_spec *spec);
int spi_write_dt(const struct spi_dt_spec *spec, const struct spi_buf_set *buffers);

#endif
