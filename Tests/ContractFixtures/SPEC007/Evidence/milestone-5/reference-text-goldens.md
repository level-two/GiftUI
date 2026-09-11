# T5.4 SPEC-005 Reference Text Goldens

`GiftUILayoutTests` now depends on the concrete
`GiftUIReferenceTextResources` package and drives layout with its validated
metrics view. The reference golden pins ASCII `A`, U+00B0, and an unsupported
valid scalar to glyphs `1`, `96`, and replacement glyph `0`; advances produce
baseline x positions `0`, `11`, and `18`, with ascent `16`, line height `20`,
and total width `29`. Every positioned glyph carries the exact instance-zero
resource identity from the SPEC-005 descriptor.

The complete focused text suite also covers empty content, CR/LF/CRLF,
positive/zero/absent wrapping, over-wide first glyphs, later baselines, line
gaps, empty lines, absolute translation, clipping, height caps, and checked
line-height and accumulated-advance overflow.

Reproduce with:

```sh
swift test --filter LayoutTextTests
```
