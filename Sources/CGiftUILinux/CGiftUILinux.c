#include "CGiftUILinux.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__)

#include <fcntl.h>
#include <linux/fb.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>

struct GiftUIFramebufferDevice {
    int file_descriptor;
    struct fb_fix_screeninfo fixed;
    struct fb_var_screeninfo variable;
    uint8_t *memory;
    size_t memory_length;
};

static volatile sig_atomic_t giftui_should_terminate = 0;

static void giftui_set_error(
    char *error_message,
    size_t error_capacity,
    const char *operation
) {
    if (error_message == NULL || error_capacity == 0) {
        return;
    }

    snprintf(
        error_message,
        error_capacity,
        "%s: %s",
        operation,
        strerror(errno)
    );
}

static int giftui_validate_bitfield(
    const struct fb_bitfield field,
    int bits_per_pixel
) {
    return field.msb_right == 0
        && field.length <= 8
        && field.offset + field.length <= (unsigned int)bits_per_pixel;
}

static uint32_t giftui_pack_component(
    uint8_t component,
    const struct fb_bitfield field
) {
    if (field.length == 0) {
        return 0;
    }

    uint32_t maximum = (1u << field.length) - 1u;
    uint32_t scaled = ((uint32_t)component * maximum + 127u) / 255u;
    return scaled << field.offset;
}

static uint32_t giftui_pack_pixel(
    const GiftUIFramebufferDevice *device,
    uint8_t red,
    uint8_t green,
    uint8_t blue,
    uint8_t alpha
) {
    return giftui_pack_component(red, device->variable.red)
        | giftui_pack_component(green, device->variable.green)
        | giftui_pack_component(blue, device->variable.blue)
        | giftui_pack_component(alpha, device->variable.transp);
}

static void giftui_write_pixel(
    uint8_t *destination,
    int bytes_per_pixel,
    uint32_t pixel
) {
    for (int byte = 0; byte < bytes_per_pixel; byte += 1) {
        destination[byte] = (uint8_t)(pixel >> (byte * 8));
    }
}

static void giftui_handle_termination_signal(int signal_number) {
    (void)signal_number;
    giftui_should_terminate = 1;
}

int giftui_linux_is_supported(void) {
    return 1;
}

int giftui_fb_open(
    const char *path,
    GiftUIFramebufferDevice **device,
    char *error_message,
    size_t error_capacity
) {
    if (path == NULL || device == NULL) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid framebuffer arguments");
        return -1;
    }

    *device = NULL;
    int file_descriptor = open(path, O_RDWR | O_CLOEXEC);
    if (file_descriptor < 0) {
        giftui_set_error(error_message, error_capacity, "open framebuffer");
        return -1;
    }

    GiftUIFramebufferDevice *opened = calloc(1, sizeof(*opened));
    if (opened == NULL) {
        giftui_set_error(error_message, error_capacity, "allocate framebuffer state");
        close(file_descriptor);
        return -1;
    }
    opened->file_descriptor = file_descriptor;

    if (ioctl(file_descriptor, FBIOGET_FSCREENINFO, &opened->fixed) < 0) {
        giftui_set_error(error_message, error_capacity, "query fixed framebuffer info");
        giftui_fb_close(opened);
        return -1;
    }
    if (ioctl(file_descriptor, FBIOGET_VSCREENINFO, &opened->variable) < 0) {
        giftui_set_error(error_message, error_capacity, "query variable framebuffer info");
        giftui_fb_close(opened);
        return -1;
    }

    int bits_per_pixel = (int)opened->variable.bits_per_pixel;
    int bytes_per_pixel = (bits_per_pixel + 7) / 8;
    if (
        opened->variable.xres == 0
        || opened->variable.yres == 0
        || opened->fixed.line_length == 0
        || (bytes_per_pixel != 2 && bytes_per_pixel != 3 && bytes_per_pixel != 4)
        || opened->variable.red.length == 0
        || opened->variable.green.length == 0
        || opened->variable.blue.length == 0
        || !giftui_validate_bitfield(opened->variable.red, bits_per_pixel)
        || !giftui_validate_bitfield(opened->variable.green, bits_per_pixel)
        || !giftui_validate_bitfield(opened->variable.blue, bits_per_pixel)
        || !giftui_validate_bitfield(opened->variable.transp, bits_per_pixel)
    ) {
        errno = ENOTSUP;
        giftui_set_error(error_message, error_capacity, "unsupported framebuffer pixel format");
        giftui_fb_close(opened);
        return -1;
    }

    opened->memory_length = opened->fixed.smem_len;
    opened->memory = mmap(
        NULL,
        opened->memory_length,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        file_descriptor,
        0
    );
    if (opened->memory == MAP_FAILED) {
        opened->memory = NULL;
        giftui_set_error(error_message, error_capacity, "map framebuffer");
        giftui_fb_close(opened);
        return -1;
    }

    *device = opened;
    return 0;
}

void giftui_fb_close(GiftUIFramebufferDevice *device) {
    if (device == NULL) {
        return;
    }
    if (device->memory != NULL) {
        munmap(device->memory, device->memory_length);
    }
    if (device->file_descriptor >= 0) {
        close(device->file_descriptor);
    }
    free(device);
}

int giftui_fb_width(const GiftUIFramebufferDevice *device) {
    return device == NULL ? 0 : (int)device->variable.xres;
}

int giftui_fb_height(const GiftUIFramebufferDevice *device) {
    return device == NULL ? 0 : (int)device->variable.yres;
}

int giftui_fb_bits_per_pixel(const GiftUIFramebufferDevice *device) {
    return device == NULL ? 0 : (int)device->variable.bits_per_pixel;
}

int giftui_fb_present_rgba(
    GiftUIFramebufferDevice *device,
    const uint8_t *rgba,
    int source_width,
    int source_height,
    int source_bytes_per_row,
    int clockwise_rotation,
    char *error_message,
    size_t error_capacity
) {
    if (
        device == NULL
        || rgba == NULL
        || source_width <= 0
        || source_height <= 0
        || source_bytes_per_row < source_width * 4
        || (
            clockwise_rotation != 0
            && clockwise_rotation != 90
            && clockwise_rotation != 180
            && clockwise_rotation != 270
        )
    ) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid presentation arguments");
        return -1;
    }

    int destination_width = (int)device->variable.xres;
    int destination_height = (int)device->variable.yres;
    int bytes_per_pixel = ((int)device->variable.bits_per_pixel + 7) / 8;
    if (
        ((size_t)device->variable.xoffset + (size_t)destination_width)
            * (size_t)bytes_per_pixel
        > (size_t)device->fixed.line_length
    ) {
        errno = EOVERFLOW;
        giftui_set_error(error_message, error_capacity, "framebuffer row exceeds stride");
        return -1;
    }
    size_t last_byte = (
        ((size_t)device->variable.yoffset + (size_t)destination_height - 1u)
        * (size_t)device->fixed.line_length
    ) + (
        ((size_t)device->variable.xoffset + (size_t)destination_width)
        * (size_t)bytes_per_pixel
    );
    if (last_byte > device->memory_length) {
        errno = EOVERFLOW;
        giftui_set_error(error_message, error_capacity, "framebuffer geometry exceeds mapping");
        return -1;
    }

    int rotated_width = (
        clockwise_rotation == 90 || clockwise_rotation == 270
    ) ? source_height : source_width;
    int rotated_height = (
        clockwise_rotation == 90 || clockwise_rotation == 270
    ) ? source_width : source_height;

    int content_width;
    int content_height;
    if (
        (uint64_t)destination_width * (uint64_t)rotated_height
        <= (uint64_t)destination_height * (uint64_t)rotated_width
    ) {
        content_width = destination_width;
        content_height = (int)(
            (uint64_t)destination_width * (uint64_t)rotated_height
            / (uint64_t)rotated_width
        );
    } else {
        content_height = destination_height;
        content_width = (int)(
            (uint64_t)destination_height * (uint64_t)rotated_width
            / (uint64_t)rotated_height
        );
    }
    if (content_width <= 0 || content_height <= 0) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid scaled framebuffer geometry");
        return -1;
    }

    int content_origin_x = (destination_width - content_width) / 2;
    int content_origin_y = (destination_height - content_height) / 2;
    uint32_t black = giftui_pack_pixel(device, 0, 0, 0, 255);

    for (int y = 0; y < destination_height; y += 1) {
        uint8_t *row = device->memory
            + ((size_t)y + device->variable.yoffset) * device->fixed.line_length
            + (size_t)device->variable.xoffset * (size_t)bytes_per_pixel;
        for (int x = 0; x < destination_width; x += 1) {
            giftui_write_pixel(
                row + (size_t)x * (size_t)bytes_per_pixel,
                bytes_per_pixel,
                black
            );
        }
    }

    for (int y = 0; y < content_height; y += 1) {
        int rotated_y = (int)(
            (uint64_t)y * (uint64_t)rotated_height / (uint64_t)content_height
        );
        uint8_t *destination_row = device->memory
            + (
                (size_t)(content_origin_y + y)
                + device->variable.yoffset
            ) * device->fixed.line_length
            + (
                (size_t)content_origin_x
                + device->variable.xoffset
            ) * (size_t)bytes_per_pixel;

        for (int x = 0; x < content_width; x += 1) {
            int rotated_x = (int)(
                (uint64_t)x * (uint64_t)rotated_width / (uint64_t)content_width
            );
            int source_x;
            int source_y;

            switch (clockwise_rotation) {
                case 90:
                    source_x = rotated_y;
                    source_y = source_height - 1 - rotated_x;
                    break;
                case 180:
                    source_x = source_width - 1 - rotated_x;
                    source_y = source_height - 1 - rotated_y;
                    break;
                case 270:
                    source_x = source_width - 1 - rotated_y;
                    source_y = rotated_x;
                    break;
                default:
                    source_x = rotated_x;
                    source_y = rotated_y;
                    break;
            }

            const uint8_t *source = rgba
                + (size_t)source_y * (size_t)source_bytes_per_row
                + (size_t)source_x * 4u;
            uint32_t pixel = giftui_pack_pixel(
                device,
                source[0],
                source[1],
                source[2],
                source[3]
            );
            giftui_write_pixel(
                destination_row + (size_t)x * (size_t)bytes_per_pixel,
                bytes_per_pixel,
                pixel
            );
        }
    }

    __sync_synchronize();
    return 0;
}

int giftui_linux_install_signal_handlers(
    char *error_message,
    size_t error_capacity
) {
    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = giftui_handle_termination_signal;
    sigemptyset(&action.sa_mask);

    if (sigaction(SIGINT, &action, NULL) < 0) {
        giftui_set_error(error_message, error_capacity, "install SIGINT handler");
        return -1;
    }
    if (sigaction(SIGTERM, &action, NULL) < 0) {
        giftui_set_error(error_message, error_capacity, "install SIGTERM handler");
        return -1;
    }
    return 0;
}

void giftui_linux_reset_termination(void) {
    giftui_should_terminate = 0;
}

int giftui_linux_should_terminate(void) {
    return giftui_should_terminate != 0;
}

void giftui_linux_sleep_milliseconds(unsigned int milliseconds) {
    struct timespec requested = {
        .tv_sec = (time_t)(milliseconds / 1000u),
        .tv_nsec = (long)(milliseconds % 1000u) * 1000000L,
    };
    while (nanosleep(&requested, &requested) < 0 && errno == EINTR) {
    }
}

#else

struct GiftUIFramebufferDevice {
    int unavailable;
};

static void giftui_unsupported(
    char *error_message,
    size_t error_capacity
) {
    if (error_message != NULL && error_capacity > 0) {
        snprintf(
            error_message,
            error_capacity,
            "Linux framebuffer support is unavailable on this platform"
        );
    }
}

int giftui_linux_is_supported(void) {
    return 0;
}

int giftui_fb_open(
    const char *path,
    GiftUIFramebufferDevice **device,
    char *error_message,
    size_t error_capacity
) {
    (void)path;
    if (device != NULL) {
        *device = NULL;
    }
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

void giftui_fb_close(GiftUIFramebufferDevice *device) {
    (void)device;
}

int giftui_fb_width(const GiftUIFramebufferDevice *device) {
    (void)device;
    return 0;
}

int giftui_fb_height(const GiftUIFramebufferDevice *device) {
    (void)device;
    return 0;
}

int giftui_fb_bits_per_pixel(const GiftUIFramebufferDevice *device) {
    (void)device;
    return 0;
}

int giftui_fb_present_rgba(
    GiftUIFramebufferDevice *device,
    const uint8_t *rgba,
    int source_width,
    int source_height,
    int source_bytes_per_row,
    int clockwise_rotation,
    char *error_message,
    size_t error_capacity
) {
    (void)device;
    (void)rgba;
    (void)source_width;
    (void)source_height;
    (void)source_bytes_per_row;
    (void)clockwise_rotation;
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

int giftui_linux_install_signal_handlers(
    char *error_message,
    size_t error_capacity
) {
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

void giftui_linux_reset_termination(void) {}
int giftui_linux_should_terminate(void) { return 1; }
void giftui_linux_sleep_milliseconds(unsigned int milliseconds) {
    (void)milliseconds;
}

#endif
