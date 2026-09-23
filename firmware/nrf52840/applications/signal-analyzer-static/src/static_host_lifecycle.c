#include "static_host_lifecycle.h"

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

__attribute__((used, retain))
int giftui_static_host_run(
    const struct giftui_static_host_lifecycle_hal *hal,
    const struct giftui_static_host_application *application)
{
    if (hal == NULL || application == NULL ||
        hal->touch_initialize == NULL || hal->display_initialize == NULL ||
        hal->touch_poll == NULL || hal->display_shutdown == NULL ||
        hal->touch_shutdown == NULL ||
        hal->scheduler.now_microseconds == NULL ||
        hal->scheduler.wait_microseconds == NULL ||
        application->validate == NULL || application->activate == NULL ||
        application->service == NULL || application->teardown == NULL) {
        return -EINVAL;
    }

    int result = application->validate();
    if (result != 0) {
        return result;
    }
    int touch_initialized = 0;
    int display_initialized = 0;
    int application_entered = 0;

    result = hal->touch_initialize();
    if (result != 0) {
        goto cleanup;
    }
    touch_initialized = 1;
    result = hal->display_initialize();
    if (result != 0) {
        goto cleanup;
    }
    display_initialized = 1;
    application_entered = 1;
    result = application->activate();
    if (result != 0) {
        goto cleanup;
    }

    for (;;) {
        result = hal->touch_poll();
        if (result != 0) {
            break;
        }
        uint64_t now = 0U;
        result = hal->scheduler.now_microseconds(&now);
        if (result != 0) {
            break;
        }
        uint64_t deadline = 0U;
        int stop = 0;
        result = application->service(now, &deadline, &stop);
        if (result != 0 || stop != 0) {
            break;
        }
        if (deadline <= now) {
            result = -ERANGE;
            break;
        }
        result = giftui_static_host_wait_until(deadline, &hal->scheduler);
        if (result != 0) {
            break;
        }
    }

cleanup:
    if (application_entered) {
        const int teardown_result = application->teardown();
        if (result == 0) {
            result = teardown_result;
        }
    }
    if (display_initialized) {
        const int shutdown_result = hal->display_shutdown();
        if (result == 0) {
            result = shutdown_result;
        }
    }
    if (touch_initialized) {
        const int shutdown_result = hal->touch_shutdown();
        if (result == 0) {
            result = shutdown_result;
        }
    }
    return result;
}
