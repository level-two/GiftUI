#include <stdint.h>

extern uint32_t giftui_spec004_resource_probe(uint32_t seed);

volatile uint32_t giftui_spec004_resource_sink;
uint8_t giftui_spec004_display_staging[3840];
const uint32_t giftui_spec004_initialization_operations = 44;

int main(void)
{
    giftui_spec004_display_staging[0] = 1;
    giftui_spec004_resource_sink = giftui_spec004_resource_probe(
        giftui_spec004_initialization_operations
    );
    return 0;
}
