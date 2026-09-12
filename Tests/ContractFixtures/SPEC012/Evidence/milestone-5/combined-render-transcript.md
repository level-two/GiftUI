# SPEC-012 T5.3 Combined Render Transcript Evidence

The canonical `fixtures.yaml` corpus now contains two ordered render cases.
The mixed case records one background fill, one nonempty round-cap/miter-join
stroke, one canonical no-op butt-cap/round-join stroke, and one positioned
glyph group in exact painter order under one begin/finish transaction. Every
stroke records exact opaque RGB, line width, cap, join, origin, inherited clip,
translated points, and explicit subpath ranges.

The zero-Canvas case records an empty drawing-plan summary and proves the
combined producer's result and begin/finish transcript equal the ordinary
SPEC-008 producer exactly. The fixture harness rejects missing fields, changed
case order, changed mixed event order, a nonempty no-op payload, and unequal
ordinary/combined zero-Canvas transcripts.

Reproduce the evidence with:

```sh
swift test --filter GiftUIDrawingTests
scripts/contracts/check-spec-012-harness.rb
```

This is host recording evidence. Cross-profile normalization remains assigned
to T6.5 and T9, and raster masks and encoded bytes remain assigned to T8.
