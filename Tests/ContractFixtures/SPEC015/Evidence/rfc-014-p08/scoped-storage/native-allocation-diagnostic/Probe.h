#ifndef P08_NATIVE_PROBE_H
#define P08_NATIVE_PROBE_H
#include <stdint.h>
#include <stdio.h>
struct probe_stats {
    uint64_t allocations, frees, requested_total, reserved_total;
    uint64_t live_requested, live_reserved, live_count;
    uint64_t peak_requested, peak_reserved, peak_rounding, peak_live_count;
    uint64_t baseline_requested, baseline_reserved, baseline_count;
    uint64_t unknown_frees, failures, nested, foreign, saturated, truncated;
    uint64_t bad_chain, io_errors;
};
int probe_setup(const char *path);
void probe_begin(unsigned cohort, int reset);
struct probe_stats probe_end(void);
void probe_report(FILE *out);
void probe_test_limits(unsigned records, unsigned pcs, unsigned frames);
void probe_test_fail_io(void);
#endif
