#include <errno.h>
#include <stddef.h>

int posix_memalign(void **memptr, size_t alignment, size_t size)
{
    (void)alignment;
    (void)size;
    if (memptr != NULL) {
        *memptr = NULL;
    }
    return ENOMEM;
}
