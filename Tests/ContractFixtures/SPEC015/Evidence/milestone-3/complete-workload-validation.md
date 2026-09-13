# Complete workload validation

`SignalAnalyzerWorkloadStartupValidation` is the pure stage-3 gate. It rejects
schema versions other than 2 before source-to-limit comparison, then requires
the complete generated runtime limit value and the exact mappings for semantic
nodes and actions, layout scopes, render semantic scopes, traversal depth,
text lines, positioned glyphs, ordinary operations, input events, completion
facts, observable locations/registrations/associations, interaction actions
and hit regions, and the separate 1/32/1 fact stores.

The Drawing sub-gate requires the normative 5/202/12/5/832/16/5 minima and
exact equality with their Drawing limit leaves. It separately checks the
combined ordinary-plus-stroke operation bound and dynamic/static Canvas table
rules. The pacing gate preserves 250,000-microsecond frame and service bounds,
50,000-microsecond transition spacing, the 20/2/6 producer categories, 28
admitted facts, 32 physical compact slots, a four-slot margin, and three
retryable refusals.

Focused tests cover all four successful generated presets; schema 1; each zero
and independently mismatched manifest source count; every cardinality and
pacing field; the 34-to-33 fact-storage boundary; every Drawing minimum; the
first Drawing excess; and dynamic/static metadata mismatch. The generated
164-row limit-leaf corpus remains the exhaustive proof that every nested
`RuntimeProfileLimits` leaf is present and fresh.

Reproduction:

```sh
scripts/format-swift.sh
ruby scripts/contracts/check-spec-015-generated-workload.rb
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
