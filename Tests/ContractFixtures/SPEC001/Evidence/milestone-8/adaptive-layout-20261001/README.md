# Signal Analyzer adaptive layout — 2026-10-01

Feature: `signal-analyzer`; SPEC-001 remains `implementing`.
This is an implementation correction under the existing T6.8/T7.7 work,
using accepted ADR-004/ADR-032 and implemented SPEC-007. MVP justification:
the shared reference application must exercise constrained sizing on the
nRF static and Pi dynamic stacks. No authority or manifest status changed.

## Result

Replaced the 120 × 96 grid and 120 × 16 trace frames with finite constraints
derived from surface extent and font line height. Stacks retain SPEC-007's
absent-main-axis proposal behavior. The common solver owns measurement,
placement and clipping. Two label columns bound the plot; all trace canvases
share the grid's horizontal bounds. The nRF projection retains the exact
96/98 scope topology and existing profile byte budgets.

## Visual evidence

These PNGs are captures of production host pixel writes executed natively,
not photographs of connected boards. The nRF rehearsal uses the firmware's
amalgamated Swift source and production C host loop. The Pi rehearsal uses
the production lifecycle owner with simulated framebuffer, input and clock.

- [nRF running](nrf-running-four-traces.png)
- [nRF diagnostic](nrf-diagnostic.png)
- [Pi running, logical surface](pi-running-four-traces.png)
- [Pi running, mapped physical surface](pi-running-four-traces-physical.png)

The directory also contains idle, stopped, cleared, all three time windows,
and diagnostic captures. Raster checks require eleven vertical grid lines,
a horizontal grid line and two separated trace levels in every channel.
The horizontal inspection interval is derived from the raster's grid pixels.
Existing reviewed RGB565 references were not replaced with these candidates.

## Validation

- Surface geometry tests resolve all five canvases at 240 × 320, 320 × 240,
  and 480 × 320. They assert equal grid/trace origins and widths, surface
  containment, and separation from channel and state labels.
- [Focused regression tests](focused-tests.log) check portable/generated
  projection parity, exact scope counts, diagnostic render behavior and the
  production dynamic presentation path.
- [Firmware cross-build](firmware-build.log): `nrf52840dk/nrf52840`, ARMv7E-M,
  [VFP register calling convention](arm-attributes.txt). The recorded
  [resource summary](memory-summary.txt) reports 243,044 flash bytes and
  195,004 RAM bytes; the linker rounds RAM usage to 195,008 bytes.
- Production host action replays and fault paths: [nRF behavior](nrf-behavior-comparison.txt),
  [nRF faults](nrf-fault-results.txt), [Pi behavior](pi-behavior-comparison.txt),
  [Pi faults](pi-fault-results.txt).
- The [repository unit run](unit-test-summary.txt) passed 1,139 tests in 17 suites.
- [Source and firmware hashes](source-hashes.tsv) identify the tested layout
  sources, amalgamation and ARM ELF.

Reproduction from the repository root:

```sh
scripts/format-swift.sh
scripts/test.sh
scripts/nrf52840/build.sh --application signal-analyzer-static
bash scripts/contracts/check-spec-001-host-native-rasters.sh --profile nrf52840-embedded --candidate-only
bash scripts/contracts/check-spec-001-host-native-rasters.sh --profile raspberry-pi-armv6 --candidate-only
```

## Repository gate outcome

The [final gate](repository-gate.log) completed with [ten failing audit rows](repository-results.tsv).
The root unit suite, diagnostic-buffer branches, governance, formatting,
SPEC-001 application, SPEC-002 declarations, SPEC-007 layout, SPEC-010 state,
and SPEC-015 host configuration checks passed.

[Failure diagnostics](audit-failure-summary.txt) identify stale dependency,
generated-asset, migration and ownership audits. A [read-only replay against
the starting commit](baseline-audit-replay.txt),
`0c53656b4432337f2255ef2e7b0f643850e41bd0`, reproduces the eight direct
failing checks. SPEC-011 delegates to the failing SPEC-012 harness; SPEC-014
reports two incomplete backend assertions. Those broader audit/evidence gates
remain open and are not counted as layout regressions or passing checks.

## Boundaries

No connected board was flashed and no Pi service was deployed. Physical TFT,
touch and target cadence validation remain connected-target evidence gates.
These captures do not grant reviewed-reference approval or transition
SPEC-001 to `implemented`. The dependency registry correction records existing
Pi rehearsal host imports already present in Package.swift; it adds no new
production dependency.
