# SPEC-012 T8.3-T8.4 Full-Surface and Tiled Consumer Join

Date: 2026-09-13

## Result

SPEC-014's production raster consumers now close SPEC-012's downstream
integration tasks without redefining the drawing contract. The full-surface
suite reads all 17 authoritative vectors from `raster-vectors.yaml` and
compares exact binary coverage plus RGBA8888 and RGB565 bytes. The bounded
operation-major tiled suite reads the same vectors, reconstructs submitted
RGB565 regions in order, and compares the same zero-tolerance mask and bytes.

The joined evidence covers round-to-nearest RGB565 conversion and big-endian
storage, partial final tiles, negative and clipped geometry, painter-order
replacement, equality/first-excess workspace bounds, checked arithmetic,
single borrowed-operation consumption, and workspace/payload poisoning. The
tiled implementation retains no normalized operation, Core address, or
complete-frame storage. Full-surface ownership remains confined to the
realizations whose validated configuration explicitly selects it.

## Reproduction

Run from the repository root:

```sh
scripts/contracts/check-spec-012-raster-vectors.rb
scripts/contracts/check-spec-014-fixtures.rb
swift test --filter everyStrokeVectorMatchesBothFullSurfaceEncodings
swift test --filter everyCanonicalStrokeMatchesTiledRGB565AcrossPartialTiles
swift test --filter oneShotProducerAndBorrowedOperationLeaveOnlyOwnedPayloadBytes
swift test --filter tileWorkspaceRejectsWrongShapeEncodingAndCapacity
swift test --filter RasterWorkTracker
```

These are host-execution and inspection results. They do not claim a connected
framebuffer, PiScreen, nRF52840 TFT, deployment, remote service, or board flash.

The detailed downstream records remain:

- `Tests/ContractFixtures/SPEC014/Evidence/milestone-5/full-surface-comparison.md`
- `Tests/ContractFixtures/SPEC014/Evidence/milestone-6/tiled-raster-equivalence.md`
- `Tests/ContractFixtures/SPEC014/Evidence/milestone-6/borrow-lifetime-evidence.md`
- `Tests/ContractFixtures/SPEC014/Evidence/milestone-6/platform-tile-high-water.md`
