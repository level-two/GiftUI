#ifndef CGIFTUI_LINUX_H
#define CGIFTUI_LINUX_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct GiftUIFramebufferDevice GiftUIFramebufferDevice;

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
