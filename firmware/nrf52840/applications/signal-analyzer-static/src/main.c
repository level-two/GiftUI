#include <stdint.h>

extern uint32_t giftui_signal_analyzer_static_preset(void);
extern uint32_t giftui_signal_analyzer_storage_bytes(void);

int main(void)
{
    return giftui_signal_analyzer_static_preset() == 360515885u &&
            giftui_signal_analyzer_storage_bytes() == 147248u
        ? 0
        : 1;
}
