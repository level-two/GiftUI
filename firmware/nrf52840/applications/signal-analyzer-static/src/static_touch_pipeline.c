#include "static_input_bridge.h"
#include "static_touch_pipeline.h"

#include <errno.h>
#include <stddef.h>

int giftui_static_touch_pipeline_initialize(
    struct giftui_static_touch_pipeline *pipeline,
    const struct giftui_touch_calibration *calibration,
    uint32_t observed_presentation_revision)
{
    if (pipeline == NULL) {
        return -EINVAL;
    }
    pipeline->valid = 0U;
    pipeline->prior_physical_sequence_is_complete = 0U;
    pipeline->awaiting_observed_release = 0U;
    const int result = giftui_touch_input_initialize(
        &pipeline->input,
        calibration);
    if (result != 0) {
        return result;
    }
    pipeline->observed_presentation_revision = observed_presentation_revision;
    pipeline->prior_physical_sequence_is_complete = 1U;
    pipeline->valid = 1U;
    return 0;
}

int giftui_static_touch_pipeline_present(
    struct giftui_static_touch_pipeline *pipeline,
    uint32_t observed_presentation_revision)
{
    if (pipeline == NULL || pipeline->valid == 0U ||
        observed_presentation_revision == 0U ||
        observed_presentation_revision <= pipeline->observed_presentation_revision) {
        return -EINVAL;
    }
    pipeline->observed_presentation_revision = observed_presentation_revision;
    giftui_static_touch_pipeline_transport_reset(pipeline);
    return 0;
}

enum giftui_static_touch_pipeline_result giftui_static_touch_pipeline_update(
    struct giftui_static_touch_pipeline *pipeline,
    uint8_t touching,
    const struct ads7846_raw_sample *sample,
    int32_t *admission_outcome)
{
    if (pipeline == NULL || admission_outcome == NULL ||
        pipeline->valid == 0U) {
        return GIFTUI_STATIC_TOUCH_PIPELINE_INVALID;
    }
    *admission_outcome = 0;
    if (touching > 1U) {
        giftui_static_touch_pipeline_transport_reset(pipeline);
        return GIFTUI_STATIC_TOUCH_PIPELINE_INVALID;
    }

    if (pipeline->awaiting_observed_release != 0U) {
        if (touching != 0U) {
            return GIFTUI_STATIC_TOUCH_PIPELINE_NONE;
        }
        pipeline->awaiting_observed_release = 0U;
        pipeline->prior_physical_sequence_is_complete = 1U;
        return GIFTUI_STATIC_TOUCH_PIPELINE_NONE;
    }

    struct giftui_touch_contact contact;
    const enum giftui_touch_update_result update = giftui_touch_input_update(
        &pipeline->input,
        touching,
        sample,
        &contact);
    if (update == GIFTUI_TOUCH_UPDATE_INVALID) {
        giftui_static_touch_pipeline_transport_reset(pipeline);
        return GIFTUI_STATIC_TOUCH_PIPELINE_INVALID;
    }
    if (update == GIFTUI_TOUCH_UPDATE_NONE) {
        return GIFTUI_STATIC_TOUCH_PIPELINE_NONE;
    }

    const uint8_t prior_complete = contact.phase == GIFTUI_TOUCH_PHASE_DOWN
        ? pipeline->prior_physical_sequence_is_complete
        : 0U;
    *admission_outcome = giftui_static_input_bridge_submit(
        &contact,
        pipeline->observed_presentation_revision,
        prior_complete);
    if (*admission_outcome < 0) {
        giftui_static_touch_pipeline_transport_reset(pipeline);
        return GIFTUI_STATIC_TOUCH_PIPELINE_INVALID;
    }

    pipeline->prior_physical_sequence_is_complete =
        contact.phase == GIFTUI_TOUCH_PHASE_UP ? 1U : 0U;
    return GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED;
}

void giftui_static_touch_pipeline_transport_reset(
    struct giftui_static_touch_pipeline *pipeline)
{
    if (pipeline == NULL) {
        return;
    }
    giftui_touch_input_reset(&pipeline->input);
    pipeline->prior_physical_sequence_is_complete = 0U;
    pipeline->awaiting_observed_release = 1U;
}
