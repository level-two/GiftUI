#include "giftui_fault.h"

#include <limits.h>
#include <zephyr/sys/printk.h>

static uint32_t fault_counts[GIFTUI_FAULT_CATEGORY_COUNT];

static const char *const fault_names[GIFTUI_FAULT_CATEGORY_COUNT] = {
    "capacity",
    "display-controller",
    "display-spi",
    "touch-controller",
    "touch-spi",
};

void giftui_fault_record(int32_t category, int32_t detail)
{
    if (category < 0 || category >= GIFTUI_FAULT_CATEGORY_COUNT) {
        return;
    }

    uint32_t count = fault_counts[category];
    if (count < UINT32_MAX) {
        count++;
        fault_counts[category] = count;
    }

    /* Preserve the first diagnostics, then log at powers of two so a failed
     * controller cannot flood UART or prevent the event loop from sleeping.
     */
    if (count <= 8U || (count & (count - 1U)) == 0U) {
        printk("GiftUI fault %s: detail=%d count=%u\n",
               fault_names[category], detail, count);
    }
}

uint32_t giftui_fault_count(int32_t category)
{
    if (category < 0 || category >= GIFTUI_FAULT_CATEGORY_COUNT) {
        return 0U;
    }
    return fault_counts[category];
}
