#include "static_input_bridge.h"

#include <errno.h>
#include <stddef.h>

int32_t giftui_static_input_bridge_submit(
    const struct giftui_touch_contact *contact,
    uint32_t observed_presentation_revision,
    uint8_t prior_physical_sequence_is_complete)
{
    if (contact == NULL || prior_physical_sequence_is_complete > 1U) {
        return -EINVAL;
    }
    return giftui_signal_analyzer_input_admit(
        (uint8_t)contact->phase,
        contact->x,
        contact->y,
        observed_presentation_revision,
        prior_physical_sequence_is_complete);
}
