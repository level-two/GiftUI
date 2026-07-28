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
- backend-independent colors, text runs, render operations, and sinks;
- `View`, result-builder composition, stacks, text, and buttons;
- runtime-neutral `ViewVisitor` traversal.

The result builder uses fixed generic overloads through five children. Swift
6.3.2 requests forbidden type metadata when the equivalent variadic-pack
builder is instantiated by an Embedded client module; the fixed overloads
retain static types and compile cleanly for the accepted thermostat arity.

Embedded compilation exposes only `StaticString` text and identified button
actions. The allocating build additionally exposes the dynamic text and
callback storage used by `GiftUIDynamicConveniences`.

Not yet admitted to this layer:

- rendering backends.

Portable render text retains `StaticString` labels or bounded integer/suffix
values and can emit UTF-8 code units without constructing a `String`.
Heap-backed render text and the array-backed `DisplayList` are available only
through dynamic targets.

The retained `ViewNode` graph, public array-backed `LayoutNode` snapshot,
string-path build context, and array/dictionary interaction snapshot now live
in `GiftUIRuntimeDynamic`. `GiftUIRuntimeStatic` provides their bounded
replacements. Rendering backends remain separate target-specific layers.

The class-backed `@State` wrapper, task-local binding context, string state
keys, and `[StateKey: Any]` store also live in `GiftUIRuntimeDynamic`.

## Static runtime layer

**Status:** Compiles in regular and Embedded Swift.

`GiftUIRuntimeStatic` provides an index-linked arena with these fixed Embedded
capacities:

- 64 layout nodes;
- 16 nested retained containers;
- 16 hit regions;
- 16 typed state slots per generated value-type store.

The runtime measures and places groups, horizontal/vertical stacks, static
text, and identified-action buttons. It reports deterministic errors for node,
depth, and hit-region exhaustion and rejects dynamic text/action storage. On
Embedded Swift the arena uses inline fixed-size arrays. The macOS conformance
harness uses capacity-checked arrays because `InlineArray` has a macOS 26
availability floor while this package still supports macOS 15.

Static state uses stable numeric `StaticStateSlot<Value>` identities and
homogeneous fixed-capacity `StaticStateStorage<Value>` instances. Generated
applications use one store per state value type, avoiding strings, `Any`,
class boxes, and task-local binding. Slot overflow is deterministic, and writes
set an invalidation bit that is cleared after rendering. The dynamic-only
`@State` spelling remains available from `GiftUIRuntimeDynamic`.

The same portable thermostat declaration compiles as an ARM Embedded Swift
module and runs in the host conformance suite through both runtimes. It uses
bounded decimal `Text(integer:suffix:)`, and the suite compares intrinsic
layout, node counts, hit regions, action identifiers, and typed state changes
as well as ordered render operations.

The fixed layout arena retains portable text payloads and emits render
operations directly into a caller-provided sink. This avoids a static
display-list allocation, propagates sink capacity failures, and produces the
same ordered operations as the dynamic runtime for the portable thermostat.
The conformance suite also rebuilds the portable thermostat from a typed
static slot after mutation and checks both runtimes again.

## RGB565 backend layer

**Status:** Compiles in regular and Embedded Swift.

`GiftUIBackendRGB565` rasterizes directly into reusable physical row tiles.
The fixed maximum is 480 × 16 × 2 bytes (15,360 bytes), while host builds
allocate only the configured width and tile height. Logical drawing is clipped
to the active physical tile before pixel writes and supports 0°, 90°, 180°,
and 270° rotation plus explicit most- or least-significant-byte-first output.

The shared `GiftUIBuiltinFont` target stores glyph rows without arrays,
dictionaries, or runtime strings. Host integration tests replay the static
thermostat into 480 × 320 RGB565 tiles, compare every pixel with the quantized
RGBA renderer, pin a deterministic golden hash, and assert that no presented
or allocated tile exceeds 15,360 bytes.
