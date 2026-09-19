---
spec: SPEC-010
feature: observable-reference-state
title: SPEC-010 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-09-19
implementation_plan: ../implementation-plans/spec-010-implementation-plan.md
related_future_work: [FW-019]
related_explorations: []
related_spikes: [SPIKE-003, SPIKE-006]
supersedes: null
superseded_by: null
---

# SPEC-010 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

## Review Scope

The review freezes [SPEC-010](../specs/spec-010-observable-reference-state.md)
at pre-report SHA-256
`bde6a33acb6c795959a81ab2276227f108fb377b42674cb6795300f2e12dada6`,
its completed [plan](../implementation-plans/spec-010-implementation-plan.md),
and implementation revision `ef3620907d857a06a94fff30f8937b2e2f8d17ce`.
Evidence covers Apple Swift 6.3.3 macOS host execution and project-local Swift
6.3.2 ARMv6/nRF hardware-free cross-build and inspection.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `OS-001` | pass | [portable declarations](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/portable-declaration-family.md), [four-profile host](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/four-profile-generated-host.md) | Exact declaration family, compile positives/negatives, and layouts pass. |
| `OS-002` | pass | [structural reconciliation](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-3/structural-reconciliation.md), [candidate lifecycle](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-3/candidate-lifecycle.md) | Same-location identity preservation and omission behavior pass. |
| `OS-003` | pass | [atomic replacement](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-4/atomic-replacement.md), [target lifetime](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-4/target-lifetime.md) | Replacement/removal are atomic and never alias retired targets. |
| `OS-004` | pass | [dirty derivation](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-5/dirty-derivation.md), [profile equivalence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-6/profile-equivalence.md) | Twenty changes coalesce to one dirty owner/wake/reevaluation. |
| `OS-005` | pass | [failure adapter](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-7/failure-adapter.md), [failure policy](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-7/failure-policy.md) | Exact local mapping, precedence, mandatory effects, and publication protection pass. |
| `OS-006` | pass | [profile equivalence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-6/profile-equivalence.md), [cross-profile comparison](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-8/cross-profile-comparison.md) | Dynamic/static transcripts agree; static operation is zero heap. |
| `OS-007` | pass | [fact admission](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-2/fact-admission.md), [report guard](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-5/report-guard.md) | Later ordered application and direct/reentrant rejection pass. |
| `OS-008` | pass | [target dependency audit](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-0/target-dependency-audit.md), [nRF evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-8/nrf52840-embedded.md) | Forbidden imports, facilities, symbols, and target-image macro support are absent. |
| `OS-009` | pass | [attachment generations](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-4/attachment-generations.md), [target lifetime](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-4/target-lifetime.md) | Fresh generation, retirement, reuse rejection, and exhaustion pass. |
| `OS-010` | pass | [deterministic generation](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/deterministic-host-generation.md), [binding decorator](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-3/binding-decorator.md) | Lexical visitation and bind-before-body are exact. |
| `OS-011` | pass | [report route](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-5/report-route.md), [mutation result](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-5/mutation-result-slot.md) | Every report outcome and first-failure result is exact. |
| `OS-012` | pass | [target lookup](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-4/target-lookup.md), [target lifetime](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-4/target-lifetime.md) | Candidate lookup visibility and publish/discard timing pass. |

## Required-Test Results

All four exact `run-spec-010.sh` commands passed at revision `ef36209` and
published immutable run ID
`ef3620907d857a06a94fff30f8937b2e2f8d17ce-36cd22863e7a64fe`.
They cover public/package surfaces, generated symbols, migration closure,
module boundaries, normalized behavior, layouts, bounds, allocations, and the
implemented downstream owner joins.

The repository gate records two downstream blockers: SPEC-011 intentionally
fails closed pending T7-T9, and SPEC-013 macOS dynamic has a same-identity
report-publication conflict after its prerequisite scan reports an empty
canonical corpus. Neither is represented as observable-state evidence.

## Profile, Backend, and Platform Evidence

macOS dynamic/static provide host execution. Pi is an ARMv6 EABI5 hard-float
cross-build/inspection only. nRF is an ARMv7E-M/VFPv4-D16 hard-float
cross-build/link/inspection only. No simulator, connected target, deployment,
service restart, remote access, or flashing is claimed.

## Resource and Performance Evidence

The four profiles agree on generated declaration input, limits, normalized
results, storage high-water, and transcript digests. Static optimized binding
is zero heap. Production capacities, platform-dependent timing, link maps,
sections, and stack values remain separately classified in SPEC-013/015-owned
evidence rather than being inferred from the observable owner fixtures.

## Deviations and Exceptions

No SPEC-010 deviation or approved exception was found. Downstream SPEC-011 and
SPEC-013 repository gates remain visible but do not amend this contract.

## Deferred Work Audit

FW-019 remains captured and unpromoted. SPIKE-003 and SPIKE-006 remain
feasibility evidence only. None conceals a current correctness requirement.

## Review Conclusion

All twelve criteria have reproducible passing evidence with no deviation or
exception. The evidence supports requesting explicit human authorization for
SPEC-010's `implemented` transition. That authorization has not been given, so
SPEC-010 remains `implementing`.
