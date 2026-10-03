---
spec: SPEC-015
feature: giftui-mvp-architecture
title: SPEC-015 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-03
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work:
  - FW-022
  - FW-032
  - FW-033
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-015 Conformance Report

**Current disposition — 2026-10-03:** The maintainer explicitly directed
performance work to future iterations and closure of the remaining Specifications.
[Recorded authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md) closes SPEC-001, SPEC-011, and SPEC-015
as `implemented` with approved exceptions for measured timing failures and
missing connected evidence. The original requirements and raw results are retained.
FW-027/FW-032 track performance; FW-031/FW-033 track connected validation.
Earlier open-gate statements below describe the pre-approval history.

> **Validation before closeout approval — 2026-10-03:** [Final-artifact closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) revalidates the approved seam and all four hardware-free profiles. Calibration is confirmed and final artifacts are deployed/flashed. Connected cadence and complete physical/fault/trace coverage were unresolved; the subsequent approval above closes this iteration with exceptions.

> **Historical amendment applicability — 2026-10-02:** The maintainer approved the
> coordinated SPEC-013/SPEC-015 seam amendment. Earlier passing rows remain historical evidence
> for the frozen baseline and their tested inputs. This report is `collecting`
> for the amendment; partial admitted-work failure and exact application
> rejection through the host opportunity boundary need new evidence from
> [SPEC-013 Milestone 9](../implementation-plans/spec-013-implementation-plan.md#milestone-9-preserve-partial-mutation-and-exact-application-failures).
> No blanket current conformance or implemented transition is claimed.

## 2026-09-27 Landscape Follow-up

The approved nRF preset and generated workload now use 320×240 with a 320×4
RGB565 tile and 2,560-byte raster, payload, and in-flight limits. Generator
freshness and the [four-preset comparison](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/320x240-four-preset-comparison.md)
pass. A [connected photograph](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-320x240-connected-landscape.jpg)
confirms a visible landscape idle frame. Input and sustained connected-host
evidence remain open. The old 240×320 comparison below is historical.

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.
>
> **Replacement-target applicability:** The nRF pass rows below are the
> historical review of the original 480 x 320 fixture and frozen contract
> hash. The [240 x 320 four-preset follow-up](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/240x320-four-preset-comparison.md)
> verifies the approved `KMRTM24024-SPI` preset and hardware-free resource
> bounds. Connected display/input behavior remains unverified.

## Review Scope

The review freezes [SPEC-015](../specs/spec-015-host-configuration.md) at
pre-report SHA-256
`599afed02b15a8116ed76c68fd4461fe0582f611620df8d43d7475711a794d3f`,
the active [implementation plan](../implementation-plans/spec-015-implementation-plan.md),
its current generated-workload and wake/pacing design notes, and reviewed
implementation revision `6202efd`. The four immutable profile reports share
run ID `6202efd224733528dd679e7426f82ea6b9544a7f-7c95f8e7532ba3bf`.
This amendment review includes schema-3 semantic structural capacity and the
2026-09-20 reapproval. Evidence covers Apple Swift 6.3.3 host
execution and project-local Swift 6.3.2 ARMv6/nRF hardware-free artifact
inspection. Connected PiScreen and nRF TFT/input evidence is intentionally not
collected.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `HC-001` | pass | [source boundaries](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/source-boundary-scan.md) | Authority, manifest, portfolio, and upstream relationships remain correctly scoped. |
| `HC-002` | pass | [validation guard](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-1/component-graph-and-validation-guard.md), [policy/report validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/policy-and-report-validation.md) | Nine pure stages stop at first failure and construction follows a complete report. |
| `HC-003` | pass | [source boundaries](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/source-boundary-scan.md), [graph validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-1/component-graph-and-validation-guard.md) | Exact owner graph and all forbidden imports/ambient lookup scans pass. |
| `HC-004` | pass | [complete workload validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/complete-workload-validation.md) | Complete schema-3/profile/storage/static-table equality, including semantic structural capacity, and per-leaf negatives pass. |
| `HC-005` | pass | [generated workload](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-2/generated-workload-and-presets.md) | Five-Canvas, point/subpath/operation, and all producer limits are exact. |
| `HC-006` | pass | [capability validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/capability-validation.md) | Drawing and capability gates remain independent and conjunctive. |
| `HC-007` | pass | [capability validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/capability-validation.md), [endpoint validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/endpoint-validation.md) | Four roles, five bits, one resolution, and endpoint equality pass. |
| `HC-008` | pass | [profile/text validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/profile-and-text-validation.md) | Exact immutable resources and all nine text mappings pass. |
| `HC-009` | pass | [normalized input/action](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/normalized-input-and-action.md) | Six actions, owner cardinalities, stale/replacement faults, and non-retention pass. |
| `HC-010` | pass | [application opportunity](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/application-opportunity-integration.md) | Same-thread/distinct-executor admission and mutation transcripts are equal. |
| `HC-011` | pass | [wake/pacing](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/wake-and-pacing.md), [presentation recovery](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/presentation-recovery.md) | Exact timing, 20/2/6 burst, 28/32/33, category excess, and refusal rules pass. |
| `HC-012` | pass | [failure adapter](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/host-failure-adapter.md) | Total policy/no-policy matrix follows mandatory effects and ignores diagnostics. |
| `HC-013` | pass | [four presets](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/four-preset-comparison.md) | macOS equality and exact Pi/nRF tiled projections pass. |
| `HC-014` | pass | [activation lifecycle](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/activation-lifecycle.md), [endpoint health](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/endpoint-health-and-reconstruction.md) | Every intermediate teardown and fresh-construction trigger passes. |
| `HC-015` | pass | [nRF static](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md), [repository gates](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/repository-gates.md) | Zero prohibited facility/allocation and exact resource categories are inspected. |
| `HC-016` | pass | [four-profile driver](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/four-profile-driver.md) | Every hardware-free fixture is explicit and evidence output is bounded to build roots. |
| `HC-017` | pass | [four presets](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/four-preset-comparison.md) | Cross-build rows are labeled and make no connected-target claim. |
| `HC-018` | pass | [preset host instance](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/two-phase-preset-construction.md), [activation lifecycle](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/activation-lifecycle.md) | Finite lifecycle, illegal-state rejection, payload preservation, and report exposure pass. |

## Required-Test Results

The exhaustive negative audit and all 144 focused Host Configuration tests
pass. All four exact driver modes, formatter, governance/documentation checks,
generated freshness, source/import scans, and
`scripts/test.sh --profile all-hardware-free` pass; see the
[repository-gate evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/repository-gates.md).

## Profile, Backend, and Platform Evidence

macOS Dynamic/Static are host execution. Raspberry Pi is exact ARMv6 EABI5
cross-build inspection with a 240×16 RGB565 region plus supplemental connected
adapter evidence: deployment without service restart, device validation, and
one exact bounded framebuffer transfer. It is not connected application/input
evidence. nRF is ARMv7E-M/VFP hard-float link inspection with a 480×4 RGB565
region, 3,840-byte bounds, and a finite device-validation entry. No nRF flash
or connected nRF display/input result is claimed.

## Resource and Performance Evidence

Static evidence records zero prohibited allocation/runtime facilities and
separate profile, host, application, capability, backend, staging, stack,
flash, and RAM costs under pinned toolchains. Dynamic reports retain bounded
allocation/bookkeeping and equal semantic checksums.

## Deviations and Exceptions

No implementation divergence or approved exception was found. The authorized
[PiScreen adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md)
now includes production device ownership and a bounded connected framebuffer
transfer, but not the configured analyzer host or a physical touch. The
[nRF adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md)
is hardware-free pending the physical safety gate and production Static host.
PiScreen and nRF52840 application-level TFT/input validation therefore remains
missing; this is an explicit
downstream conformance gate, not an exception.

## Deferred Work Audit

FW-022 remains a post-MVP simulator idea and cannot replace connected evidence.
Contextual FW-006, FW-009, and FW-018 remain outside this Specification. No
deferred item conceals a current host-configuration correctness requirement.

## Review Conclusion

All eighteen contract criteria have passing hardware-free dispositions, but
the Specification requires separately named connected PiScreen and nRF TFT/
input evidence before the assembled configuration may transition to
`implemented`. This report is ready for human review but does not yet support
that transition. SPEC-015 and its plan remain active/`implementing` with the
connected-target rows open.

## Approved amendment seam handoff — 2026-10-02

The [SPEC-013 Milestone 9 handoff](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-9/owner-handoff.md)
records the implemented partial-mutation/generic owner seam, passing behavior
and bounded carrier checks, and four passing registered profiles for this
owner at f6ef6fb6. This supersedes the pre-amendment seam defect only.
Assembled SPEC-001 T10.5/T10.6 and total budget/fault revalidation remain
outstanding; historical criterion rows do not silently become current
production conformance. No implemented transition is requested.

## Pi display/control signoff verified — 2026-10-03

The [connected approval packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/connected-pi-20261003/README.md) supersedes the older statements that
production Pi physical controls were unobserved. Eugene confirmed plus/minus
and the calibrated S toggle worked, then explicitly marked the Pi application
verified after reviewing the repeated-R deadline failure. The approval-only
Pi application display/control signoff is complete. This is connected-target
evidence with exact binary identities, raw/normalized contacts, dispatch counts,
health observations, and code-1 exit status; it is not inferred from a build.

The full connected obligations remain open: four-frame/second cadence and
250 ms fact-service latency are not met, burst input includes refusals, and
complete connected interaction/trace/failure-recovery coverage is not collected.
No timing exception or whole-Spec `implemented` transition is inferred from
application signoff. These current blockers cannot be deferred as Future Work.
Temporary stopped-startup hosting and monitoring helpers are removed, with the
working calibration and captured-tap regression retained.

## Current connected closeout and maintainer dispositions — 2026-10-03

The [final-artifact closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) supersedes earlier claims that no
production artifact was deployed/flashed or that calibration is provisional.
The maintainer explicitly confirmed touch calibration; that subtask is complete.
Pi timing work is postponed under FW-027, and macOS physical-pointer work is
postponed under FW-031. Neither postponement is an acceptance-criterion waiver.

All 72 final registered hardware-free checks pass, including this owner's four
profiles and current production-join/pixel evidence. The final Pi hash is
verified on the target. Its 32 measured updates average approximately 0.72
frames/second, with 1.294–1.522-second costs and 9,740 KiB peak sampled RSS;
bounded SIGINT teardown prints `status=completed`. The cleaned final nRF image
is flashed and running. Its recorded software Start succeeds, driver/CPU fault
samples are zero, and nine live records match the deterministic source prefix.
Observed presentation intervals of approximately 21 seconds fail cadence.

Complete connected physical/failure coverage, sustained 80-Hz acceptance,
target costs and full connected semantic/action/drawing trace comparison remain
unproved. The macOS physical-pointer subset is explicitly postponed. The
Specification and connected plan remain implementing/active; this complete
evidence disposition does not support a full `implemented` transition.

## Final current-artifact stack case — 2026-10-03

The [painted final-firmware snapshot](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) measures 19,480 / 27,648 bytes after startup/idle, with zero driver/CFSR/HFSR faults and production revision 1. This closes the current startup/idle measurement subcase; it does not establish sustained-load timing or exhaustive worst-case stack use.

## Approved exception and implemented transition — 2026-10-03

**Current disposition — 2026-10-03:** The maintainer explicitly directed
performance work to future iterations and closure of the remaining Specifications.
[Recorded authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md) closes SPEC-001, SPEC-011, and SPEC-015
as `implemented` with approved exceptions for measured timing failures and
missing connected evidence. The original requirements and raw results are retained.
FW-027/FW-032 track performance; FW-031/FW-033 track connected validation.
Earlier open-gate statements below describe the pre-approval history.

Hardware-free acceptance rows retain their passing scope. The remaining
connected gate is closed by the explicit exception in the linked authorization,
with its uncollected physical/fault/trace evidence retained as follow-up.
