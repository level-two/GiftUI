#include <stdint.h>

#include "device_validation.h"
#include "ili9486.h"
#include "static_host_storage.h"

extern uint32_t giftui_signal_analyzer_static_preset(void);
extern uint32_t giftui_signal_analyzer_storage_bytes(void);
extern uint32_t giftui_signal_analyzer_capture_layout(void);
extern uint32_t giftui_signal_analyzer_capture_region_valid(
    void *address, uint32_t bytes);

int main(void)
{
    struct giftui_static_host_storage regions;
    if (giftui_signal_analyzer_static_preset() != 360515885u ||
        giftui_signal_analyzer_storage_bytes() != 155840u ||
        giftui_signal_analyzer_capture_layout() != 115392u ||
        giftui_signal_analyzer_storage_regions(&regions) != 0 ||
        regions.capture_bytes != GIFTUI_STATIC_CAPTURE_BYTES ||
        giftui_signal_analyzer_capture_region_valid(
            regions.capture, (uint32_t)regions.capture_bytes) != 1u ||
        ili9486_tile_height() != 4u ||
        ili9486_spi_segment_bytes() != 3840u) {
        return 1;
    }
    return giftui_device_validation_run();
}
