# T5.3 Positioned Text Evidence

Top-down text placement translates every relative line bound, line baseline,
and glyph baseline through the resolved text origin. The text primitive scope
intersects its inherited clip with its resolved bounds; each line intersects
that text clip with its logical bounds; every glyph reuses its line's exact
clip.

The height-cap golden proves that clipped-away content is still staged and
that a disjoint line produces a zero-size clip at the greater minimum point.
The padding golden proves all emitted coordinates are absolute root
coordinates and glyph indices remain source ordered across the occurrence.

Reproduce with:

```sh
swift test --filter LayoutTextTests
swift test --filter LayoutGeometryTests
```
