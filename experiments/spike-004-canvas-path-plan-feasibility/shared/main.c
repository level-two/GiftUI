#include <stdint.h>

extern uint64_t spike004_swift_run(uint32_t seed);

volatile uint32_t spike004_runtime_seed = 0x004004u;
volatile uint64_t spike004_result;

int main(void) {
    spike004_result = spike004_swift_run(spike004_runtime_seed);
    return spike004_result == 0u ? 1 : 0;
}
