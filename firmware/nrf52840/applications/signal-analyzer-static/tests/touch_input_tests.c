#include "ads7846.h"
#include "touch_input.h"

#include <assert.h>
#include <errno.h>
#include <stddef.h>

static struct giftui_touch_calibration calibration(void)
{
    return (struct giftui_touch_calibration) {
        .horizontal_minimum = 100U,
        .horizontal_maximum = 1100U,
        .vertical_minimum = 200U,
        .vertical_maximum = 2200U,
        .logical_width = 480U,
        .logical_height = 320U,
        .swap_axes = 0U,
        .invert_horizontal = 0U,
        .invert_vertical = 0U,
    };
}

static void ordered_contact_sequence(void)
{
    struct giftui_touch_input input;
    struct giftui_touch_calibration configured = calibration();
    struct giftui_touch_contact contact;
    struct ads7846_raw_sample sample = {
        .x = 100U,
        .y = 200U,
        .z1 = 1U,
        .z2 = 2U,
    };
    assert(giftui_touch_input_initialize(&input, &configured) == 0);
    assert(giftui_touch_input_update(&input, 0U, NULL, &contact) ==
           GIFTUI_TOUCH_UPDATE_NONE);
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    assert(contact.phase == GIFTUI_TOUCH_PHASE_DOWN);
    assert(contact.x == 0U && contact.y == 0U);

    sample.x = 600U;
    sample.y = 1200U;
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    assert(contact.phase == GIFTUI_TOUCH_PHASE_MOVE);
    assert(contact.x == 239U && contact.y == 159U);
    assert(giftui_touch_input_update(&input, 0U, NULL, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    assert(contact.phase == GIFTUI_TOUCH_PHASE_UP);
    assert(contact.x == 239U && contact.y == 159U);
    assert(giftui_touch_input_update(&input, 0U, NULL, &contact) ==
           GIFTUI_TOUCH_UPDATE_NONE);
}

static void orientation_and_bounds(void)
{
    struct giftui_touch_input input;
    struct giftui_touch_calibration configured = calibration();
    configured.swap_axes = 1U;
    configured.invert_horizontal = 1U;
    configured.invert_vertical = 1U;
    struct giftui_touch_contact contact;
    struct ads7846_raw_sample sample = {
        .x = 200U,
        .y = 100U,
        .z1 = 0U,
        .z2 = 0U,
    };
    assert(giftui_touch_input_initialize(&input, &configured) == 0);
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    assert(contact.phase == GIFTUI_TOUCH_PHASE_DOWN);
    assert(contact.x == 479U && contact.y == 319U);

    sample.x = 2200U;
    sample.y = 1100U;
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    assert(contact.phase == GIFTUI_TOUCH_PHASE_MOVE);
    assert(contact.x == 0U && contact.y == 0U);

    sample.y = 1101U;
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    assert(contact.phase == GIFTUI_TOUCH_PHASE_UP);
    assert(contact.x == 0U && contact.y == 0U);
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_NONE);
}

static void invalid_configuration_and_transport_reset(void)
{
    struct giftui_touch_input input;
    struct giftui_touch_calibration configured = calibration();
    struct giftui_touch_contact contact;
    struct ads7846_raw_sample sample = {
        .x = 600U,
        .y = 1200U,
        .z1 = 0U,
        .z2 = 0U,
    };
    assert(giftui_touch_input_initialize(&input, &configured) == 0);
    configured.horizontal_maximum = configured.horizontal_minimum;
    assert(giftui_touch_input_initialize(&input, &configured) == -EINVAL);
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_INVALID);

    configured = calibration();
    assert(giftui_touch_input_initialize(&input, &configured) == 0);
    assert(giftui_touch_input_update(&input, 1U, NULL, &contact) ==
           GIFTUI_TOUCH_UPDATE_INVALID);
    assert(giftui_touch_input_update(&input, 1U, &sample, &contact) ==
           GIFTUI_TOUCH_UPDATE_EVENT);
    giftui_touch_input_reset(&input);
    assert(giftui_touch_input_update(&input, 0U, NULL, &contact) ==
           GIFTUI_TOUCH_UPDATE_NONE);
}

int main(void)
{
    ordered_contact_sequence();
    orientation_and_bounds();
    invalid_configuration_and_transport_reset();
    return 0;
}
