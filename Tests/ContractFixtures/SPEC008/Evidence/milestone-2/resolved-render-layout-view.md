# T2.3 Resolved Render Layout View Evidence

Date: 2026-09-11

`GiftUILayout` owns `ResolvedRenderTextLine`, `ResolvedRenderGlyph`, and
`ResolvedRenderLayoutView`. A narrow result-storage and sink adapter makes the
successful SPEC-007 publication available as a read-only render projection;
the adapter forwards exact identities and publication fields and performs no
text measurement, shaping, resource translation, or rendering.

Reproduce on the pinned host toolchain:

```sh
swift test --filter ResolvedRenderLayoutViewTests
scripts/contracts/check-spec-008-resolved-render-layout-view.rb
```

The focused layout fixture validates exact root and scope geometry, logical
clips, line counts and indices, occurrence-wide glyph indices, font-instance
and glyph identities, baselines, and glyph counts derived from the one
published result. Unknown identities and all tested out-of-range line/glyph
indices return `nil`.

The source audit proves the three normative declarations have one owner,
imports only `GiftUI` and `GiftUITextResources`, and contains no public,
render-core/lowering, failure, or capability coupling.
