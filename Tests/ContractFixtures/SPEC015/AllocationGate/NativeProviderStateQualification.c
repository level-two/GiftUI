// Qualification only: inspect the pinned loaded providers, then exit before
// Main. This never calls the Counter entry or starts allocation collection.
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <pthread.h>
#include <dispatch/dispatch.h>
#include <errno.h>
#include <unistd.h>

_Static_assert(sizeof(FILE) == 152, "qualification requires the pinned FILE layout");
_Static_assert(offsetof(FILE, _flags) == 16 && offsetof(FILE, _file) == 18 &&
    offsetof(FILE, _extra) == 104, "qualification requires the pinned FILE fields");
_Static_assert(sizeof(pthread_mutex_t) == 64, "qualification requires the pinned mutex layout");

// Bind the exported implementation, rather than once.h's inline fast-path copy.
#undef dispatch_once_f

// Keep SwiftCore initialization ahead of this constructor. Never call this
// anchor: its declaration is used solely to retain the dylib dependency.
extern void swift_willThrowTypedImpl(void);
__attribute__((used)) static void (*const swift_anchor)(void) = swift_willThrowTypedImpl;

struct image {
    const struct mach_header_64 *header;
    intptr_t slide;
};

static int image_uuid(const struct mach_header_64 *header, uint8_t output[16]) {
    if (header->magic != MH_MAGIC_64 || header->ncmds > 512 || header->sizeofcmds > 65536) return 0;
    const uint8_t *cursor = (const uint8_t *)(header + 1);
    const uint8_t *end = cursor + header->sizeofcmds;
    for (uint32_t i = 0; i < header->ncmds; ++i) {
        if ((size_t)(end - cursor) < sizeof(struct load_command)) return 0;
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmdsize < sizeof(*command) || command->cmdsize > (size_t)(end - cursor)) return 0;
        if (command->cmd == LC_UUID && command->cmdsize >= sizeof(struct uuid_command)) {
            const uint8_t *actual = ((const struct uuid_command *)command)->uuid;
            for (int j = 0; j < 16; ++j) output[j] = actual[j];
            return 1;
        }
        cursor += command->cmdsize;
    }
    return 0;
}

static int uuid_matches(const struct mach_header_64 *header, const uint8_t expected[16]) {
    uint8_t actual[16];
    if (!image_uuid(header, actual)) return 0;
    for (int j = 0; j < 16; ++j) if (actual[j] != expected[j]) return 0;
    return 1;
}

static int segment_contains(struct image image, uintptr_t address, size_t count, int protections) {
    if (!image.header || !count) return 0;
    const uint8_t *cursor = (const uint8_t *)(image.header + 1);
    const uint8_t *end = cursor + image.header->sizeofcmds;
    for (uint32_t i = 0; i < image.header->ncmds; ++i) {
        if ((size_t)(end - cursor) < sizeof(struct load_command)) return 0;
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmdsize < sizeof(*command) || command->cmdsize > (size_t)(end - cursor)) return 0;
        if (command->cmd == LC_SEGMENT_64 && command->cmdsize >= sizeof(struct segment_command_64)) {
            const struct segment_command_64 *segment = (const struct segment_command_64 *)command;
            uintptr_t start = (uintptr_t)segment->vmaddr + (uintptr_t)image.slide;
            if ((segment->initprot & protections) == protections && address >= start && count <= segment->vmsize &&
                address - start <= segment->vmsize - count) return 1;
        }
        cursor += command->cmdsize;
    }
    return 0;
}

static int readable(struct image image, uintptr_t address, size_t count) {
    return segment_contains(image, address, count, 1);
}

static int bind_function(uintptr_t address, uint64_t output[4], uint32_t images) {
    for (uint32_t i = 0; i < images; ++i) {
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(i);
        uint8_t uuid[16];
        if (!header || !image_uuid(header, uuid)) continue;
        struct image image = {header, _dyld_get_image_vmaddr_slide(i)};
        if (!segment_contains(image, address, 4, 5)) continue;
        output[0] = address - (uintptr_t)image.slide;
        output[1] = (uintptr_t)header - (uintptr_t)image.slide;
        __builtin_memcpy(output + 2, uuid, 16);
        return 1;
    }
    return 0;
}

static int read_cell(struct image image, uintptr_t unslid, uint64_t *result) {
    uintptr_t address = unslid + (uintptr_t)image.slide;
    if (!readable(image, address, sizeof(*result))) return 0;
    __builtin_memcpy(result, (const void *)address, sizeof(*result));
    return 1;
}

static size_t append_hex(char *out, size_t used, uint64_t value) {
    static const char digits[] = "0123456789abcdef";
    for (int i = 15; i >= 0; --i) out[used++] = digits[(value >> (i * 4)) & 15];
    out[used++] = '\n';
    return used;
}

__attribute__((constructor)) static void qualify_provider_state(void) {
    static const uint8_t swift_uuid[16] = {0x83,0x79,0x4f,0xb3,0xde,0x9b,0x3d,0x23,0xab,0x5e,0x2c,0x1d,0x5d,0x30,0xf1,0x34};
    static const uint8_t libc_uuid[16] = {0xd7,0x7c,0xeb,0x62,0xaf,0xf6,0x3c,0xec,0xba,0x9b,0x4f,0x05,0x7f,0xbe,0x2e,0xb5};
    struct image swift = {0}, libc = {0};
    uint32_t images = _dyld_image_count();
    if (images > 4096) _exit(97);
    for (uint32_t i = 0; i < images; ++i) {
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(i);
        if (!header) continue;
        if (uuid_matches(header, swift_uuid)) swift = (struct image){header, _dyld_get_image_vmaddr_slide(i)};
        if (uuid_matches(header, libc_uuid)) libc = (struct image){header, _dyld_get_image_vmaddr_slide(i)};
    }
    // Words 0...11 contain state; 12...31 bind five exported functions;
    // 32...37 contain the stdout callback, cookie check and callback binding.
    uint64_t words[38] = {0};
    if (swift.header) words[0] |= 1;
    if (libc.header) words[0] |= 2;
    if (read_cell(swift, UINT64_C(0x1ea7fec78), &words[1]) &&
        read_cell(swift, UINT64_C(0x1ea7fec40), &words[2])) words[0] |= 4;
    if (read_cell(libc, UINT64_C(0x1ea474d20), &words[3])) words[0] |= 8;
    FILE *stream = stdout;
    if ((uintptr_t)stream % _Alignof(FILE) == 0 &&
        readable(libc, (uintptr_t)stream, sizeof(*stream))) {
        words[6] = 1;
        words[4] = (uint16_t)stream->_flags;
        words[5] = (uint16_t)stream->_file;
        words[9] = (uintptr_t)stream->_ub._base;
        words[10] = (uintptr_t)stream->_bf._base;
        words[11] = (uintptr_t)stream->_p;
        words[32] = (uintptr_t)stream->_write;
        words[33] = stream->_cookie == (void *)stream;
        if (words[9] == 0 && words[10] == 0 && words[11] == 0) words[0] |= 128;
        if (words[5] == 1) words[0] |= 16;
        uintptr_t extra = (uintptr_t)stream->_extra;
        if (extra <= UINTPTR_MAX - 8 && (extra + 8) % _Alignof(pthread_mutex_t) == 0 &&
            readable(libc, extra, 8 + sizeof(pthread_mutex_t) + 1)) {
            words[7] = 1;
            __builtin_memcpy(&words[8], (const void *)(extra + 8), sizeof(uint64_t));
            words[0] |= 32;
        }
    }
    uintptr_t functions[5] = {(uintptr_t)&pthread_mutex_lock, (uintptr_t)&pthread_mutex_unlock,
        (uintptr_t)&__error, (uintptr_t)&write, (uintptr_t)&dispatch_once_f};
    int bound = 1;
    for (int i = 0; i < 5; ++i) bound &= bind_function(functions[i], words + 12 + i * 4, images);
    if (bound) words[0] |= 64;
    if (words[33] && bind_function(words[32], words + 34, images)) words[0] |= 256;
    char output[38 * 17];
    size_t length = 0;
    for (int i = 0; i < 38; ++i) length = append_hex(output, length, words[i]);
    if (write(STDERR_FILENO, output, length) != (ssize_t)length) _exit(98);
    _exit(words[0] == 511 && words[1] == 0 && words[2] == 0 && words[3] == 0 ? 0 : 97);
}
