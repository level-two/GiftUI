#ifndef GIFTUI_TEST_ZEPHYR_GPIO_H
#define GIFTUI_TEST_ZEPHYR_GPIO_H

struct gpio_dt_spec { int pin; };

#define GPIO_DT_SPEC_GET(node, prop) { .pin = GIFTUI_TEST_##prop }
#define GIFTUI_TEST_dc_gpios 1
#define GIFTUI_TEST_reset_gpios 2
#define GPIO_OUTPUT_INACTIVE 0
#define GPIO_OUTPUT_ACTIVE 1

int gpio_is_ready_dt(const struct gpio_dt_spec *spec);
int gpio_pin_configure_dt(const struct gpio_dt_spec *spec, int flags);
int gpio_pin_set_dt(const struct gpio_dt_spec *spec, int value);

#endif
