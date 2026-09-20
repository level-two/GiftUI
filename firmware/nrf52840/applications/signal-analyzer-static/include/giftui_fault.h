#ifndef GIFTUI_FAULT_H
#define GIFTUI_FAULT_H

#include <stdint.h>

enum giftui_fault_category {
    GIFTUI_FAULT_CAPACITY = 0,
    GIFTUI_FAULT_DISPLAY_CONTROLLER,
    GIFTUI_FAULT_DISPLAY_SPI,
    GIFTUI_FAULT_TOUCH_CONTROLLER,
    GIFTUI_FAULT_TOUCH_SPI,
    GIFTUI_FAULT_CATEGORY_COUNT,
};

void giftui_fault_record(int32_t category, int32_t detail);
uint32_t giftui_fault_count(int32_t category);

#endif
