#include "static_host_lifecycle.h"

#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <string.h>

static char events[64];
static unsigned event_count;
static uint64_t current_time;
static unsigned service_count;
static unsigned wait_count;
static char fail_at;
static int context_token = 7;
static unsigned context_visits;

static void check_context(void *context)
{
    assert(context == &context_token);
    assert(*(int *)context == 7);
    ++context_visits;
}

static void record(char event)
{
    assert(event_count + 1U < sizeof(events));
    events[event_count++] = event;
    events[event_count] = '\0';
}

static int outcome(char event)
{
    record(event);
    return fail_at == event ? -EIO : 0;
}

static int validate(void *context)
{
    check_context(context);
    return outcome('V');
}
static int touch_initialize(void) { return outcome('T'); }
static int display_initialize(void) { return outcome('D'); }
static int activate(void *context)
{
    check_context(context);
    return outcome('A');
}
static int touch_poll(void) { return outcome('P'); }
static int teardown(void *context)
{
    check_context(context);
    return outcome('a');
}
static int display_shutdown(void) { return outcome('d'); }
static int touch_shutdown(void) { return outcome('t'); }

static int now_microseconds(uint64_t *timestamp)
{
    record('C');
    if (fail_at == 'C') {
        return -EIO;
    }
    *timestamp = current_time;
    return 0;
}

static void wait_microseconds(uint32_t duration)
{
    record('w');
    assert(duration <= 1000U);
    current_time += duration;
    ++wait_count;
}

static int service_watchdog(void) { return outcome('W'); }

static int service(void *context, uint64_t now, uint64_t *deadline, int *stop)
{
    check_context(context);
    record('S');
    assert(now == current_time);
    ++service_count;
    if (fail_at == 'S') {
        return -EIO;
    }
    if (fail_at == 'R') {
        *deadline = now;
        return 0;
    }
    *stop = service_count == 2U || fail_at == 'Q';
    *deadline = now + 2500U;
    return 0;
}

static const struct giftui_static_host_lifecycle_hal hal = {
    .touch_initialize = touch_initialize,
    .display_initialize = display_initialize,
    .touch_poll = touch_poll,
    .display_shutdown = display_shutdown,
    .touch_shutdown = touch_shutdown,
    .scheduler = {
        .now_microseconds = now_microseconds,
        .wait_microseconds = wait_microseconds,
        .service_watchdog = service_watchdog,
    },
};

static const struct giftui_static_host_application application = {
    .context = &context_token,
    .validate = validate,
    .activate = activate,
    .service = service,
    .teardown = teardown,
};

static void reset(char failure)
{
    memset(events, 0, sizeof(events));
    event_count = 0U;
    current_time = 100U;
    service_count = 0U;
    wait_count = 0U;
    fail_at = failure;
    context_visits = 0U;
}

int main(void)
{
    assert(giftui_static_host_run(0, &application) == -EINVAL);
    assert(giftui_static_host_run(&hal, 0) == -EINVAL);
    struct giftui_static_host_application missing_context = application;
    missing_context.context = 0;
    assert(giftui_static_host_run(&hal, &missing_context) == -EINVAL);

    reset('V');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(strcmp(events, "V") == 0);
    assert(context_visits == 1U);

    reset('D');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(strcmp(events, "VTDt") == 0);

    reset('A');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(strcmp(events, "VTDAadt") == 0);

    reset('P');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(strcmp(events, "VTDAPadt") == 0);

    reset('S');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(strcmp(events, "VTDAPCSadt") == 0);

    reset('W');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(service_count == 1U && wait_count == 0U);
    assert(strcmp(events + event_count - 3U, "adt") == 0);

    reset('R');
    assert(giftui_static_host_run(&hal, &application) == -ERANGE);
    assert(service_count == 1U && wait_count == 0U);
    assert(strcmp(events + event_count - 3U, "adt") == 0);

    reset('Q');
    assert(giftui_static_host_run(&hal, &application) == 0);
    assert(strcmp(events, "VTDAPCSadt") == 0);

    reset(0);
    assert(giftui_static_host_run(&hal, &application) == 0);
    assert(service_count == 2U && wait_count == 3U);
    assert(context_visits == 5U);
    assert(current_time == 2600U);
    assert(strcmp(events + event_count - 3U, "adt") == 0);

    reset('d');
    assert(giftui_static_host_run(&hal, &application) == -EIO);
    assert(strcmp(events + event_count - 3U, "adt") == 0);
    return 0;
}
