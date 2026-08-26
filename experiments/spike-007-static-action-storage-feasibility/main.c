#include <stdint.h>

extern uint32_t spike007_swift_run(uint32_t seed);

volatile uint32_t spike007_result;

int main(void) {
    spike007_result = spike007_swift_run(7u);
    return spike007_result == 0u;
}
