---
spec: SPEC-011
feature: giftui-mvp-architecture
title: SPEC-011 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-05
implementation_plan: ../implementation-plans/spec-011-implementation-plan.md
related_future_work:
  - FW-021
  - FW-031
  - FW-033
related_explorations: []
related_spikes: [SPIKE-007]
supersedes: null
superseded_by: null
---

# SPEC-011 Conformance Report

**Current disposition — 2026-10-03:** The maintainer explicitly directed
performance work to future iterations and closure of the remaining Specifications.
[Recorded authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md) closes SPEC-001, SPEC-011, and SPEC-015
as `implemented` with approved exceptions for measured timing failures and
missing connected evidence. The original requirements and raw results are retained.
FW-027/FW-032 track performance; FW-031/FW-033 track connected validation.
Earlier open-gate statements below describe the pre-approval history.

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.
>
> **nRF target applicability:** The ILI9486/ADS7846 adapter statements below
> describe the original 480 x 320 fixture at the frozen review revision. The
> approved nRF target is now the 240 x 320 `KMRTM24024-SPI` direct-SPI module.
> Its [hardware-free application and input follow-up](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-240x320-hardware-free.md)
> passes; connected touch and display routing remain open for `T9.4`.

## Review Scope

The review freezes [SPEC-011](../specs/spec-011-interaction.md) at pre-report
SHA-256 `e7250223a39d7babd3bceae7a5d683c90d76cfe0ac145f4a2608ceb0c0fb6008`,
the active [implementation plan](../implementation-plans/spec-011-implementation-plan.md),
the current target-bound dispatch design note, and implementation revision
`41f9e86128fab0194f8e5971e9bb0c8144899570`. The complete hardware-free gate
passed on Apple Swift 6.3.3 host execution and project-local Swift 6.3.2 ARMv6
and nRF cross-build/link inspection.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `IN-001` | pass | [four-profile declarations](../../Tests/ContractFixtures/SPEC011/Evidence/t8-1-four-profile-declarations.md) | Exact declarations and registered negative shapes compile/check in all modes. |
| `IN-002` | pass | [interaction corpus](../../Tests/ContractFixtures/SPEC011/Evidence/t8-2-interaction-corpus.md) | Six codes, wrong type, and invalid code follow exact dispatch outcomes. |
| `IN-003` | pass | [semantic borrows](../../Tests/ContractFixtures/SPEC011/Evidence/t2-4-semantic-borrows.md), [resource audit](../../Tests/ContractFixtures/SPEC011/Evidence/t8-4-layout-resource-audit.md) | Stable identity/value are retained without handler/model ownership. |
| `IN-004` | pass | [interaction corpus](../../Tests/ContractFixtures/SPEC011/Evidence/t8-2-interaction-corpus.md) | Checked hit bounds, clips, painter order, and disabled overlap pass. |
| `IN-005` | pass | [interaction corpus](../../Tests/ContractFixtures/SPEC011/Evidence/t8-2-interaction-corpus.md) | Capture is identity/generation only; all invalid releases cancel. |
| `IN-006` | pass | [replacement timing](../../Tests/ContractFixtures/SPEC011/Evidence/t5-5-replacement-timing.md) | Replacement races invoke neither stale model and preserve failed replacement. |
| `IN-007` | pass | [mutation dispatch](../../Tests/ContractFixtures/SPEC011/Evidence/t5-6-mutation-dispatch.md) | Valid activation dispatches once in mutation order and reports synchronously. |
| `IN-008` | pass | [generation offer](../../Tests/ContractFixtures/SPEC011/Evidence/t5-2-generation-offer.md) | Candidate lifecycle and atomic commit/discard behavior are exact. |
| `IN-009` | pass | [failure precedence](../../Tests/ContractFixtures/SPEC011/Evidence/t6-2-failure-precedence.md), [containment](../../Tests/ContractFixtures/SPEC011/Evidence/t6-3-containment.md) | Every mapped failure performs mandatory containment with no fallback. |
| `IN-010` | pass | [allocation/workspaces](../../Tests/ContractFixtures/SPEC011/Evidence/t8-3-static-allocation-workspace.md) | Equal-limit transcripts match and Static reports zero heap. |
| `IN-011` | pass | [integration audit](../../Tests/ContractFixtures/SPEC011/Evidence/t9-1-integration-audit.md), [resource audit](../../Tests/ContractFixtures/SPEC011/Evidence/t8-4-layout-resource-audit.md) | Dependency and forbidden-facility scans pass. |
| `IN-012` | pass | [cross-target artifacts](../../Tests/ContractFixtures/SPEC011/Evidence/t8-5-cross-target-artifacts.md) | Exact ABI, fixed storage, stack, RAM/flash, direct dispatch, and symbols are inspected. |
| `IN-013` | pass | [target binding](../../Tests/ContractFixtures/SPEC011/Evidence/t5-1-target-binding.md), [interaction corpus](../../Tests/ContractFixtures/SPEC011/Evidence/t8-2-interaction-corpus.md) | All candidate generation and non-publication dispositions use the exact publishable generation. |

## Required-Test Results

All four exact standalone drivers passed at revision `00ed92c` with immutable
run ID `00ed92cf190ab5d99af9584aa62d24e1c3ba26f5-634d5f4540fd9f1f`.
After the shared gate repairs, `scripts/format-swift.sh` and
`scripts/test.sh --profile all-hardware-free` passed completely at revision
`2aeeb81`; see the [repository-gate record](../../Tests/ContractFixtures/SPEC011/Evidence/t9-2-repository-gate.md).

## Profile, Backend, and Platform Evidence

macOS Dynamic and Static are host execution. Raspberry Pi is exact ARMv6
EABI5 artifact inspection. nRF is ARMv7E-M/Thumb-2/VFPv4-D16 hard-float link
inspection. No simulator, connected display/input, remote access, deployment,
service restart, or flashing is claimed.

## Resource and Performance Evidence

The reports separate record/candidate/committed/profile workspaces, stack by
stage, Dynamic allocator bookkeeping, zero-heap Static paths, value layouts,
timing, sections, maps, flash, and RAM. Static SIL/IR and linked-symbol scans
reject closure boxes, reflection, unrestricted existentials, indirect
registries, tasks/threads, and allocator facilities.

## Deviations and Exceptions

No contract divergence or approved exception was found. The authorized
[Pi adapter work](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md)
now validates accessible framebuffer/touchscreen devices and records one exact
bounded connected framebuffer transfer. No physical touch occurred and the
artifact has no production analyzer host loop, so routing, provenance, and
dispatch remain unobserved and the Pi portion of T9.3 stays blocked.
Connected macOS pointer evidence and nRF input/display evidence (T9.4) are not
collected. The [nRF adapter build](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md)
selects and links the ILI9486/ADS7846 stack but was not flashed and is not
inferred as connected evidence.

## Deferred Work Audit

FW-021 remains post-MVP and SPIKE-007 remains feasibility evidence only.
Neither conceals a current interaction correctness requirement.

## Review Conclusion

All thirteen acceptance criteria have passing hardware-free evidence, but the
Specification explicitly retains connected input/display as an implemented-
conformance gate. This report is ready for human conformance review but does
not yet support the `implemented` transition. SPEC-011 remains `implementing`;
T9.3 and T9.4 remain open.

## SPEC-001 milestone 10 gate applicability — 2026-10-02

The complete current hardware-free gate has failed this owner's profile
checks. The [milestone 10 disposition packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/revalidation-disposition.md)
records the exact gate results and failure logs. Historical passing evidence
above remains scoped to its recorded revision and inputs; it is not a current
full-gate pass. The owner assertion must be resolved and rerun, without waiving
a boundary or migration requirement, before the assembled cleanup can close.

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

## Iteration 2 maintenance integration — 2026-10-05

[Fresh 30s-contract packet](../iterations/iteration-002-cleanup/evidence/10-integration/result.md)
reviews all 13 criteria against the unchanged approved contract at revision
759cf594. All four owner profiles and their composed resource/dependency gates
pass; all 74 repository checks and 60 immutable reports verify. The original
criterion table and historical raw evidence retain their dispositions. New
startup/capacity/source-selection/generator/compiler observations apply only
to their maintained and hardware-free evidence, with exact hashes and limits
in the linked packet. No lifecycle transition or new exception follows.
Connected changed-path checks and final application reconciliation remain
SPEC-001 T11.7/T11.8. Retention remains 30s/2,404 pending RFC/ADR/Spec gates.
