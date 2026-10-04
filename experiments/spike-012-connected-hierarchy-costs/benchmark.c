#include <stdint.h>
#include <zephyr/kernel.h>
#include <cmsis_core.h>
#include "static_host_storage.h"

extern uint32_t giftui_spike012_packed(void *, uint32_t, void *, uint32_t, uint32_t, uint32_t);
extern uint32_t giftui_spike010_derive(uint32_t, uint32_t, uint32_t, uint32_t, uint16_t, uint16_t);
#ifndef SPIKE012_MODE
#define SPIKE012_MODE 0
#endif
/* Serialized little-endian uint32_t words, read by symbol-addressed SWD. */
volatile struct {
    uint32_t magic, status, mode, iterations, cpu_hz, clock_hz, calibration_cycles, calibration_ticks;
    uint32_t batch_cycles[2][5], batch_results[2][5];
    uint32_t depth_refusal, nodes_refusal, post_refusal;
} giftui_spike012_results = {.mode = SPIKE012_MODE};
volatile uint32_t giftui_spike012_continue_production;

static int giftui_spike012_run(void) {
    struct giftui_static_host_storage regions;
    giftui_spike012_results.magic = 0x53503132;
    giftui_spike012_results.status = 1;
    giftui_spike012_results.iterations = 32;
    giftui_spike012_results.cpu_hz = SystemCoreClock;
    giftui_spike012_results.clock_hz = CONFIG_SYS_CLOCK_HW_CYCLES_PER_SEC;
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
    __DSB(); __ISB();
    uint32_t tick = k_cycle_get_32(), cycle = DWT->CYCCNT;
    k_busy_wait(100000);
    giftui_spike012_results.calibration_cycles = DWT->CYCCNT - cycle;
    giftui_spike012_results.calibration_ticks = k_cycle_get_32() - tick;
    if (giftui_signal_analyzer_storage_regions(&regions) != 0) return 1;
    for (uint32_t diagnostic = 0; diagnostic < 2; ++diagnostic) {
        for (uint32_t sample = 0; sample < 5; ++sample) {
            uint32_t sum = 0;
            __DSB(); __ISB(); cycle = DWT->CYCCNT;
            if (giftui_spike012_results.mode == 2) {
                for (uint32_t i = 0; i < 32; ++i)
                    sum += giftui_spike010_derive(1, 2, diagnostic, 1, 64, 512);
            } else {
                sum = giftui_spike012_packed(regions.profile, regions.profile_bytes,
                    regions.capture, regions.capture_bytes, diagnostic, 32);
            }
            __DSB(); __ISB();
            giftui_spike012_results.batch_cycles[diagnostic][sample] = DWT->CYCCNT - cycle;
            giftui_spike012_results.batch_results[diagnostic][sample] = sum;
        }
    }
    if (giftui_spike012_results.mode == 2) {
        giftui_spike012_results.depth_refusal = giftui_spike010_derive(1, 2, 1, 1, 1, 512);
        giftui_spike012_results.nodes_refusal = giftui_spike010_derive(1, 2, 1, 1, 64, 1);
        giftui_spike012_results.post_refusal = giftui_spike010_derive(1, 2, 1, 1, 64, 512);
    }
    giftui_spike012_results.status = 2;
    /* Hold before production startup while preserving its reachable link closure. */
    while (giftui_spike012_continue_production == 0) k_sleep(K_MSEC(10));
    return 0;
}
