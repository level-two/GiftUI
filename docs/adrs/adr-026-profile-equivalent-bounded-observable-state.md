---
id: ADR-026
feature: observable-reference-state
title: Profile-Equivalent Bounded Observable State Realization
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-27
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-002
  - RFC-005
  - RFC-008
  - RFC-011
related_adrs:
  - ADR-006
  - ADR-008
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-025
  - ADR-027
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-010
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-003
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-026: Profile-Equivalent Bounded Observable State Realization

## Status

Accepted.

## Context

GiftUI must preserve one observable-reference-state behavior across dynamic
desktop/Linux and static Embedded Swift configurations. A dynamic class and
observer implementation is feasible on hosts but cannot be the common
dependency. SPIKE-003 established that an address-stable generated typed
handle with explicit generated setters can preserve the portable `@State`
source shape and synchronous signaling without an allocator entry point.

## Decision Boundary

This record extracts RFC-008 Decision Summary item 3. It owns cross-profile
equivalence, physical contract placement, bounded static representation, and
state/registration failure obligations. It does not select exact declarations,
generation mechanics, capacities, or layouts.

## Decision

Dynamic and static profiles MUST expose the same portable observable model and
`@State` source-level concept and MUST preserve the ownership, identity,
initializer, replacement, removal, change, coalescing, and publication
semantics established by ADR-024 and ADR-025.

The portable client contract MUST reside in the `GiftUI` import surface.
Runtime storage, registration, generated descriptors, and host composition
MUST remain below that surface and preserve the accepted acyclic module
direction. Portable Presentation MUST NOT import a runtime, backend, platform,
scheduler, Apple Observation, or hardware module.

The static realization MUST use generated, fixed, or caller-supplied typed
state locations and bounded registration and bookkeeping storage. It MAY use
address-stable generated models or typed handles, direct field access, numeric
slot identities, inline arrays, bit sets, and specialized calls. Copying a
handle MUST preserve one underlying model identity rather than copy or fork
model state.

The static path MUST NOT depend on heap allocation, reflection, `Any`, string
structural paths, arbitrary existential registries, task-local binding,
Objective-C runtime facilities, Apple Observation, tasks, threads,
exceptions, or unbounded observer collections. State locations,
registrations, live/staged/dirty sets, stale-registration protection, and any
replacement staging MUST each have finite declared bounds.

State-location exhaustion, registration exhaustion, duplicate ownership,
incompatible association, stale reports, and detected phase violations MUST
produce deterministic bounded outcomes conforming to ADR-014 and ADR-015.
No profile MAY silently fall back to local wrapper state, heap allocation,
untracked observation, or dropped required registration.

A dynamic profile MAY use retained classes, heap-backed lookup and tokens, or
runtime-local binding context internally, but MUST enforce the common
cardinality, failure, and publication behavior and MUST NOT retain an
unbounded invalidation history.

## Rationale

Separating shared semantics from profile mechanisms preserves one portable
application while allowing each environment to use appropriate storage. The
bounded typed family is the demonstrated zero-heap route for Embedded Swift,
and explicit outcomes prevent the dynamic profile's greater resources from
creating a different semantic contract.

## Consequences

### Positive

- The same portable Signal Analyzer presentation can compile for all MVP
  configurations.
- Embedded memory and failure obligations are finite and reviewable.
- Dynamic conveniences remain implementation details rather than portable
  dependencies.

### Negative

- Static targets require generation or caller-supplied typed configuration.
- Every finite capacity and stale-token strategy must be specified and tested.
- Rich dynamic observation behavior cannot become client-visible unless a
  later accepted feature generalizes the common contract.

### Follow-up

- A Specification must select exact declarations, generation mechanics,
  storage layout, identities, capacities, replacement staging, and outcomes.
- The assembled Signal Analyzer must remeasure RAM, flash, stack, and timing
  and verify the embedded image has no forbidden runtime dependencies.
- Shared semantic fixtures must run against both dynamic and static hosts.

## Deferred and Follow-up Work

None. SPIKE-003 is supporting evidence, not a production implementation or a
deferred architectural decision.

## Rejected Alternatives

### Different public APIs by runtime profile

Rejected because it would fork the portable presentation and violate shared
runtime-profile semantics.

### Escaping Swift class identity as the static requirement

Rejected because the representative Embedded Swift fixture retained an
unavailable allocation path.

### Unbounded dynamic fallback on static exhaustion

Rejected because it makes capacity behavior profile-dependent and violates
the bounded failure architecture.

### The SPIKE-003 declarations as a production contract

Rejected because the Spike proved a feasible family but did not review exact
API spelling, generation layout, capacities, or assembled application costs.

## References

- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [SPIKE-003: Portable Observable Reference State Feasibility](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](adr-006-shared-semantics-runtime-profiles.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
