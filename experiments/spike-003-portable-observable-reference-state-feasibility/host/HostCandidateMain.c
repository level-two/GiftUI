#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern uint64_t spike003_swift_run(uint32_t seed);
extern uint64_t spike003_read_counters(void);

int main(void) {
    uint64_t digest = spike003_swift_run(0x003003u);
    uint64_t counters = spike003_read_counters();
    printf("metric\tcount\n");
    printf("materialization\t%" PRIu64 "\n", counters & 0xffu);
    printf("attach\t%" PRIu64 "\n", (counters >> 8) & 0xffu);
    printf("mutation-report-total\t%" PRIu64 "\n", (counters >> 16) & 0xffu);
    printf("coalesced-report\t%" PRIu64 "\n", (counters >> 24) & 0xffu);
    printf("replacement\t%" PRIu64 "\n", (counters >> 32) & 0xffu);
    printf("detach\t%" PRIu64 "\n", (counters >> 40) & 0xffu);
    printf("stale-reject\t%" PRIu64 "\n", (counters >> 48) & 0xffu);
    printf("dirty-transition-wake\t%" PRIu64 "\n", (counters >> 56) & 0xffu);
    printf("digest\t%" PRIu64 "\n", digest);
    return 0;
}
