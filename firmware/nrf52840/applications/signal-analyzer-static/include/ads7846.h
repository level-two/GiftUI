#ifndef GIFTUI_ADS7846_H
#define GIFTUI_ADS7846_H

#include <stdint.h>

struct ads7846_raw_sample {
    uint16_t x;
    uint16_t y;
    uint16_t z1;
    uint16_t z2;
};

#ifndef GIFTUI_DRIVER_ENTRY
#define GIFTUI_DRIVER_ENTRY __attribute__((used, retain))
#endif

GIFTUI_DRIVER_ENTRY int ads7846_initialize(void);
GIFTUI_DRIVER_ENTRY int ads7846_shutdown(void);
GIFTUI_DRIVER_ENTRY int ads7846_pen_is_down(void);
GIFTUI_DRIVER_ENTRY int ads7846_read_raw(struct ads7846_raw_sample *sample);
GIFTUI_DRIVER_ENTRY int ads7846_read_raw_values(uint16_t *x,
                            uint16_t *y,
                            uint16_t *z1,
                            uint16_t *z2);

#endif
