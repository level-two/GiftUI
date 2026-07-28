#include "ili9486.h"

#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

uint32_t giftui_display_uptime_ms(void)
{
    return k_uptime_get_32();
}

void giftui_display_sleep_ms(uint32_t milliseconds)
{
    k_msleep(milliseconds);
}

void giftui_display_log(int32_t event, int32_t value)
{
    switch (event) {
    case 1:
        printk("GiftUI ILI9486 initialization failed: %d\n", value);
        break;
    case 2:
        printk("GiftUI ILI9486 color bars failed: %d\n", value);
        break;
    case 3:
        printk("GiftUI ILI9486 color bars transferred in %d ms\n", value);
        break;
    case 4:
        printk("GiftUI thermostat transferred in %d ms\n", value);
        break;
    case 5:
        printk("GiftUI ILI9486 tile transfer failed: %d\n", value);
        break;
    case 6:
        printk("GiftUI static render failed\n");
        break;
    default:
        printk("GiftUI display event %d: %d\n", event, value);
        break;
    }
}

extern int32_t giftui_swift_display_application_run(void);

int main(void)
{
    return giftui_swift_display_application_run();
}
