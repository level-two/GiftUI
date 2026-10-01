# Analyzer touch controls — 2026-10-01

Implementation: `53e300af` (portable controls), `b3012e5c` (nRF projection and routing),
`214bb9bb` (target touch workloads and raster comparisons), and `165abb6c`
(maximum diagnostic glyph-budget correction).

The maintainer-requested SPEC-001 amendment replaces visible Start/Stop/Clear
and duration selectors with three bordered 44×44 controls. R/green is the active
recording state and dispatches Stop; S/pink is the stopped state and dispatches
Start. Minus sits above CH, plus above HIGH/LOW. They select adjacent 1/2/5-second
windows; minus is disabled at 1 second and plus at 5 seconds. Disabled controls
retain their bounds and ignore taps. Grid and traces stay between label columns.

## Visual evidence

These PNGs decode RGB565 framebuffer output from the actual production host
loops under hardware-free recording adapters; they are not design mockups.
Pi logical output is 240×240 and its mapped physical framebuffer is 240×320.
nRF output is 320×240. Header and ruler text wrap on the narrower Pi surface.
Both use the existing shared Inter font. Compare:

- [nRF running](nrf-running-four-traces.png) and [stopped](nrf-stopped.png)
- [nRF 1 second](nrf-window-one-second.png) and [5 seconds](nrf-window-five-seconds.png)
- [Pi running](pi-running-four-traces.png) and [stopped](pi-stopped.png)
- [Pi 1 second](pi-window-one-second.png) and [5 seconds](pi-window-five-seconds.png)

Idle, 2-second, diagnostic and physical Pi captures are also included.
These are fresh candidate evidence. Reviewed PixelReferences and historical
milestone evidence remain unchanged. T7.7's reference review and T8.2's connected
hardware checks remain open. No firmware was flashed and no Pi service deployed.

## Reproduction and checks

Run from repository root:

```sh
scripts/format-swift.sh
scripts/test.sh
scripts/nrf52840/build.sh --application signal-analyzer-static
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
scripts/contracts/check-spec-001-host-native-rasters.sh --profile raspberry-pi-armv6 --candidate-only --reference-traces Tests/ContractFixtures/SPEC001/Evidence/milestone-8/touch-controls-20261001
scripts/contracts/check-spec-001-host-native-rasters.sh --profile nrf52840-embedded --candidate-only --reference-traces Tests/ContractFixtures/SPEC001/Evidence/milestone-8/touch-controls-20261001
```

The updated macOS Dynamic oracle executes on the Pi's target extent so responsive
wrapping and render operation counts are compared at the same size. The static
oracle executes at nRF extent. Neither comparator ignores differing fields.
Both run 2,400 source transitions and 120 acquisition frames, followed by 12
pointer actions: 8 enabled actions and 4 repeated disabled endpoint taps.
Pi also checks 9 initial/action frames; nRF checks all 129 ordered frames.
The regression suite checks 44×44 hits and verifies generated nRF primitives,
modifier values, text, identities, bindings, clipping and topology against the
portable semantic tree. Full 96-byte diagnostic wrapping is exercised too.

Pi startup/display/input faults and seven nRF fault paths pass. A maximum
96-byte diagnostic passes the actual nRF render handoff and is captured in
[nrf-maximum-diagnostic.png](nrf-maximum-diagnostic.png). The firmware guard
now matches the configured 224-glyph capacity rather than the old 150-glyph
restriction. Font pixels are
identical across seven captured states in controls and channel labels; diagnostic
state differences are excluded only for the recording and HIGH/LOW text.

Both cross-builds pass. Pi is ARMv6 hard float; nRF is Cortex-M4F hard float.
nRF linked RAM is 195,008 bytes (raw section sum 195,004), below the existing
196,608-byte limit. Profile allocation remains 39,696 bytes. The same 4,704-byte
layout/render workspace accommodates the deeper hierarchy with a 38-byte layout
stack, publication marker at scratch +38 and render scratch at +48.

Source hashes, build logs, raster hashes, pointer/frame traces, ABI attributes,
fault results and repository gate output accompany these screenshots. The full 1,144-test unit suite and Signal Analyzer contract gate pass. The broad
repository gate retains 10 pre-existing audit/evidence failures in SPEC-003,
004, 005, 006, 008, 009, 011, 012, 013 and 014. These match the earlier
[baseline audit replay](../adaptive-layout-20261001/baseline-audit-replay.txt);
this task does not promote those conformance gates.
