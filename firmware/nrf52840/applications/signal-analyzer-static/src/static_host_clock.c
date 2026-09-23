#include "static_host_clock.h"

#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <zephyr/kernel.h>

int giftui_static_host_clock_now(uint64_t *timestamp_microseconds)
{
    if (timestamp_microseconds == NULL) {
        return -EINVAL;
    }
    const int64_t milliseconds = k_uptime_get();
    if (milliseconds < 0 || (uint64_t)milliseconds > UINT64_MAX / 1000U) {
        return -ERANGE;
    }
    *timestamp_microseconds = (uint64_t)milliseconds * 1000U;
    return 0;
}
