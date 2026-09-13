# SPEC-014 T6.1 Operation-Major Tile Workspace

Date: 2026-09-13

Raster Core provides one caller-owned, bounded RGB565 tile workspace. Backend
Integration walks all full-width row tiles intersecting one resolved operation
from top to bottom, including a partial final tile, and completes each raster
and consumer borrow synchronously. The traversal does not receive a producer
closure, retain operation data, revisit an operation, or allocate a full-frame
buffer.

Focused tests cover exact visit, reset, raster, consumer, and operation counts;
empty intersection; partial final tiles; canonical byte placement; workspace
capacity and encoding rejection; invalid lifecycle calls; and idle restoration
after raster or consumer failure.

Run from the repository root:

```sh
swift test --filter OperationMajorTileTraversal
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

All focused tests and all four compilation profiles pass. Horizontal run
formation, payload segmentation, and target submission remain assigned to
T6.2 and later tasks.
