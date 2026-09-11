#include <stdint.h>

extern int32_t giftui_spec008_render_probe(int32_t seed);

volatile int32_t giftui_spec008_render_sink;

int main(void)
{
    giftui_spec008_render_sink = giftui_spec008_render_probe(8);
    return 0;
}
