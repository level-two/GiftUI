#include <stdint.h>

extern uint32_t giftui_spec003_resource_entry(uint32_t seed);
extern uint32_t giftui_spec003_named_storage_probe(void) __attribute__((weak));

volatile uint32_t giftui_spec003_resource_sink;

int main(void)
{
    giftui_spec003_resource_sink = giftui_spec003_resource_entry(41);
    if (giftui_spec003_named_storage_probe != 0) {
        giftui_spec003_resource_sink += giftui_spec003_named_storage_probe();
    }
    return 0;
}
