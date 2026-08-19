#include <stdint.h>
#include <stdio.h>

static uint32_t path_traces[8];
static uint32_t path_counters[8];
static uint32_t snapshot[4];

void spike002_store_result(uint32_t available, uint32_t reason,
                           uint32_t width, uint32_t height,
                           uint32_t tile_bytes, uint32_t staging_bytes,
                           uint32_t trace, uint32_t counters)
{
    snapshot[0] = width;
    snapshot[1] = height;
    snapshot[2] = tile_bytes;
    snapshot[3] = staging_bytes;
    printf("RESULT\t%u\t%u\t%u\t%u\t%u\t%u\t%u\t%u\n",
           available, reason, width, height, tile_bytes, staging_bytes,
           trace, counters);
}

uint32_t spike002_read_snapshot(void)
{
    return snapshot[0] ^ (snapshot[1] << 16) ^ snapshot[2] ^ snapshot[3];
}

#define DEFINE_PATH_STORE(index)                                             \
    void spike002_store_path##index(uint32_t trace, uint32_t counters)        \
    {                                                                         \
        path_traces[index] = trace;                                           \
        path_counters[index] = counters;                                      \
    }

DEFINE_PATH_STORE(0)
DEFINE_PATH_STORE(1)
DEFINE_PATH_STORE(2)
DEFINE_PATH_STORE(3)
DEFINE_PATH_STORE(4)
DEFINE_PATH_STORE(5)
DEFINE_PATH_STORE(6)

void spike002_print_paths(void)
{
    for (uint32_t path = 0; path < 7U; ++path) {
        uint32_t value = path_counters[path];
        printf("PATH\t%u\t%u\t%u\t%u\t%u\t%u\t%u\n", path,
               path_traces[path], value & 31U, (value >> 5) & 63U,
               (value >> 11) & 63U, (value >> 17) & 15U,
               (value >> 21) & 15U);
    }
}
