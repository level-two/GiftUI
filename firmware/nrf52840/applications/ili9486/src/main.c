#include <errno.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

#define ILI9486_NODE DT_ALIAS(giftui_ili9486)

static const struct spi_dt_spec display_spi = SPI_DT_SPEC_GET(
    ILI9486_NODE,
    SPI_OP_MODE_MASTER | SPI_WORD_SET(8) | SPI_TRANSFER_MSB);
static const struct gpio_dt_spec display_dc =
    GPIO_DT_SPEC_GET(ILI9486_NODE, dc_gpios);
static const struct gpio_dt_spec display_reset =
    GPIO_DT_SPEC_GET(ILI9486_NODE, reset_gpios);

static int configure_safe_display_state(void)
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

    /* Hold the controller in reset until the explicit init sequence exists. */
    return gpio_pin_configure_dt(&display_reset, GPIO_OUTPUT_ACTIVE);
}

int32_t giftui_display_safe_state_run(void)
{
    const int result = configure_safe_display_state();

    if (result != 0) {
        printk("GiftUI ILI9486 safe-state setup failed: %d\n", result);
        return result;
    }

    printk("GiftUI ILI9486 wiring ready at %u Hz; controller held in reset\n",
           display_spi.config.frequency);

    while (true) {
        k_sleep(K_FOREVER);
    }
}

extern int32_t giftui_swift_display_application_run(void);

int main(void)
{
    return giftui_swift_display_application_run();
}
