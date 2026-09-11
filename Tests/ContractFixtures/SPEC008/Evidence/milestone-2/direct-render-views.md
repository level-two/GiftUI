# T2.4 Direct Render View Evidence

Date: 2026-09-11

The `GiftUIRenderLoweringTests` target contains reusable direct
`SemanticRenderView` and `ResolvedRenderLayoutView` fixtures keyed by the
closed `RenderFixtureIdentity` token enum. The fixtures are test-only inputs
for the upcoming shared preflight and failure corpus.

Reproduce on the pinned host toolchain:

```sh
swift test --filter DirectRenderViewFixtureTests
scripts/contracts/check-spec-008-direct-render-views.rb
swift package dump-package | ruby scripts/contracts/check-target-dependencies.rb
```

The valid pair proves independent semantic/layout counts and exact transparent,
render-only, text-line, and occurrence-wide glyph relationships. Malformed
variants cover unequal roots, missing and duplicate identity data, modifier
and text arity, every view lookup family’s unknown/out-of-range behavior,
prohibited in-range `nil`, line-index gaps, glyph/line disagreement, and
occurrence-wide glyph-index gaps. The audit rejects pointer, hash,
memory-layout, unsafe-byte, or object-identity comparison.
