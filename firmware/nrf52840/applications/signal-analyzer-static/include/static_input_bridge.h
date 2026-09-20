#ifndef GIFTUI_STATIC_INPUT_BRIDGE_H
#define GIFTUI_STATIC_INPUT_BRIDGE_H

#include "touch_input.h"

#include <stdint.h>

#ifndef GIFTUI_STATIC_INPUT_ENTRY
#define GIFTUI_STATIC_INPUT_ENTRY __attribute__((used, retain))
#endif

GIFTUI_STATIC_INPUT_ENTRY int32_t giftui_signal_analyzer_input_initialize(
    uint16_t source);
GIFTUI_STATIC_INPUT_ENTRY int32_t giftui_signal_analyzer_input_install_presentation(
    uint32_t revision);
GIFTUI_STATIC_INPUT_ENTRY int32_t giftui_signal_analyzer_input_admit(
    uint8_t phase,
    uint16_t x,
    uint16_t y,
    uint32_t observed_presentation_revision,
    uint8_t prior_physical_sequence_is_complete);
GIFTUI_STATIC_INPUT_ENTRY uint16_t giftui_signal_analyzer_input_pending_count(void);
GIFTUI_STATIC_INPUT_ENTRY void giftui_signal_analyzer_input_quiesce(void);

GIFTUI_STATIC_INPUT_ENTRY int32_t giftui_static_input_bridge_submit(
    const struct giftui_touch_contact *contact,
    uint32_t observed_presentation_revision,
    uint8_t prior_physical_sequence_is_complete);

#endif
