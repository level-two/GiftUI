#include <stdint.h>

extern uint32_t giftui_spec013_static_profile_probe(void);

volatile uint32_t giftui_spec013_static_profile_sink;

int main(void)
{
    giftui_spec013_static_profile_sink = giftui_spec013_static_profile_probe();
    return 0;
}
