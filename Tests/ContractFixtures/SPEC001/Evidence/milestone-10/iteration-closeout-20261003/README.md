# Final-artifact validation and iteration closeout — 2026-10-03

**Latest disposition:** [Maintainer approval](remaining-spec-transition-approval.md)
closes SPEC-001/011/015 as implemented with explicit exceptions. Performance
is deferred under FW-027/FW-032; connected evidence under FW-031/FW-033.
All earlier open-gate statements below record the state before this approval.

Governing scope: SPEC-001 T8.1/T8.2/T8.3, SPEC-011 T9.3/T9.4,
and SPEC-015's assembled connected-target gate. This record distinguishes
passing hardware-free checks, connected observations, failed requirements,
and explicitly postponed work. It does not establish full MVP conformance.

## Maintainer decisions

The maintainer explicitly instructed:

- Postpone the Pi timing fix and macOS physical-pointer campaign to the next
  iterations. [FW-027](../../../../../../docs/future-work/fw-027-pi-performance-investigation-resumption.md)
  and [FW-031](../../../../../../docs/future-work/fw-031-macos-connected-pointer-validation-resumption.md)
  preserve those work-ordering decisions. The requirements remain unresolved;
  no timing exception or full Specification transition was requested explicitly.
- Touch calibration is confirmed and its subtask may close. This supersedes
  provisional-calibration statements in the earlier connected nRF record.
- Execute final-artifact validation, remaining connected tests, trace
  comparison, and conformance reconciliation. This authorized deployment,
  flashing, bounded application execution, and debugger observation.

Calibration confirmation is human evidence. It is not inferred from an
emulator or promoted into complete interaction, cadence, or recovery coverage.

## Source and artifact identity

Base revision: `ec77b3faf080517e90ba18c1664501240d892774`. Application source is
unchanged in this closeout. Two contract drivers received a Bash 3.2-compatible
empty-array expansion correction; validation documentation was reconciled
after the complete gate. Source hashes and the exact scripts are archived.

- Pi product: `SignalAnalyzerRaspberryPiARMv6`, ARMv6 hard-float ELF.
  SHA-256 `acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e`.
  The remote reports `armv6l`; the final connected run independently records
  this same binary hash after atomic deployment. No service was restarted.
- nRF application: `signal-analyzer-static`, `nrf52840dk/nrf52840`, ARMv7E-M
  with VFP register calling convention. Final ELF SHA-256
  `c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c`.
  The cleaned final firmware was flashed through the repository J-Link runner.
  Flash: 275,600 bytes; RAM: 191,104 bytes; heap disabled.
- Both repository-local toolchain doctors and target ABI/build checks pass.
  Toolchains and generated artifacts remain under their prescribed roots.

## Final local validation

`scripts/test.sh --profile all-hardware-free` completed one final invocation
with **72 passing checks and zero failures**, including all fifteen registered
Specification drivers in all four profiles, selected runtime checks, governance,
formatting, root tests, independent behavior references, production fault
corpora, and the current reviewed Pi/nRF pixel gates.

Root validation passed 298 XCTest tests and 1,160 Swift Testing cases.
The constrained-profile Signal Analyzer selections each passed 269 tests.
Formatting and `git diff --check` pass. The changed shell drivers pass `bash -n`
and guarded empty/nonempty-array expansion checks under `/bin/bash` nounset.

The earlier sandboxed gate failed because compiler/cache access was restricted
and empty arrays triggered Bash nounset. Its console log is preserved as a
failed attempt. A final unsandboxed invocation follows the driver correction;
its separate console log is the source of `gate-ledger.tsv`. The earlier run
also appended to the runner's shared metadata/results while the final run
started. Those shared files are retained as historical output, not used as an
unambiguous final-run ledger. No failing row is rewritten as passing.

## Connected Pi final-artifact run

The remote application ran under a 45-second timeout, with monotonic elapsed
time, timestamped trace output, sampled RSS, and final application status.
The timeout's exit code is 124; the application itself printed
`status=completed` during SIGINT teardown. Elapsed collection was 47.23 seconds.

- 32 measured update costs, minimum 1.294164 s, median 1.3509545 s,
  maximum 1.522434 s.
- Observed cadence between measured updates: **0.72335 frames/second**.
- Peak sampled application RSS: **9,740 KiB**.
- The final artifact launches and tears down; four-frame/second cadence fails.
  This collection does not prove 80 transition events/second, complete physical
  interaction, or full trace equivalence.

A preliminary run began before deployment finished and used a different
remote binary. It is retained separately and excluded from final-artifact
claims. The accepted prior physical-control signoff remains preserved, but
does not waive the measured cadence or previous service-deadline failure.

## Connected nRF final-artifact run

Nonhalting SWD reads record the production presentation revision and five
driver fault counters plus CFSR/HFSR and DHCSR. The idle window had revision 1
and no driver or CPU faults. No new physical contacts were observed in that
window; the requested physical-control corpus has not been supplied.

An additional **software-injected** down/up Start sequence, using the existing
production input ABI and committed hit point, returned 255 for both admissions
and two queued events. The real firmware consumed it. This is connected
software-action evidence, not physical-touch evidence.

The subsequent 600-read nonhalting acquisition window included 60 seconds of
requested sleeps plus probe overhead. Observed revision changes were:

| UTC | Revision |
| --- | --- |
| 15:45:17.531217 | 1 |
| 15:45:20.070977 | 2 |
| 15:45:41.250874 | 3 |
| 15:46:02.501036 | 4 |
| 15:46:24.137436 | 5 |

The approximately 21-second gaps do not meet four-frame/second cadence. All
sampled driver fault counters and CFSR/HFSR were zero. A later halted snapshot
reports revision 6, running acquisition, nine capture records, 40 drawing
points, zero queued input, and zero driver/CPU fault counters. DFSR includes
the debugger halt bit; it is not classified as an application fault.

The first nine live capture records match the independent deterministic
source equations exactly: four initial low records, followed by CH3 at
80/160/240 ms, CH1 at 250 ms, and CH2 at 400 ms. This is a **prefix comparison**;
it cannot establish a complete semantic/action/drawing trace, sustained 80-Hz
delivery, or target timing conformance. A recorded software Stop was admitted,
but its completed application is not claimed by this snapshot.

The initial raw stack dump was not sentinel-painted and included an incorrect
buffer origin. It is retained as an excluded diagnostic; no high-water value
is inferred from it. The earlier approved painted measurement remains scoped
to its original artifact. The current measurement method uses the actual
`z_main_stack` symbol plus its 64-byte MPU guard and the documented pre-boot
reset/paint/resume sequence.

The final painted measurement after startup/idle is **19,480 / 27,648 bytes**,
with an 8,168-byte untouched low prefix, production revision 1, and zero
driver/CFSR/HFSR faults. The raw dump is exactly 27,648 bytes from
`0x20027E80`. This current-artifact measurement covers startup and idle;
the earlier running-acquisition measurement remains separately scoped. It
does not establish an exhaustive worst-case stack bound or sustained cadence.

A reset-only observation after 60 seconds still had no constructed production
context. That observation does not prove completed startup recovery. It is
retained separately from sustained execution. The later painted run did finish
startup and return to the idle presentation; its snapshot supplies that limited
reset/startup evidence. There is no configured production watchdog callback,
and no connected transport-failure recovery corpus is claimed.

## Current task and conformance dispositions

| Work | Disposition |
| --- | --- |
| Final artifact builds, ABI/resource checks, local/profile/pixel gates | Pass |
| Touch calibration | Complete, explicit maintainer confirmation |
| Pi timing fix | Postponed to next iteration, FW-027; measured cadence failure remains |
| macOS physical-pointer campaign | Postponed to next iteration, FW-031 |
| T8.1 remaining complete connected acceptance | Open; measured cadence failure and incomplete interaction/recovery/trace coverage |
| T8.2 remaining complete connected acceptance | Open; measured cadence failure, incomplete physical/fault corpus and sustained-load evidence |
| T8.3 full connected-oracle comparison | Open; only the nRF capture prefix is compared |
| SPEC-011 T9.3/T9.4 | Partial connected evidence; full corpus not complete |
| SPEC-015 assembled connected gate | Open |

SA-AC-023 has a measured cadence failure. SA-AC-039 lacks compliant current
target timing and records a cadence failure. SA-AC-005 and SA-AC-024 retain
their complete connected-display/input evidence blockers. Historical SA-AC-025
fit evidence is preserved with its scope; current build/resource and live
execution evidence do not silently turn an unmeasured stack into a measurement.

The refreshed owner/profile checks supersede earlier sandbox or resolved
runner-seam failures for their tested inputs. Plans SPEC-004 and SPEC-013 now
have completed task dispositions. SPEC-001, SPEC-011 and SPEC-015 retain their
connected gates. No whole-Spec `implemented` transition or exception is inferred
from this execution request. A full transition needs passing conformance or
explicitly approved exceptions and an explicit human transition instruction.

## Reproduction and retained evidence

[Machine-readable measurements](measurements.json) and `gate-ledger.tsv`
summarize the raw evidence. `validation.tar.gz` preserves command scripts,
source identities, build/deploy/flash logs, separate gate console logs,
individual driver logs, raw Pi JSONL and nRF SWD/debugger observations,
capture/profile dumps, toolchain and ABI/resource reports, and failed/excluded
attempts. `archive.sha256` identifies that immutable packet.

Use the archived commands from the repository root with the recorded artifacts
and connected target identities. Deployment, flashing, reset and debugger
actions require the normal explicit connected-target authorization.

## Explicit owner-transition approval

Eugene subsequently approved the ten named owner transitions: SPEC-002, 003, 004, 005, 006, 009, 010, 012, 013, and 014. They are now implemented. [The exact approval and scope](owner-transition-approval.md) supersede earlier pending-authorization statements. SPEC-001, 011 and 015 remain implementing; measured timing failures and missing connected evidence are unchanged.
