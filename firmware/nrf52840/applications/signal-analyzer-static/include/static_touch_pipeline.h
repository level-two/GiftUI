#ifndef GIFTUI_STATIC_TOUCH_PIPELINE_H
#define GIFTUI_STATIC_TOUCH_PIPELINE_H

#include "touch_input.h"

#include <stdint.h>

#ifndef GIFTUI_STATIC_TOUCH_ENTRY
#define GIFTUI_STATIC_TOUCH_ENTRY __attribute__((used, retain))
#endif

enum giftui_static_touch_pipeline_result {
    GIFTUI_STATIC_TOUCH_PIPELINE_INVALID = -1,
    GIFTUI_STATIC_TOUCH_PIPELINE_NONE = 0,
    GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED = 1,
};

struct giftui_static_touch_pipeline {
    struct giftui_touch_input input;
    uint32_t observed_presentation_revision;
    uint8_t prior_physical_sequence_is_complete;
    uint8_t awaiting_observed_release;
    uint8_t valid;
};

GIFTUI_STATIC_TOUCH_ENTRY int giftui_static_touch_pipeline_initialize(
    struct giftui_static_touch_pipeline *pipeline,
    const struct giftui_touch_calibration *calibration,
    uint32_t observed_presentation_revision);

/* Replacement frames invalidate the current physical sequence until release. */
GIFTUI_STATIC_TOUCH_ENTRY int giftui_static_touch_pipeline_present(
    struct giftui_static_touch_pipeline *pipeline,
    uint32_t observed_presentation_revision);

GIFTUI_STATIC_TOUCH_ENTRY enum giftui_static_touch_pipeline_result
giftui_static_touch_pipeline_update(
    struct giftui_static_touch_pipeline *pipeline,
    uint8_t touching,
    const struct ads7846_raw_sample *sample,
    int32_t *admission_outcome);

GIFTUI_STATIC_TOUCH_ENTRY void giftui_static_touch_pipeline_transport_reset(
    struct giftui_static_touch_pipeline *pipeline);

#endif
