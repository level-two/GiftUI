#ifndef GIFTUI_TOUCH_INPUT_H
#define GIFTUI_TOUCH_INPUT_H

#include <stdint.h>

struct ads7846_raw_sample;

#ifndef GIFTUI_INPUT_ENTRY
#define GIFTUI_INPUT_ENTRY __attribute__((used, retain))
#endif

enum giftui_touch_phase {
    GIFTUI_TOUCH_PHASE_DOWN = 0,
    GIFTUI_TOUCH_PHASE_MOVE = 1,
    GIFTUI_TOUCH_PHASE_UP = 2,
};

enum giftui_touch_update_result {
    GIFTUI_TOUCH_UPDATE_INVALID = -1,
    GIFTUI_TOUCH_UPDATE_NONE = 0,
    GIFTUI_TOUCH_UPDATE_EVENT = 1,
};

struct giftui_touch_calibration {
    uint16_t horizontal_minimum;
    uint16_t horizontal_maximum;
    uint16_t vertical_minimum;
    uint16_t vertical_maximum;
    uint16_t logical_width;
    uint16_t logical_height;
    uint8_t swap_axes;
    uint8_t invert_horizontal;
    uint8_t invert_vertical;
};

struct giftui_touch_contact {
    enum giftui_touch_phase phase;
    uint16_t x;
    uint16_t y;
};

struct giftui_touch_input {
    struct giftui_touch_calibration calibration;
    uint16_t last_x;
    uint16_t last_y;
    uint8_t active;
    uint8_t valid;
};

GIFTUI_INPUT_ENTRY int giftui_touch_input_initialize(
    struct giftui_touch_input *input,
    const struct giftui_touch_calibration *calibration);

GIFTUI_INPUT_ENTRY enum giftui_touch_update_result giftui_touch_input_update(
    struct giftui_touch_input *input,
    uint8_t touching,
    const struct ads7846_raw_sample *sample,
    struct giftui_touch_contact *contact);

GIFTUI_INPUT_ENTRY void giftui_touch_input_reset(
    struct giftui_touch_input *input);

#endif
