#include <stdint.h>

/* Exact generated profile workspace from the nRF52840 Static preset. */
uint8_t giftui_signal_analyzer_profile_storage[28016];

/* Live capture plus the one complete publication snapshot: 2 * 2,404 * 24. */
uint8_t giftui_signal_analyzer_capture_storage[115392];

/* One full-width 480 x 4 RGB565 raster/payload/in-flight slot. */
uint8_t giftui_signal_analyzer_raster_staging[3840];

uint32_t giftui_signal_analyzer_storage_bytes(void)
{
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_profile_storage) : "memory");
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_capture_storage) : "memory");
    __asm__ volatile("" : : "r"(giftui_signal_analyzer_raster_staging) : "memory");
    return sizeof(giftui_signal_analyzer_profile_storage) +
        sizeof(giftui_signal_analyzer_capture_storage) +
        sizeof(giftui_signal_analyzer_raster_staging);
}
