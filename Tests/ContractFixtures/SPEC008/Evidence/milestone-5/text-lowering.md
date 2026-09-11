# Text Lowering Evidence

The exact-transport golden changes resolved glyph baselines and supplies a
partial logical line clip. Render Lowering preserves the nominal font instance,
glyph identities, occurrence-wide indices, glyph baselines, group count, and
effective foreground while applying only the required checked surface
intersection. It emits neither text nor measurement data.

Focused negative cases independently inject a different resource, an unknown
instance, and an unknown glyph. Each returns `incompatibleTextResource` during
preflight with zero sink-capacity reads and zero `begin` calls. The source audit
excludes raw-text, shaping, fallback, and advance behavior from both passes.

Run:

```sh
swift test --filter textLoweringPreservesResolvedGlyphMeaningAndOnlyIntersectsItsClip
swift test --filter textResourceInstanceAndGlyphDisagreementsAllFailBeforeBegin
scripts/contracts/check-spec-008-text-lowering.rb
```
