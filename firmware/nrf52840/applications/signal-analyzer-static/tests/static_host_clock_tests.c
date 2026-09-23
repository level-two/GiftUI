#include "static_host_clock.h"

#include <assert.h>
#include <errno.h>
#include <stddef.h>
#include <stdint.h>

static int64_t uptime_milliseconds;

int64_t k_uptime_get(void)
{
    return uptime_milliseconds;
}

int main(void)
{
    uint64_t microseconds = 7U;
    assert(giftui_static_host_clock_now(NULL) == -EINVAL);
    assert(microseconds == 7U);

    uptime_milliseconds = 250;
    assert(giftui_static_host_clock_now(&microseconds) == 0);
    assert(microseconds == 250000U);

    uptime_milliseconds = -1;
    assert(giftui_static_host_clock_now(&microseconds) == -ERANGE);
    assert(microseconds == 250000U);

    uptime_milliseconds = (int64_t)(UINT64_MAX / 1000U) + 1;
    assert(giftui_static_host_clock_now(&microseconds) == -ERANGE);
    assert(microseconds == 250000U);
    return 0;
}
