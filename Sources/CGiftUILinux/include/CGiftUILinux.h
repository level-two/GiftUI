#ifndef CGIFTUI_LINUX_H
#define CGIFTUI_LINUX_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct GiftUIFramebufferDevice GiftUIFramebufferDevice;
typedef struct GiftUIGPIOInput GiftUIGPIOInput;
typedef struct GiftUITouchInput GiftUITouchInput;

typedef struct GiftUIGPIOEvent {
    uint32_t line_index;
    uint32_t edge;
    uint64_t timestamp_nanoseconds;
} GiftUIGPIOEvent;

enum {
    GIFTUI_GPIO_EDGE_RISING = 1,
    GIFTUI_GPIO_EDGE_FALLING = 2,
};

typedef struct GiftUITouchEvent {
    int32_t x;
    int32_t y;
    uint32_t kind;
} GiftUITouchEvent;

enum {
    GIFTUI_TOUCH_DOWN = 1,
    GIFTUI_TOUCH_MOVE = 2,
    GIFTUI_TOUCH_UP = 3,
};

int giftui_linux_is_supported(void);

int giftui_fb_open(
    const char *path,
    GiftUIFramebufferDevice **device,
    char *error_message,
    size_t error_capacity
);

void giftui_fb_close(GiftUIFramebufferDevice *device);

int giftui_fb_width(const GiftUIFramebufferDevice *device);
int giftui_fb_height(const GiftUIFramebufferDevice *device);
int giftui_fb_bits_per_pixel(const GiftUIFramebufferDevice *device);

int giftui_fb_present_rgba(
    GiftUIFramebufferDevice *device,
    const uint8_t *rgba,
    int source_width,
    int source_height,
    int source_bytes_per_row,
    int clockwise_rotation,
    char *error_message,
    size_t error_capacity
);

int giftui_fb_clear(
    GiftUIFramebufferDevice *device,
    uint8_t red,
    uint8_t green,
    uint8_t blue,
    uint8_t alpha,
    char *error_message,
    size_t error_capacity
);

int giftui_fb_present_rgb565_tile(
    GiftUIFramebufferDevice *device,
    const uint8_t *pixels,
    int source_width,
    int source_height,
    int tile_x,
    int tile_y,
    int tile_width,
    int tile_height,
    int tile_bytes_per_row,
    int clockwise_rotation,
    char *error_message,
    size_t error_capacity
);

int giftui_gpio_open(
    const char *chip_path,
    const uint32_t *line_offsets,
    size_t line_count,
    int request_pull_up,
    GiftUIGPIOInput **input,
    char *error_message,
    size_t error_capacity
);

void giftui_gpio_close(GiftUIGPIOInput *input);

int giftui_gpio_poll(
    GiftUIGPIOInput *input,
    GiftUIGPIOEvent *events,
    size_t event_capacity,
    size_t *event_count,
    char *error_message,
    size_t error_capacity
);

int giftui_touch_open(
    const char *device_path,
    GiftUITouchInput **input,
    char *error_message,
    size_t error_capacity
);

void giftui_touch_close(GiftUITouchInput *input);

int giftui_touch_minimum_x(const GiftUITouchInput *input);
int giftui_touch_maximum_x(const GiftUITouchInput *input);
int giftui_touch_minimum_y(const GiftUITouchInput *input);
int giftui_touch_maximum_y(const GiftUITouchInput *input);

int giftui_touch_poll(
    GiftUITouchInput *input,
    GiftUITouchEvent *events,
    size_t event_capacity,
    size_t *event_count,
    char *error_message,
    size_t error_capacity
);

int giftui_linux_install_signal_handlers(
    char *error_message,
    size_t error_capacity
);

void giftui_linux_reset_termination(void);
int giftui_linux_should_terminate(void);
void giftui_linux_sleep_milliseconds(unsigned int milliseconds);

#ifdef __cplusplus
}
#endif

#endif
