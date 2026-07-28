#include <errno.h>
#include <stdlib.h>

int posix_memalign(void **memptr, size_t alignment, size_t size)
{
    void *allocation = aligned_alloc(alignment, size);
    if (allocation == NULL) {
        return errno == 0 ? ENOMEM : errno;
    }
    *memptr = allocation;
    return 0;
}
