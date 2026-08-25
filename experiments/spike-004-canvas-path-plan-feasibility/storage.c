#include <stdint.h>

typedef struct { int32_t x; int32_t y; } spike004_point;
typedef struct { uint32_t start; uint16_t count; uint16_t reserved; } spike004_subpath;
typedef struct {
    uint32_t point_start;
    uint32_t point_count;
    uint16_t subpath_start;
    uint16_t subpath_count;
    uint32_t color;
    uint16_t width;
    uint16_t flags;
    uint32_t reserved;
} spike004_stroke_record;

enum {
    PLAN_POINTS = 836,
    PLAN_SUBPATHS = 16,
    PLAN_STROKES = 5,
    PATH_POINTS = 803,
    PATH_SUBPATHS = 12
};

#if defined(SPIKE004_COPY_PLAN)
static spike004_point plan_points[PLAN_POINTS];
static spike004_subpath plan_subpaths[PLAN_SUBPATHS];
static spike004_stroke_record plan_strokes[PLAN_STROKES];
static spike004_point path_points[PATH_POINTS];
static spike004_subpath path_subpaths[PATH_SUBPATHS];
#elif defined(SPIKE004_SEAL_PLAN)
// Two spare points permit the later-mutation fixture after the 836-point plan.
static spike004_point arena_points[PLAN_POINTS + 2];
static spike004_subpath arena_subpaths[PLAN_SUBPATHS + 1];
static spike004_stroke_record plan_strokes[PLAN_STROKES];
#elif defined(SPIKE004_DIRECT)
static spike004_point path_points[PATH_POINTS];
static spike004_subpath path_subpaths[PATH_SUBPATHS];
#endif

static uint32_t path_point_count;
static uint16_t path_subpath_count;
static uint32_t plan_point_count;
static uint16_t plan_subpath_count;
static uint16_t stroke_count;
static uint32_t digest;
static uint32_t failure;

void spike004_storage_reset(void) {
    path_point_count = 0;
    path_subpath_count = 0;
    plan_point_count = 0;
    plan_subpath_count = 0;
    stroke_count = 0;
    digest = 0x811c9dc5u;
    failure = 0;
}

static uint32_t record_point(int32_t x, int32_t y, uint8_t starts_subpath) {
    if (failure) return failure;
#if defined(SPIKE004_SEAL_PLAN)
    if (plan_point_count + path_point_count >= PLAN_POINTS + 2u) return failure = 2u;
    uint32_t index = plan_point_count + path_point_count;
    arena_points[index].x = x;
    arena_points[index].y = y;
    if (starts_subpath) {
        if (plan_subpath_count + path_subpath_count >= PLAN_SUBPATHS + 1u) return failure = 3u;
        uint16_t sub = (uint16_t)(plan_subpath_count + path_subpath_count++);
        arena_subpaths[sub].start = index;
        arena_subpaths[sub].count = 0;
    }
    arena_subpaths[plan_subpath_count + path_subpath_count - 1u].count++;
#else
    if (path_point_count >= PATH_POINTS) return failure = 2u;
    path_points[path_point_count].x = x;
    path_points[path_point_count].y = y;
    if (starts_subpath) {
        if (path_subpath_count >= PATH_SUBPATHS) return failure = 3u;
        path_subpaths[path_subpath_count].start = path_point_count;
        path_subpaths[path_subpath_count].count = 0;
        path_subpath_count++;
    }
    path_subpaths[path_subpath_count - 1u].count++;
#endif
    path_point_count++;
    digest = (digest ^ (uint32_t)x) * 16777619u;
    digest = (digest ^ (uint32_t)y) * 16777619u;
    return digest;
}

uint32_t spike004_move(int32_t x, int32_t y) { return record_point(x, y, 1); }
uint32_t spike004_line(int32_t x, int32_t y) {
    if (path_subpath_count == 0u) return failure = 1u;
    return record_point(x, y, 0);
}

uint32_t spike004_stroke(uint32_t color, uint16_t width) {
    if (failure) return failure;
    if (stroke_count >= PLAN_STROKES) return failure = 4u;
#if defined(SPIKE004_COPY_PLAN)
    if (plan_point_count + path_point_count > PLAN_POINTS
        || plan_subpath_count + path_subpath_count > PLAN_SUBPATHS) return failure = 5u;
    for (uint32_t index = 0; index < path_point_count; ++index) {
        plan_points[plan_point_count + index] = path_points[index];
    }
    for (uint16_t index = 0; index < path_subpath_count; ++index) {
        spike004_subpath copied = path_subpaths[index];
        copied.start += plan_point_count;
        plan_subpaths[plan_subpath_count + index] = copied;
    }
    plan_strokes[stroke_count] = (spike004_stroke_record){
        plan_point_count, path_point_count, plan_subpath_count,
        path_subpath_count, color, width, 3u, 0u
    };
    plan_point_count += path_point_count;
    plan_subpath_count += path_subpath_count;
#elif defined(SPIKE004_SEAL_PLAN)
    plan_strokes[stroke_count] = (spike004_stroke_record){
        plan_point_count, path_point_count, plan_subpath_count,
        path_subpath_count, color, width, 3u, 0u
    };
    plan_point_count += path_point_count;
    plan_subpath_count += path_subpath_count;
#elif defined(SPIKE004_DIRECT)
    // The sink consumes synchronously. No plan or path address is retained.
    for (uint32_t index = 0; index < path_point_count; ++index) {
        digest ^= (uint32_t)path_points[index].x + (uint32_t)path_points[index].y;
    }
#endif
    digest ^= color ^ width ^ stroke_count;
    stroke_count++;
    path_point_count = 0;
    path_subpath_count = 0;
    return digest;
}

uint64_t spike004_finish(void) {
    // Make every measured arena observable in the linked image.
#if defined(SPIKE004_COPY_PLAN)
    for (uint32_t index = 0; index < plan_point_count; ++index) {
        digest ^= (uint32_t)plan_points[index].x ^ (uint32_t)plan_points[index].y;
    }
    for (uint16_t index = 0; index < plan_subpath_count; ++index) {
        digest ^= plan_subpaths[index].start ^ plan_subpaths[index].count;
    }
#elif defined(SPIKE004_SEAL_PLAN)
    for (uint32_t index = 0; index < plan_point_count; ++index) {
        digest ^= (uint32_t)arena_points[index].x ^ (uint32_t)arena_points[index].y;
    }
    for (uint16_t index = 0; index < plan_subpath_count; ++index) {
        digest ^= arena_subpaths[index].start ^ arena_subpaths[index].count;
    }
#endif
#if defined(SPIKE004_COPY_PLAN) || defined(SPIKE004_SEAL_PLAN)
    for (uint16_t index = 0; index < stroke_count; ++index) {
        digest ^= plan_strokes[index].point_start ^ plan_strokes[index].point_count
            ^ plan_strokes[index].color ^ plan_strokes[index].width;
    }
#endif
    uint64_t counts = ((uint64_t)stroke_count << 48)
        | ((uint64_t)plan_subpath_count << 32)
        | (uint64_t)plan_point_count;
#if defined(SPIKE004_DIRECT)
    counts = ((uint64_t)stroke_count << 48) | 836u;
#endif
    return counts ^ ((uint64_t)failure << 56) ^ digest;
}

uint64_t spike004_candidate_run(uint32_t seed) {
    spike004_storage_reset();
    digest ^= seed;
    for (int32_t index = 0; index < 12; ++index) {
        int32_t x = index * 40;
        (void)spike004_move(x, 0);
        (void)spike004_line(x, 319);
    }
    (void)spike004_stroke(0x00555555u, 1u);
    for (int32_t channel = 0; channel < 4; ++channel) {
        int32_t base_y = 40 + channel * 60;
        int32_t transitions = channel == 0 ? 400 : 0;
        int32_t level = base_y;
        (void)spike004_move(0, base_y);
        (void)spike004_line(1, base_y);
        for (int32_t index = 0; index < transitions; ++index) {
            int32_t x = 2 + index;
            (void)spike004_line(x, level);
            level = level == base_y ? base_y + 20 : base_y;
            (void)spike004_line(x, level);
        }
        (void)spike004_line(479, level);
        (void)spike004_stroke(0x0000ff00u + (uint32_t)channel, 2u);
    }
    return spike004_finish();
}
