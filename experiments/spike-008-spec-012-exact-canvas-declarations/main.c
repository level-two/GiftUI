#include <stdint.h>

extern uint32_t spike008_swift_run(uint32_t seed);

volatile uint32_t spike008_result;

int main(void) {
    spike008_result = spike008_swift_run(7u);
    return spike008_result == 0u;
}
