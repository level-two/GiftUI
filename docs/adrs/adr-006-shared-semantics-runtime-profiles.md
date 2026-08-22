---
id: ADR-006
feature: giftui-mvp-architecture
title: Shared Semantics Across Runtime Profiles
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-22
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
related_adrs:
  - ADR-005
  - ADR-011
  - ADR-017
  - ADR-019
related_specs:
  - SPEC-002
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-006: Shared Semantics Across Runtime Profiles

## Status

Accepted.

## Context

GiftUI must run the same portable Signal Analyzer presentation in dynamic and
static configurations. Dynamic storage and dispatch conveniences do not fit
every constrained target, but separate semantic frameworks would undermine
the MVP portability claim and allow behavioral drift.

## Decision Boundary

This record extracts RFC-002 Decision Summary item 2. It owns the requirement
for profile-equivalent observable semantics while allowing different storage,
composition, and dispatch strategies. It does not select capability
representation or resolution (ADR-017 through ADR-020), nor does it define
the exact storage and capacity contracts left to Specifications.

## Decision

Static and dynamic runtimes MUST be alternative storage, composition, and
dispatch strategies beneath one portable declarative semantic model. Profile
selection MAY change representation, specialization, allocation strategy, and
render-plan materialization, but MUST preserve observable semantics including
identity, state lifetime, action ordering, layout, operation order, failures,
and publication boundaries.

## Rationale

The distinction that matters to portable clients is semantic behavior, not
the runtime's storage technique. Keeping profile variation below one contract
allows constrained implementations to use generated and bounded mechanisms
without creating a second application model.

## Consequences

### Positive

- One portable presentation and shared conformance suite cover all MVP
  configurations.
- Static implementations may specialize aggressively without changing client
  semantics.

### Negative

- Both profiles must satisfy the stricter common behavior and deterministic
  failure rules.
- Dynamic conveniences must remain optional and cannot become semantic
  requirements.

### Follow-up

- Specifications must define profile-neutral behavior and profile-specific
  storage bounds.
- Conformance tests must compare equivalent static and dynamic results.

## Deferred and Follow-up Work

None. Alternative storage techniques remain allowed when they preserve this
decision.

## Rejected Alternatives

### Separate static and dynamic UI architectures

Rejected because it duplicates contracts and tests, invites semantic drift,
and would require separate portable application hierarchies.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
