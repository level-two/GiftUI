#include <stdint.h>
#include <stdlib.h>

static uint64_t giftui_allocation_count = 0;

static void *giftui_counting_malloc(size_t size) {
    giftui_allocation_count += 1;
    return malloc(size);
}

static void *giftui_counting_calloc(size_t count, size_t size) {
    giftui_allocation_count += 1;
    return calloc(count, size);
}

static void *giftui_counting_realloc(void *pointer, size_t size) {
    giftui_allocation_count += 1;
    return realloc(pointer, size);
}

#define DYLD_INTERPOSE(replacement, replacee)                                      \
    __attribute__((used)) static struct {                                          \
        const void *replacement;                                                   \
        const void *replacee;                                                      \
    } interpose_##replacee __attribute__((section("__DATA,__interpose"))) = {      \
        (const void *)(uintptr_t)&replacement,                                     \
        (const void *)(uintptr_t)&replacee                                         \
    }

DYLD_INTERPOSE(giftui_counting_malloc, malloc);
DYLD_INTERPOSE(giftui_counting_calloc, calloc);
DYLD_INTERPOSE(giftui_counting_realloc, realloc);

void giftui_allocation_probe_reset(void) {
    giftui_allocation_count = 0;
}

uint64_t giftui_allocation_probe_read(void) {
    return giftui_allocation_count;
}
