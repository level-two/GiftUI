#include <stdint.h>
#include <string.h>

typedef struct {
    int32_t control;
    int32_t capture;
    uint16_t identity;
    uint16_t reserved;
} spike003_baseline_model_record;

spike003_baseline_model_record spike003_baseline_models[2];

void spike003_baseline_reset(void) {
    memset(spike003_baseline_models, 0, sizeof(spike003_baseline_models));
    spike003_baseline_models[0].identity = 1;
    spike003_baseline_models[1].identity = 2;
    spike003_baseline_models[0].control = 1;
    spike003_baseline_models[0].capture = 2;
    spike003_baseline_models[1].control = 8;
    spike003_baseline_models[1].capture = 13;
}

uint16_t spike003_baseline_identity(uint8_t slot) { return spike003_baseline_models[slot].identity; }
int32_t spike003_baseline_control(uint8_t slot) { return spike003_baseline_models[slot].control; }
int32_t spike003_baseline_capture(uint8_t slot) { return spike003_baseline_models[slot].capture; }
int32_t spike003_baseline_derived(uint8_t slot) {
    return spike003_baseline_models[slot].control + spike003_baseline_models[slot].capture;
}
void spike003_baseline_add_control(uint8_t slot, int32_t delta) {
    spike003_baseline_models[slot].control += delta;
}
void spike003_baseline_add_capture(uint8_t slot, int32_t delta) {
    spike003_baseline_models[slot].capture += delta;
}
