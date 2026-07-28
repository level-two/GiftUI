#ifndef GIFTUI_ADS7846_H
#define GIFTUI_ADS7846_H

#include <stdint.h>

struct ads7846_raw_sample {
    uint16_t x;
    uint16_t y;
    uint16_t z1;
    uint16_t z2;
};

int ads7846_initialize(void);
int ads7846_pen_is_down(void);
int ads7846_read_raw(struct ads7846_raw_sample *sample);

#endif
