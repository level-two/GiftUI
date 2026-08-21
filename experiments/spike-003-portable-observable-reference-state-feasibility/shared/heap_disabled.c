#include <errno.h>
#include <stddef.h>

// Satisfy the Swift runtime's alignment probe without retaining an allocator.
// The final ELF is separately rejected if allocator entry points survive GC.
int posix_memalign(void **memory, size_t alignment, size_t size) {
    (void)alignment;
    (void)size;
    if (memory != NULL) *memory = NULL;
    return ENOMEM;
}
