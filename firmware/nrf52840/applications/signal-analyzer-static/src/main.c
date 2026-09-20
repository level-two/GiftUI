#include <stdint.h>

#include "ili9486.h"

extern uint32_t giftui_signal_analyzer_static_preset(void);
extern uint32_t giftui_signal_analyzer_storage_bytes(void);

int main(void)
{
    return giftui_signal_analyzer_static_preset() == 360515885u &&
            giftui_signal_analyzer_storage_bytes() == 147248u &&
            ili9486_tile_height() == 4u &&
            ili9486_spi_segment_bytes() == 3840u
        ? 0
        : 1;
}
