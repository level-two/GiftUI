#include "Probe.h"
#include <malloc/malloc.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <signal.h>
#include <string.h>
#include <sys/resource.h>

static int rejected(struct probe_stats s) {
    return s.saturated || s.foreign || s.truncated || s.bad_chain || s.io_errors;
}
static void report(const char *name, struct probe_stats s) {
#define FIELD(x) fprintf(stderr, " " #x "=%llu", s.x)
    fprintf(stderr, "WINDOW %s", name);
    FIELD(allocations); FIELD(frees); FIELD(requested_total); FIELD(reserved_total);
    FIELD(live_requested); FIELD(live_reserved); FIELD(live_count);
    FIELD(peak_requested); FIELD(peak_reserved); FIELD(peak_rounding); FIELD(peak_live_count);
    FIELD(baseline_requested); FIELD(baseline_reserved); FIELD(baseline_count);
    FIELD(unknown_frees); FIELD(failures); FIELD(nested); FIELD(foreign); FIELD(saturated); FIELD(truncated); FIELD(bad_chain); FIELD(io_errors);
    fputc('\n', stderr);
#undef FIELD
}
#ifdef VALIDATE_ONLY
static void *volatile escape;
static int failures;
static atomic_int foreign_gate;
static __attribute__((noinline)) unsigned deep_capture(unsigned remaining) {
    if (!remaining) { void *p = malloc(113); escape = p; free(p); return 1; }
    unsigned value = deep_capture(remaining - 1); return value + 1;
}
static void *foreign_allocation(void *unused) {
    (void)unused;
    while (atomic_load(&foreign_gate) != 1) {}
    void *p = malloc(113); escape = p; free(p);
    atomic_store(&foreign_gate, 2); return NULL;
}
static void check(const char *name, unsigned expected, int bypass) {
    struct probe_stats s = probe_end(); report(name, s);
    uint64_t requested = expected == 0 ? 0 : expected == 2 ? 634 : expected == 3 ? 384 : strstr(name, "calloc") ? 339 : strstr(name, "aligned_alloc") ? 128 : 113;
    if (s.allocations != expected || s.requested_total != requested || s.reserved_total < requested || s.failures || s.saturated || s.foreign || s.truncated || s.bad_chain || s.io_errors || s.live_count || s.live_requested || s.live_reserved) failures++;
    fprintf(stderr, "VALIDATE %s expected=%u bypass=%d result=%s\n", name, expected, bypass, failures ? "inspect-total" : "pass");
}
#define TEST(name, expression, release) do { \
    probe_begin(0, 1); void *p = (expression); escape = p; \
    if (!p) failures++; release; check(name, 1, 0); \
} while (0)
int main(int argc, char **argv) {
    if (argc < 2 || probe_setup(argv[1])) return 21;
    if (argc == 3 && strcmp(argv[2], "--negative-io") == 0) {
        probe_begin(0, 1); void *p = malloc(113); escape = p; free(p);
        probe_test_fail_io(); struct probe_stats failed = probe_end(); report("negative-io", failed);
        fprintf(stderr, "NEGATIVE io-rejected=%d\n", failed.io_errors != 0);
        return failed.io_errors && rejected(failed) ? 0 : 1;
    }
    malloc_zone_t *z = malloc_default_zone();
    TEST("malloc", malloc(113), free(p));
    TEST("calloc", calloc(3, 113), free(p));
    TEST("valloc", valloc(113), free(p));
    TEST("aligned_alloc", aligned_alloc(64, 128), free(p));
    probe_begin(0, 1); void *a = NULL; int rc = posix_memalign(&a, 64, 113); escape = a;
    if (rc) failures++; free(a); check("posix_memalign", 1, 0);
    probe_begin(0, 1); a = malloc(113); escape = a; a = realloc(a, 521); escape = a;
    if (!a) failures++; free(a); check("realloc", 2, 0);
    TEST("zone_malloc", malloc_zone_malloc(z, 113), malloc_zone_free(z, p));
    TEST("zone_calloc", malloc_zone_calloc(z, 3, 113), malloc_zone_free(z, p));
    TEST("zone_valloc", malloc_zone_valloc(z, 113), malloc_zone_free(z, p));
    TEST("zone_memalign", malloc_zone_memalign(z, 64, 113), malloc_zone_free(z, p));
    probe_begin(0, 1); a = malloc_zone_malloc(z, 113); escape = a; a = malloc_zone_realloc(z, a, 521); escape = a;
    if (!a) failures++; malloc_zone_free(z, a); check("zone_realloc", 2, 0);
    TEST("type_malloc", malloc_type_malloc(113, 123), malloc_type_free(p, 123));
    TEST("type_calloc", malloc_type_calloc(3, 113, 123), malloc_type_free(p, 123));
    TEST("type_valloc", malloc_type_valloc(113, 123), malloc_type_free(p, 123));
    TEST("type_aligned_alloc", malloc_type_aligned_alloc(64, 128, 123), malloc_type_free(p, 123));
    probe_begin(0, 1); a = NULL; rc = malloc_type_posix_memalign(&a, 64, 113, 123); escape = a;
    if (rc) failures++; malloc_type_free(a, 123); check("type_posix_memalign", 1, 0);
    probe_begin(0, 1); a = malloc_type_malloc(113, 123); escape = a; a = malloc_type_realloc(a, 521, 123); escape = a;
    if (!a) failures++; malloc_type_free(a, 123); check("type_realloc", 2, 0);
    TEST("type_zone_malloc", malloc_type_zone_malloc(z, 113, 123), malloc_type_zone_free(z, p, 123));
    TEST("type_zone_calloc", malloc_type_zone_calloc(z, 3, 113, 123), malloc_type_zone_free(z, p, 123));
    TEST("type_zone_valloc", malloc_type_zone_valloc(z, 113, 123), malloc_type_zone_free(z, p, 123));
    TEST("type_zone_memalign", malloc_type_zone_memalign(z, 64, 113, 123), malloc_type_zone_free(z, p, 123));
    probe_begin(0, 1); a = malloc_type_zone_malloc(z, 113, 123); escape = a; a = malloc_type_zone_realloc(z, a, 521, 123); escape = a;
    if (!a) failures++; malloc_type_zone_free(z, a, 123); check("type_zone_realloc", 2, 0);
    probe_begin(0, 1); void *batch[3]; unsigned n = malloc_zone_batch_malloc(z, 128, batch, 3);
    if (n != 3) failures++; malloc_zone_batch_free(z, batch, n); check("zone_batch", n, 0);
    /* Deliberately demonstrate whether direct function-table dispatch bypasses hooks. */
    probe_begin(0, 1); a = z->malloc(z, 113); escape = a; z->free(z, a); check("direct_zone_callback", 0, 1);
    /* Cold retained allocation must be included in reuse baseline and freed exactly once. */
    probe_begin(1, 1); a = malloc(113); escape = a; struct probe_stats cold = probe_end();
    probe_begin(2, 0); free(a); struct probe_stats reuse = probe_end();
    if (cold.live_count != 1 || reuse.baseline_count != 1 || reuse.live_count || reuse.frees != 1) failures++;
    report("retained-cold", cold); report("retained-reuse", reuse);
    probe_begin(0, 1); volatile unsigned depth_result = deep_capture(32);
    if (depth_result != 33) failures++; check("deep-capture", 1, 0);
    probe_test_limits(65536, 65536, 2); probe_begin(0, 1);
    depth_result = deep_capture(8); struct probe_stats clipped = probe_end(); report("negative-truncation", clipped);
    if (!clipped.truncated || clipped.bad_chain || clipped.io_errors || !rejected(clipped)) failures++;
    probe_test_limits(1, 65536, 512); probe_begin(0, 1);
    void *first = malloc(113); escape = first; void *second = malloc(117); escape = second; free(first); free(second);
    struct probe_stats full_records = probe_end(); report("negative-record-overflow", full_records);
    if (!full_records.saturated || full_records.allocations != 1 || !rejected(full_records)) failures++;
    probe_test_limits(65536, 1, 512); probe_begin(0, 1);
    first = malloc(113); escape = first; free(first);
    struct probe_stats full_pcs = probe_end(); report("negative-pc-overflow", full_pcs);
    if (!full_pcs.saturated || !rejected(full_pcs)) failures++;
    probe_test_limits(65536, 65536, 512);
    fprintf(stderr, "NEGATIVE truncation-rejected=%d record-overflow-rejected=%d pc-overflow-rejected=%d\n", clipped.truncated != 0, full_records.saturated != 0, full_pcs.saturated != 0);
    /* Start the thread outside the window, so only its allocation/free is tested. */
    pthread_t other; atomic_store(&foreign_gate, 0);
    if (pthread_create(&other, NULL, foreign_allocation, NULL)) return 20;
    probe_begin(0, 1); atomic_store(&foreign_gate, 1);
    while (atomic_load(&foreign_gate) != 2) {}
    struct probe_stats other_stats = probe_end(); pthread_join(other, NULL);
    report("foreign-thread", other_stats);
    if (other_stats.foreign < 2 || other_stats.allocations || other_stats.saturated) failures++;
    fprintf(stderr, "VALIDATION failures=%d\n", failures); return failures != 0;
}
#else
extern uint32_t giftui_rfc014_counter_entry(void *writer);
int main(int argc, char **argv) {
    if (argc < 2 || probe_setup(argv[1])) return 21;
    struct rlimit stack; if (getrlimit(RLIMIT_STACK, &stack)) return 10;
    fprintf(stderr, "HOST rlimit_stack_soft=%llu rlimit_stack_hard=%llu pthread_stack_size=%zu pthread_stack_high=%p\n", stack.rlim_cur, stack.rlim_max, pthread_get_stacksize_np(pthread_self()), pthread_get_stackaddr_np(pthread_self()));
    sigset_t mask; stack_t alternate;
    if (pthread_sigmask(SIG_SETMASK, NULL, &mask) || sigaltstack(NULL, &alternate)) return 13;
    fprintf(stderr, "SIGNALS altstack_flags=%d altstack_size=%zu blocked=", alternate.ss_flags, alternate.ss_size);
    for (int signal_number = 1; signal_number < NSIG; signal_number++) if (sigismember(&mask, signal_number) == 1) fprintf(stderr, "%d,", signal_number);
    fputc('\n', stderr);
    for (int signal_number = 1; signal_number < NSIG; signal_number++) {
        struct sigaction action;
        if (!sigaction(signal_number, NULL, &action)) fprintf(stderr, "SIGNAL number=%d handler=%p flags=%d\n", signal_number, (void *)action.sa_handler, action.sa_flags);
    }
    probe_begin(1, 1);
    uint32_t cold_result = giftui_rfc014_counter_entry(NULL);
    struct probe_stats cold = probe_end();
    /* No report or other workload between these windows; preserve cold live records. */
    probe_begin(2, 0);
    uint32_t reuse_result = giftui_rfc014_counter_entry(NULL);
    struct probe_stats reuse = probe_end();
    fprintf(stderr, "ENTRY cold=%u reuse=%u\n", cold_result, reuse_result);
    report("cold", cold); report("reuse", reuse); probe_report(stderr);
    /* Preserve actual loaded runtime identity, including dyld shared-cache UUIDs. */
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header_64 *h = (const void *)_dyld_get_image_header(i);
        if (h->magic != MH_MAGIC_64) return 12;
        const struct load_command *lc = (const void *)(h + 1);
        fprintf(stderr, "IMAGE base=%p slide=0x%lx path=%s uuid=", (const void *)h, _dyld_get_image_vmaddr_slide(i), _dyld_get_image_name(i));
        for (uint32_t j = 0; j < h->ncmds; j++) {
            if (lc->cmd == LC_UUID) {
                const struct uuid_command *u = (const void *)lc;
                for (unsigned k = 0; k < 16; k++) fprintf(stderr, "%02x", u->uuid[k]);
            }
            lc = (const void *)((const char *)lc + lc->cmdsize);
        }
        fputc('\n', stderr);
    }
    return cold_result == 0 || cold_result != reuse_result || rejected(cold) || rejected(reuse) ? 11 : 0;
}
#endif
