#include "ads7846.h"
#include "static_touch_pipeline.h"

#include <assert.h>
#include <errno.h>
#include <stddef.h>
#include <stdint.h>

static uint32_t admission_count;
static uint8_t admitted_phase;
static uint16_t admitted_x;
static uint16_t admitted_y;
static uint32_t admitted_revision;
static uint8_t admitted_prior_complete;
static int32_t next_admission_outcome = 0x00ff;

int32_t giftui_signal_analyzer_input_admit(
    uint8_t phase,
    uint16_t x,
    uint16_t y,
    uint32_t observed_presentation_revision,
    uint8_t prior_physical_sequence_is_complete)
{
    ++admission_count;
    admitted_phase = phase;
    admitted_x = x;
    admitted_y = y;
    admitted_revision = observed_presentation_revision;
    admitted_prior_complete = prior_physical_sequence_is_complete;
    return next_admission_outcome;
}

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

static void normalized_sequence_reaches_swift_bridge(void)
{
    struct giftui_static_touch_pipeline pipeline;
    struct giftui_touch_calibration configured = calibration();
    struct ads7846_raw_sample sample = {
        .x = 600U,
        .y = 1200U,
        .z1 = 1U,
        .z2 = 2U,
    };
    int32_t outcome = 0;

    assert(giftui_static_touch_pipeline_initialize(
               &pipeline, &configured, 17U) == 0);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(outcome == 0x00ff);
    assert(admission_count == 1U);
    assert(admitted_phase == GIFTUI_TOUCH_PHASE_DOWN);
    assert(admitted_x == 239U && admitted_y == 159U);
    assert(admitted_revision == 17U);
    assert(admitted_prior_complete == 1U);

    sample.x = 1100U;
    sample.y = 2200U;
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(admitted_phase == GIFTUI_TOUCH_PHASE_MOVE);
    assert(admitted_x == 479U && admitted_y == 319U);
    assert(admitted_prior_complete == 0U);

    assert(giftui_static_touch_pipeline_update(
               &pipeline, 0U, NULL, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(admitted_phase == GIFTUI_TOUCH_PHASE_UP);
    assert(admitted_prior_complete == 0U);

    sample.x = 100U;
    sample.y = 200U;
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(admitted_phase == GIFTUI_TOUCH_PHASE_DOWN);
    assert(admitted_prior_complete == 1U);
}

static void transport_failure_requires_observed_release(void)
{
    struct giftui_static_touch_pipeline pipeline;
    struct giftui_touch_calibration configured = calibration();
    struct ads7846_raw_sample sample = {
        .x = 600U,
        .y = 1200U,
        .z1 = 1U,
        .z2 = 2U,
    };
    int32_t outcome = 0;
    const uint32_t initial_admissions = admission_count;

    assert(giftui_static_touch_pipeline_initialize(
               &pipeline, &configured, 18U) == 0);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    giftui_static_touch_pipeline_transport_reset(&pipeline);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
    assert(admission_count == initial_admissions + 1U);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 0U, NULL, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(admitted_phase == GIFTUI_TOUCH_PHASE_DOWN);
    assert(admitted_prior_complete == 1U);
}

static void invalid_and_refused_handoff_fail_closed(void)
{
    struct giftui_static_touch_pipeline pipeline;
    struct giftui_touch_calibration configured = calibration();
    struct ads7846_raw_sample sample = {
        .x = 600U,
        .y = 1200U,
        .z1 = 1U,
        .z2 = 2U,
    };
    int32_t outcome = 0;

    assert(giftui_static_touch_pipeline_initialize(NULL, &configured, 0U) ==
           -EINVAL);
    configured.horizontal_maximum = configured.horizontal_minimum;
    assert(giftui_static_touch_pipeline_initialize(
               &pipeline, &configured, 0U) == -EINVAL);

    configured = calibration();
    assert(giftui_static_touch_pipeline_initialize(
               &pipeline, &configured, 19U) == 0);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 2U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_INVALID);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 0U, NULL, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
    next_admission_outcome = -EINVAL;
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_INVALID);
    assert(outcome == -EINVAL);
    next_admission_outcome = 0x00ff;
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
}

static void replacement_waits_for_release_before_new_revision(void)
{
    struct giftui_static_touch_pipeline pipeline;
    struct giftui_touch_calibration configured = calibration();
    struct ads7846_raw_sample sample = {
        .x = 600U, .y = 1200U, .z1 = 1U, .z2 = 2U,
    };
    int32_t outcome = 0;
    const uint32_t initial_admissions = admission_count;
    assert(giftui_static_touch_pipeline_initialize(
               &pipeline, &configured, 20U) == 0);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(admitted_revision == 20U);
    assert(giftui_static_touch_pipeline_present(&pipeline, 20U) == -EINVAL);
    assert(giftui_static_touch_pipeline_present(&pipeline, 21U) == 0);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
    assert(admission_count == initial_admissions + 1U);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 0U, NULL, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_NONE);
    assert(giftui_static_touch_pipeline_update(
               &pipeline, 1U, &sample, &outcome) ==
           GIFTUI_STATIC_TOUCH_PIPELINE_SUBMITTED);
    assert(admitted_revision == 21U);
    assert(admitted_phase == GIFTUI_TOUCH_PHASE_DOWN);
    assert(admitted_prior_complete == 1U);
}

int main(void)
{
    normalized_sequence_reaches_swift_bridge();
    transport_failure_requires_observed_release();
    invalid_and_refused_handoff_fail_closed();
    replacement_waits_for_release_before_new_revision();
    return 0;
}
