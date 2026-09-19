---
spec: SPEC-011
feature: giftui-mvp-architecture
title: SPEC-011 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-09-19
implementation_plan: ../implementation-plans/spec-011-implementation-plan.md
related_future_work: [FW-021]
related_explorations: []
related_spikes: [SPIKE-007]
supersedes: null
superseded_by: null
---

# SPEC-011 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

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

No contract divergence or approved exception was found. Connected macOS/Pi
pointer-display evidence (T9.3) and connected nRF input/display evidence
(T9.4) are not collected and are not inferred from hardware-free artifacts.

## Deferred Work Audit

FW-021 remains post-MVP and SPIKE-007 remains feasibility evidence only.
Neither conceals a current interaction correctness requirement.

## Review Conclusion

All thirteen acceptance criteria have passing hardware-free evidence, but the
Specification explicitly retains connected input/display as an implemented-
conformance gate. This report is ready for human conformance review but does
not yet support the `implemented` transition. SPEC-011 remains `implementing`;
T9.3 and T9.4 remain open.
