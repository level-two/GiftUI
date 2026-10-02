---
spec: SPEC-013
feature: giftui-mvp-architecture
title: SPEC-013 Conformance Report
status: collecting
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-02
implementation_plan: ../implementation-plans/spec-013-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: [SPIKE-003, SPIKE-004, SPIKE-007, SPIKE-008]
supersedes: null
superseded_by: null
---

# SPEC-013 Conformance Report

> **Current applicability — 2026-10-02:** The maintainer approved the
> coordinated SPEC-013/SPEC-015 seam amendment. Earlier passing rows remain historical evidence
> for the frozen baseline and their tested inputs. This report is `collecting`
> for the amendment; partial admitted-work failure and exact application
> rejection through the host opportunity boundary need new evidence from
> [SPEC-013 Milestone 9](../implementation-plans/spec-013-implementation-plan.md#milestone-9-preserve-partial-mutation-and-exact-application-failures).
> No blanket current conformance or implemented transition is claimed.

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

## Review Scope

The review freezes [SPEC-013](../specs/spec-013-runtime-profiles.md) at
pre-report SHA-256
`fa23d3cb09efd86e223e1651667126f1671c59456e8e8eeab11774c2732fcfce`,
the completed [implementation plan](../implementation-plans/spec-013-implementation-plan.md),
its three current design notes, and reviewed implementation revision
`6202efd`. This amendment review includes the independently bounded semantic
candidate and published structural-occurrence stores introduced by the
2026-09-20 reapproval. Evidence covers Apple Swift 6.3.3 host execution and project-local
Swift 6.3.2 ARMv6/nRF hardware-free cross-build, link, and inspection.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `RP-001` | pass | [final package audit](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-8/final-package-audit.md) | Exact owner graph has no sibling or concrete backend import. |
| `RP-002` | pass | [storage audit](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-1/storage-audit-accounting.md) | Every store, including independent semantic node/structural candidate and published capacities, and four render-workspace capacities have checked exact totals. |
| `RP-003` | pass | [startup corpus](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/startup-validation.md) | All missing, invalid, first-shortfall, overflow, and static-table cases fail before client or endpoint use. |
| `RP-004` | pass | [common transaction](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-2/common-transaction.md), [cycle failures](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/cycle-failure-matrix.md) | Stage order, binding, release, and every cleanup row pass. |
| `RP-005` | pass | [profile equivalence](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/profile-equivalence.md) | All normalized semantic through disposition categories compare exactly. |
| `RP-006` | pass | [storage boundaries](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/storage-boundaries.md) | Exact limit and first excess pass for every storage family. |
| `RP-007` | pass | [cleanup oracle](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-2/cleanup-oracle.md) | Failed derivation releases candidate/attempt state without replay. |
| `RP-008` | pass | [handoff recovery](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/handoff-recovery.md) | Only accepted handoff commits routing. |
| `RP-009` | pass | [handoff recovery](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/handoff-recovery.md) | Refusal retains only constant-space intent. |
| `RP-010` | pass | [target inspection](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-7/target-inspection.md) | Generated table/capture/destruction and zero-heap/forbidden-facility checks pass. |
| `RP-011` | pass | [final package audit](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-8/final-package-audit.md), [profile equivalence](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/profile-equivalence.md) | Dynamic conveniences remain separate and semantics are equal. |
| `RP-012` | pass | [borrow boundaries](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/borrow-boundaries.md) | Dependencies, typed negatives, poisoning, and table coverage pass. |
| `RP-013` | pass | [resource instrumentation](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-7/resource-instrumentation.md), [repository gates](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-8/repository-profile-gates.md) | Pinned-toolchain reports are reproducible and same-input reuse is verified. |
| `RP-014` | pass | [production observable workspaces](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-5/production-observable-profile-workspaces.md) | Initial/replacement/discard generation behavior is exact. |
| `RP-015` | pass | [focused failure disposition](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-2/focused-failure-disposition.md), [profile equivalence](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-6/profile-equivalence.md) | Exact focused values, mappings, cleanup, and equal transcripts pass. |

## Required-Test Results

The formatter, focused suites, four exact profile drivers, module/dependency
audits, governance checks, and `scripts/test.sh --profile all-hardware-free`
all pass. The aggregate result and idempotent publication behavior are recorded
in the [repository/profile gate evidence](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-8/repository-profile-gates.md).
The schema-3 amendment additionally passes exact-limit/first-excess Dynamic
semantic storage tests and all four SPEC-015 profile drivers.

## Profile, Backend, and Platform Evidence

macOS Dynamic/Static provide host behavior. Pi provides exact ARMv6 cross-
object/link inspection. nRF provides ARMv7E-M/VFP hard-float ELF inspection.
SPEC-013 does not require connected target execution for contract approval;
none is claimed.

## Resource and Performance Evidence

Reports retain every value layout, disjoint storage family, high-water count,
stack stage, allocation/peak/bookkeeping value, linked section, flash/RAM
value, and both timing workloads. Static modes report zero heap and no
forbidden runtime or language facility.

## Deviations and Exceptions

No implementation divergence, failed criterion, or approved exception was
found. The same-input publication repair preserves immutable evidence by
verifying and reusing an existing report rather than overwriting variable
timing samples.

## Deferred Work Audit

SPIKE-003, SPIKE-004, SPIKE-007, and SPIKE-008 remain feasibility evidence.
No deferred item conceals a current runtime-profile requirement.

## Review Conclusion

All fifteen criteria have reproducible passing evidence and no remaining
SPEC-013 conformance gate. This report supports requesting explicit human
authorization for the `implemented` transition. That authorization has not
been given, so SPEC-013 remains `implementing`.

## SPEC-001 production-join discovery — 2026-10-02

The [T10.5 reproduction](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/dynamic-runner-blocker.md)
exposes a gap outside the earlier tested fixture assumptions. Applying one
admitted fact before application failure returns an unchanged semantic
disposition and no dirty wake. The shared mutation result cannot carry partial
application, and the exact application-rejection boundary needs owner review.
RP-004/RP-007 production applicability is therefore blocked pending the owner
repair; RP-015 needs revalidation of the complete production error route.
Earlier passing rows remain historical results for their tested corpus, not
a current blanket production-readiness conclusion. No exception or contract
amendment has been approved.

## Approved amendment seam handoff — 2026-10-02

The [SPEC-013 Milestone 9 handoff](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-9/owner-handoff.md)
records the implemented partial-mutation/generic owner seam, passing behavior
and bounded carrier checks, and four passing registered profiles for this
owner at f6ef6fb6. This supersedes the pre-amendment seam defect only.
Assembled SPEC-001 T10.5/T10.6 and total budget/fault revalidation remain
outstanding; historical criterion rows do not silently become current
production conformance. No implemented transition is requested.
