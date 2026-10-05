---
spec: SPEC-013
feature: giftui-mvp-architecture
title: SPEC-013 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-05
implementation_plan: ../implementation-plans/spec-013-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: [SPIKE-003, SPIKE-004, SPIKE-007, SPIKE-008]
supersedes: null
superseded_by: null
---

# SPEC-013 Conformance Report

**Current amendment — 2026-10-05:** Approved five-second retention is implemented and all four hardware-free profiles pass in the [fresh integration](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Focused nRF connected checks/restoration and current Pi deployment/ARMv6 rehearsal/bounded physical endpoint loop succeed. Original exception authority remains unchanged.


> **Current disposition — 2026-10-03:** [Final owner review](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) closes the amended seam and production-join applicability blockers. All four owner profiles and the complete 72-check gate pass; all owner task dispositions are complete. The maintainer explicitly approved the implemented transition in the linked owner-approval record.

> **Historical amendment applicability — 2026-10-02:** The maintainer approved the
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

## Current final-artifact gate review — 2026-10-03

The [iteration closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) records a complete final invocation of the
registered hardware-free gate: 72 checks pass, including this owner's four
profiles, current application integration, selected-runtime isolation, fault
corpora and reviewed pixel comparisons. This supersedes the earlier recorded
sandbox/profile failures and resolved production-join blockers for these
tested inputs; historical reports retain their original scope.

The criterion evidence has been reviewed against the current approved contract;
all existing owner acceptance rows retain their passing dispositions for the
applicable corpus. No new contract, exception, connected-hardware claim or
Specification status transition is inferred. The report is complete and
supports requesting an explicit human `implemented` transition for this owner.

## Human implemented-transition authorization — 2026-10-03

Eugene explicitly approved SPEC-013's `implementing → implemented` transition as one of the ten named owner transitions. [The approval record](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/owner-transition-approval.md) supersedes prior statements that authorization was pending. The Specification is now implemented; connected application and MVP gates retain their distinct scope.

## Iteration 2 maintenance integration — 2026-10-05

[Fresh 30s-contract packet](../iterations/iteration-002-cleanup/evidence/10-integration/result.md)
reviews all 15 criteria against the unchanged approved contract at revision
759cf594. All four owner profiles and their composed resource/dependency gates
pass; all 74 repository checks and 60 immutable reports verify. The original
criterion table and historical raw evidence retain their dispositions. New
startup/capacity/source-selection/generator/compiler observations apply only
to their maintained and hardware-free evidence, with exact hashes and limits
in the linked packet. No lifecycle transition or new exception follows.
Connected changed-path checks and final application reconciliation remain
SPEC-001 T11.7/T11.8. Retention remains 30s/2,404 pending RFC/ADR/Spec gates.

## Current maintenance limits — 2026-10-05

[Connected attempt](../iterations/iteration-002-cleanup/evidence/11-connected-attempt/result.md)
is incomplete and cannot satisfy a new connected criterion or enlarge the
2026-10-03 exceptions. SPEC-001 T11.7 and its dependent T11.8 remain blocked.
The production fixes and all fresh hardware-free observations stand separately;
iteration closure and retention's RFC/ADR/Spec gates remain unmet.

| New maintenance observation | Criteria affected | Evidence and limit |
| --- | --- | --- |
| Explicit Embedded source selection and profile/resource/dependency negatives | RP-002/003/006/013/014/015 | [Selected-file packet](../iterations/iteration-002-cleanup/evidence/07-source-selection/result.md) and [four-profile integration](../iterations/iteration-002-cleanup/evidence/10-integration/result.md); isolated linked-size delta zero, no lifecycle/profile contract change. |

## Current approved retention amendment — 2026-10-05

[Explicit approval](../iterations/iteration-002-cleanup/retention-approval.md)
and accepted ADR-034 supersede earlier pending-approval/30s descriptions for
current production. [Five-second integration](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md)
verifies all four owner profiles with current source-hashed raster references:
74 checks and 60 report manifests pass. Five-second/404-record baseline,
eviction, snapshots, replay and independent full-history 1/2/5s left edges pass;
the 30s/80-event-per-second delivery workload remains unchanged. Linked nRF
RAM is 95,104 (−96,000), flash 274,144 (−128), configured stacks unchanged,
heaps zero and hard-float ABI verified. Exact criteria/commands/compiler/
artifact identities and raw failures are retained in the packet.

[nRF connected verification](../iterations/iteration-002-cleanup/evidence/16-nrf-connected/result.md)
completes startup/software Start/Stop/1/2/5s/capture/fault/cleanup observations
on the current firmware and restores running idle. This is not physical-input,
independent pixel, sustained 80-Hz, cadence or exhaustive stack evidence.
Pi connectivity blocks its new deployment/production-loop check and dependent
SPEC-001 T12.4/T11.7/T11.8. Prior specifically approved exceptions and original
criterion/raw evidence remain unchanged; no broader exception or lifecycle
transition is inferred. Earlier connected-failure statements are historical;
current nRF restoration succeeds and explicit deployment approval is recorded.

### Current criterion dispositions for the approved amendment

| Criterion | Disposition | Current evidence and limit |
| --- | --- | --- |
| `RP-001` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-002` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-003` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-004` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-005` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-006` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-007` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-008` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-009` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-010` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-011` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-012` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-013` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-014` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `RP-015` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |

## Current Pi completion and iteration reconciliation — 2026-10-05

[Verified deployed image](../iterations/iteration-002-cleanup/evidence/21-pi-deployment/result.md)
and [current ARMv6 connected packet](../iterations/iteration-002-cleanup/evidence/22-pi-connected/result.md)
supersede the previous connectivity blocker. Actual ARMv6 production-owner
software/recording rehearsal passes 120 workload frames, nine startup/action
frames and 12 actions against the current hashed reference. Real physical
framebuffer/touch loop runs boundedly, observes no supplied contacts, and ends
`status=completed` with no remaining process and unchanged hash. Physical-loop
frame costs remain 1.322–1.509s; no timing pass is inferred. Software/control/
source proof and physical endpoint startup/cleanup remain separately classified.
Together with nRF packet 16, T12.4/T11.7 and final T11.8 are complete.
[Final criterion/closure record](../iterations/iteration-002-cleanup/evidence/23-closeout/result.md)
retains the original exception and deferred boundaries; no Specification
lifecycle transition or broader physical/timing/stack conformance follows.
