#include <stdint.h>

extern uint32_t giftui_spec014_backend_probe(uint32_t seed);

volatile uint32_t giftui_spec014_backend_sink;

int main(void)
{
    giftui_spec014_backend_sink = giftui_spec014_backend_probe(14);
    return 0;
}
