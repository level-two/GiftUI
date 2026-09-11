# T6.4 Render Resource Instrumentation

The canonical work conformers use dense ordinal identities and direct,
size-independent accessors. Their equality implementation counts every render
identity comparison, while every semantic and resolved-layout property or
method entry counts one view access across preflight and streaming. The
registered geometric corpus reaches 16 occurrences and 16 positioned glyphs.
Observed work is exact:

- without text, view accesses are `26o + 25`;
- with text, view accesses are `26o + 33 + 2g`;
- identity comparisons are `4o + 1`.

The source audit rejects result rescans in those conformers and dynamically
growing retained collections in Render Lowering. Direct sink emission remains
the production path; there is no complete display list, glyph-run array, or
per-field preflight transcript.

The static probe calls the real generic `RenderProducer.produce` entry with a
finite concrete workspace and sink. Optimized whole-module SIL for both the
concrete entry and all Render Lowering sources contains no `alloc_ref`,
`alloc_box`, or `swift_allocObject`. Target IR exposes workspace size, stride,
alignment, each render/structural capacity, and the bytes for exactly one
caller-owned `Color` foreground slot.

The fixture registers nine `ContinuousClock` samples around synchronous
lowering, recursive semantic-frame high-water, foreground-slot high-water,
workspace bytes, and the four linked-section categories plus linker-map
ownership. These are instrumentation methods, not final Signal Analyzer or
connected-target measurements; the exact four-profile values and link images
remain T8.2-T8.4 evidence.

Reproduce the focused evidence with:

```console
swift test --filter renderTraversalWorkIsAffineInOccurrencesAndGlyphs
scripts/contracts/check-spec-008-render-work.rb
scripts/contracts/check-spec-008-render-view-static-exposure.sh
```
