# SPEC-014 T5.1 Full-Surface RGBA8888 Buffer

Date: 2026-09-13

`FullSurfaceRGBA8888Buffer` is a bounded `RasterSurface` parameterized by
caller-owned storage. It owns no dynamic collection or host policy. Its
constructor proves the selected full-surface RGBA8888 descriptor and complete
stride-derived capacity before a frame can begin.

Focused tests use a 3 x 2 surface with a 15-byte odd stride. They verify exact
RGBA bytes, untouched padding, partial-damage admission, wrong-encoding and
first-byte-short construction rejection, begin/finish/discard grammar, and
validation-only draining after responsibility transfer.

Run from the repository root:

```sh
swift test --filter fullSurfaceRGBA8888Buffer
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

The test storage uses an Array only in the host test target. Production Raster
Core stores the generic bounded owner value and links no allocator itself.
