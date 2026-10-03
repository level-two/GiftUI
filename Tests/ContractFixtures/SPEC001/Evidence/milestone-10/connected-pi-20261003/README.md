# Connected Raspberry Pi application verification — 2026-10-03

Evidence kind: `connected-target`. Target: Raspberry Pi 1, reporting `armv6l`,
Linux framebuffer `/dev/fb0` (480 x 320 RGB565), ADS7846 `/dev/input/event0`.
The current Signal Analyzer validates the Linux/PiScreen stack in MVP Scope.
SPEC-001, SPEC-011, and SPEC-015 remain `implementing`.

## Maintainer approval and completed signoff

After the calibrated run, Eugene confirmed: “Cool, it works”. After the R-tap
failure was diagnosed, he explicitly requested: “mark Raspberry Pi application
as verified and complete the open tasks which waited for this approval”.
The Raspberry Pi application **display and physical-control signoff is verified
and complete**. This closes the approval-only portion of SPEC-001 T8.1,
SPEC-011 T9.3's Pi application controls, and SPEC-015's Pi display/input signoff.
The overall tasks also require evidence beyond this signoff; their remaining
requirements are kept open below. This approval is not recorded as a waiver of
unmet timing or failure-recovery criteria or as complete Spec conformance.

Eugene separately confirmed that temporary `--start-stopped` hosting code and
monitoring helpers should be reverted while preserving the working calibration.
The production startup path is restored. The final cleanup artifact is
cross-built locally; this record does not claim it was subsequently redeployed.

## Reproduction and identity

The repository-local Swift 6.3.2 toolchain passed `doctor.sh`. The exact
`SignalAnalyzerRaspberryPiARMv6` product passed ELF/ARMv6/hard-float checks.
Deployment used `scripts/raspberry-pi/deploy.sh --product
SignalAnalyzerRaspberryPiARMv6 --no-build --host 192.168.55.44
--host-key-alias giftui-pi.local --resume`; architecture and SHA-256 were
verified before atomic replacement. No service was restarted.

The test command was `sudo -n env GIFTUI_PI_TRACE=1 SWIFT_BACKTRACE=enable=yes
stdbuf -oL -eL /home/giftui/giftui/bin/SignalAnalyzerRaspberryPiARMv6
--run-signal-analyzer --start-stopped`. The temporary option stopped through
the ordinary action/paced-opportunity path after normal activation. The
unprivileged recorder independently read evdev records without grabbing the
input device, timestamped stdout/stderr, polled process state/CPU/RSS every
five seconds, and retained the child exit status.

- [Stopped-run binary identity](stopped-binary.sha256) and
  [complete capture](stopped-events.log): plus/minus dispatch and failed S taps.
- [Calibrated-run binary identity](calibrated-binary.sha256) and
  [complete capture](calibrated-events.log): working S followed by the R-tap exit.
- [Failure analysis](failure-summary.txt): final trace and code-supported cause.

The artifacts were built from revision `eac66f8b39bd8b732b6a4e3f1e625c75c85cb12a`
with the local calibration and temporary hosting changes. These are actual
physical runs, separate from the hardware-free exact-pixel oracle.

## Observations

The stopped screen remained stable after its initial update. Plus/minus
contacts around `(24,128)` and `(192,128)` dispatched one action per successful
release; Eugene confirmed both worked. S taps decoded at y=48–56, outside the
committed y=2..<46 hit area. Changing the vertical raw range from
`-205...3890` to `205...4300` places all seven recorded S contact starts inside
the actual current hit area and preserves the recorded plus/minus hits.
The captured-tap regression checks the production presentation's action bounds.
Eugene confirmed S worked after deploying that calibration.

On repeated R taps during acquisition/redraw, one action dispatched, followed
by a nine-contact batch with six queued and three rejected. The process then
reported `pacing(HostWakePacingError.serviceDeadlineMissed)` and exited with
code 1, without a terminating signal. The immediately preceding redraw took
1,357,026 microseconds; the configured fact-service deadline is 250,000.
Stop-action facts admitted after sealing await a later opportunity, so the
synchronous redraw can consume the deadline. Per-fact timestamps were not
captured; this explanation combines the observed error with code inspection.
The run had approximately 10 MB RSS and no logged signal crash.

## Remaining conformance requirements

This approval does not establish four frames/second, deadline-safe Stop during
redraw, burst input without refusal, complete connected six-action/endpoint
coverage, failure recovery, or full semantic/action/drawing trace equivalence.
They remain current conformance obligations in SPEC-001 T8.1/T8.3 and the
relevant connected portions of SPEC-011/015, not deferred Future Work.
No failed measurement is relabeled as passing, and no Specification is marked
`implemented`. The nRF and macOS connected obligations are unaffected.

## Validation after cleanup

The working calibration and its recorded-contact regression remain; the
stopped-startup option and live recorder helper scripts are removed. Focused
Pi geometry, evdev, square-hit, and raw-touch propagation tests, governance,
formatting, and the exact ARMv6 cross-build are recorded alongside this packet.

Final cleanup validation passed:

- [14 focused tests](final-focused-tests.log), including 11 raw-touch cases
  and all recorded S/+/- contacts against committed action bounds.
- [Exact ARMv6/hard-float build](final-build.log), with
  [final binary identity](final-binary.sha256) and
  [source identities](final-source-hashes.tsv).
- `scripts/validate-governance.rb` passed all six task manifests and the
  authority graph; `scripts/format-swift.sh --lint` and `git diff --check` passed.

The full Raspberry Pi repository gate was not completed for this final source
state; the focused tests and cross-build above are the final validation claims.
