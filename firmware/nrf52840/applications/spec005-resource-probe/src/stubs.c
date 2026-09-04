#include <stdlib.h>

int posix_memalign(void **memptr, size_t alignment, size_t size)
{
    (void)memptr;
    (void)alignment;
    (void)size;
    return 12;
}
