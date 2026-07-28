#include "ads7846.h"
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
    case 7:
        printk("GiftUI ADS7846 read failed: %d\n", value);
        break;
    case 8:
        printk("GiftUI ADS7846 touch calibration target %d\n", value);
        break;
    case 9:
        printk("GiftUI ADS7846 calibration failed: %d\n", value);
        break;
    case 10:
        printk("GiftUI ADS7846 calibration ready\n");
        break;
    case 11:
        printk("GiftUI thermostat target changed to %d\n", value);
        break;
    default:
        printk("GiftUI display event %d: %d\n", event, value);
        break;
    }
}

void giftui_touch_log_sample(int32_t target,
                             uint16_t x,
                             uint16_t y,
                             uint16_t z1,
                             uint16_t z2)
{
    printk("GiftUI ADS7846 target %d: x=%u y=%u z1=%u z2=%u\n",
           target, x, y, z1, z2);
}

extern int32_t giftui_swift_display_application_run(void);

int main(void)
{
    printk("GiftUI ILI9486 transfer configuration: tile=%u rows, "
           "segment<=%u bytes\n",
           ili9486_tile_height(),
           (unsigned int)ili9486_spi_segment_bytes());

    const int touch_result = ads7846_initialize();
    if (touch_result != 0) {
        printk("GiftUI ADS7846 initialization failed: %d\n", touch_result);
        return touch_result;
    }

    return giftui_swift_display_application_run();
}
