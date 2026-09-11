# T2.2 Semantic Result Render Adapter Evidence

Date: 2026-09-11

`SemanticRenderResultStorage` extends the existing complete semantic-result
storage contract with one read-only render projection whose identity is
required to equal the layout projection identity. `SemanticLayoutResultSink`
exposes that projection after publication; no second semantic expansion,
identity translation, layout computation, or render operation is introduced.

Shared payload classification in `GiftUISemanticCore` maps admitted and invalid
text declarations to `text`, foreground/background modifiers to their exact
RGB-bearing scopes, both SPEC-007 frame modifiers to `clipBoundary`, and all
other current primitives/modifiers to `structural`. The profile-owned result
storage retains the canonical semantic children and selects an existing
flattened layout identity for transparent scopes.

Reproduce on the pinned host toolchain:

```sh
swift test --filter SemanticLayoutResultAdapterTests
scripts/contracts/check-spec-008-semantic-render-view.rb
```

The tests expand actual GiftUI declarations and verify:

- the render projection is obtained from the same published result storage;
- every reachable semantic identity resolves exactly once and selects an
  existing layout scope;
- transparent-root selection, text leaf arity, one-child render modifiers,
  foreground/background RGB, and exactly frame-owned clip boundaries;
- an oversized `Text(StaticString)` remains the invalid marker represented to
  SPEC-007 by the already-rejected invalid scalar path, without render work.

The source audit keeps all render-view declarations in
`GiftUISemanticCore`, imports only `GiftUI`, and rejects public/dynamic or
upward module coupling.
