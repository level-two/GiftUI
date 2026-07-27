# GiftUI Embedded Layer Inventory

This inventory tracks the top-down migration gates used by
`scripts/nrf52840/compile-layer.sh`. Each accepted layer must compile both in
the regular SwiftPM build and with the pinned Embedded Swift compiler for
`armv7em-none-none-eabi`.

## GiftUI portable declaration layer

**Status:** Compiles in regular and Embedded Swift.

Included:

- geometry and checked layout arithmetic;
- runtime-profile markers;
- input and identified-action values;
- `View`, result-builder composition, stacks, text, and buttons;
- runtime-neutral `ViewVisitor` traversal.

Embedded compilation exposes only `StaticString` text and identified button
actions. The allocating build additionally exposes the dynamic text and
callback storage used by `GiftUIDynamicConveniences`.

Not yet admitted to this layer:

- class/task-local `@State` binding and string structural keys;
- the retained `ViewNode` graph and public array-backed `LayoutNode` snapshot;
- array/dictionary interaction snapshots;
- `String`-backed render runs and `DisplayList`;
- rendering backends.

The retained graph, dynamic state, and interaction storage are inputs to the
dynamic runtime migration. Bounded replacements belong to
`GiftUIRuntimeStatic`. Render operations and backends are intentionally left
for the separate render-layer activity.

## Static runtime layer

**Status:** Compiles in regular and Embedded Swift.

`GiftUIRuntimeStatic` provides an index-linked arena with these fixed Embedded
capacities:

- 64 layout nodes;
- 16 nested retained containers;
- 16 hit regions.

The runtime measures and places groups, horizontal/vertical stacks, static
text, and identified-action buttons. It reports deterministic errors for node,
depth, and hit-region exhaustion and rejects dynamic text/action storage. On
Embedded Swift the arena uses inline fixed-size arrays. The macOS conformance
harness uses capacity-checked arrays because `InlineArray` has a macOS 26
availability floor while this package still supports macOS 15.

State slots and render emission remain outside this accepted layer. The first
static application fixture owns typed mutable state and dispatches bounded
action identifiers explicitly; adapting `@State` to generated/fixed slots is a
subsequent state-layer step.
