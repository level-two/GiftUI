# SPEC-014 T5.4 Full-Surface Raster Comparison

Date: 2026-09-13

The full-surface comparison replays every independently frozen SPEC-012 stroke
vector through both concrete full-surface encodings. It compares the final
painter-ordered logical image with the recording mask, exact canonical bytes
for each winning operation, poison retention for every unaffected pixel, and
poison retention for every odd-stride padding byte.

The canonical mixed recording endpoint plus the focused fill and exact glyph-
resource suites cover the remaining populated `raster.yaml` operations,
resource calls, partial/empty damage, clipping, order, and overflow cases.

Run from the repository root:

```sh
scripts/contracts/check-spec-012-raster-vectors.rb
scripts/contracts/check-spec-014-fixtures.rb
swift test --filter everyStrokeVectorMatchesBothFullSurfaceEncodings
swift test --filter GiftUIRasterCoreTests
swift test --filter fullSurfaceEmitter
```

All comparisons are exact. BI-007 and BI-009 remain pending until the tiled
realization and final cross-profile evidence tasks complete.
