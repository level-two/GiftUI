// Diagnostic-only, exact event trace. No framework/frozen-object modification.
#include "Probe.h"
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <malloc/malloc.h>
#include <pthread.h>
#include <ptrauth.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define RECORDS 65536u
#define PCS 65536u
#define FRAMES 512u
#define BUFFER 65536u
#define TOMBSTONE ((void *)(uintptr_t)1)
struct record { void *pointer; size_t requested, reserved; uint64_t allocation; };
/* All fields are native little-endian uint64; allocation records append tag&0xffff PCs.
   kind 1=begin, 2=allocation, 3=retirement, 4=end. Allocation tag:
   low16=frame count, next16=route, high32=capture status (0=root,1=limit,2=bad chain).
   Retirement tag is the original allocation sequence. */
struct event { uint64_t kind, window, cohort, sequence, pointer, requested, reserved, tag; };
_Static_assert(sizeof(struct event) == 64, "event format");
static struct record records[RECORDS];
static uintptr_t pc_table[PCS];
static unsigned char buffer[BUFFER];
static unsigned record_limit = RECORDS, pc_limit = PCS, frame_limit = FRAMES;
static size_t buffered;
static uint64_t sequence, window, cohort, event_bytes;
static int trace_fd = -1, stream_failed;
static struct probe_stats stats;
static atomic_int tracking;
static atomic_uint_fast64_t foreign;
static pthread_t owner;
static uintptr_t stack_low, stack_high, driver_frame;
static _Thread_local unsigned depth;

static void flush(void) {
    size_t written = 0;
    while (!stream_failed && written < buffered) {
        ssize_t n = write(trace_fd, buffer + written, buffered - written);
        if (n > 0) { written += (size_t)n; event_bytes += (uint64_t)n; }
        else if (n < 0 && errno == EINTR) continue;
        else { stats.io_errors++; stream_failed = 1; }
    }
    buffered = 0;
}
static void emit(const void *source, size_t count) {
    const unsigned char *bytes = source;
    while (!stream_failed && count) {
        size_t room = BUFFER - buffered, n = count < room ? count : room;
        memcpy(buffer + buffered, bytes, n); buffered += n; bytes += n; count -= n;
        if (buffered == BUFFER) flush();
    }
}
int probe_setup(const char *path) {
    trace_fd = open(path, O_WRONLY | O_CREAT | O_EXCL, 0600);
    if (trace_fd < 0) return -1;
    const unsigned char magic[8] = {'P','0','8','A','L','L','O','1'};
    emit(magic, sizeof(magic)); return 0;
}
static int enter(void) {
    if (!atomic_load_explicit(&tracking, memory_order_relaxed)) return 0;
    if (pthread_self() != owner) { atomic_fetch_add_explicit(&foreign, 1, memory_order_relaxed); return 0; }
    if (depth++) { stats.nested++; return 2; }
    return 1;
}
static void leave(int active) { if (active) depth--; }
static void intern_pc(uintptr_t pc) {
    size_t i = ((pc >> 2) * 11400714819323198485ull) & (pc_limit - 1);
    for (size_t k = 0; k < pc_limit; k++, i = (i + 1) & (pc_limit - 1)) {
        if (pc_table[i] == pc) return;
        if (!pc_table[i]) { pc_table[i] = pc; return; }
    }
    stats.saturated++;
}
static unsigned capture(uintptr_t *pcs, unsigned *status) {
    uintptr_t *fp = __builtin_frame_address(0); unsigned n = 0;
    *status = 2;
    while (n < frame_limit && (uintptr_t)fp >= stack_low && (uintptr_t)fp + 16 <= stack_high && ((uintptr_t)fp & 15) == 0) {
        uintptr_t pc = (uintptr_t)ptrauth_strip((void *)fp[1], ptrauth_key_return_address);
        if (!pc) break;
        pcs[n++] = pc; intern_pc(pc);
        if ((uintptr_t)fp == driver_frame) { *status = 0; return n; }
        uintptr_t next = fp[0];
        if (next <= (uintptr_t)fp || next > driver_frame) break;
        fp = (uintptr_t *)next;
    }
    if (n == frame_limit) { stats.truncated++; *status = 1; }
    else stats.bad_chain++;
    return n;
}
static size_t slot(void *p, int insertion) {
    size_t i = (((uintptr_t)p >> 4) * 11400714819323198485ull) & (record_limit - 1), empty = record_limit;
    for (size_t k = 0; k < record_limit; k++, i = (i + 1) & (record_limit - 1)) {
        if (records[i].pointer == p) return i;
        if (records[i].pointer == TOMBSTONE && empty == record_limit) empty = i;
        if (!records[i].pointer) return insertion ? (empty == record_limit ? i : empty) : record_limit;
    }
    return insertion ? empty : record_limit;
}
static void add(void *p, size_t request, unsigned route) {
    if (!p) { stats.failures++; return; }
    size_t i = slot(p, 1), reserved = malloc_size(p);
    if (i == record_limit || (records[i].pointer && records[i].pointer != TOMBSTONE)) { stats.saturated++; return; }
    uintptr_t pcs[FRAMES]; unsigned status; unsigned n = capture(pcs, &status);
    struct event e = {2, window, cohort, ++sequence, (uintptr_t)p, request, reserved,
        (uint64_t)n | ((uint64_t)route << 16) | ((uint64_t)status << 32)};
    emit(&e, sizeof(e)); emit(pcs, n * sizeof(uintptr_t));
    records[i] = (struct record){p, request, reserved, e.sequence};
    stats.allocations++; stats.requested_total += request; stats.reserved_total += reserved;
    stats.live_requested += request; stats.live_reserved += reserved; stats.live_count++;
    if (stats.live_requested > stats.peak_requested) stats.peak_requested = stats.live_requested;
    if (stats.live_reserved > stats.peak_reserved) stats.peak_reserved = stats.live_reserved;
    if (stats.live_count > stats.peak_live_count) stats.peak_live_count = stats.live_count;
    if (reserved < request) stats.saturated++;
    else if (stats.live_reserved - stats.live_requested > stats.peak_rounding) stats.peak_rounding = stats.live_reserved - stats.live_requested;
}
static void remove_record(void *p) {
    if (!p) return;
    size_t i = slot(p, 0);
    if (i == record_limit) { stats.unknown_frees++; return; }
    struct record r = records[i];
    struct event e = {3, window, cohort, ++sequence, (uintptr_t)p, r.requested, r.reserved, r.allocation};
    emit(&e, sizeof(e));
    stats.frees++; stats.live_requested -= r.requested; stats.live_reserved -= r.reserved; stats.live_count--;
    records[i] = (struct record){.pointer = TOMBSTONE};
}
#define INTERPOSE(fn) __attribute__((used)) static const struct { const void *replacement, *replacee; } interpose_##fn __attribute__((section("__DATA,__interpose"))) = {(const void *)(uintptr_t)&observe_##fn, (const void *)(uintptr_t)&fn}
static __attribute__((noinline)) void *observe_malloc(size_t size) {
    int a = enter(); void *p = malloc(size);
    if (a == 1) add(p, size, 0); leave(a); return p;
}
INTERPOSE(malloc);
static __attribute__((noinline)) void *observe_calloc(size_t count, size_t size) {
    int a = enter(); void *p = calloc(count, size);
    if (a == 1) add(p, count * size, 1); leave(a); return p;
}
INTERPOSE(calloc);
static __attribute__((noinline)) void *observe_valloc(size_t size) {
    int a = enter(); void *p = valloc(size);
    if (a == 1) add(p, size, 2); leave(a); return p;
}
INTERPOSE(valloc);
static __attribute__((noinline)) void *observe_aligned_alloc(size_t alignment, size_t size) {
    int a = enter(); void *p = aligned_alloc(alignment, size);
    if (a == 1) add(p, size, 3); leave(a); return p;
}
INTERPOSE(aligned_alloc);
static __attribute__((noinline)) void *observe_realloc(void *p, size_t size) {
    int a = enter(); void *q = realloc(p, size);
    /* Darwin realloc(p, 0) frees p and returns a new minimum-size allocation on success. */
    if (a == 1) { if (q) { remove_record(p); add(q, size, 4); } else stats.failures++; }
    leave(a); return q;
}
INTERPOSE(realloc);
static __attribute__((noinline)) void observe_free(void *p) {
    int a = enter(); if (a == 1) remove_record(p); free(p); leave(a);
}
INTERPOSE(free);
static __attribute__((noinline)) int observe_posix_memalign(void **result, size_t alignment, size_t size) {
    int a = enter(); int rc = posix_memalign(result, alignment, size);
    if (a == 1) { if (!rc) add(*result, size, 6); else stats.failures++; } leave(a); return rc;
}
INTERPOSE(posix_memalign);
static __attribute__((noinline)) void *observe_malloc_zone_malloc(malloc_zone_t *zone, size_t size) {
    int a = enter(); void *p = malloc_zone_malloc(zone, size);
    if (a == 1) add(p, size, 7); leave(a); return p;
}
INTERPOSE(malloc_zone_malloc);
static __attribute__((noinline)) void *observe_malloc_zone_calloc(malloc_zone_t *zone, size_t count, size_t size) {
    int a = enter(); void *p = malloc_zone_calloc(zone, count, size);
    if (a == 1) add(p, count * size, 8); leave(a); return p;
}
INTERPOSE(malloc_zone_calloc);
static __attribute__((noinline)) void *observe_malloc_zone_valloc(malloc_zone_t *zone, size_t size) {
    int a = enter(); void *p = malloc_zone_valloc(zone, size);
    if (a == 1) add(p, size, 9); leave(a); return p;
}
INTERPOSE(malloc_zone_valloc);
static __attribute__((noinline)) void *observe_malloc_zone_memalign(malloc_zone_t *zone, size_t alignment, size_t size) {
    int a = enter(); void *p = malloc_zone_memalign(zone, alignment, size);
    if (a == 1) add(p, size, 10); leave(a); return p;
}
INTERPOSE(malloc_zone_memalign);
static __attribute__((noinline)) void *observe_malloc_zone_realloc(malloc_zone_t *zone, void *p, size_t size) {
    int a = enter(); void *q = malloc_zone_realloc(zone, p, size);
    /* Darwin realloc(p, 0) frees p and returns a new minimum-size allocation on success. */
    if (a == 1) { if (q) { remove_record(p); add(q, size, 11); } else stats.failures++; }
    leave(a); return q;
}
INTERPOSE(malloc_zone_realloc);
static __attribute__((noinline)) void observe_malloc_zone_free(malloc_zone_t *zone, void *p) {
    int a = enter(); if (a == 1) remove_record(p); malloc_zone_free(zone, p); leave(a);
}
INTERPOSE(malloc_zone_free);
static __attribute__((noinline)) void *observe_malloc_type_malloc(size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_malloc(size, type);
    if (a == 1) add(p, size, 13); leave(a); return p;
}
INTERPOSE(malloc_type_malloc);
static __attribute__((noinline)) void *observe_malloc_type_calloc(size_t count, size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_calloc(count, size, type);
    if (a == 1) add(p, count * size, 14); leave(a); return p;
}
INTERPOSE(malloc_type_calloc);
static __attribute__((noinline)) void *observe_malloc_type_valloc(size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_valloc(size, type);
    if (a == 1) add(p, size, 15); leave(a); return p;
}
INTERPOSE(malloc_type_valloc);
static __attribute__((noinline)) void *observe_malloc_type_aligned_alloc(size_t alignment, size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_aligned_alloc(alignment, size, type);
    if (a == 1) add(p, size, 16); leave(a); return p;
}
INTERPOSE(malloc_type_aligned_alloc);
static __attribute__((noinline)) void *observe_malloc_type_realloc(void *p, size_t size, malloc_type_id_t type) {
    int a = enter(); void *q = malloc_type_realloc(p, size, type);
    /* Darwin realloc(p, 0) frees p and returns a new minimum-size allocation on success. */
    if (a == 1) { if (q) { remove_record(p); add(q, size, 17); } else stats.failures++; }
    leave(a); return q;
}
INTERPOSE(malloc_type_realloc);
static __attribute__((noinline)) void observe_malloc_type_free(void *p, malloc_type_id_t type) {
    int a = enter(); if (a == 1) remove_record(p); malloc_type_free(p, type); leave(a);
}
INTERPOSE(malloc_type_free);
static __attribute__((noinline)) int observe_malloc_type_posix_memalign(void **result, size_t alignment, size_t size, malloc_type_id_t type) {
    int a = enter(); int rc = malloc_type_posix_memalign(result, alignment, size, type);
    if (a == 1) { if (!rc) add(*result, size, 19); else stats.failures++; } leave(a); return rc;
}
INTERPOSE(malloc_type_posix_memalign);
static __attribute__((noinline)) void *observe_malloc_type_zone_malloc(malloc_zone_t *zone, size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_zone_malloc(zone, size, type);
    if (a == 1) add(p, size, 20); leave(a); return p;
}
INTERPOSE(malloc_type_zone_malloc);
static __attribute__((noinline)) void *observe_malloc_type_zone_calloc(malloc_zone_t *zone, size_t count, size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_zone_calloc(zone, count, size, type);
    if (a == 1) add(p, count * size, 21); leave(a); return p;
}
INTERPOSE(malloc_type_zone_calloc);
static __attribute__((noinline)) void *observe_malloc_type_zone_valloc(malloc_zone_t *zone, size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_zone_valloc(zone, size, type);
    if (a == 1) add(p, size, 22); leave(a); return p;
}
INTERPOSE(malloc_type_zone_valloc);
static __attribute__((noinline)) void *observe_malloc_type_zone_memalign(malloc_zone_t *zone, size_t alignment, size_t size, malloc_type_id_t type) {
    int a = enter(); void *p = malloc_type_zone_memalign(zone, alignment, size, type);
    if (a == 1) add(p, size, 23); leave(a); return p;
}
INTERPOSE(malloc_type_zone_memalign);
static __attribute__((noinline)) void *observe_malloc_type_zone_realloc(malloc_zone_t *zone, void *p, size_t size, malloc_type_id_t type) {
    int a = enter(); void *q = malloc_type_zone_realloc(zone, p, size, type);
    /* Darwin realloc(p, 0) frees p and returns a new minimum-size allocation on success. */
    if (a == 1) { if (q) { remove_record(p); add(q, size, 24); } else stats.failures++; }
    leave(a); return q;
}
INTERPOSE(malloc_type_zone_realloc);
static __attribute__((noinline)) void observe_malloc_type_zone_free(malloc_zone_t *zone, void *p, malloc_type_id_t type) {
    int a = enter(); if (a == 1) remove_record(p); malloc_type_zone_free(zone, p, type); leave(a);
}
INTERPOSE(malloc_type_zone_free);
static unsigned observe_malloc_zone_batch_malloc(malloc_zone_t *zone, size_t size, void **results, unsigned count) {
    int a = enter(); unsigned n = malloc_zone_batch_malloc(zone, size, results, count);
    if (a == 1) for (unsigned i = 0; i < n; i++) add(results[i], size, 26);
    leave(a); return n;
}
INTERPOSE(malloc_zone_batch_malloc);
static void observe_malloc_zone_batch_free(malloc_zone_t *zone, void **pointers, unsigned count) {
    int a = enter(); if (a == 1) for (unsigned i = 0; i < count; i++) remove_record(pointers[i]);
    malloc_zone_batch_free(zone, pointers, count); leave(a);
}
INTERPOSE(malloc_zone_batch_free);
static const char *route_names[] = {"malloc", "calloc", "valloc", "aligned_alloc", "realloc", "free", "posix_memalign", "malloc_zone_malloc", "malloc_zone_calloc", "malloc_zone_valloc", "malloc_zone_memalign", "malloc_zone_realloc", "malloc_zone_free", "malloc_type_malloc", "malloc_type_calloc", "malloc_type_valloc", "malloc_type_aligned_alloc", "malloc_type_realloc", "malloc_type_free", "malloc_type_posix_memalign", "malloc_type_zone_malloc", "malloc_type_zone_calloc", "malloc_type_zone_valloc", "malloc_type_zone_memalign", "malloc_type_zone_realloc", "malloc_type_zone_free", "malloc_zone_batch_malloc"};
void __attribute__((noinline)) probe_begin(unsigned selected_cohort, int reset) {
    atomic_store(&tracking, 0); owner = pthread_self(); depth = 1;
    stack_high = (uintptr_t)pthread_get_stackaddr_np(owner);
    stack_low = stack_high - pthread_get_stacksize_np(owner);
    driver_frame = ((uintptr_t *)__builtin_frame_address(0))[0];
    uint64_t lr = stats.live_requested, lv = stats.live_reserved, lc = stats.live_count;
    if (reset) { memset(records, 0, sizeof(records)); lr = lv = lc = 0; }
    stats = (struct probe_stats){.live_requested=lr, .live_reserved=lv, .live_count=lc,
        .peak_requested=lr, .peak_reserved=lv, .peak_live_count=lc,
        .baseline_requested=lr, .baseline_reserved=lv, .baseline_count=lc};
    if (stream_failed) stats.io_errors++;
    if (lv >= lr) stats.peak_rounding = lv - lr;
    atomic_store(&foreign, 0); cohort = selected_cohort; window++;
    struct event e = {1, window, cohort, ++sequence, driver_frame, lr, lv, lc};
    emit(&e, sizeof(e)); depth = 0; atomic_store(&tracking, 1);
}
struct probe_stats probe_end(void) {
    atomic_store(&tracking, 0); stats.foreign = atomic_load(&foreign);
    struct event e = {4, window, cohort, ++sequence, stats.allocations, stats.live_requested, stats.live_reserved, stats.live_count};
    emit(&e, sizeof(e)); flush(); return stats;
}
/* Diagnostic negative controls only. Production driver never calls these. */
void probe_test_limits(unsigned record_count, unsigned pc_count, unsigned frames) {
    if (atomic_load(&tracking) || !record_count || record_count > RECORDS || (record_count & (record_count-1)) ||
        !pc_count || pc_count > PCS || (pc_count & (pc_count-1)) || !frames || frames > FRAMES) abort();
    record_limit = record_count; pc_limit = pc_count; frame_limit = frames;
    memset(pc_table, 0, sizeof(pc_table));
}
void probe_test_fail_io(void) { if (trace_fd >= 0) close(trace_fd); }
void probe_report(FILE *out) {
    fprintf(out, "CONTROL records=%zu pc_table=%zu event_buffer=%zu globals_min=%zu capture_local_max=%zu stack_low=0x%lx stack_high=0x%lx driver_frame=0x%lx event_bytes=%llu\n", sizeof(records), sizeof(pc_table), sizeof(buffer), sizeof(records)+sizeof(pc_table)+sizeof(buffer)+sizeof(stats), (size_t)FRAMES*sizeof(uintptr_t), stack_low, stack_high, driver_frame, event_bytes);
    for (unsigned i = 0; i < sizeof(route_names)/sizeof(route_names[0]); i++) fprintf(out, "ROUTE %u %s\n", i, route_names[i]);
    for (unsigned i = 0; i < PCS; i++) if (pc_table[i]) {
        Dl_info d = {0}; dladdr((void *)pc_table[i], &d);
        fprintf(out, "PC pc=0x%lx base=0x%lx offset=0x%lx image=%s symbol=%s\n", pc_table[i], (uintptr_t)d.dli_fbase, pc_table[i]-(uintptr_t)d.dli_fbase, d.dli_fname ? d.dli_fname : "?", d.dli_sname ? d.dli_sname : "?");
    }
}
