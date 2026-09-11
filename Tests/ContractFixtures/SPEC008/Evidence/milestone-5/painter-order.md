# Painter Order Evidence

The direct render-view golden supplies three structural children in source
order: an opaque green background, one three-line text occurrence, and an
opaque blue background over the same bounds. The resulting event sequence
preserves both fills around the intervening text, proving there is no sorting,
cross-operation batching, resource/color reordering, or opaque-overdraw
elimination. Because ZStack reaches Render Lowering as the same canonical
structural child order, this is its required back-to-front painter order.

The text occurrence contains two non-empty lines separated by an empty line.
It emits exactly two complete positioned-glyph groups; the empty line emits
none, and glyph indices advance occurrence-wide as `0`, `1`, then `2`.

Run:

```sh
swift test --filter sourceOrderChildrenPaintBackToFrontWithoutOpaqueEliminationAndLinesStayGrouped
scripts/contracts/check-spec-008-painter-order.rb
```
