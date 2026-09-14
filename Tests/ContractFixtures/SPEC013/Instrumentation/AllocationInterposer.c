#include <malloc/malloc.h>
#include <stdint.h>
#include <stdlib.h>

#define GIFTUI_ALLOCATION_RECORD_LIMIT 4096

struct giftui_allocation_record {
    void *pointer;
    size_t requested;
    size_t reserved;
};

static struct giftui_allocation_record giftui_records[GIFTUI_ALLOCATION_RECORD_LIMIT];
static uint64_t giftui_allocation_count;
static uint64_t giftui_live_requested;
static uint64_t giftui_live_reserved;
static uint64_t giftui_peak_reserved;
static uint64_t giftui_peak_bookkeeping;
static uint8_t giftui_tracking;
static uint8_t giftui_saturated;

static void giftui_remove_record(void *pointer) {
    for (size_t index = 0; index < GIFTUI_ALLOCATION_RECORD_LIMIT; index += 1) {
        if (giftui_records[index].pointer != pointer) continue;
        giftui_live_requested -= giftui_records[index].requested;
        giftui_live_reserved -= giftui_records[index].reserved;
        giftui_records[index] = (struct giftui_allocation_record){0};
        return;
    }
}

static void giftui_add_record(void *pointer, size_t requested) {
    if (!giftui_tracking || pointer == NULL) return;
    size_t reserved = malloc_size(pointer);
    for (size_t index = 0; index < GIFTUI_ALLOCATION_RECORD_LIMIT; index += 1) {
        if (giftui_records[index].pointer != NULL) continue;
        giftui_records[index] = (struct giftui_allocation_record){pointer, requested, reserved};
        giftui_allocation_count += 1;
        giftui_live_requested += requested;
        giftui_live_reserved += reserved;
        if (giftui_live_reserved > giftui_peak_reserved) giftui_peak_reserved = giftui_live_reserved;
        uint64_t bookkeeping = giftui_live_reserved - giftui_live_requested;
        if (bookkeeping > giftui_peak_bookkeeping) giftui_peak_bookkeeping = bookkeeping;
        return;
    }
    giftui_saturated = 1;
}

static void *giftui_counting_malloc(size_t size) {
    void *pointer = malloc(size);
    giftui_add_record(pointer, size);
    return pointer;
}

static void *giftui_counting_calloc(size_t count, size_t size) {
    void *pointer = calloc(count, size);
    giftui_add_record(pointer, count * size);
    return pointer;
}

static void *giftui_counting_realloc(void *pointer, size_t size) {
    void *replacement = realloc(pointer, size);
    if (replacement == NULL) return NULL;
    if (giftui_tracking && pointer != NULL) giftui_remove_record(pointer);
    giftui_add_record(replacement, size);
    return replacement;
}

static void giftui_counting_free(void *pointer) {
    if (giftui_tracking && pointer != NULL) giftui_remove_record(pointer);
    free(pointer);
}

#define DYLD_INTERPOSE(replacement, replacee)                                      \
    __attribute__((used)) static struct {                                          \
        const void *replacement;                                                   \
        const void *replacee;                                                       \
    } interpose_##replacee __attribute__((section("__DATA,__interpose"))) = {      \
        (const void *)(uintptr_t)&replacement,                                     \
        (const void *)(uintptr_t)&replacee                                         \
    }

DYLD_INTERPOSE(giftui_counting_malloc, malloc);
DYLD_INTERPOSE(giftui_counting_calloc, calloc);
DYLD_INTERPOSE(giftui_counting_realloc, realloc);
DYLD_INTERPOSE(giftui_counting_free, free);

void giftui_allocation_probe_begin(void) {
    for (size_t index = 0; index < GIFTUI_ALLOCATION_RECORD_LIMIT; index += 1) {
        giftui_records[index] = (struct giftui_allocation_record){0};
    }
    giftui_allocation_count = 0;
    giftui_live_requested = 0;
    giftui_live_reserved = 0;
    giftui_peak_reserved = 0;
    giftui_peak_bookkeeping = 0;
    giftui_saturated = 0;
    giftui_tracking = 1;
}

void giftui_allocation_probe_end(void) { giftui_tracking = 0; }
uint64_t giftui_allocation_probe_count(void) { return giftui_allocation_count; }
uint64_t giftui_allocation_probe_peak_bytes(void) { return giftui_peak_reserved; }
uint64_t giftui_allocation_probe_bookkeeping_bytes(void) { return giftui_peak_bookkeeping; }
uint8_t giftui_allocation_probe_saturated(void) { return giftui_saturated; }
