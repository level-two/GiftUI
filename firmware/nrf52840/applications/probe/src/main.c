#include <stdint.h>
#include <zephyr/device.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

extern int32_t giftui_swift_probe_value(int32_t seed);

static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(DT_ALIAS(led0), gpios);
static const struct gpio_dt_spec button = GPIO_DT_SPEC_GET(DT_ALIAS(sw0), gpios);

int main(void)
{
    if (!gpio_is_ready_dt(&led) || !gpio_is_ready_dt(&button)) {
        return 1;
    }
    if (gpio_pin_configure_dt(&led, GPIO_OUTPUT_INACTIVE) != 0 ||
        gpio_pin_configure_dt(&button, GPIO_INPUT) != 0) {
        return 2;
    }

    int32_t swift_value = giftui_swift_probe_value(41);
    printk("GiftUI Embedded Swift probe: %d\n", swift_value);
    if (swift_value != 42) {
        return 3;
    }

    while (true) {
        int pressed = gpio_pin_get_dt(&button);
        if (pressed >= 0) {
            gpio_pin_set_dt(&led, pressed);
        }
        k_msleep(20);
    }
    return 0;
}
