#include <stdint.h>

/* Named, fixed-size retained storage makes the capability path attributable
 * in ELF/map evidence. None of these records has dynamic extent. */
volatile uint32_t spike002_validation_storage[4];
volatile uint32_t spike002_effective_snapshot[8];
volatile uint32_t spike002_path_trace[8];

void spike002_store_result(uint32_t available,
                           uint32_t reason,
                           uint32_t width,
                           uint32_t height,
                           uint32_t tile_bytes,
                           uint32_t staging_bytes,
                           uint32_t trace,
                           uint32_t counters)
{
    spike002_validation_storage[0] = available;
    spike002_validation_storage[1] = reason;
    spike002_validation_storage[2] = trace;
    spike002_validation_storage[3] = counters;
    spike002_effective_snapshot[0] = width;
    spike002_effective_snapshot[1] = height;
    spike002_effective_snapshot[2] = tile_bytes;
    spike002_effective_snapshot[3] = staging_bytes;
}

uint32_t spike002_read_snapshot(void)
{
    return spike002_effective_snapshot[0] ^
           (spike002_effective_snapshot[1] << 16) ^
           spike002_effective_snapshot[2] ^
           spike002_effective_snapshot[3];
}

#define DEFINE_PATH_STORE(index)                                             \
    void spike002_store_path##index(uint32_t trace, uint32_t counters)        \
    {                                                                         \
        spike002_path_trace[index] = trace ^ counters;                        \
    }

DEFINE_PATH_STORE(0)
DEFINE_PATH_STORE(1)
DEFINE_PATH_STORE(2)
DEFINE_PATH_STORE(3)
DEFINE_PATH_STORE(4)
DEFINE_PATH_STORE(5)
DEFINE_PATH_STORE(6)
