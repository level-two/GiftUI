#include <stdint.h>
#include <zephyr/kernel.h>

#include "spi_tft.h"

typedef int32_t (*counter_pixel_write)(uint16_t, uint16_t, uint16_t, uint16_t,
                                      const uint8_t *, size_t);
extern uint32_t giftui_rfc014_counter_entry(counter_pixel_write write, void *backing, size_t byte_count);

int main(void)
{
    /* Explicit caller-owned slots. Graph0 ends before complete0 is created;
     * failure3 ends after each teardown before the next fresh owner uses it. */
    static _Alignas(8) uint8_t counter_backing[4][32000];
    if (spi_tft_initialize() != 0) {
        printk("P08 counter display initialization failed\n");
        return 1;
    }
    uint32_t checks = giftui_rfc014_counter_entry(spi_tft_write_rgb565, counter_backing, sizeof(counter_backing));
    int shutdown = spi_tft_shutdown();
    printk("P08 counter assertions=%u shutdown=%d\n", checks, shutdown);
    return checks > 0 && shutdown == 0 ? 0 : 1;
}
