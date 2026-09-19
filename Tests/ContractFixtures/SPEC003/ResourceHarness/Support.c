#include <stddef.h>
#include <stdint.h>

volatile uint32_t giftui_spec003_resource_sink;

void giftui_spec003_consume(uint32_t value)
{
    giftui_spec003_resource_sink = value;
}

void bzero(void *destination, size_t count)
{
    volatile unsigned char *bytes = (volatile unsigned char *)destination;
    while (count > 0) {
        *bytes = 0;
        ++bytes;
        --count;
    }
}

void *memset(void *destination, int value, size_t count)
{
    volatile unsigned char *bytes = (volatile unsigned char *)destination;
    while (count > 0) {
        *bytes = (unsigned char)value;
        ++bytes;
        --count;
    }
    return destination;
}

void *memcpy(void *destination, const void *source, size_t count)
{
    volatile unsigned char *output = (volatile unsigned char *)destination;
    const volatile unsigned char *input = (const volatile unsigned char *)source;
    while (count > 0) {
        *output = *input;
        ++output;
        ++input;
        --count;
    }
    return destination;
}
