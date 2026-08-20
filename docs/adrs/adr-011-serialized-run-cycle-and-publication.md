---
id: ADR-011
feature: giftui-mvp-architecture
title: Serialized Run Cycle and Semantic Publication
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-004
related_adrs:
  - ADR-006
  - ADR-010
  - ADR-012
  - ADR-013
  - ADR-015
related_specs: []
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-011: Serialized Run Cycle and Semantic Publication

## Status

Proposed.

## Context

The Signal Analyzer may receive state-change facts much faster than it
presents frames. External callbacks and interrupts cannot safely mutate
GiftUI-observed state during reconciliation, and frame failure must not replay
client actions or expose partially derived revisions.

## Decision

Each run cycle MUST seal an ordered bounded batch of input, state-change facts,
and admitted work before semantic evaluation. The runtime MUST apply each
admitted mutation and action at most once in one non-suspending serialized
domain, coalesce invalidation, freeze observed state during derivation, and
publish only a complete semantic revision.

Facts arriving after the seal and reentrant external input MUST wait for a
later admission boundary. A pre-publication derivation failure MUST discard
partial derived work, leave already-applied state dirty, and request a later
host-paced recomputation from current state without replaying mutations,
actions, or effects.

Semantic publication MUST remain independent from presentation outcome. A
published revision MUST NOT be rolled back by frame refusal or later physical
presentation failure; presentation-coupled routing state remains staged until
its frame commits.

## Rationale

Sealed admission makes ordering deterministic across dynamic and static
profiles. At-most-once effects avoid requiring rollback of arbitrary client
state, while complete publication gives GiftUI observers a coherent revision
even when the display is temporarily unavailable.

## Consequences

### Positive

- Mutations, actions, and effects are not replayed by recovery.
- Observers never receive an intermediate GiftUI-managed revision.
- Input coalescing and lower presentation rates do not change semantic order.

### Negative

- External producers need bounded admission rather than direct mutation.
- Direct observation of an underlying mutable client reference is outside the
  atomic GiftUI publication guarantee.
- Persistent derivation failure can leave state dirty and requires paced host
  scheduling.

### Follow-up

- Specifications must define queues, phase APIs, dirty tracking, publication,
  wake requests, capacities, and profile-equivalent tests.
- The separate observable-reference-state lifecycle must conform to these
  boundaries.

## Deferred and Follow-up Work

None. Public observable-state syntax and storage remain in their separately
governed feature lifecycle rather than this ADR.

## Rejected Alternatives

### Replay failed mutation batches or frames

Rejected because client actions and side effects may be irreversible and must
not execute more than once.

### Transactional observation of arbitrary mutable references

Rejected because journaling, staging, copying, and rollback add storage and
interception costs not justified by the MVP.

### Delay semantic publication until presentation succeeds

Rejected because display backpressure would stall complete semantic state and
non-presentation observers.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
