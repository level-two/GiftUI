#include <stdint.h>

extern uint64_t spike003_swift_run(uint32_t seed);

volatile uint32_t spike003_runtime_seed = 0x003003u;
volatile uint64_t spike003_result;

int main(void) {
    spike003_result = spike003_swift_run(spike003_runtime_seed);
    return spike003_result == 0u ? 1 : 0;
}
