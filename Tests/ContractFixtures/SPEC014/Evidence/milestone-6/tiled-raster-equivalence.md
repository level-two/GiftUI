# SPEC-014 T6.3 Tiled Raster Equivalence

Date: 2026-09-13

The tiled integration test reads the checked-in SPEC-012 raster-vector YAML as
its authoritative source. It replays all 17 canonical vectors through the
production operation-major traversal, shared stroke rasterizer, bounded tile
workspace, maximal-run payload emitter, and a synchronous recording target.
The target payloads are reconstructed in submission order and compared against
the exact RGB565 palette and zero-tolerance masks in the fixture.

A separate mixed-operation comparison runs a cross-tile fill and a three-row
exact monochrome glyph bitmap with painter overwrite through tiled and
full-surface RGB565 realizations. Their complete logical byte images must be
identical. Together the cases cover partial final tiles, empty intersections,
clips, negative translated coordinates, tile and region boundaries, canonical
RGB rounding, and later-operation replacement.

Run from the repository root:

```sh
scripts/contracts/check-spec-012-raster-vectors.rb
swift test --filter everyCanonicalStrokeMatchesTiledRGB565
swift test --filter tiledFillAndExactGlyph
swift test --filter tileEmitter
```

All comparisons are exact and passed on 2026-09-13.
