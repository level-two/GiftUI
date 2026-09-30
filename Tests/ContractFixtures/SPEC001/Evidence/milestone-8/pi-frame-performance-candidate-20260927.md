# Pi frame performance candidate — 2026-09-27

This record follows the [measured phase analysis](pi-performance-analysis-20260927.md)
for SPEC-001 T8.1. The changes below were subsequently measured on the Pi;
see the [2026-09-28 connected measurement](pi-performance-candidate-measurement-20260928.md).
No panel-visible response measurement exists.

| Commit | Change | Expected reduction |
| --- | --- | --- |
| `41ab45dc` | Track the first and last affected pixel in each RGB565 tile and scan only that interval during payload formation and failure drain. | Avoid flag checks before and after sparse operation coverage. |
| `499bb073` | Convert the first projected framebuffer row of each region, then copy its bytes to that region's remaining physical rows. | Avoid repeated RGB565 conversion and source indexing for vertically duplicated rows. |
| `9fd4a807` | Check a run's source byte range once before writing its pixels. | Avoid repeated checked row-offset arithmetic for every emitted pixel. |

These changes preserve operation and region order, maximal horizontal runs,
payload limits, output byte order, and the existing mapped-framebuffer storage.
The row copy still writes the same physical byte volume; the prior scratch-row
trial was slower on the Pi, so a speedup from this distinct mapped-row copy
must be measured rather than inferred. A new retained semantic lookup cache
was also tried locally but discarded before commit because the earlier
connected retained-cache trial crashed after its first frame.

## Verification

- Focused RGB565 payload tests passed, including full-surface pixel comparison,
  payload segmentation, failure drain, and exact platform high-water cases.
- The new Pi projection test passed for RGB565 byte order, adjacent-row
  overlap, and region ordering.
- The Pi host-native full-loop rehearsal passed on the candidate source.
- The Pi host-native exact-raster gate matched its reference pixels, behavior,
  and fault cases.
- The final ARMv6 hard-float release cross-build passed with ELF build ID
  `5135704b50e6a0b8acfa10a54e2514affa43b797`. At candidate validation
  time, its artifact remained under `.build/raspberry-pi/artifacts/` and had
  not been deployed.
- Governance validation passed after linking the preceding investigation files
  to T8.1. The SPEC-001 macOS dynamic contract driver passed 255 reference
  tests across 17 suites.

The broader `scripts/test.sh macos-dynamic` gate was stopped after SPEC-001
passed. Unrelated SPEC-003 and SPEC-004 dependency-fixture checks, SPEC-005's
generated-asset hash, and SPEC-006's legacy-string scan failed on files or
declarations unchanged by this work. The gate's initial governance check also
found eight unlinked investigation files; that traceability issue was fixed
and `scripts/validate-governance.rb` passed on the final tree. The later
connected run measured a 2.322-second mean frame service across 25 steady
frames, still above the 250 ms period. T8.1 remains blocked by cadence and
unmeasured physical interaction.
