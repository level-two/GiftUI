#include <stdint.h>

int spike005_validate(void);
volatile uint32_t spike005_sink;

int main(void) {
    spike005_sink = (uint32_t)spike005_validate();
    return 0;
}
