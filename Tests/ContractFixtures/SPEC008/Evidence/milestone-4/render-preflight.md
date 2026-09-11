# SPEC-008 T4.2 Render Preflight Evidence

`GiftUIRenderLowering.RenderProducer` now owns the canonical bounded preflight.
It samples both immutable snapshot versions, validates the semantic-root to
layout-root relation, declared counts, dense forward/reverse ordinals,
preflight-only semantic/layout visits, every required scope and layout lookup,
modifier/text arity, line and occurrence-wide glyph indices, exact resource
compatibility, checked clips and damage, and exact operation, glyph, clip,
traversal, and text-line totals.

The preflight retains only bounded counters and traversal state. It emits no
operation, keeps no display list or per-field transcript, and reads idle sink
capacity exactly once after successful validation. Focused tests prove:

- the valid five-semantic-scope/two-layout-scope fixture produces two
  operations, two glyphs, maximum clip depth two, five first semantic visits,
  and two first layout visits;
- equality at all supplied limits succeeds, while declared semantic capacity,
  observed traversal depth, render-operation limits, and sink capacity fail at
  one over before emission;
- render-capacity failure precedes a simultaneously incompatible resource; and
- root, ordinal, snapshot, and text-resource disagreement return their exact
  errors without reading sink capacity or emitting operations.

Reproduce the focused evidence with:

```text
swift test --filter RenderPreflightTests
scripts/contracts/check-spec-008-render-preflight.rb
```

The source audit verifies the exact lowering imports, ordinal and snapshot
accesses, all four structural-capacity fields, checked intersection and
resource lookups, one sink-capacity access, and absence of sink lifecycle calls
or dynamic transcript storage. This is host execution and source evidence; it
does not claim simulator, deployment, connected-hardware, or flashing results.
