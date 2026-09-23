#include <stdint.h>

#include "device_validation.h"
#include "ili9486.h"

extern uint32_t giftui_signal_analyzer_static_preset(void);
extern uint32_t giftui_signal_analyzer_storage_bytes(void);
extern uint32_t giftui_signal_analyzer_capture_layout(void);

int main(void)
{
    if (giftui_signal_analyzer_static_preset() != 360515885u ||
        giftui_signal_analyzer_storage_bytes() != 155840u ||
        giftui_signal_analyzer_capture_layout() != 115392u ||
        ili9486_tile_height() != 4u ||
        ili9486_spi_segment_bytes() != 3840u) {
        return 1;
    }
    return giftui_device_validation_run();
}
