#include "ads7846.h"
#include "touch_input.h"

#include <errno.h>
#include <stddef.h>

static int normalize_axis(uint16_t raw,
                          uint16_t minimum,
                          uint16_t maximum,
                          uint16_t extent,
                          uint8_t inverted,
                          uint16_t *normalized)
{
    if (raw < minimum || raw > maximum) {
        return -ERANGE;
    }
    const uint32_t span = (uint32_t)maximum - minimum;
    uint32_t offset = (uint32_t)raw - minimum;
    if (inverted != 0U) {
        offset = span - offset;
    }
    *normalized = (uint16_t)(
        (offset * ((uint32_t)extent - 1U)) / span);
    return 0;
}

int giftui_touch_input_initialize(
    struct giftui_touch_input *input,
    const struct giftui_touch_calibration *calibration)
{
    if (input == NULL) {
        return -EINVAL;
    }
    input->valid = 0U;
    input->active = 0U;
    if (calibration == NULL ||
        calibration->horizontal_minimum >= calibration->horizontal_maximum ||
        calibration->vertical_minimum >= calibration->vertical_maximum ||
        calibration->logical_width == 0U || calibration->logical_height == 0U ||
        calibration->swap_axes > 1U ||
        calibration->invert_horizontal > 1U ||
        calibration->invert_vertical > 1U) {
        return -EINVAL;
    }
    input->calibration = *calibration;
    input->last_x = 0U;
    input->last_y = 0U;
    input->active = 0U;
    input->valid = 1U;
    return 0;
}

enum giftui_touch_update_result giftui_touch_input_update(
    struct giftui_touch_input *input,
    uint8_t touching,
    const struct ads7846_raw_sample *sample,
    struct giftui_touch_contact *contact)
{
    if (input == NULL || contact == NULL || input->valid == 0U || touching > 1U) {
        return GIFTUI_TOUCH_UPDATE_INVALID;
    }
    if (touching == 0U) {
        if (input->active == 0U) {
            return GIFTUI_TOUCH_UPDATE_NONE;
        }
        contact->phase = GIFTUI_TOUCH_PHASE_UP;
        contact->x = input->last_x;
        contact->y = input->last_y;
        input->active = 0U;
        return GIFTUI_TOUCH_UPDATE_EVENT;
    }
    if (sample == NULL) {
        return GIFTUI_TOUCH_UPDATE_INVALID;
    }

    const uint16_t horizontal =
        input->calibration.swap_axes != 0U ? sample->y : sample->x;
    const uint16_t vertical =
        input->calibration.swap_axes != 0U ? sample->x : sample->y;
    uint16_t x;
    uint16_t y;
    const int horizontal_result = normalize_axis(
        horizontal,
        input->calibration.horizontal_minimum,
        input->calibration.horizontal_maximum,
        input->calibration.logical_width,
        input->calibration.invert_horizontal,
        &x);
    const int vertical_result = normalize_axis(
        vertical,
        input->calibration.vertical_minimum,
        input->calibration.vertical_maximum,
        input->calibration.logical_height,
        input->calibration.invert_vertical,
        &y);
    if (horizontal_result != 0 || vertical_result != 0) {
        if (input->active == 0U) {
            return GIFTUI_TOUCH_UPDATE_NONE;
        }
        contact->phase = GIFTUI_TOUCH_PHASE_UP;
        contact->x = input->last_x;
        contact->y = input->last_y;
        input->active = 0U;
        return GIFTUI_TOUCH_UPDATE_EVENT;
    }

    contact->phase = input->active == 0U
        ? GIFTUI_TOUCH_PHASE_DOWN
        : GIFTUI_TOUCH_PHASE_MOVE;
    contact->x = x;
    contact->y = y;
    input->last_x = x;
    input->last_y = y;
    input->active = 1U;
    return GIFTUI_TOUCH_UPDATE_EVENT;
}

void giftui_touch_input_reset(struct giftui_touch_input *input)
{
    if (input == NULL) {
        return;
    }
    input->active = 0U;
    input->last_x = 0U;
    input->last_y = 0U;
}
