# SPEC-014 T4.4 Canonical Stroke Raster

Date: 2026-09-13

## Result

Raster Core now consumes one borrowed SPEC-012 `StraightLineStrokeView` and
emits exact row-major covered pixels without retaining the view, allocating a
point/segment collection, consulting Canvas bounds, antialiasing, or using
floating point. Invalid headers, accessors, ranges, translation, damage, and
replacement refusal remain explicit local results.

The focused Swift test mirrors all 17 independently frozen SPEC-012 masks.
It covers horizontal, vertical, diagonal, single/repeated/zero points, every
cap/join/angle class, exact reversal, miter-limit bevel fallback, odd/even
widths, negative translated geometry, every clip edge, empty clip, painter
replacement, and the RGB-boundary geometry.

## Reproduction

From the repository root:

```sh
scripts/contracts/check-spec-012-raster-vectors.rb
swift test --filter RasterStrokeCoverage
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

The first command is the independent Q160 oracle. The Swift suite runs the
separate Int128/Q31 production implementation. The profile commands compile
the production source under all four registered configurations. BI-009 stays
pending until T5.4, T6.3, and T8.3 add concrete full-surface/tiled exact-byte
evidence.
