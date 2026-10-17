#include <stdint.h>
static volatile uint64_t input = 7;
static volatile uint8_t observed;
uint64_t probe_input(void) { return input; }
void probe_touch(const void *pointer) { observed = *(const uint8_t *)pointer; }
