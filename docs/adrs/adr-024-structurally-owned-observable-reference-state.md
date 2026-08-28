---
id: ADR-024
feature: observable-reference-state
title: Structurally Owned Observable Reference State
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-27
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-008
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-025
  - ADR-026
  - ADR-027
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-010
  - SPEC-011
  - SPEC-013
related_future_work:
  - FW-017
related_explorations: []
related_spikes:
  - SPIKE-003
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-024: Structurally Owned Observable Reference State

## Status

Accepted.

## Context

The Signal Analyzer needs one identity-bearing presentation model to survive
transient declarative view reconstruction while remaining removable and
replaceable under deterministic semantic-runtime rules. Wrapper-instance
ownership would lose state during reevaluation, while externally owned or
multi-observer lifetimes would introduce behavior outside the fixed MVP
hierarchy.

## Decision Boundary

This record extracts RFC-008 Decision Summary item 1. It owns observable state
location identity, preservation, initialization, replacement, removal, and
registration cardinality. It does not define change-report processing
(ADR-025), profile representation (ADR-026), or external-fact admission
(ADR-027).

## Decision

One observable `@State` declaration MUST correspond to one runtime-owned state
location identified by semantic structural identity plus declaration-local
state identity. The first successful materialization MUST install and preserve
one identity-bearing model and one invalidation registration for that live
location. Repeated transient initializers at the same live location MUST
observe the preserved model and MUST NOT replace it.

An admitted assignment MAY replace the model only as one atomic state
operation: it MUST install the candidate with an active registration and then
retire the old registration, or leave the existing model and registration
unchanged. A successful replacement remains applied if later derivation
fails, and the location remains dirty for rederivation without replay.

A location absent from a complete candidate hierarchy MUST be retired only
when that semantic revision publishes. Failed derivation MUST preserve the
previous published live set. Reinsertion after published removal MUST create
fresh state rather than resurrecting the retired association.

Within one assembled MVP runtime, one observable model MAY have only one
owning state location and one runtime registration. Descendants MAY borrow the
model during evaluation without adding registrations. Duplicate ownership and
incompatible association MUST return deterministic bounded outcomes.

Application observation startup and shutdown MUST remain explicit host or
application responsibilities; state access, body evaluation, and structural
removal MUST NOT synthesize those external lifecycle effects.

## Rationale

Structural ownership preserves familiar declarative state behavior without a
retained view lifecycle. Publication-committed removal prevents an abandoned
candidate hierarchy from destroying live state. Atomic replacement prevents
ordinary capacity or attachment failures from leaving a location vacant or
unobservable, and one-owner cardinality supplies the smallest complete
contract required by the Signal Analyzer.

## Consequences

### Positive

- Model identity is stable across reevaluation and equivalent across profiles.
- Removal and replacement have explicit failure and publication semantics.
- The MVP avoids general observer-list and retained-lifecycle machinery.

### Negative

- Initializers at an already-live location do not update its model.
- Replacement requires bounded preflight or staging before the old
  registration can be retired.
- One model cannot be installed as two independent owning locations.
- Structural removal does not imply destruction while other application
  owners remain.

### Follow-up

- A Specification must define state identity encoding, initializer and
  assignment APIs, replacement staging, type/layout validation, and removal
  reconciliation.
- Shared fixtures must cover preservation, replacement failures, failed
  derivation, published removal, reinsertion, and duplicate ownership.

## Deferred and Follow-up Work

- [FW-017](../future-work/fw-017-public-binding-abstraction.md) preserves
  externally owned observation, public projection, and binding-dependent
  controls. Those facilities are not required to apply this decision.

## Rejected Alternatives

### Wrapper-instance ownership

Rejected because transient declarative wrappers are recreated and cannot own
the required structural lifetime.

### Runtime-external ownership as the MVP state contract

Rejected because it introduces borrowed observation, potentially multiple
subscribers, and teardown rules not required by the Signal Analyzer.

### General multi-observer registration

Rejected because subscriber identity, ordering, capacity, and partial removal
add costs without an MVP use case.

### Application lifecycle callbacks from state materialization

Rejected because candidate evaluation may repeat or fail before publication,
making external side effects dependent on an uncommitted hierarchy.

## References

- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [SPIKE-003: Portable Observable Reference State Feasibility](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
