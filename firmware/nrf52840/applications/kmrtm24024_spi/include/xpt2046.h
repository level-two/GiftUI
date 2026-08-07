#ifndef GIFTUI_XPT2046_H
#define GIFTUI_XPT2046_H

#include <stdint.h>

struct xpt2046_raw_sample {
    uint16_t x;
    uint16_t y;
    uint16_t z1;
    uint16_t z2;
};

int xpt2046_initialize(void);
int xpt2046_pen_is_down(void);
int xpt2046_read_raw(struct xpt2046_raw_sample *sample);
int xpt2046_read_raw_values(uint16_t *x,
                            uint16_t *y,
                            uint16_t *z1,
                            uint16_t *z2);

#endif
