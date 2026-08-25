#include "nrf-resource-data.h"

#include <stddef.h>
#include <stdint.h>

typedef struct {
    uint32_t state[8];
    uint64_t bit_count;
    uint8_t block[64];
    size_t used;
} Spike005SHA256;

static const uint32_t round_constants[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

static uint32_t rotate_right(uint32_t value, unsigned count) {
    return (value >> count) | (value << (32 - count));
}

static uint32_t load_u32(const uint8_t *bytes) {
    return ((uint32_t)bytes[0] << 24) | ((uint32_t)bytes[1] << 16) |
        ((uint32_t)bytes[2] << 8) | bytes[3];
}

static void store_u32(uint8_t *bytes, uint32_t value) {
    bytes[0] = (uint8_t)(value >> 24);
    bytes[1] = (uint8_t)(value >> 16);
    bytes[2] = (uint8_t)(value >> 8);
    bytes[3] = (uint8_t)value;
}

static void transform(Spike005SHA256 *context, const uint8_t block[64]) {
    uint32_t words[64];
    for (unsigned index = 0; index < 16; ++index) {
        words[index] = load_u32(block + index * 4);
    }
    for (unsigned index = 16; index < 64; ++index) {
        uint32_t s0 = rotate_right(words[index - 15], 7) ^
            rotate_right(words[index - 15], 18) ^ (words[index - 15] >> 3);
        uint32_t s1 = rotate_right(words[index - 2], 17) ^
            rotate_right(words[index - 2], 19) ^ (words[index - 2] >> 10);
        words[index] = words[index - 16] + s0 + words[index - 7] + s1;
    }

    uint32_t a = context->state[0];
    uint32_t b = context->state[1];
    uint32_t c = context->state[2];
    uint32_t d = context->state[3];
    uint32_t e = context->state[4];
    uint32_t f = context->state[5];
    uint32_t g = context->state[6];
    uint32_t h = context->state[7];
    for (unsigned index = 0; index < 64; ++index) {
        uint32_t sum1 = rotate_right(e, 6) ^ rotate_right(e, 11) ^ rotate_right(e, 25);
        uint32_t choice = (e & f) ^ ((~e) & g);
        uint32_t temporary1 = h + sum1 + choice + round_constants[index] + words[index];
        uint32_t sum0 = rotate_right(a, 2) ^ rotate_right(a, 13) ^ rotate_right(a, 22);
        uint32_t majority = (a & b) ^ (a & c) ^ (b & c);
        uint32_t temporary2 = sum0 + majority;
        h = g;
        g = f;
        f = e;
        e = d + temporary1;
        d = c;
        c = b;
        b = a;
        a = temporary1 + temporary2;
    }
    context->state[0] += a;
    context->state[1] += b;
    context->state[2] += c;
    context->state[3] += d;
    context->state[4] += e;
    context->state[5] += f;
    context->state[6] += g;
    context->state[7] += h;
}

static void initialize(Spike005SHA256 *context) {
    static const uint32_t initial[8] = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    };
    for (unsigned index = 0; index < 8; ++index) {
        context->state[index] = initial[index];
    }
    context->bit_count = 0;
    context->used = 0;
}

static void update(Spike005SHA256 *context, const uint8_t *bytes, size_t count) {
    context->bit_count += (uint64_t)count * 8;
    while (count != 0) {
        size_t available = 64 - context->used;
        size_t amount = count < available ? count : available;
        for (size_t index = 0; index < amount; ++index) {
            context->block[context->used + index] = bytes[index];
        }
        context->used += amount;
        bytes += amount;
        count -= amount;
        if (context->used == 64) {
            transform(context, context->block);
            context->used = 0;
        }
    }
}

static void finalize(Spike005SHA256 *context, uint8_t result[32]) {
    uint64_t original_bits = context->bit_count;
    uint8_t marker = 0x80;
    uint8_t zero = 0;
    update(context, &marker, 1);
    while (context->used != 56) {
        update(context, &zero, 1);
    }
    uint8_t length[8];
    for (unsigned index = 0; index < 8; ++index) {
        length[7 - index] = (uint8_t)(original_bits >> (index * 8));
    }
    update(context, length, 8);
    for (unsigned index = 0; index < 8; ++index) {
        store_u32(result + index * 4, context->state[index]);
    }
}

static int equal_digest(const uint8_t left[32], const uint8_t right[32]) {
    uint8_t difference = 0;
    for (unsigned index = 0; index < 32; ++index) {
        difference |= left[index] ^ right[index];
    }
    return difference == 0;
}

static int validate_digest(const uint8_t *bytes, size_t count, const uint8_t expected[32]) {
    Spike005SHA256 context;
    uint8_t actual[32];
    initialize(&context);
    update(&context, bytes, count);
    finalize(&context, actual);
    return equal_digest(actual, expected);
}

int spike005_validate_inputs(
    const uint8_t *manifest,
    size_t manifest_count,
    const uint8_t manifest_digest[32],
    const uint8_t *bitmap,
    size_t bitmap_count,
    const uint8_t bitmap_digest[32]
) {
    if (manifest_count > 16384 || bitmap_count > 65536) {
        return 1;
    }
    if (!validate_digest(manifest, manifest_count, manifest_digest)) {
        return 2;
    }
    if (!validate_digest(bitmap, bitmap_count, bitmap_digest)) {
        return 3;
    }
    return 0;
}

int spike005_validate(void) {
    return spike005_validate_inputs(
        spike005_manifest,
        spike005_manifest_count,
        spike005_manifest_sha256,
        spike005_bitmap,
        spike005_bitmap_count,
        spike005_bitmap_sha256
    );
}
