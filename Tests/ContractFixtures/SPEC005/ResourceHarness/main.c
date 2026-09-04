#include <stdint.h>

extern uint32_t giftui_spec005_resource_probe(uint32_t seed);

volatile uint32_t giftui_spec005_resource_sink;

int main(void)
{
    giftui_spec005_resource_sink = giftui_spec005_resource_probe(0x5005u);
    return 0;
}
