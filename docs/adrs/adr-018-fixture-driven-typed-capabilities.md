---
id: ADR-018
feature: capability-system
title: Fixture-Driven Typed Capability Model
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-006
related_adrs:
  - ADR-017
  - ADR-019
  - ADR-020
related_specs: []
related_future_work:
  - FW-007
  - FW-008
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-018: Fixture-Driven Typed Capability Model

## Status

Proposed.

## Context

GiftUI needs capabilities only where differences among the four MVP stacks
affect a semantic promise or a quantitative conformance bound. Platform checks,
backend Boolean bags, or a speculative registry would either lose important
constraints or introduce unused dynamic machinery.

## Decision Boundary

This record extracts RFC-006 Decision Summary item 2. It owns the admission
rule and semantic shape of MVP capability families: fixture justification,
typed domain-specific values, quantitative constraints, owned contributions,
and explicit absence behavior. It does not select the host resolution
mechanism (ADR-019) or the concrete MVP family and its fields (ADR-020).

## Decision

Every MVP capability family and field MUST be justified by a Signal Analyzer
or supported-configuration fixture. Each admitted family MUST use typed,
domain-specific requirements, component-owned contributions, effective
results, constraints, and explicit required/optional absence behavior.

Capability support MUST describe semantic behavior rather than target,
backend, board, driver, or device identity. Availability MUST retain any
dimension, format, capacity, lifetime, alignment, or other quantitative bound
that determines conformance. Policy MAY select only among conforming
realizations and MUST NOT manufacture support or weaken semantics.

The MVP MUST NOT require one universal lattice, an open heterogeneous
registry, or a speculative catalogue.

## Rationale

Fixture-first admission keeps the model proportional to MVP needs while typed
families preserve the exact constraints their consumers use. Owned
contributions respect the module graph and prevent any one component from
claiming end-to-end support it cannot establish.

## Consequences

### Positive

- Every implemented capability remains traceable to a concrete need.
- Missing and constrained behavior is explicit and deterministically testable.
- Portable code avoids target and implementation identity checks.

### Negative

- New families require evidence and lifecycle work rather than ad hoc flags.
- Different domains may need different value and resolution shapes.

### Follow-up

- Specifications must define the admitted typed vocabulary, stable absence
  reasons, contribution rules, and fixture coverage.

## Deferred and Follow-up Work

- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) preserves
  a general measured realization planner.
- [FW-008](../future-work/fw-008-generalized-component-traits.md) preserves a
  generalized Trait system beyond the demonstrated MVP catalogue.

## Rejected Alternatives

### Build flags or target identity as the capability model

Rejected because they cannot express initialization-time or cross-component
constraints and leak concrete identity into consumers.

### Backend Boolean bag

Rejected because no backend owns the complete presentation path and Booleans
discard quantitative compatibility.

### String-keyed runtime registry

Rejected because allocation, casting, discovery, ordering, and unbounded
storage are unnecessary for closed MVP stacks.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
