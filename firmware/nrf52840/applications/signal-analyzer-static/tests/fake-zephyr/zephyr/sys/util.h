#ifndef GIFTUI_TEST_ZEPHYR_UTIL_H
#define GIFTUI_TEST_ZEPHYR_UTIL_H

#define BIT(index) (1U << (index))
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define ARRAY_SIZE(array) (sizeof(array) / sizeof((array)[0]))
#define BUILD_ASSERT(condition) _Static_assert(condition, #condition)
#define DT_ALIAS(name) 1
#define DT_NODE_HAS_PROP(node, prop) 0

#endif
