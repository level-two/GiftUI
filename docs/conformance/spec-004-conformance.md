---
spec: SPEC-004
feature: capability-system
title: SPEC-004 Conformance Report
status: complete
reviewers:
  - codex
created: 2026-09-19
updated: 2026-09-19
implementation_plan: ../implementation-plans/spec-004-implementation-plan.md
related_future_work: [FW-006, FW-007, FW-008, FW-014, FW-015, FW-018]
related_explorations: []
related_spikes: [SPIKE-001, SPIKE-002]
supersedes: null
superseded_by: null
---

# SPEC-004 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

## Review Scope

- Governing contract: [SPEC-004 Capability Contribution and Resolution](../specs/spec-004-capability-contribution-and-resolution.md), status `implementing`, pre-report SHA-256 `e7c6e526c9543c3dec38e1890d82aae61d924347886dc7a7ca5a3388631b80d8`.
- Completed plan: [SPEC-004 Implementation Plan](../implementation-plans/spec-004-implementation-plan.md).
- Reviewed implementation revision: `383d1e72b398fedb0ffb85313526ccbcee8cf8e9`.
- Environments: Apple Swift 6.3.3 macOS arm64 dynamic/static host execution;
  project-local Swift 6.3.2 ARMv6 and Embedded Swift/nRF52840 hardware-free
  compile, link, and artifact inspection.

The Proposal, RFCs, ADRs, Specification, manifest, and reciprocal SPEC-002/003
relationships remain authoritative and internally consistent. The conformance
review changes no capability, failure, startup, backend, or host contract.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `CR-001` | pass | [navigation audit](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-6/navigation-audit.md) | Authority, manifest, and reciprocal links pass. |
| `CR-002` | pass | [final boundaries](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-4/final-capability-boundaries.md) | Exact leaf imports and identity-free portable values pass. |
| `CR-003` | pass | [closed vocabulary](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-1/closed-vocabulary.md) | The catalogue contains only `rasterPresentation`. |
| `CR-004` | pass | [bounded values](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-1/bounded-value-audits.md), [resource boundary](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-5/nrf-resource-boundary.md) | Declarations, validation, capacities, and layouts satisfy their ceilings. |
| `CR-005` | pass | [resolver orchestration](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-2/public-resolver-orchestration.md) | All 24 contributor permutations normalize identically. |
| `CR-006` | pass | [negative coverage](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-3/negative-and-control-coverage.md) | Missing, duplicate, malformed, optional, and workspace cases are exact. |
| `CR-007` | pass | [precedence matrix](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-2/primary-reason-precedence.md) | Every constructible simultaneous incompatibility follows the fixed order. |
| `CR-008` | pass | [compatibility evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-2/path-compatibility-and-policy.md) | Encoding and submission-lifetime failures remain distinct. |
| `CR-009` | pass | [one-shot lease](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-3/one-shot-lease-and-payload.md), [production consumers](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-4/production-one-shot-consumers.md) | The complete lifetime/handoff matrix passes with no retained stream. |
| `CR-010` | pass | [four-profile compilation](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-5/four-profile-compilation.md), [final matrix](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-6/final-hardware-free-matrix.md) | Exact normalized host results and target cross-builds pass. |
| `CR-010A` | pass | [checked arithmetic](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-2/checked-raster-arithmetic.md) | Formula, bound, and overflow corpus includes the exact 3,840-byte nRF row. |
| `CR-011` | pass | [static path](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-5/static-path-and-semantic-equivalence.md) | Static resolution and snapshot access allocate zero heap. |
| `CR-012` | pass | [bounded work](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-2/bounded-resolver-work.md), [static path](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-5/static-path-and-semantic-equivalence.md) | Steady-state access performs zero resolution; initialization remains at 44 operations. |
| `CR-013` | pass | [nRF resource evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-5/nrf-resource-boundary.md) | Two pristine matched pairs, layouts, RAM, flash, storage, stack, and call graph pass. |
| `CR-014` | pass | [production consumers](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-4/production-one-shot-consumers.md) | Both first-party tiled consumers borrow once and retain/replay nothing. |
| `CR-015` | pass | [failure adapter](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-4/failure-outcome-adapter.md), [production consumers](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-4/production-one-shot-consumers.md) | Runtime faults preserve the immutable snapshot and use SPEC-003 seams. |
| `CR-016` | pass | [startup gates](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-4/conjunctive-startup-gates.md) | B2 and capability gates fail independently and start conjunctively. |

## Required-Test Results

All four exact standalone commands passed at clean revision `383d1e7` and
published the same immutable report identity; the commands and classifications
are preserved in the [final hardware-free matrix](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-6/final-hardware-free-matrix.md).
The complete registered `scripts/test.sh all-hardware-free` command also ran to
completion. Its nonzero status comes from independently fail-closed SPEC-011
T7-T9 rows and a SPEC-007 nRF direct-compilation defect, not a remaining
SPEC-004 failure.

## Profile, Backend, and Platform Evidence

macOS dynamic/static supply behavioral host execution. Raspberry Pi supplies
only an ARMv6 EABI5 hard-float cross-build and object inspection. nRF52840
supplies only an Embedded Swift/Zephyr ARMv7E-M, VFPv4-D16, VFP-register-ABI
cross-build, link, and inspection. No connected target, simulator, deployment,
service restart, remote access, or flashing is claimed.

## Resource and Performance Evidence

The matched nRF evidence records +252 bytes linked RAM, +4,768 bytes linked
flash, 202 bytes named capability storage, 3,840 bytes display staging, 44
initialization operations, and an 80-byte conservative resolver stack. All ten
named record layouts pass on 32-bit ARMv6/nRF and 64-bit macOS. Two pristine
baseline/candidate rebuilds reproduce byte-identical ELFs, metrics, and the
seven-node resolved call graph with no indirect call, dynamic stack,
recursion, or missing body.

## Deviations and Exceptions

No SPEC-004 implementation divergence, failed criterion, or approved exception
was found. The ARMv6 driver defect was evidence selection, not product
behavior; it is corrected by selecting the exact target-triple module. The
repository-wide aggregate observations are not exceptions and do not weaken
any SPEC-004 result.

## Deferred Work Audit

FW-006, FW-007, FW-008, FW-014, FW-015, and FW-018 remain captured and
unpromoted. SPIKE-001 and SPIKE-002 remain feasibility evidence only. None
conceals a current capability correctness or conformance requirement.

## Review Conclusion

All seventeen criteria have reproducible passing evidence with no deviation or
exception. This report supports requesting explicit human authorization for
SPEC-004's `implemented` transition. That authorization has not been given, so
SPEC-004 remains `implementing`.
