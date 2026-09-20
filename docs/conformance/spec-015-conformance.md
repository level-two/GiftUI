---
spec: SPEC-015
feature: giftui-mvp-architecture
title: SPEC-015 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-09-20
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: [FW-022]
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-015 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

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
