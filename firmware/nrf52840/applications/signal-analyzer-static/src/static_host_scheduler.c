#include "static_host_scheduler.h"

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

#define GIFTUI_STATIC_WAIT_SLICE_MICROSECONDS 1000U

__attribute__((used, retain))
int giftui_static_host_wait_until(
    uint64_t deadline_microseconds,
    const struct giftui_static_host_scheduler_hal *hal)
{
    if (hal == NULL || hal->now_microseconds == NULL ||
        hal->wait_microseconds == NULL) {
        return -EINVAL;
    }

    uint64_t previous = 0U;
    int has_previous = 0;
    for (;;) {
        uint64_t now = 0U;
        const int clock_result = hal->now_microseconds(&now);
        if (clock_result != 0) {
            return clock_result;
        }
        if (has_previous && now < previous) {
            return -ERANGE;
        }
        if (now >= deadline_microseconds) {
            return 0;
        }
        previous = now;
        has_previous = 1;

        if (hal->service_watchdog != NULL) {
            const int watchdog_result = hal->service_watchdog();
            if (watchdog_result != 0) {
                return watchdog_result;
            }
        }
        const uint64_t remaining = deadline_microseconds - now;
        const uint32_t slice =
            remaining > GIFTUI_STATIC_WAIT_SLICE_MICROSECONDS
                ? GIFTUI_STATIC_WAIT_SLICE_MICROSECONDS
                : (uint32_t)remaining;
        hal->wait_microseconds(slice);
    }
}
