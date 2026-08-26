#include <errno.h>
#include <stddef.h>

void *posix_memalign_stub_result;

int posix_memalign(void **memptr, size_t alignment, size_t size) {
    (void)alignment;
    (void)size;
    *memptr = NULL;
    posix_memalign_stub_result = NULL;
    return ENOMEM;
}
