#include <stdint.h>
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
        printk("GiftUI KMRTM display initialization failed: %d\n", value);
        break;
    case 2:
        printk("GiftUI KMRTM static render failed: %d\n", value);
        break;
    case 3:
        printk("GiftUI KMRTM initial frame transferred in %d ms\n", value);
        break;
    case 4:
        printk("GiftUI XPT2046 ready: PENIRQ=%s\n",
               value > 0 ? "active" : "idle");
        break;
    case 5:
        printk("GiftUI XPT2046 initialization failed: %d; touch disabled\n",
               value);
        break;
    case 6:
        printk("GiftUI XPT2046 read failed: %d\n", value);
        break;
    case 7:
        printk("GiftUI XPT2046 calibration target %d\n", value);
        break;
    case 8:
        printk("GiftUI XPT2046 calibration failed: %d\n", value);
        break;
    case 9:
        printk("GiftUI XPT2046 calibration ready\n");
        break;
    case 10:
        printk("GiftUI thermostat target changed to %d\n", value);
        break;
    case 11:
        printk("GiftUI touch release to visible update: %d ms\n", value);
        break;
    case 12:
        printk("GiftUI KMRTM dirty update transferred in %d ms\n", value);
        break;
    default:
        printk("GiftUI KMRTM display event %d: %d\n", event, value);
        break;
    }
}

void giftui_touch_log_sample(int32_t target,
                             uint16_t x,
                             uint16_t y,
                             uint16_t z1,
                             uint16_t z2)
{
    printk("GiftUI XPT2046 target %d: x=%u y=%u z1=%u z2=%u\n",
           target, x, y, z1, z2);
}

void giftui_display_log_stack(void)
{
    size_t unused = 0U;
    const int result = k_thread_stack_space_get(k_current_get(), &unused);
    if (result != 0 || unused > CONFIG_MAIN_STACK_SIZE) {
        printk("GiftUI main stack measurement failed: %d\n", result);
        return;
    }
    printk("GiftUI main stack high-water: used=%u bytes, unused=%u bytes\n",
           (unsigned int)(CONFIG_MAIN_STACK_SIZE - unused),
           (unsigned int)unused);
}

extern int32_t giftui_swift_display_application_run(void);

int main(void)
{
    printk("GiftUI KMRTM24024-SPI profile: display=240x320@4MHz "
           "touch=XPT2046@2MHz\n");
    return giftui_swift_display_application_run();
}
