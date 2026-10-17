// Separate diagnostic only; no framework or frozen-object modification.
#include "Probe.h"
#include <dlfcn.h>
#include <malloc/malloc.h>
#include <pthread.h>
#include <ptrauth.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>

#define RECORDS 65536u
#define GROUPS 8192u
#define FRAMES 24u
#define TOMBSTONE ((void *)(uintptr_t)1)
struct record { void *pointer; size_t requested, reserved; unsigned group; };
struct group {
    uintptr_t pc[FRAMES]; unsigned frames, cohort, route;
    uint64_t count, requested, reserved, live_requested, live_reserved, peak_reserved;
};
static struct record records[RECORDS];
static struct group groups[GROUPS];
static unsigned group_count, cohort;
static struct probe_stats stats;
static atomic_int tracking;
static atomic_uint_fast64_t foreign;
static pthread_t owner;
static uintptr_t stack_low, stack_high;
static _Thread_local unsigned depth;

static int enter(void) {
    if (!atomic_load_explicit(&tracking, memory_order_relaxed)) return 0;
    if (pthread_self() != owner) { atomic_fetch_add_explicit(&foreign, 1, memory_order_relaxed); return 0; }
    if (depth++) { stats.nested++; return 2; }
    return 1;
}
static void leave(int active) { if (active) depth--; }
static unsigned capture(uintptr_t *pcs) {
    uintptr_t *fp = __builtin_frame_address(0); unsigned n = 0;
    while (n < FRAMES && (uintptr_t)fp >= stack_low && (uintptr_t)fp + 16 <= stack_high && ((uintptr_t)fp & 15) == 0) {
        uintptr_t pc = (uintptr_t)ptrauth_strip((void *)fp[1], ptrauth_key_return_address);
        if (!pc) break;
        pcs[n++] = pc;
        uintptr_t next = fp[0];
        if (next <= (uintptr_t)fp || next >= stack_high) break;
        fp = (uintptr_t *)next;
    }
    if (n == FRAMES) stats.truncated++;
    return n;
}
static unsigned find_group(unsigned route) {
    uintptr_t pcs[FRAMES] = {0}; unsigned n = capture(pcs);
    for (unsigned i = 0; i < group_count; i++)
        if (groups[i].cohort == cohort && groups[i].route == route && groups[i].frames == n && memcmp(groups[i].pc, pcs, n * sizeof(uintptr_t)) == 0) return i;
    if (group_count == GROUPS) { stats.saturated++; return GROUPS; }
    unsigned i = group_count++;
    groups[i].frames = n; groups[i].cohort = cohort; groups[i].route = route;
    memcpy(groups[i].pc, pcs, n * sizeof(uintptr_t)); return i;
}
static size_t slot(void *p, int insertion) {
    size_t i = (((uintptr_t)p >> 4) * 11400714819323198485ull) & (RECORDS - 1), empty = RECORDS;
    for (size_t k = 0; k < RECORDS; k++, i = (i + 1) & (RECORDS - 1)) {
        if (records[i].pointer == p) return i;
        if (records[i].pointer == TOMBSTONE && empty == RECORDS) empty = i;
        if (!records[i].pointer) return insertion ? (empty == RECORDS ? i : empty) : RECORDS;
    }
    return insertion ? empty : RECORDS;
}
static void add(void *p, size_t request, unsigned route) {
    if (!p) { stats.failures++; return; }
    size_t i = slot(p, 1), reserved = malloc_size(p);
    if (i == RECORDS || (records[i].pointer && records[i].pointer != TOMBSTONE)) { stats.saturated++; return; }
    unsigned g = find_group(route);
    records[i] = (struct record){p, request, reserved, g};
    stats.allocations++; stats.requested_total += request; stats.reserved_total += reserved;
    stats.live_requested += request; stats.live_reserved += reserved; stats.live_count++;
    if (stats.live_requested > stats.peak_requested) stats.peak_requested = stats.live_requested;
    if (stats.live_reserved > stats.peak_reserved) stats.peak_reserved = stats.live_reserved;
    if (stats.live_count > stats.peak_live_count) stats.peak_live_count = stats.live_count;
    if (reserved < request) stats.saturated++;
    else if (stats.live_reserved - stats.live_requested > stats.peak_rounding) stats.peak_rounding = stats.live_reserved - stats.live_requested;
    if (g < GROUPS) {
        groups[g].count++; groups[g].requested += request; groups[g].reserved += reserved;
        groups[g].live_requested += request; groups[g].live_reserved += reserved;
        if (groups[g].live_reserved > groups[g].peak_reserved) groups[g].peak_reserved = groups[g].live_reserved;
    }
}
static void remove_record(void *p) {
    if (!p) return;
    size_t i = slot(p, 0);
    if (i == RECORDS) { stats.unknown_frees++; return; }
    struct record r = records[i];
    stats.frees++; stats.live_requested -= r.requested; stats.live_reserved -= r.reserved; stats.live_count--;
    if (r.group < GROUPS) { groups[r.group].live_requested -= r.requested; groups[r.group].live_reserved -= r.reserved; }
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
void probe_begin(unsigned selected_cohort, int reset) {
    atomic_store(&tracking, 0); owner = pthread_self(); depth = 1;
    stack_high = (uintptr_t)pthread_get_stackaddr_np(owner);
    stack_low = stack_high - pthread_get_stacksize_np(owner);
    uint64_t lr = stats.live_requested, lv = stats.live_reserved, lc = stats.live_count;
    if (reset) { memset(records, 0, sizeof(records)); memset(groups, 0, sizeof(groups)); group_count = 0; lr = lv = lc = 0; }
    stats = (struct probe_stats){.live_requested=lr, .live_reserved=lv, .live_count=lc,
        .peak_requested=lr, .peak_reserved=lv, .peak_live_count=lc,
        .baseline_requested=lr, .baseline_reserved=lv, .baseline_count=lc};
    if (lv >= lr) stats.peak_rounding = lv - lr;
    atomic_store(&foreign, 0); cohort = selected_cohort; depth = 0;
    atomic_store(&tracking, 1);
}
struct probe_stats probe_end(void) {
    atomic_store(&tracking, 0); stats.foreign = atomic_load(&foreign); return stats;
}
void probe_report(FILE *out) {
    fprintf(out, "CONTROL records=%zu groups=%zu globals_min=%zu stack_low=0x%lx stack_high=0x%lx\n", sizeof(records), sizeof(groups), sizeof(records)+sizeof(groups)+sizeof(stats), stack_low, stack_high);
    for (unsigned i = 0; i < group_count; i++) {
        struct group *g = &groups[i];
        fprintf(out, "GROUP %u cohort=%u route=%s count=%llu requested=%llu reserved=%llu live_requested=%llu live_reserved=%llu peak_reserved=%llu frames=%u\n", i, g->cohort, route_names[g->route], g->count, g->requested, g->reserved, g->live_requested, g->live_reserved, g->peak_reserved, g->frames);
        for (unsigned j = 0; j < g->frames; j++) {
            Dl_info d = {0}; dladdr((void *)g->pc[j], &d);
            fprintf(out, "FRAME %u %u pc=0x%lx base=0x%lx offset=0x%lx image=%s symbol=%s\n", i, j, g->pc[j], (uintptr_t)d.dli_fbase, g->pc[j]-(uintptr_t)d.dli_fbase, d.dli_fname ? d.dli_fname : "?", d.dli_sname ? d.dli_sname : "?");
        }
    }
}
