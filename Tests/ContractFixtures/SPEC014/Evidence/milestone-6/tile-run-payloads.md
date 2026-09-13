# SPEC-014 T6.2 Tile Run and Payload Segmentation

Date: 2026-09-13

The tiled emitter scans the bounded workspace in row-major order, forms one
maximal horizontal region for each contiguous set of affected pixels, and
copies its canonical big-endian RGB565 bytes directly into the reserved
writer. A checked scalar cursor is the only state retained between synchronous
payload submissions. The next run triggers a flush before it would exceed the
writer's byte or region capacity.

Focused tests freeze exact region origins, pixel counts, bytes, payload counts,
region counts, and high-water values for multiple segmentations. They also
cover empty workspaces, a run larger than the admitted writer, and deterministic
zeroing of the reusable writer storage.

Run from the repository root:

```sh
swift test --filter tileEmitter
swift test --filter RasterWorkTracker
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

T6.3 retains the zero-tolerance full operation-corpus comparison across tiled
and full-surface realizations.
