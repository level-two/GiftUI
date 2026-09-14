#include <stdint.h>
#include <stdlib.h>

void giftui_allocation_probe_begin(void);
void giftui_allocation_probe_end(void);
uint64_t giftui_allocation_probe_count(void);
uint64_t giftui_allocation_probe_peak_bytes(void);
uint64_t giftui_allocation_probe_bookkeeping_bytes(void);
uint8_t giftui_allocation_probe_saturated(void);

int main(void) {
    giftui_allocation_probe_begin();
    volatile uint8_t *first = malloc(17);
    volatile uint8_t *second = calloc(3, 19);
    if (first == NULL || second == NULL) return 10;
    first[0] = 1;
    second[0] = 2;
    first = realloc((void *)first, 71);
    if (first == NULL) return 11;
    first[70] = 3;
    free((void *)first);
    free((void *)second);
    giftui_allocation_probe_end();

    if (giftui_allocation_probe_count() < 3) return 20;
    if (giftui_allocation_probe_peak_bytes() < 74) return 21;
    if (giftui_allocation_probe_bookkeeping_bytes() > giftui_allocation_probe_peak_bytes()) return 22;
    if (giftui_allocation_probe_saturated() != 0) return 23;
    return 0;
}
