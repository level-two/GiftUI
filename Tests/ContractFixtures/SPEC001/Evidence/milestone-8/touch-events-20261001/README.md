# Automated touch propagation — 2026-10-01

This is maintenance evidence for SPEC-001 T6.7/T6.8/T7.7, SPEC-009 input
admission, and SPEC-011 gesture/dispatch behavior under accepted ADR-011 and
ADR-033. Signal Analyzer controls and cross-platform interaction are required
by MVP Scope. The features remain `implementation`; no approval, Specification
status, storage budget, or architecture is changed. The feature manifest needs
no new relationships for this test-only work and the two local decoder fixes.

## Coverage and substitutions

| Configuration | Exercised path | Mocked boundary |
| --- | --- | --- |
| macOS dynamic | Committed button bounds → gesture resolution → current-model action dispatch → observable mutation → semantic/layout/drawing/render recording | Render recording endpoint; no native window/input driver exists in the preset executable |
| macOS static | Normalized down/up ABI → bounded input queue → Static interaction session → current registered model → generated semantic/layout/drawing/render recording | Render recording endpoint; the test no longer calls model methods after merely checking a gesture |
| Pi dynamic / RGB565 tiles / framebuffer | Raw `EV_ABS`, `BTN_TOUCH`, `SYN_REPORT` values → production evdev decoder → Pi calibration/aspect fit → contact phases → normalized admission → serialized opportunity → action/model/state → replacement framebuffer | Device reads, framebuffer sink, deterministic clock; the Linux device uses the same extracted evdev decoder |
| nRF static / RGB565 tiles / SPI TFT | Raw ADS7846 samples → production C firmware loop → calibration/contact decoder → C-to-Swift ABI → fixed input storage → Static interaction/model owner → generated presentation → SPI TFT writes | ADS7846 and SPI callbacks, Zephyr host shims, deterministic clock; Swift production application source is linked into the rehearsal |

The Dynamic framebuffer matrix has **11 cases**: tap, hold, movement inside,
movement outside, miss, disabled, stale presentation, release without press,
leaving/re-entering the logical surface, release outside the button, and
release in the letterbox. It checks no mutation/frame change on down, exact
dispatch count on release, current model state, presentation revision, and
changed/unchanged framebuffer pixels.

The Static ABI matrix has **8 cases** covering the corresponding common
sequence behavior, current-model dispatch and observable dirty state. Raw nRF
negative probes independently check that holding does not activate, dragging
outside cancels, and a complete tap on empty content leaves the model, frame
revision and display write count unchanged. They also check firmware teardown.
Existing raw nRF normal scripts cover the enabled recording/window controls
and repeated disabled endpoint taps.

Two evdev adapter tests check synchronization boundaries, calibration,
movement filtering, repeated/unknown records, letterbox handling, and physical
release. These adapter tests plus the two profile matrices and existing contact
decoder test passed together (`focused-tests.log`).

## Defects reproduced and fixed

1. Leaving the Pi logical surface emitted a synthetic `up` at the last valid
   button coordinate. Returning to the surface while still touching emitted
   another `down`. The end-to-end regression observed **two dispatches** and a
   changed frame when it expected none. The decoder now sends an outside move
   to cancel capture, suppresses re-entry until physical release, and completes
   that sequence with an outside release.
2. The Pi release event used the previous coordinate even when the final raw
   sample placed the pen outside the button or in the letterbox. Release now
   carries the final normalized coordinate, or an outside coordinate when it
   cannot be normalized. Both release regressions dispatch zero actions.

No phase or public contract was added. The fixes use the existing movement
cancellation and release hit-validation contract.

## Results and reproduction

- `swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter
  'rawFramebuffer|staticTouchABI|evdev|contactDecoder'`: five test functions,
  including 19 matrix cases, passed. See `focused-tests.log`.
- Both macOS reference workloads passed. See `macos-reference-traces.log`.
- `scripts/contracts/check-spec-001-pi-host-native-rehearsal.sh` passed with
  raw evdev injection. See `pi-trace.log`.
- `scripts/contracts/check-spec-001-nrf-host-native-rehearsal.sh` passed with
  normal raw touches and the isolated negative-probe lifetime. See
  `nrf-trace.log` and `nrf-touch-probes.tsv`. Its generated production Swift
  source requires the normal `signal-analyzer-static` build first.
- Dynamic/Pi comparison passed: 120 workload frames, nine initial/action
  frames, 12 actions. Static/nRF comparison passed: 129 ordered frames,
  12 actions. See `behavior-comparison.txt`.
- The repository unit gate passed **1,149 test functions in 17 suites** during
  the all-profile run. Final release-coordinate changes were subsequently
  checked by the focused suite and later profile drivers.

Run `scripts/format-swift.sh` and `scripts/test.sh all-hardware-free` for the
repository gate. This directory records that gate separately from successful
touch checks: existing audit blockers and absent reviewed pixel references
prevent claiming full conformance. No hardware was flashed, deployed,
restarted, or manually pressed. These results establish automated propagation
with mocked physical I/O, not connected-device electrical or timing evidence.
Native macOS event delivery and full-surface rendering are not wired into the
preset executables; recording oracles and existing backend contract tests are
the available evidence for those profiles.


The four-profile repository invocation finished with **43 failed checks**:
40 contract-driver failures across SPEC-003/004/005/006/008/009/011/012/013/014,
two SPEC-001 missing reviewed pixel-reference failures (Pi and nRF), and one
diagnostic-buffer build interrupted by a test-source edit during compilation.
The diagnostic-buffer check passed on a clean rerun of all four capacity
branches, leaving **42 existing audit/conformance blockers**. The previous
[touch-control audit summary](../touch-controls-20261001/audit-failure-summary.txt)
records the same dependency, migration, generated-asset, owner-audit and
resource blockers; they were not relaxed by this work. See
`repository-results.tsv`, `repository-gate.log`, and
`diagnostic-buffer-rerun.log`. SPEC-001 macOS dynamic/static checks and SPEC-015
all four profile checks passed. The repository gate is **not green**.

`source-hashes.tsv` identifies the final source/test changes. Each coherent
code/test step and each production fix was committed separately before this
evidence record. The isolated nRF probe revision corrects the initial test
harness mistake of shifting acquisition pacing with pre-workload idle time.
