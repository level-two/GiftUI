#include <stdint.h>
#include <string.h>

typedef struct {
    int32_t control;
    int32_t capture;
    uint32_t owner_token;
    uint16_t identity;
    uint16_t reserved;
} spike003_model_record;

typedef struct {
    uint8_t live;
    uint8_t model_slot;
    uint8_t registration;
    uint8_t dirty;
} spike003_location_record;

typedef struct {
    uint8_t active;
    uint8_t location;
    uint8_t model_slot;
    uint8_t reserved;
    uint16_t generation;
    uint16_t reserved2;
} spike003_registration_record;

typedef struct {
    uint16_t materialize;
    uint16_t attach;
    uint16_t mutation_report;
    uint16_t coalesced_report;
    uint16_t replacement;
    uint16_t detach;
    uint16_t stale_reject;
    uint16_t wake;
} spike003_operation_counters;

spike003_model_record spike003_models[2];
spike003_location_record spike003_locations[1];
spike003_registration_record spike003_registrations[1];
spike003_operation_counters spike003_counters;
uint16_t spike003_next_generation;

static uint32_t make_token(uint8_t registration, uint16_t generation) {
    return (uint32_t)registration | ((uint32_t)generation << 8);
}

void spike003_reset(void) {
    memset(spike003_models, 0, sizeof(spike003_models));
    memset(spike003_locations, 0, sizeof(spike003_locations));
    memset(spike003_registrations, 0, sizeof(spike003_registrations));
    memset(&spike003_counters, 0, sizeof(spike003_counters));
    spike003_models[0].identity = 1;
    spike003_models[1].identity = 2;
    spike003_models[0].control = 1;
    spike003_models[0].capture = 2;
    spike003_models[1].control = 8;
    spike003_models[1].capture = 13;
    spike003_next_generation = 1;
}

uint16_t spike003_model_identity(uint8_t slot) { return spike003_models[slot].identity; }
int32_t spike003_model_control(uint8_t slot) { return spike003_models[slot].control; }
int32_t spike003_model_capture(uint8_t slot) { return spike003_models[slot].capture; }
int32_t spike003_model_derived(uint8_t slot) {
    return spike003_models[slot].control + spike003_models[slot].capture;
}

uint8_t spike003_report(uint32_t token) {
    spike003_counters.mutation_report++;
    uint8_t index = (uint8_t)(token & 0xffu);
    uint16_t generation = (uint16_t)((token >> 8) & 0xffffu);
    if (index >= 1 || !spike003_registrations[index].active
        || spike003_registrations[index].generation != generation) {
        spike003_counters.stale_reject++;
        return 0;
    }
    uint8_t location = spike003_registrations[index].location;
    if (!spike003_locations[location].live
        || spike003_locations[location].model_slot != spike003_registrations[index].model_slot) {
        spike003_counters.stale_reject++;
        return 0;
    }
    if (spike003_locations[location].dirty) {
        spike003_counters.coalesced_report++;
    } else {
        spike003_locations[location].dirty = 1;
        spike003_counters.wake++;
    }
    return 1;
}

static uint32_t attach(uint8_t location, uint8_t model_slot) {
    if (location >= 1 || spike003_registrations[0].active
        || spike003_models[model_slot].owner_token != 0) {
        return 0;
    }
    spike003_counters.attach++;
    uint16_t generation = spike003_next_generation++;
    uint32_t token = make_token(0, generation);
    spike003_registrations[0].active = 1;
    spike003_registrations[0].location = location;
    spike003_registrations[0].model_slot = model_slot;
    spike003_registrations[0].generation = generation;
    spike003_models[model_slot].owner_token = token;
    spike003_locations[location].live = 1;
    spike003_locations[location].model_slot = model_slot;
    spike003_locations[location].registration = 0;
    spike003_locations[location].dirty = 0;
    return token;
}

uint32_t spike003_materialize(uint8_t location, uint8_t model_slot) {
    spike003_counters.materialize++;
    if (location >= 1) return 0;
    if (spike003_locations[location].live) {
        uint8_t preserved = spike003_locations[location].model_slot;
        return spike003_models[preserved].owner_token;
    }
    return attach(location, model_slot);
}

void spike003_detach(uint8_t location) {
    if (location >= 1 || !spike003_locations[location].live) return;
    spike003_counters.detach++;
    uint8_t model_slot = spike003_locations[location].model_slot;
    uint8_t registration = spike003_locations[location].registration;
    spike003_models[model_slot].owner_token = 0;
    spike003_registrations[registration].active = 0;
    memset(&spike003_locations[location], 0, sizeof(spike003_locations[location]));
}

uint32_t spike003_replace(uint8_t location, uint8_t model_slot) {
    spike003_counters.replacement++;
    spike003_detach(location);
    return attach(location, model_slot);
}

void spike003_model_add_control(uint8_t slot, int32_t delta) {
    spike003_models[slot].control += delta;
    uint32_t token = spike003_models[slot].owner_token;
    if (token != 0) (void)spike003_report(token);
}

void spike003_model_add_capture(uint8_t slot, int32_t delta) {
    spike003_models[slot].capture += delta;
    uint32_t token = spike003_models[slot].owner_token;
    if (token != 0) (void)spike003_report(token);
}

uint8_t spike003_take_dirty(uint8_t location) {
    uint8_t dirty = spike003_locations[location].dirty;
    spike003_locations[location].dirty = 0;
    return dirty;
}

uint64_t spike003_read_counters(void) {
    return (uint64_t)spike003_counters.materialize
        | ((uint64_t)spike003_counters.attach << 8)
        | ((uint64_t)spike003_counters.mutation_report << 16)
        | ((uint64_t)spike003_counters.coalesced_report << 24)
        | ((uint64_t)spike003_counters.replacement << 32)
        | ((uint64_t)spike003_counters.detach << 40)
        | ((uint64_t)spike003_counters.stale_reject << 48)
        | ((uint64_t)spike003_counters.wake << 56);
}
