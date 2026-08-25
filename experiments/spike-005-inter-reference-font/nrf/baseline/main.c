#include <stdint.h>

volatile uint32_t spike005_sink;

int main(void) {
    spike005_sink = 0;
    return 0;
}
