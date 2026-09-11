# Text Declaration Integration Evidence

Implementation-plan task `T6.2` is complete. Existing focused declaration
tests exhaust empty and 96/97-byte boundaries, nine malformed UTF-8 forms,
embedded and trailing NUL handling, ASCII, degree-sign and replacement-scalar
bytes, plus `Int32.min`, `-1`, `0`, `1`, and `Int32.max` formatting.

The registered declaration probe exercises the required admitted values and
oversized invalid literal on both macOS profiles with zero measured heap
allocations and zero traps; the same source and compile fixtures are compiled
for ARMv6 and nRF52840 without claiming target execution. The semantic adapter
test proves that an oversized `Text(StaticString)` becomes the preserved
invalid scalar marker in the published shared layout projection.

The layout integration test feeds that marker shape through the production
layout entry point. It returns `.invalidDeclaration`, resets the acquired
workspace, never begins or publishes the layout sink, preserves prior current
output, and leaves the gated render-invocation count at zero. The source audit
also fixes validation before measurement and publication.

Run:

```sh
scripts/contracts/check-spec-008-text-integration.rb
swift test --filter BoundedText
swift test --filter invalidTextMarkerRemainsInvalidInTheSharedLayoutProjection
swift test --filter invalidTextDeclarationStopsBeforeLayoutPublicationOrRenderInvocation
```
