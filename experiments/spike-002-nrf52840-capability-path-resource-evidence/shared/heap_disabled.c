#include <errno.h>
#include <stddef.h>

int posix_memalign(void **memory, size_t alignment, size_t size)
{
    (void)alignment;
    (void)size;
    if (memory != NULL) {
        *memory = NULL;
    }
    return ENOMEM;
}
