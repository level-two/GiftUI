#include <stdint.h>

extern int32_t giftui_spec002_resource_probe(int32_t seed);

volatile int32_t giftui_spec002_resource_sink;

int main(void)
{
    giftui_spec002_resource_sink = giftui_spec002_resource_probe(7);
    return 0;
}
