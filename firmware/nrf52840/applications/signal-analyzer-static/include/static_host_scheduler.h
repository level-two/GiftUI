#ifndef GIFTUI_STATIC_HOST_SCHEDULER_H
#define GIFTUI_STATIC_HOST_SCHEDULER_H

#include <stdint.h>

struct giftui_static_host_scheduler_hal {
    int (*now_microseconds)(uint64_t *timestamp);
    void (*wait_microseconds)(uint32_t duration);
    /* Optional only when no hardware watchdog is active. */
    int (*service_watchdog)(void);
};

/* Waits against one absolute monotonic deadline in at most 1 ms slices. */
int giftui_static_host_wait_until(
    uint64_t deadline_microseconds,
    const struct giftui_static_host_scheduler_hal *hal);

#endif
