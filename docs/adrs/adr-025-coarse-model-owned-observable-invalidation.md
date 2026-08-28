---
id: ADR-025
feature: observable-reference-state
title: Coarse Model-Owned Observable Invalidation
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-27
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-004
  - RFC-008
  - RFC-011
related_adrs:
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-026
  - ADR-027
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-010
  - SPEC-011
  - SPEC-013
related_future_work:
  - FW-019
related_explorations: []
related_spikes:
  - SPIKE-003
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-025: Coarse Model-Owned Observable Invalidation

## Status

Accepted.

## Context

Observable presentation mutations must invalidate dependent GiftUI output
without exposing runtime calls to portable Presentation or depending on
Apple Observation. The fixed Signal Analyzer hierarchy does not justify a
property-read graph, retained subtrees, or mutation history, and every update
must remain inside the serialized publication architecture of RFC-004 and
ADR-011.

## Decision Boundary

This record extracts RFC-008 Decision Summary item 2. It owns the semantic
meaning and timing of model change reports and the MVP invalidation
granularity. It inherits state-location lifetime from ADR-024, realization
constraints from ADR-026, and mutation admission from ADR-027.

## Decision

An observable model MUST provide a narrow model-owned mechanism that attaches
and detaches one bounded change sink for its owning state location. Every
admitted mutation that changes observable model state MUST synchronously
produce at least one change report before that mutation returns. A mutation
MAY omit a report only when it proves that no observable model state changed.

A change report MUST carry only the meaning that values derived from the
owning model may have changed. It MUST NOT expose a property path, new value,
snapshot, backend identity, scheduler identity, or diagnostic authority.

The runtime MUST coalesce reports into bounded owner-level dirtiness and at
most one pending wake requirement. Reports MUST NOT trigger reentrant
evaluation or accumulate into correctness-relevant history. When any live
observable state location is dirty, the common MVP behavior MUST permit
complete-root reevaluation and MUST NOT require property-read tracking,
dependency edges, or selective subtree reconciliation.

Observable mutations MUST occur only during RFC-004's serialized mutation
phase. The runtime MUST freeze model mutation before derivation and publish
only complete semantic revisions. If derivation fails after mutation, the
mutation MUST NOT be replayed or rolled back; affected state MUST remain dirty
for paced rederivation. Dirtiness represented by a published semantic
revision MAY clear independently of backend acceptance or physical display.

Profile-specific optimizations MAY reduce work only when they preserve these
semantics and pass the shared conformance fixtures.

## Rationale

Synchronous model-owned signaling keeps invalidation coupled to mutation while
leaving portable views independent of runtime integration. Coarse dirtiness
has constant report work, bounded retained state, and no dependency graph. It
is sufficient for the fixed Signal Analyzer and composes directly with the
existing freeze and complete-publication contract.

## Consequences

### Positive

- Portable Presentation never calls a runtime `invalidate()` function.
- Multiple changes can coalesce without losing admitted model updates.
- Static and dynamic profiles share one observable result without sharing an
  instrumentation mechanism.
- Failed rendering cannot roll semantic state backward.

### Negative

- Any reported change may reevaluate the complete portable root.
- Models or generated adapters must instrument every observable mutation.
- Direct observation of mutable model fields outside a published GiftUI
  revision is not transactionally covered by GiftUI.

### Follow-up

- A Specification must define attach/detach declarations, dirty-state
  handling, phase-violation outcomes, and wake integration.
- Conformance tests must cover synchronous reporting, no-op omission,
  coalescing, freeze violations, failed derivation, and publication clearing.

## Deferred and Follow-up Work

- [FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md)
  preserves property-level tracking and selective reevaluation. Revisit only
  when accepted performance evidence or a later feature requires it.

## Rejected Alternatives

### Apple Observation as the common contract

Rejected because it is unavailable across the supported Linux and Embedded
Swift profiles and would expose machinery beyond the required semantics.

### Property-level dependency tracking

Rejected because dependency identity, graph capacity, stale-edge cleanup, and
subtree reconciliation are not justified by the MVP workload.

### Polling or snapshot comparison

Rejected because it creates clock-driven or copying work and does not define
safe mutation timing relative to freeze.

### Explicit client `invalidate()` calls

Rejected because mutation and invalidation can drift apart and runtime
coordination would leak into portable Presentation.

## References

- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [SPIKE-003: Portable Observable Reference State Feasibility](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
