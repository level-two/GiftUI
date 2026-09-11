# T4.1 Checked Geometry Evidence

`LayoutGeometry` centralizes the SPEC-007 arithmetic used by measurement and
placement: independent proposal caps, checked size expansion and translation,
floored proposal insets, deterministic alignment offsets, checked gap totals,
constraint clamping, and rectangular intersection.

`LayoutGeometryTests` covers absent and present proposal axes, overflow at
size/origin/gap/alignment sites, centering with an oversized child, and both
overlapping and empty intersections. Empty intersections retain zero size at
the greater minimum edges, as required by SPEC-007.

Reproduce with:

```sh
swift test --filter LayoutGeometryTests
```
