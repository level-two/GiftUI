#include <stdint.h>

#include "device_validation.h"
#include "ili9486.h"
#include "production_host.h"
#include "static_host_storage.h"

extern uint32_t giftui_signal_analyzer_static_preset(void);
extern uint32_t giftui_signal_analyzer_topology_valid(
    void *profile, uint32_t bytes, void *capture, uint32_t capture_bytes);
extern uint32_t giftui_signal_analyzer_layout_scope_valid(
    void *profile, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_layout_text_valid(
    void *profile, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_full_layout_valid(
    void *profile, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_drawing_storage_valid(
    void *profile, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_full_canvas_valid(
    void *profile, uint32_t bytes, void *capture, uint32_t capture_bytes,
    void *raster, uint32_t raster_bytes,
    void *coverage, uint32_t coverage_bytes);
extern uint32_t giftui_signal_analyzer_tile_valid(
    void *raster, uint32_t raster_bytes,
    void *coverage, uint32_t coverage_bytes);
extern uint32_t giftui_signal_analyzer_canvas_payload_valid(
    void *profile, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_source_valid(void);
extern uint32_t giftui_signal_analyzer_storage_bytes(void);
extern uint32_t giftui_signal_analyzer_capture_layout(void);
extern uint32_t giftui_signal_analyzer_capture_roundtrip(void);
extern uint32_t giftui_signal_analyzer_compact_fact_valid(void);
extern uint32_t giftui_signal_analyzer_presentation_fact_layout_valid(void);
extern uint32_t giftui_signal_analyzer_compact_ring_valid(
    void *profile, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_snapshot_admission_valid(
    void *profile, uint32_t profile_bytes,
    void *capture, uint32_t capture_bytes);
extern uint32_t giftui_signal_analyzer_sealed_application_valid(
    void *profile, uint32_t profile_bytes,
    void *capture, uint32_t capture_bytes);
extern uint32_t giftui_signal_analyzer_repository_producer_valid(
    void *profile, uint32_t profile_bytes,
    void *capture, uint32_t capture_bytes);
extern uint32_t giftui_signal_analyzer_revision_failure_valid(
    void *profile, uint32_t profile_bytes,
    void *capture, uint32_t capture_bytes);
extern uint32_t giftui_signal_analyzer_model_location_valid(void);
extern uint32_t giftui_signal_analyzer_diagnostic_value_valid(void);
extern uint32_t giftui_signal_analyzer_capture_region_valid(
    void *address, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_capture_history_valid(
    void *address, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_snapshot_view_valid(
    void *address, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_model_capture_replay_valid(
    void *address, uint32_t bytes);
extern uint32_t giftui_signal_analyzer_region_map_valid(
    void *profile, uint32_t profile_bytes,
    void *capture, uint32_t capture_bytes,
    void *raster, uint32_t raster_bytes,
    void *coverage, uint32_t coverage_bytes);

int main(void)
{
    struct giftui_static_host_storage regions;
    if (giftui_signal_analyzer_static_preset() != 360515885u ||
        giftui_signal_analyzer_source_valid() != 1u ||
        giftui_signal_analyzer_storage_bytes() != 159168u ||
        giftui_signal_analyzer_capture_layout() != 115392u ||
        giftui_signal_analyzer_capture_roundtrip() != 1u ||
        giftui_signal_analyzer_compact_fact_valid() != 1u ||
        giftui_signal_analyzer_presentation_fact_layout_valid() != 1u ||
        giftui_signal_analyzer_model_location_valid() != 1u ||
        giftui_signal_analyzer_diagnostic_value_valid() != 1u ||
        giftui_signal_analyzer_storage_regions(&regions) != 0 ||
        giftui_signal_analyzer_topology_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_layout_scope_valid(
            regions.profile, (uint32_t)regions.profile_bytes) != 1u ||
        giftui_signal_analyzer_layout_text_valid(
            regions.profile, (uint32_t)regions.profile_bytes) != 1u ||
        giftui_signal_analyzer_full_layout_valid(
            regions.profile, (uint32_t)regions.profile_bytes) != 1u ||
        giftui_signal_analyzer_drawing_storage_valid(
            regions.profile, (uint32_t)regions.profile_bytes) != 1u ||
        giftui_signal_analyzer_canvas_payload_valid(
            regions.profile, (uint32_t)regions.profile_bytes) != 1u ||
        giftui_signal_analyzer_full_canvas_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes,
            regions.raster, (uint32_t)regions.raster_bytes,
            regions.coverage, (uint32_t)regions.coverage_bytes) != 1u ||
        giftui_signal_analyzer_tile_valid(
            regions.raster, (uint32_t)regions.raster_bytes,
            regions.coverage, (uint32_t)regions.coverage_bytes) != 1u ||
        regions.capture_bytes != GIFTUI_STATIC_CAPTURE_BYTES ||
        giftui_signal_analyzer_capture_region_valid(
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_capture_history_valid(
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_snapshot_view_valid(
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_model_capture_replay_valid(
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_region_map_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes,
            regions.raster, (uint32_t)regions.raster_bytes,
            regions.coverage, (uint32_t)regions.coverage_bytes) != 1u ||
        giftui_signal_analyzer_compact_ring_valid(
            regions.profile, (uint32_t)regions.profile_bytes) != 1u ||
        giftui_signal_analyzer_snapshot_admission_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_sealed_application_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_repository_producer_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        giftui_signal_analyzer_revision_failure_valid(
            regions.profile, (uint32_t)regions.profile_bytes,
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        ili9486_tile_height() != 4u ||
        ili9486_spi_segment_bytes() != 3840u) {
        return 1;
    }
    return giftui_production_host_run();
}
