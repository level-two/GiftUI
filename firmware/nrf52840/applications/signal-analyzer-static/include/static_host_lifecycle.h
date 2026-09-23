#ifndef GIFTUI_STATIC_HOST_LIFECYCLE_H
#define GIFTUI_STATIC_HOST_LIFECYCLE_H

#include "static_host_scheduler.h"

#include <stdint.h>

struct giftui_static_host_lifecycle_hal {
    int (*touch_initialize)(void);
    int (*display_initialize)(void);
    int (*touch_poll)(void);
    int (*display_shutdown)(void);
    int (*touch_shutdown)(void);
    struct giftui_static_host_scheduler_hal scheduler;
};

struct giftui_static_host_application {
    /* Validation is side-effect-free and precedes device construction. */
    int (*validate)(void);
    int (*activate)(void);
    /* A completed service supplies the next absolute deadline or stops. */
    int (*service)(uint64_t now_microseconds,
                   uint64_t *next_deadline_microseconds, int *stop);
    int (*teardown)(void);
};

/* Owns activation, paced service, and reverse-order teardown. */
int giftui_static_host_run(
    const struct giftui_static_host_lifecycle_hal *hal,
    const struct giftui_static_host_application *application);

#endif
