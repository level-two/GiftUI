#ifndef GIFTUI_STATIC_HOST_CLOCK_H
#define GIFTUI_STATIC_HOST_CLOCK_H

#include <stdint.h>

#ifndef GIFTUI_STATIC_HOST_CLOCK_ENTRY
#define GIFTUI_STATIC_HOST_CLOCK_ENTRY __attribute__((used, retain))
#endif

/* Monotonic microseconds for the generated host pacing controller. */
GIFTUI_STATIC_HOST_CLOCK_ENTRY int giftui_static_host_clock_now(
    uint64_t *timestamp_microseconds);

#endif
