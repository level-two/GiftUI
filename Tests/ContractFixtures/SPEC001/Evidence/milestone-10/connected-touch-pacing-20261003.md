# Connected nRF touch orientation and input pacing — 2026-10-03

Status: connected Start/Stop and minus/plus button retry **verified and complete**
by Eugene's explicit confirmation in this session. Broader T8.2 remains open.

Scope: the maintainer authorized flashing the current Signal Analyzer firmware,
recording physical button taps, monitoring faults, and correcting the observed
nonresponsive controls. This is collecting evidence for SPEC-001 T8.2; it does
not close connected interaction, cadence, or conformance criteria.

The first run recorded three contact groups near (272, 27), (170, 30), and
(174, 207) under the default unswapped, uninverted full-ADC mapping. Swapping
the axes and reversing both directions aligns the groups with the landscape
Start/Stop and window-control areas. The maintainer reported no visible response
both before and after the orientation correction. The oriented run recorded
press/release contacts within the visible control areas, with presentation
revision remaining 1, zero driver fault counters, zero CFSR/HFSR, and no CPU
halt or lockup. Endpoint calibration is still provisional.

The production loop admitted a contact event every 10 ms, including stationary
move samples. Its six-slot queue drained only at the 250 ms paced opportunity.
The seventh queued sample therefore cancels the physical sequence before a
normal held press can release. `staticNRFHeldPressSurvivesPacedInputSampling`
reproduces cancellation at the original rate and verifies complete down/move/up
delivery at 50 ms sampling with the same queue and opportunity cadence.

The correction gives physical touch sampling its own 50,000-microsecond
deadline. Source-transition wakes still service the application promptly but
cannot admit extra touch samples before that deadline. The frame interval and
all input capacities remain unchanged. Serial diagnostics now record contact
edges and sequence-capacity cancellations with coordinates, packed admission
outcome, and pending count during diagnosis. The native controller fixture applies the inverse
of the selected landscape mapping.

Validation:

- `scripts/format-swift.sh` completed.
- `scripts/contracts/check-spec-001-nrf-touch-input.sh` passed.
- `scripts/contracts/check-spec-001-nrf-production-host.sh` passed, including
  a temporary frequent-wake probe that verified the independent sample deadline.
- `swift test -Xswiftc -DGIFTUI_STATIC_PROFILE --filter
  'staticNRFInputABI|staticNRFFirmwareInputStorage|staticNRFHeldPress'` passed
  six tests.
- `scripts/contracts/check-spec-001-nrf-host-native-rehearsal.sh` passed its
  2,400-transition workload, production control sequence, hold/drag and miss
  probes, and common-owner fault/recovery checks.
- The exact board build passed ARMv7E-M/VFP and resource checks at 275,704
  flash bytes and 191,104 RAM bytes, and was explicitly flashed through J-Link.

The corrected board run recorded accepted down/up contacts (`admission=255`)
at the window-control areas, including (280, 109)/(278, 112) and
(45, 111)/(46, 114), and at the recording control (285, 33)/(285, 35).
Presentation revision advanced from 1 to 14. Timestamped health samples from
10:55:17 through 11:03:45 UTC retained all five driver fault counters at zero,
CFSR/HFSR at zero, and no CPU halt or lockup. Eugene then explicitly requested
recording this part as verified and completed.

Verified diagnostic ELF SHA-256:
`0b51069a214359910fdd2488746532679dcf301c0ac25ff7870ddce48fd618f0`.

At the maintainer's request, cleanup removed the temporary serial diagnostics,
their two native `printk` stubs and fake header, the added held-press regression,
and the added frequent-wake assertions. The pre-cleanup regression results above
remain historical evidence in their retained logs. Existing tests retain only
the clock advancement and inverse controller-coordinate fixture adaptations
needed to exercise the corrected firmware. The board still runs the verified
diagnostic image; cleanup does not silently reflash a different image.

Post-cleanup validation passes the existing five Swift input ABI/storage tests,
the C production-host and touch-normalization checks, and the ARMv7E-M/VFP build
at 275,600 flash bytes and 191,104 RAM bytes. The native production rehearsal is
rerun against the cleaned source. The [validation archive](connected-touch-pacing-validation.tar.gz)
preserves board identity, touch/health events, serial output, and build/rehearsal
logs independently of ignored live directories.

Ignored live records are retained under
`.build/nrf52840/signal-analyzer-static/reports/`: `live-input-20261003`,
`live-input-oriented-20261003`, and `live-input-paced-20261003`. Each capture
has ELF identity, timestamped touch/health events, raw J-Link reads, and serial
output. The collector resolves driver-counter addresses from the current ELF.
Host test logs are `input-pacing-tests.log` and `input-pacing-rehearsal.log`.

The physical button retry is complete. Endpoint calibration, connected frame
costs/cadence, trace comparison, and full T8.2 acceptance remain unmeasured. This
record establishes the tested controls and observed fault-free interval, not
absence of all possible runtime hangs.
