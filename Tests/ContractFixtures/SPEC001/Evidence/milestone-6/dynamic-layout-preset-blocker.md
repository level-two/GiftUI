# Dynamic layout preset blocker

The production Dynamic semantic-to-layout join now uses the real
`SignalAnalyzerView`, state binding, semantic expansion, canonical text
metrics, `LayoutEngine`, bounded Dynamic layout workspace, and atomic resolved
layout publication storage. It does not use the integrated-cycle fixture's
layout substitute.

The normal hierarchy measured 52 layout scopes, 117 text scalars, 20 text
lines, 117 positioned glyphs, and depth 6. The diagnostic-present maximum
measured 53 layout scopes, 129 text scalars, 21 text lines, 129 positioned
glyphs, and depth 6. Semantic expansion generated 155 recording identities in
the normal state and 158 in the diagnostic-present state; the published
structural maxima remain the separately approved 80 and 81.

At the time of discovery, the schema-3 preset admitted 32 layout scopes.
Running the same diagnostic-present hierarchy with that exact preset therefore fails closed as
`LayoutError.capacityExhausted` before layout publication. The existing text,
glyph, and depth capacities admit the measured maximum; only layout-scope
capacity is deficient.

## Resolution

On 2026-09-20 the maintainer explicitly approved the measured additional
layout scopes. SPEC-013 and SPEC-015 now require 53 layout scopes and the
derived exact candidate/render-workspace byte projections. The regenerated
schema-3 presets admit the diagnostic-present production join at the exact
approved limit, so this former blocker no longer prevents T6.7. Host-loop,
render, input-routing, console-ownership, and connected validation work remain
open and are not claimed by this resolution.

Reproduction:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter signalAnalyzerDynamicLayoutJoinMeasuresDiagnosticMaximum
```
