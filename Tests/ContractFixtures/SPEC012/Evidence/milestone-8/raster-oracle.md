# SPEC-012 T8.2 Independent Raster Oracle

Date: 2026-09-13

The registered raster oracle is independent of every SPEC-014 production
target. It parses only the frozen SPEC-012 vector document and computes:

- exact doubled-integer segment, projection, disk, and pixel-center tests;
- Q160 widened-integer normalized exterior offsets;
- exact-rational offset-edge intersections and closed polygon tests;
- the fixed ten-times-half-width miter decision and bevel fallback;
- zero-tangent removal, inherited half-open clipping, and painter replacement;
- exact RGBA8888 and round-to-nearest big-endian RGB565 bytes.

Run from the repository root:

```sh
scripts/contracts/check-spec-012-raster-vectors.rb
scripts/contracts/run-spec-012.sh --profile macos-dynamic
```

The standalone command produces zero-tolerance host evidence. The registered
profile command records the same oracle and its input identity before running
the profile-specific compile and inspection checks. No backend implementation
is imported or invoked.
