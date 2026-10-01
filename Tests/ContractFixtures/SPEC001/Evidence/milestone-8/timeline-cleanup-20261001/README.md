# Analyzer timeline and status cleanup — 2026-10-01

Implementation commits: `6f0d263c` (shared allocation-free timeline rounding)
and `d94683a7` (grid placement, header error slot, generated nRF projection,
and regression checks).

Timeline labels round to the nearest tenth, with whole seconds shown without
a decimal. Capture times and visible ranges retain their full precision.
The grid spans only the four channel trace rows, below the ruler and between
CH and HIGH/LOW labels. R/S is the sole normal acquisition indicator. Errors
appear in the former status line beneath the subtitle, constrained to a single
canonical line height so they cannot overlap the timeline. The full 96-byte
bounded diagnostic remains in semantic storage and uses viewport clipping.

## Visual evidence

These PNGs decode actual RGB565 output from production host loops with
hardware-free display, touch, clock and acquisition adapters. They are not
mockups. Pi logical output is 240×240; its mapped physical output is 240×320.
nRF output is 320×240. Both use the shared Inter resource; the narrower Pi
surface wraps longer title and timeline labels.

- [nRF recording](nrf-running-four-traces.png), [stopped](nrf-stopped.png),
  [error](nrf-diagnostic.png), [maximum diagnostic](nrf-maximum-diagnostic.png).
- [Pi recording](pi-running-four-traces.png), [stopped](pi-stopped.png),
  [error](pi-diagnostic.png), [physical mapping](pi-running-four-traces-physical.png).

Idle and 1/2/5-second window captures are included for both targets. The pixel
check requires eleven grid columns and rejects gray vertical runs through the
ruler. Visual inspection confirmed clear labels and the red error line.
Font pixels match in channel labels and controls across all seven states.
Diagnostic host-state differences are excluded for recording/state labels.

## Verification

The full unit suite passes 1,145 tests. Layout regression cases cover normal
and diagnostic output at 240×240, 240×320, 320×240 and 480×320; assert ruler
bounds end before the grid, grid/trace alignment, errors remain in the header,
and no READY/RUNNING/STOPPED/FAILED text is drawn. Tests retain and check all
96 diagnostic bytes, rounding boundaries, carry, and extreme timestamps.

Target traces match the macOS oracle at each target extent: 120 Pi workload
frames, 9 Pi initial/action frames, all 129 nRF committed frames, and 12 actions.
Eight actions update the frame; four repeated disabled endpoint taps do not.
Pi startup/display/input fault cases and seven nRF faults pass. Maximum nRF
diagnostic rendering also passes its production handoff.

Both target builds pass. Pi is ARMv6 hard float; nRF is Cortex-M4F hard float.
nRF linked RAM remains 195,008 bytes (raw section sum 195,004), below its
196,608-byte limit. Fixed profile/storage capacities remain unchanged.
Normal and diagnostic states share 92 scopes, 41 nodes, 51 modifiers,
119 structural occurrences, 187 traversal identities and 3 actions.

These captures are candidate evidence; reviewed PixelReferences are preserved.
T7.7 pixel-reference review and connected hardware conformance remain open.
No firmware was flashed and no Pi service deployed.

Reproduce from the repository root:

```sh
scripts/format-swift.sh
scripts/test.sh
scripts/nrf52840/build.sh --application signal-analyzer-static
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
scripts/contracts/check-spec-001-host-native-rasters.sh --profile raspberry-pi-armv6 --candidate-only --reference-traces Tests/ContractFixtures/SPEC001/Evidence/milestone-8/timeline-cleanup-20261001
scripts/contracts/check-spec-001-host-native-rasters.sh --profile nrf52840-embedded --candidate-only --reference-traces Tests/ContractFixtures/SPEC001/Evidence/milestone-8/timeline-cleanup-20261001
```

Build logs, frame/action traces, reference comparisons, raster hashes, font
comparison, fault results and repository-gate evidence accompany the images.

The Signal Analyzer (SPEC-001) and host-configuration (SPEC-015) contract gates
pass. The broad repository gate retains ten pre-existing failures in SPEC-003,
004, 005, 006, 008, 009, 011, 012, 013 and 014, matching the earlier
[baseline audit replay](../adaptive-layout-20261001/baseline-audit-replay.txt).
See `repository-results.tsv` for all check results. Repository metadata records
the starting revision; the committed implementation and source hashes above
identify this UI change. Existing lifecycle/conformance gates are not promoted.
