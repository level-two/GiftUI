#include "static_host_scheduler.h"

#include <assert.h>
#include <errno.h>
#include <stdint.h>

static uint64_t clock_value;
static uint32_t wait_calls;
static uint32_t watchdog_calls;
static uint32_t longest_wait;
static int clock_failure;
static int watchdog_failure;
static int regress_clock;

static int read_clock(uint64_t *timestamp)
{
    if (clock_failure != 0) {
        return clock_failure;
    }
    *timestamp = regress_clock && wait_calls != 0U
        ? 0U : clock_value;
    return 0;
}

static void wait_slice(uint32_t duration)
{
    assert(duration > 0U);
    if (duration > longest_wait) {
        longest_wait = duration;
    }
    clock_value += duration;
    ++wait_calls;
}

static int feed_watchdog(void)
{
    ++watchdog_calls;
    return watchdog_failure;
}

static void reset(void)
{
    clock_value = 100U;
    wait_calls = 0U;
    watchdog_calls = 0U;
    longest_wait = 0U;
    clock_failure = 0;
    watchdog_failure = 0;
    regress_clock = 0;
}

int main(void)
{
    const struct giftui_static_host_scheduler_hal hal = {
        .now_microseconds = read_clock,
        .wait_microseconds = wait_slice,
        .service_watchdog = feed_watchdog,
    };
    reset();
    assert(giftui_static_host_wait_until(100U, &hal) == 0);
    assert(wait_calls == 0U && watchdog_calls == 0U);

    reset();
    assert(giftui_static_host_wait_until(2601U, &hal) == 0);
    assert(clock_value == 2601U);
    assert(wait_calls == 3U && watchdog_calls == 3U);
    assert(longest_wait == 1000U);

    reset();
    watchdog_failure = -EIO;
    assert(giftui_static_host_wait_until(1100U, &hal) == -EIO);
    assert(wait_calls == 0U && watchdog_calls == 1U);

    reset();
    clock_failure = -ENODEV;
    assert(giftui_static_host_wait_until(1100U, &hal) == -ENODEV);
    assert(wait_calls == 0U && watchdog_calls == 0U);

    reset();
    regress_clock = 1;
    assert(giftui_static_host_wait_until(2100U, &hal) == -ERANGE);
    assert(wait_calls == 1U && watchdog_calls == 1U);

    reset();
    const struct giftui_static_host_scheduler_hal no_watchdog = {
        .now_microseconds = read_clock,
        .wait_microseconds = wait_slice,
        .service_watchdog = 0,
    };
    assert(giftui_static_host_wait_until(1100U, &no_watchdog) == 0);
    assert(wait_calls == 1U && watchdog_calls == 0U);

    assert(giftui_static_host_wait_until(0U, 0) == -EINVAL);
    const struct giftui_static_host_scheduler_hal invalid = {0};
    assert(giftui_static_host_wait_until(0U, &invalid) == -EINVAL);
    return 0;
}
