#include <stdint.h>

extern uint64_t spike002_swift_run(uint32_t seed);

volatile uint32_t spike002_runtime_seed = 0x5a17c3e1U;
volatile uint64_t spike002_observable_digest;

int main(void)
{
    spike002_observable_digest = spike002_swift_run(spike002_runtime_seed);
    return spike002_observable_digest == 0U ? 1 : 0;
}
