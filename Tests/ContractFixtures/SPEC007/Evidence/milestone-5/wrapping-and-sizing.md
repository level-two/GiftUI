# T5.2 Wrapping and Sizing Evidence

The canonical text pass wraps only from accumulated glyph advances. Focused
goldens cover absent width, positive width, zero width, over-wide first glyphs,
and leading, trailing, and consecutive explicit breaks. They assert line
membership, capped logical widths, glyph baseline x positions, line baseline
progression, line-gap offsets, and the complete ideal text height.

Ink metrics do not participate in wrapping, and a present width affects line
and resolved text widths without dropping any logical content.

Reproduce with:

```sh
swift test --filter LayoutTextTests
```
