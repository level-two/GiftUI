#include "static_input_bridge.h"

#include <assert.h>
#include <errno.h>
#include <stddef.h>

static uint32_t call_count;
static uint8_t captured_phase;
static uint16_t captured_x;
static uint16_t captured_y;
static uint32_t captured_revision;
static uint8_t captured_prior_complete;

int32_t giftui_signal_analyzer_input_admit(
    uint8_t phase,
    uint16_t x,
    uint16_t y,
    uint32_t observed_presentation_revision,
    uint8_t prior_physical_sequence_is_complete)
{
    ++call_count;
    captured_phase = phase;
    captured_x = x;
    captured_y = y;
    captured_revision = observed_presentation_revision;
    captured_prior_complete = prior_physical_sequence_is_complete;
    return 0x0102;
}

int main(void)
{
    const struct giftui_touch_contact contact = {
        .phase = GIFTUI_TOUCH_PHASE_MOVE,
        .x = 317U,
        .y = 211U,
    };
    assert(giftui_static_input_bridge_submit(&contact, 29U, 1U) == 0x0102);
    assert(call_count == 1U);
    assert(captured_phase == (uint8_t)GIFTUI_TOUCH_PHASE_MOVE);
    assert(captured_x == 317U);
    assert(captured_y == 211U);
    assert(captured_revision == 29U);
    assert(captured_prior_complete == 1U);

    assert(giftui_static_input_bridge_submit(NULL, 29U, 0U) == -EINVAL);
    assert(giftui_static_input_bridge_submit(&contact, 29U, 2U) == -EINVAL);
    assert(call_count == 1U);
    return 0;
}
