#include <stdint.h>
#include <zephyr/device.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

extern int32_t giftui_swift_application_run(void);

static const struct gpio_dt_spec status_led =
    GPIO_DT_SPEC_GET(DT_ALIAS(led0), gpios);
static const struct gpio_dt_spec user_button =
    GPIO_DT_SPEC_GET(DT_ALIAS(sw0), gpios);

int32_t giftui_board_initialize(void)
{
    if (!gpio_is_ready_dt(&status_led) || !gpio_is_ready_dt(&user_button)) {
        return -1;
    }
    if (gpio_pin_configure_dt(&status_led, GPIO_OUTPUT_INACTIVE) != 0) {
        return -2;
    }
    if (gpio_pin_configure_dt(&user_button, GPIO_INPUT) != 0) {
        return -3;
    }
    return 0;
}

int32_t giftui_board_button_is_pressed(void)
{
    return gpio_pin_get_dt(&user_button);
}

void giftui_board_set_status_led(int32_t enabled)
{
    (void)gpio_pin_set_dt(&status_led, enabled != 0);
}

void giftui_board_sleep_ms(uint32_t milliseconds)
{
    k_msleep(milliseconds);
}

void giftui_board_log_event(int32_t event)
{
    switch (event) {
    case 0:
        printk("GiftUI Swift skeleton started\n");
        break;
    case 1:
        printk("GiftUI board initialization failed\n");
        break;
    case 2:
        printk("GiftUI button pressed\n");
        break;
    case 3:
        printk("GiftUI button released\n");
        break;
    case 4:
        printk("GiftUI button read failed\n");
        break;
    default:
        printk("GiftUI unknown event: %d\n", event);
        break;
    }
}

int main(void)
{
    return giftui_swift_application_run();
}
