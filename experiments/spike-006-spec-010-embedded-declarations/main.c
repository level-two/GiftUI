#include <stdint.h>

extern uint32_t spike006_swift_run(uint32_t seed);

volatile uint32_t spike006_result;

int main(void) {
    spike006_result = spike006_swift_run(7u);
    return spike006_result == 0u;
}

uint8_t spike006_report(uint32_t route) {
    spike006_result ^= route;
    return 1u;
}
