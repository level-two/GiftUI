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

The schema-3 preset currently admits 32 layout scopes. Running the same
diagnostic-present hierarchy with that exact preset therefore fails closed as
`LayoutError.capacityExhausted` before layout publication. The existing text,
glyph, and depth capacities admit the measured maximum; only layout-scope
capacity is deficient.

This evidence does not revise SPEC-013 or SPEC-015. T6.7 remains blocked until
the layout-scope capacity and its candidate/render-workspace byte projections
are deliberately amended and reapproved, or the portable hierarchy is
changed under its own governing authority.

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
