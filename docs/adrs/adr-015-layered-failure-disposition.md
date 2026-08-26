---
id: ADR-015
feature: giftui-mvp-architecture
title: Layered Failure Disposition Ownership
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-004
  - RFC-005
related_adrs:
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-014
  - ADR-016
  - ADR-017
related_specs:
  - SPEC-001
  - SPEC-003
  - SPEC-009
  - SPEC-010
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-015: Layered Failure Disposition Ownership

## Status

Accepted.

## Context

A detecting layer knows how to reject partial local work, a coordinator knows
the active cycle or frame transaction, and only target composition knows
whether an optional facility may be disabled or the product must quiesce.
Giving all decisions to any one of those owners either leaks mechanics upward
or lets local code choose whole-product policy.

## Decision Boundary

This record extracts RFC-005 Decision Summary item 2. It owns the ordered
allocation of failure-disposition authority among the detecting contract,
owning coordinator, and target composition. It inherits outcome meaning from
ADR-014 and execution effects from ADR-010 through ADR-012; it does not define
diagnostic projection or capability semantics.

## Decision

Failure disposition MUST occur in this order:

1. The detecting layer performs only contract-mandated mechanical containment
   and preserves the original outcome.
2. The owning coordinator applies every mandatory operation, publication, and
   frame-transaction effect.
3. The target composition selects only among the remaining safe, explicitly
   allowed product responses using total bounded policy.

Composition policy MUST NOT weaken containment, narrow affected scope,
override mandatory coordinator behavior, manufacture semantic support,
reinterpret failure as success, silently fall back, or retry without a bound.
If safe propagation is impossible, the detecting boundary MAY trap as required
by its contract rather than treating that action as product policy.

## Rationale

Each decision remains with the layer that has the required knowledge. Local
invariants stay deterministic, transaction semantics remain uniform across
products, and targets retain only genuine product choices.

## Consequences

### Positive

- Equivalent failures receive consistent mandatory handling across profiles.
- Product policy does not need to understand partial buffers or borrowed
  resource mechanics.
- Reusable layers do not decide whether a facility is product-critical.

### Negative

- Outcome propagation must preserve enough context for coordinator and policy
  stages.
- Specifications must clearly distinguish mandatory behavior from residual
  choices.

### Follow-up

- Specifications must define the outcome path, execution correlation, policy
  seam, and total policy tables for each supported composition.

## Deferred and Follow-up Work

None. Optional finer recovery choices remain outside MVP unless separately
approved.

## Rejected Alternatives

### One fixed architecture-wide response per outcome

Rejected because a reusable layer cannot know whether the affected facility is
required or which fatal action a target supports.

### Composition policy for every non-success outcome

Rejected because it exposes mechanical containment and transaction invariants
to product policy.

### Independent subsystem product policies

Rejected because they permit inconsistent whole-product dispositions for
equivalent conditions.

## References

- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
