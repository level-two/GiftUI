#if defined(__linux__)
#define _GNU_SOURCE
#define _POSIX_C_SOURCE 200809L
#endif

#include "CGiftUILinux.h"

#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__)

#include <dlfcn.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <linux/input.h>
#include <poll.h>
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

struct GiftUITouchInput {
    int file_descriptor;
    struct input_absinfo x_axis;
    struct input_absinfo y_axis;
    int x;
    int y;
    int touching;
    int reported_touching;
    int reported_x;
    int reported_y;
};

struct gpiod_chip;
struct gpiod_line;

struct GiftUIGPIODLineEvent {
    struct timespec timestamp;
    int event_type;
};

typedef struct gpiod_chip *(*GiftUIGPIODChipOpen)(const char *path);
typedef void (*GiftUIGPIODChipClose)(struct gpiod_chip *chip);
typedef struct gpiod_line *(*GiftUIGPIODChipGetLine)(
    struct gpiod_chip *chip,
    unsigned int offset
);
typedef int (*GiftUIGPIODLineRequestBothEdges)(
    struct gpiod_line *line,
    const char *consumer
);
typedef int (*GiftUIGPIODLineRequestBothEdgesFlags)(
    struct gpiod_line *line,
    const char *consumer,
    int flags
);
typedef int (*GiftUIGPIODLineEventGetFD)(struct gpiod_line *line);
typedef int (*GiftUIGPIODLineEventReadFD)(
    int file_descriptor,
    struct GiftUIGPIODLineEvent *event
);
typedef void (*GiftUIGPIODLineRelease)(struct gpiod_line *line);

enum {
    GIFTUI_GPIO_MAX_LINES = 16,
    GIFTUI_GPIOD_EVENT_RISING_EDGE = 1,
    GIFTUI_GPIOD_EVENT_FALLING_EDGE = 2,
    GIFTUI_GPIOD_LINE_REQUEST_FLAG_BIAS_PULL_UP = 1 << 5,
};

struct GiftUIGPIOInput {
    void *library;
    struct gpiod_chip *chip;
    size_t line_count;
    struct gpiod_line *lines[GIFTUI_GPIO_MAX_LINES];
    int event_file_descriptors[GIFTUI_GPIO_MAX_LINES];
    GiftUIGPIODChipOpen chip_open;
    GiftUIGPIODChipClose chip_close;
    GiftUIGPIODChipGetLine chip_get_line;
    GiftUIGPIODLineRequestBothEdges line_request_both_edges;
    GiftUIGPIODLineRequestBothEdgesFlags line_request_both_edges_flags;
    GiftUIGPIODLineEventGetFD line_event_get_fd;
    GiftUIGPIODLineEventReadFD line_event_read_fd;
    GiftUIGPIODLineRelease line_release;
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

static void giftui_set_message(
    char *error_message,
    size_t error_capacity,
    const char *message
) {
    if (error_message == NULL || error_capacity == 0) {
        return;
    }
    snprintf(error_message, error_capacity, "%s", message);
}

static int giftui_load_gpiod_symbol(
    void *library,
    const char *name,
    void **destination,
    char *error_message,
    size_t error_capacity
) {
    dlerror();
    void *symbol = dlsym(library, name);
    const char *dynamic_error = dlerror();
    if (dynamic_error != NULL || symbol == NULL) {
        char message[256];
        snprintf(
            message,
            sizeof(message),
            "libgpiod is missing %s: %s",
            name,
            dynamic_error == NULL ? "symbol unavailable" : dynamic_error
        );
        giftui_set_message(error_message, error_capacity, message);
        return -1;
    }
    *destination = symbol;
    return 0;
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

static int giftui_validate_framebuffer_mapping(
    const GiftUIFramebufferDevice *device,
    char *error_message,
    size_t error_capacity
) {
    if (device == NULL || device->memory == NULL) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid framebuffer device");
        return -1;
    }

    int width = (int)device->variable.xres;
    int height = (int)device->variable.yres;
    int bytes_per_pixel = ((int)device->variable.bits_per_pixel + 7) / 8;
    if (
        ((size_t)device->variable.xoffset + (size_t)width)
            * (size_t)bytes_per_pixel
        > (size_t)device->fixed.line_length
    ) {
        errno = EOVERFLOW;
        giftui_set_error(error_message, error_capacity, "framebuffer row exceeds stride");
        return -1;
    }
    size_t last_byte = (
        ((size_t)device->variable.yoffset + (size_t)height - 1u)
        * (size_t)device->fixed.line_length
    ) + (
        ((size_t)device->variable.xoffset + (size_t)width)
        * (size_t)bytes_per_pixel
    );
    if (last_byte > device->memory_length) {
        errno = EOVERFLOW;
        giftui_set_error(error_message, error_capacity, "framebuffer geometry exceeds mapping");
        return -1;
    }
    return 0;
}

static int giftui_is_supported_rotation(int clockwise_rotation) {
    return clockwise_rotation == 0
        || clockwise_rotation == 90
        || clockwise_rotation == 180
        || clockwise_rotation == 270;
}

static int giftui_scaled_boundary(int source, int destination, int source_extent) {
    uint64_t numerator = (uint64_t)source * (uint64_t)destination;
    return (int)((numerator + (uint64_t)source_extent - 1u)
        / (uint64_t)source_extent);
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

int giftui_fb_clear(
    GiftUIFramebufferDevice *device,
    uint8_t red,
    uint8_t green,
    uint8_t blue,
    uint8_t alpha,
    char *error_message,
    size_t error_capacity
) {
    if (giftui_validate_framebuffer_mapping(
        device,
        error_message,
        error_capacity
    ) != 0) {
        return -1;
    }

    int width = (int)device->variable.xres;
    int height = (int)device->variable.yres;
    int bytes_per_pixel = ((int)device->variable.bits_per_pixel + 7) / 8;
    uint32_t pixel = giftui_pack_pixel(device, red, green, blue, alpha);
    for (int y = 0; y < height; y += 1) {
        uint8_t *row = device->memory
            + ((size_t)y + device->variable.yoffset) * device->fixed.line_length
            + (size_t)device->variable.xoffset * (size_t)bytes_per_pixel;
        for (int x = 0; x < width; x += 1) {
            giftui_write_pixel(
                row + (size_t)x * (size_t)bytes_per_pixel,
                bytes_per_pixel,
                pixel
            );
        }
    }
    __sync_synchronize();
    return 0;
}

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
) {
    if (
        device == NULL
        || pixels == NULL
        || source_width <= 0
        || source_height <= 0
        || tile_x < 0
        || tile_y < 0
        || tile_width <= 0
        || tile_height <= 0
        || tile_width > source_width - tile_x
        || tile_height > source_height - tile_y
        || tile_width > INT_MAX / 2
        || tile_bytes_per_row < tile_width * 2
        || !giftui_is_supported_rotation(clockwise_rotation)
    ) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid RGB565 tile arguments");
        return -1;
    }
    if (giftui_validate_framebuffer_mapping(
        device,
        error_message,
        error_capacity
    ) != 0) {
        return -1;
    }

    int destination_width = (int)device->variable.xres;
    int destination_height = (int)device->variable.yres;
    int bytes_per_pixel = ((int)device->variable.bits_per_pixel + 7) / 8;
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

    int tile_max_x = tile_x + tile_width;
    int tile_max_y = tile_y + tile_height;
    int rotated_min_x;
    int rotated_max_x;
    int rotated_min_y;
    int rotated_max_y;
    switch (clockwise_rotation) {
        case 90:
            rotated_min_x = source_height - tile_max_y;
            rotated_max_x = source_height - tile_y;
            rotated_min_y = tile_x;
            rotated_max_y = tile_max_x;
            break;
        case 180:
            rotated_min_x = source_width - tile_max_x;
            rotated_max_x = source_width - tile_x;
            rotated_min_y = source_height - tile_max_y;
            rotated_max_y = source_height - tile_y;
            break;
        case 270:
            rotated_min_x = tile_y;
            rotated_max_x = tile_max_y;
            rotated_min_y = source_width - tile_max_x;
            rotated_max_y = source_width - tile_x;
            break;
        default:
            rotated_min_x = tile_x;
            rotated_max_x = tile_max_x;
            rotated_min_y = tile_y;
            rotated_max_y = tile_max_y;
            break;
    }

    int destination_min_x = giftui_scaled_boundary(
        rotated_min_x,
        content_width,
        rotated_width
    );
    int destination_max_x = giftui_scaled_boundary(
        rotated_max_x,
        content_width,
        rotated_width
    );
    int destination_min_y = giftui_scaled_boundary(
        rotated_min_y,
        content_height,
        rotated_height
    );
    int destination_max_y = giftui_scaled_boundary(
        rotated_max_y,
        content_height,
        rotated_height
    );
    int content_origin_x = (destination_width - content_width) / 2;
    int content_origin_y = (destination_height - content_height) / 2;

    for (int y = destination_min_y; y < destination_max_y; y += 1) {
        int rotated_y = (int)(
            (uint64_t)y * (uint64_t)rotated_height / (uint64_t)content_height
        );
        uint8_t *destination_row = device->memory
            + (
                (size_t)(content_origin_y + y)
                + device->variable.yoffset
            ) * device->fixed.line_length
            + (
                (size_t)(content_origin_x + destination_min_x)
                + device->variable.xoffset
            ) * (size_t)bytes_per_pixel;

        for (int x = destination_min_x; x < destination_max_x; x += 1) {
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
            if (
                source_x < tile_x
                || source_x >= tile_max_x
                || source_y < tile_y
                || source_y >= tile_max_y
            ) {
                continue;
            }

            const uint8_t *source = pixels
                + (size_t)(source_y - tile_y) * (size_t)tile_bytes_per_row
                + (size_t)(source_x - tile_x) * 2u;
            uint16_t rgb565 = ((uint16_t)source[0] << 8) | source[1];
            uint8_t red = (uint8_t)((((rgb565 >> 11) & 0x1fu) * 255u + 15u) / 31u);
            uint8_t green = (uint8_t)((((rgb565 >> 5) & 0x3fu) * 255u + 31u) / 63u);
            uint8_t blue = (uint8_t)(((rgb565 & 0x1fu) * 255u + 15u) / 31u);
            uint32_t pixel = giftui_pack_pixel(device, red, green, blue, 255u);
            giftui_write_pixel(
                destination_row
                    + (size_t)(x - destination_min_x) * (size_t)bytes_per_pixel,
                bytes_per_pixel,
                pixel
            );
        }
    }

    __sync_synchronize();
    return 0;
}

int giftui_gpio_open(
    const char *chip_path,
    const uint32_t *line_offsets,
    size_t line_count,
    int request_pull_up,
    GiftUIGPIOInput **input,
    char *error_message,
    size_t error_capacity
) {
    if (
        chip_path == NULL
        || line_offsets == NULL
        || line_count == 0
        || line_count > GIFTUI_GPIO_MAX_LINES
        || input == NULL
    ) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid GPIO arguments");
        return -1;
    }

    *input = NULL;
    GiftUIGPIOInput *opened = calloc(1, sizeof(*opened));
    if (opened == NULL) {
        giftui_set_error(error_message, error_capacity, "allocate GPIO input state");
        return -1;
    }
    for (size_t index = 0; index < GIFTUI_GPIO_MAX_LINES; index += 1) {
        opened->event_file_descriptors[index] = -1;
    }

    const char *library_names[] = {
        "libgpiod.so.2",
        "libgpiod.so",
    };
    for (
        size_t index = 0;
        index < sizeof(library_names) / sizeof(library_names[0]);
        index += 1
    ) {
        opened->library = dlopen(library_names[index], RTLD_NOW | RTLD_LOCAL);
        if (opened->library != NULL) {
            break;
        }
    }
    if (opened->library == NULL) {
        giftui_set_message(
            error_message,
            error_capacity,
            "libgpiod.so.2 is unavailable; install the Raspberry Pi OS libgpiod2 package"
        );
        giftui_gpio_close(opened);
        return -1;
    }

#define GIFTUI_LOAD_GPIOD(name, field) \
    if (giftui_load_gpiod_symbol( \
        opened->library, \
        name, \
        (void **)&opened->field, \
        error_message, \
        error_capacity \
    ) < 0) { \
        giftui_gpio_close(opened); \
        return -1; \
    }

    GIFTUI_LOAD_GPIOD("gpiod_chip_open", chip_open)
    GIFTUI_LOAD_GPIOD("gpiod_chip_close", chip_close)
    GIFTUI_LOAD_GPIOD("gpiod_chip_get_line", chip_get_line)
    GIFTUI_LOAD_GPIOD(
        "gpiod_line_request_both_edges_events",
        line_request_both_edges
    )
    GIFTUI_LOAD_GPIOD("gpiod_line_event_get_fd", line_event_get_fd)
    GIFTUI_LOAD_GPIOD("gpiod_line_event_read_fd", line_event_read_fd)
    GIFTUI_LOAD_GPIOD("gpiod_line_release", line_release)

#undef GIFTUI_LOAD_GPIOD

    dlerror();
    *(void **)(&opened->line_request_both_edges_flags) = dlsym(
        opened->library,
        "gpiod_line_request_both_edges_events_flags"
    );
    (void)dlerror();
    if (request_pull_up != 0 && opened->line_request_both_edges_flags == NULL) {
        giftui_set_message(
            error_message,
            error_capacity,
            "installed libgpiod does not support GPIO bias flags"
        );
        giftui_gpio_close(opened);
        return -1;
    }

    opened->chip = opened->chip_open(chip_path);
    if (opened->chip == NULL) {
        giftui_set_error(error_message, error_capacity, "open GPIO chip");
        giftui_gpio_close(opened);
        return -1;
    }

    for (size_t index = 0; index < line_count; index += 1) {
        struct gpiod_line *line = opened->chip_get_line(
            opened->chip,
            line_offsets[index]
        );
        if (line == NULL) {
            giftui_set_error(error_message, error_capacity, "get GPIO line");
            giftui_gpio_close(opened);
            return -1;
        }

        int request_result;
        if (request_pull_up != 0) {
            request_result = opened->line_request_both_edges_flags(
                line,
                "GiftUI",
                GIFTUI_GPIOD_LINE_REQUEST_FLAG_BIAS_PULL_UP
            );
        } else {
            request_result = opened->line_request_both_edges(line, "GiftUI");
        }
        if (request_result < 0) {
            giftui_set_error(error_message, error_capacity, "request GPIO edge events");
            giftui_gpio_close(opened);
            return -1;
        }

        opened->lines[index] = line;
        opened->line_count = index + 1;
        opened->event_file_descriptors[index] = opened->line_event_get_fd(line);
        if (opened->event_file_descriptors[index] < 0) {
            giftui_set_error(error_message, error_capacity, "get GPIO event descriptor");
            giftui_gpio_close(opened);
            return -1;
        }
    }

    *input = opened;
    return 0;
}

void giftui_gpio_close(GiftUIGPIOInput *input) {
    if (input == NULL) {
        return;
    }
    if (input->line_release != NULL) {
        for (size_t index = 0; index < input->line_count; index += 1) {
            if (input->lines[index] != NULL) {
                input->line_release(input->lines[index]);
            }
        }
    }
    if (input->chip != NULL && input->chip_close != NULL) {
        input->chip_close(input->chip);
    }
    if (input->library != NULL) {
        dlclose(input->library);
    }
    free(input);
}

int giftui_gpio_poll(
    GiftUIGPIOInput *input,
    GiftUIGPIOEvent *events,
    size_t event_capacity,
    size_t *event_count,
    char *error_message,
    size_t error_capacity
) {
    if (
        input == NULL
        || events == NULL
        || event_capacity == 0
        || event_count == NULL
    ) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid GPIO poll arguments");
        return -1;
    }

    *event_count = 0;
    struct pollfd descriptors[GIFTUI_GPIO_MAX_LINES];
    for (size_t index = 0; index < input->line_count; index += 1) {
        descriptors[index].fd = input->event_file_descriptors[index];
        descriptors[index].events = POLLIN | POLLPRI;
        descriptors[index].revents = 0;
    }

    int poll_result = poll(descriptors, input->line_count, 0);
    if (poll_result < 0) {
        if (errno == EINTR) {
            return 0;
        }
        giftui_set_error(error_message, error_capacity, "poll GPIO events");
        return -1;
    }

    for (
        size_t index = 0;
        index < input->line_count && *event_count < event_capacity;
        index += 1
    ) {
        if ((descriptors[index].revents & (POLLERR | POLLNVAL)) != 0) {
            errno = EIO;
            giftui_set_error(error_message, error_capacity, "GPIO event descriptor failed");
            return -1;
        }
        if ((descriptors[index].revents & (POLLIN | POLLPRI)) == 0) {
            continue;
        }

        struct GiftUIGPIODLineEvent raw_event;
        if (
            input->line_event_read_fd(
                input->event_file_descriptors[index],
                &raw_event
            ) < 0
        ) {
            giftui_set_error(error_message, error_capacity, "read GPIO event");
            return -1;
        }

        GiftUIGPIOEvent *event = &events[*event_count];
        event->line_index = (uint32_t)index;
        event->edge = raw_event.event_type == GIFTUI_GPIOD_EVENT_RISING_EDGE
            ? GIFTUI_GPIO_EDGE_RISING
            : GIFTUI_GPIO_EDGE_FALLING;
        if (raw_event.timestamp.tv_sec < 0 || raw_event.timestamp.tv_nsec < 0) {
            event->timestamp_nanoseconds = 0;
        } else {
            event->timestamp_nanoseconds =
                (uint64_t)raw_event.timestamp.tv_sec * 1000000000ull
                + (uint64_t)raw_event.timestamp.tv_nsec;
        }
        *event_count += 1;
    }

    return 0;
}

int giftui_touch_open(
    const char *device_path,
    GiftUITouchInput **input,
    char *error_message,
    size_t error_capacity
) {
    if (device_path == NULL || input == NULL) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid touch input arguments");
        return -1;
    }

    *input = NULL;
    int file_descriptor = open(
        device_path,
        O_RDONLY | O_NONBLOCK | O_CLOEXEC
    );
    if (file_descriptor < 0) {
        giftui_set_error(error_message, error_capacity, "open touch input");
        return -1;
    }

    GiftUITouchInput *opened = calloc(1, sizeof(*opened));
    if (opened == NULL) {
        giftui_set_error(error_message, error_capacity, "allocate touch input state");
        close(file_descriptor);
        return -1;
    }
    opened->file_descriptor = file_descriptor;

    if (ioctl(file_descriptor, EVIOCGABS(ABS_X), &opened->x_axis) < 0) {
        giftui_set_error(error_message, error_capacity, "query touch X axis");
        giftui_touch_close(opened);
        return -1;
    }
    if (ioctl(file_descriptor, EVIOCGABS(ABS_Y), &opened->y_axis) < 0) {
        giftui_set_error(error_message, error_capacity, "query touch Y axis");
        giftui_touch_close(opened);
        return -1;
    }
    if (
        opened->x_axis.maximum <= opened->x_axis.minimum
        || opened->y_axis.maximum <= opened->y_axis.minimum
    ) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid touch axis range");
        giftui_touch_close(opened);
        return -1;
    }

    opened->x = opened->x_axis.value;
    opened->y = opened->y_axis.value;
    *input = opened;
    return 0;
}

void giftui_touch_close(GiftUITouchInput *input) {
    if (input == NULL) {
        return;
    }
    if (input->file_descriptor >= 0) {
        close(input->file_descriptor);
    }
    free(input);
}

int giftui_touch_minimum_x(const GiftUITouchInput *input) {
    return input == NULL ? 0 : input->x_axis.minimum;
}

int giftui_touch_maximum_x(const GiftUITouchInput *input) {
    return input == NULL ? 0 : input->x_axis.maximum;
}

int giftui_touch_minimum_y(const GiftUITouchInput *input) {
    return input == NULL ? 0 : input->y_axis.minimum;
}

int giftui_touch_maximum_y(const GiftUITouchInput *input) {
    return input == NULL ? 0 : input->y_axis.maximum;
}

static void giftui_touch_report(
    GiftUITouchInput *input,
    GiftUITouchEvent *events,
    size_t *event_count
) {
    uint32_t kind = 0;
    if (input->touching != 0 && input->reported_touching == 0) {
        kind = GIFTUI_TOUCH_DOWN;
    } else if (
        input->touching != 0
        && (
            input->x != input->reported_x
            || input->y != input->reported_y
        )
    ) {
        kind = GIFTUI_TOUCH_MOVE;
    } else if (input->touching == 0 && input->reported_touching != 0) {
        kind = GIFTUI_TOUCH_UP;
    }

    if (kind != 0) {
        GiftUITouchEvent *event = &events[*event_count];
        event->x = input->x;
        event->y = input->y;
        event->kind = kind;
        *event_count += 1;
    }
    input->reported_x = input->x;
    input->reported_y = input->y;
    input->reported_touching = input->touching;
}

int giftui_touch_poll(
    GiftUITouchInput *input,
    GiftUITouchEvent *events,
    size_t event_capacity,
    size_t *event_count,
    char *error_message,
    size_t error_capacity
) {
    if (
        input == NULL
        || events == NULL
        || event_capacity == 0
        || event_count == NULL
    ) {
        errno = EINVAL;
        giftui_set_error(error_message, error_capacity, "invalid touch poll arguments");
        return -1;
    }

    *event_count = 0;
    while (*event_count < event_capacity) {
        struct input_event raw_event;
        ssize_t byte_count = read(
            input->file_descriptor,
            &raw_event,
            sizeof(raw_event)
        );
        if (byte_count < 0) {
            if (errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR) {
                return 0;
            }
            giftui_set_error(error_message, error_capacity, "read touch input");
            return -1;
        }
        if (byte_count == 0) {
            errno = ENODEV;
            giftui_set_error(error_message, error_capacity, "touch input disconnected");
            return -1;
        }
        if ((size_t)byte_count != sizeof(raw_event)) {
            errno = EIO;
            giftui_set_error(error_message, error_capacity, "read partial touch event");
            return -1;
        }

        if (raw_event.type == EV_ABS && raw_event.code == ABS_X) {
            input->x = raw_event.value;
        } else if (raw_event.type == EV_ABS && raw_event.code == ABS_Y) {
            input->y = raw_event.value;
        } else if (raw_event.type == EV_KEY && raw_event.code == BTN_TOUCH) {
            input->touching = raw_event.value != 0;
        } else if (raw_event.type == EV_SYN && raw_event.code == SYN_REPORT) {
            giftui_touch_report(input, events, event_count);
        }
    }

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

struct GiftUIGPIOInput {
    int unavailable;
};

struct GiftUITouchInput {
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

int giftui_fb_clear(
    GiftUIFramebufferDevice *device,
    uint8_t red,
    uint8_t green,
    uint8_t blue,
    uint8_t alpha,
    char *error_message,
    size_t error_capacity
) {
    (void)device;
    (void)red;
    (void)green;
    (void)blue;
    (void)alpha;
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

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
) {
    (void)device;
    (void)pixels;
    (void)source_width;
    (void)source_height;
    (void)tile_x;
    (void)tile_y;
    (void)tile_width;
    (void)tile_height;
    (void)tile_bytes_per_row;
    (void)clockwise_rotation;
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

int giftui_gpio_open(
    const char *chip_path,
    const uint32_t *line_offsets,
    size_t line_count,
    int request_pull_up,
    GiftUIGPIOInput **input,
    char *error_message,
    size_t error_capacity
) {
    (void)chip_path;
    (void)line_offsets;
    (void)line_count;
    (void)request_pull_up;
    if (input != NULL) {
        *input = NULL;
    }
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

void giftui_gpio_close(GiftUIGPIOInput *input) {
    (void)input;
}

int giftui_gpio_poll(
    GiftUIGPIOInput *input,
    GiftUIGPIOEvent *events,
    size_t event_capacity,
    size_t *event_count,
    char *error_message,
    size_t error_capacity
) {
    (void)input;
    (void)events;
    (void)event_capacity;
    if (event_count != NULL) {
        *event_count = 0;
    }
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

int giftui_touch_open(
    const char *device_path,
    GiftUITouchInput **input,
    char *error_message,
    size_t error_capacity
) {
    (void)device_path;
    if (input != NULL) {
        *input = NULL;
    }
    giftui_unsupported(error_message, error_capacity);
    return -1;
}

void giftui_touch_close(GiftUITouchInput *input) {
    (void)input;
}

int giftui_touch_minimum_x(const GiftUITouchInput *input) {
    (void)input;
    return 0;
}

int giftui_touch_maximum_x(const GiftUITouchInput *input) {
    (void)input;
    return 0;
}

int giftui_touch_minimum_y(const GiftUITouchInput *input) {
    (void)input;
    return 0;
}

int giftui_touch_maximum_y(const GiftUITouchInput *input) {
    (void)input;
    return 0;
}

int giftui_touch_poll(
    GiftUITouchInput *input,
    GiftUITouchEvent *events,
    size_t event_capacity,
    size_t *event_count,
    char *error_message,
    size_t error_capacity
) {
    (void)input;
    (void)events;
    (void)event_capacity;
    if (event_count != NULL) {
        *event_count = 0;
    }
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
