#include <errno.h>
#include <stddef.h>

/* Embedded Swift references this ABI entry point even when its retained code
 * is allocation-free. Keep the symbol fail-closed without linking an allocator.
 */
int posix_memalign(void **memptr, size_t alignment, size_t size)
{
    (void)alignment;
    (void)size;
    if (memptr != NULL) {
        *memptr = NULL;
    }
    return ENOMEM;
}
