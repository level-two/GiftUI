# T3.2 Bounded Dynamic Storage

Date: 2026-09-12

`DynamicProfileStorage` allocates one non-overlapping heap region for each of
the sixteen SPEC-013 audit families. Its audit method checks the retained
successful Dynamic audit against every live region and rejects family order,
extent, or count drift as an invariant violation. The exact owned payload
total excludes the separately reported observed allocator reserve and spare
payload values.

A fixed 51-case logical-limit vocabulary covers the independent Semantic
candidate and published capacities, Layout, render and structural workspace,
Canvas, Path, drawing plan, Observable State live and candidate stores,
Interaction candidate and committed stores, admission and sealed batches,
pointer sources, coordinator state, and failure state. Reservation checks
checked arithmetic and the immutable configured limit before mutation. Heap
or `Array` headroom cannot change its result.

Verification command:

```text
swift test --filter GiftUIRuntimeDynamicTests
```

Result: six focused tests passed under Apple Swift 6.3.3. The table-driven
boundary test exercised all 51 logical dimensions at exact limit and first
excess, checked unchanged use/high-water state after every rejection, and
confirmed all sixteen exact audit regions total 136 artificial payload bytes.
