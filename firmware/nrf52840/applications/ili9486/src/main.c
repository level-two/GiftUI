#include "ili9486.h"

#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

int32_t giftui_display_bringup_run(void)
{
    int result = ili9486_initialize();

    if (result != 0) {
        printk("GiftUI ILI9486 initialization failed: %d\n", result);
        return result;
    }

    const uint32_t started_at = k_uptime_get_32();
    result = ili9486_render_color_bars();
    if (result != 0) {
        printk("GiftUI ILI9486 color bars failed: %d\n", result);
        return result;
    }
    printk("GiftUI ILI9486 color bars transferred in %u ms\n",
           k_uptime_get_32() - started_at);

    while (true) {
        k_sleep(K_FOREVER);
    }
}

extern int32_t giftui_swift_display_application_run(void);

int main(void)
{
    return giftui_swift_display_application_run();
}
