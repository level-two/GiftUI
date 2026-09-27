#include "spi_tft.h"
#include "giftui_fault.h"
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>

#include <assert.h>
#include <stdbool.h>
#include <errno.h>
#include <stdint.h>
#include <string.h>

struct transfer {
    uint8_t bytes[2560];
    size_t count;
    int dc;
};

static struct transfer transfers[1024];
static size_t transfer_count;
static int dc_level;
static int fail_transfer = -1;
static int fault_category = -1;
static int fault_detail;

void k_msleep(int32_t duration) { (void)duration; }
int gpio_is_ready_dt(const struct gpio_dt_spec *spec)
{
    return spec != NULL;
}
int gpio_pin_configure_dt(const struct gpio_dt_spec *spec, int flags)
{
    (void)flags;
    return spec != NULL ? 0 : -ENODEV;
}
int gpio_pin_set_dt(const struct gpio_dt_spec *spec, int value)
{
    if (spec->pin == 1) { dc_level = value; }
    return 0;
}
int spi_is_ready_dt(const struct spi_dt_spec *spec)
{
    return spec != NULL;
}
int spi_cs_is_gpio_dt(const struct spi_dt_spec *spec)
{
    (void)spec;
    return 1;
}
int spi_write_dt(const struct spi_dt_spec *spec, const struct spi_buf_set *buffers)
{
    (void)spec;
    assert(buffers->count == 1 && transfer_count < 1024);
    const struct spi_buf *buffer = buffers->buffers;
    assert(buffer->len <= sizeof(transfers[0].bytes));
    if ((int)transfer_count == fail_transfer) { return -EIO; }
    struct transfer *entry = &transfers[transfer_count++];
    entry->count = buffer->len;
    entry->dc = dc_level;
    memcpy(entry->bytes, buffer->buf, buffer->len);
    return 0;
}
void giftui_fault_record(int32_t category, int32_t detail)
{
    fault_category = category;
    fault_detail = detail;
}

static void expect_transfer(size_t index, int dc, const uint8_t *bytes, size_t count)
{
    assert(index < transfer_count);
    assert(transfers[index].dc == dc);
    assert(transfers[index].count == count);
    assert(memcmp(transfers[index].bytes, bytes, count) == 0);
}

int main(void)
{
    assert(spi_tft_initialize() == 0);
    const uint8_t landscape_madctl[] = {0x28};
    bool saw_landscape_madctl = false;
    for (size_t index = 1; index < transfer_count; ++index) {
        if (transfers[index - 1].dc == 0 &&
            transfers[index - 1].count == 1 &&
            transfers[index - 1].bytes[0] == 0x36 &&
            transfers[index].dc == 1 &&
            transfers[index].count == 1 &&
            transfers[index].bytes[0] == landscape_madctl[0]) {
            saw_landscape_madctl = true;
        }
    }
    assert(saw_landscape_madctl);
    transfer_count = 0;
    const uint8_t pixels[] = {0x12, 0x34, 0xab, 0xcd};
    assert(spi_tft_write_rgb565(318, 239, 2, 1, pixels, sizeof(pixels)) == 0);
    assert(transfer_count == 6);
    const uint8_t case_command[] = {0x2a};
    const uint8_t columns[] = {0x01, 0x3e, 0x01, 0x3f};
    const uint8_t page_command[] = {0x2b};
    const uint8_t pages[] = {0x00, 0xef, 0x00, 0xef};
    const uint8_t ram_command[] = {0x2c};
    expect_transfer(0, 0, case_command, sizeof(case_command));
    expect_transfer(1, 1, columns, sizeof(columns));
    expect_transfer(2, 0, page_command, sizeof(page_command));
    expect_transfer(3, 1, pages, sizeof(pages));
    expect_transfer(4, 0, ram_command, sizeof(ram_command));
    expect_transfer(5, 1, pixels, sizeof(pixels));
    assert(spi_tft_write_rgb565(319, 239, 2, 1, pixels, sizeof(pixels)) == -EINVAL);
    assert(spi_tft_write_rgb565(318, 239, 2, 1, pixels, 2) == -EMSGSIZE);
    assert(transfer_count == 6);

    transfer_count = 0;
    fail_transfer = 2;
    assert(spi_tft_write_rgb565(0, 0, 2, 1, pixels, sizeof(pixels)) == -EIO);
    assert(transfer_count == 2);
    assert(fault_category == GIFTUI_FAULT_DISPLAY_SPI && fault_detail == -EIO);
    fail_transfer = -1;
    assert(spi_tft_shutdown() == 0);
    return 0;
}
