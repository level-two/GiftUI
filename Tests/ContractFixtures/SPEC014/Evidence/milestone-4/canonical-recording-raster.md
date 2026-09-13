# SPEC-014 T4.6 Canonical Recording Raster

Date: 2026-09-13

The canonical test endpoint conforms to the complete drawing sink grammar and
drives one recording `RasterSurface`. Its mixed transcript applies a clipped
negative-origin fill, the exact immutable glyph resource, and a later borrowed
stroke within a partial damage rectangle. The resulting affected mask, RGB565
bytes, row-major order, and three-byte row padding are frozen in `raster.yaml`.

The same corpus registers all 17 SPEC-012 vectors by authoritative source
reference and a translated-point overflow that performs no replacement. This
does not claim the later full-surface or tiled realization comparisons.

Run from the repository root:

```sh
scripts/contracts/check-spec-012-raster-vectors.rb
scripts/contracts/check-spec-014-fixtures.rb
swift test --filter canonicalRecordingEndpoint
swift test --filter RasterStrokeCoverage
swift test --filter RasterGlyphCoverage
swift test --filter RasterFillCoverage
```

All comparisons use zero pixel and channel tolerance. The recording surface is
test-owned dynamic storage and is not linked into any production profile.
