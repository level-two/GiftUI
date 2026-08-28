---
id: PROPOSAL-005
feature: observable-reference-state
title: Observable Reference State
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-27
proposal: []
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-004
  - RFC-008
related_adrs:
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-027
related_specs:
  - SPEC-001
  - SPEC-010
  - SPEC-013
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# PROPOSAL-005: Observable Reference State

## Summary

GiftUI should provide observable reference-state behavior that lets one
portable declarative presentation preserve a reference-model instance and
update dependent view descriptions when that model changes. The feature must
support the Signal Analyzer across dynamic desktop and Linux environments and
the bounded static embedded configuration without creating separate client
semantics.

## Problem

The Signal Analyzer receives changing capture data, acquisition status,
errors, and visible-window selection through a presentation model. GiftUI's
MVP scope requires those changes to invalidate and update the affected
presentation while preserving the model across transient view-value
evaluation.

The integrating architecture currently assigns semantic state, identity,
invalidation, and action ordering above the backend boundary, but it does not
establish the public observable-state contract or the feature-specific
behavior needed by downstream Specifications. If implementation proceeds
without that lifecycle, static and dynamic runtimes could make incompatible
choices about preservation, invalidation, observation, storage, or failure,
and Specifications would have to invent architecture.

## Motivation

Observable reference state is required now by the Signal Analyzer's Rank 2
client surface. Start, Stop, Clear, acquisition status, errors, capture data,
and visible-window controls must reflect changes in the presentation model on
all four MVP configurations.

The feature is also a required integration point between client declarations,
semantic runtime execution, action dispatch, run-cycle publication, and
bounded embedded storage. Establishing its architecture before those seams
are frozen prevents desktop-only observation assumptions or proof-of-concept
details from becoming implicit framework authority.

## Users / Use Cases

- Application developers need a familiar way to keep one reference model
  alive while declarative view values are recreated.
- Signal Analyzer Presentation needs capture, acquisition, error, and visible-
  window changes to update dependent content and control state.
- Runtime implementers need equivalent observable behavior across dynamic and
  static profiles.
- Embedded integrators need finite storage obligations, deterministic
  exhaustion behavior, and no dependency on unavailable runtime facilities.
- Test authors need deterministic evidence that mutations, invalidation, and
  state lifetime behave consistently across supported profiles.

## Goals

- Establish the observable reference-state behavior required by the portable
  Signal Analyzer presentation.
- Preserve one portable client concept across dynamic and static runtimes.
- Define reviewable expectations for model preservation, removal,
  invalidation, mutation admission, and update publication.
- Make ownership, lifetime, synchronization, resource costs, and failure
  behavior explicit enough for downstream contracts.
- Support bounded, deterministic realization on the nRF52840 static profile.
- Fit the layered architecture and run-cycle boundaries without exposing
  backend, platform, scheduler, or hardware identity to portable views.

## Non-goals

- Reproduce Apple's Observation framework or guarantee source compatibility
  with SwiftUI property wrappers.
- Provide general reactive streams, arbitrary dependency graphs, persistence,
  undo, distributed state, concurrency actors, or background synchronization.
- Define application-domain capture storage or signal acquisition behavior.
- Select concrete APIs, property wrappers, storage layouts, identity
  algorithms, invalidation algorithms, or module placement in this Proposal.
- Add animation, fine-grained partial rendering, or a retained view lifecycle
  unless separately justified.
- Authorize implementation or migration of proof-of-concept state code.

## Constraints

- The feature MUST satisfy the observable updates used by the Signal Analyzer
  and MUST NOT expand the MVP client surface without another concrete need.
- Portable behavior MUST remain equivalent across macOS dynamic, macOS
  static, Raspberry Pi/Linux dynamic, and nRF52840 static configurations.
- The embedded path MUST NOT assume heap allocation, reflection, unrestricted
  existential use, Objective-C runtime facilities, or unbounded storage.
- State mutation and invalidation MUST fit the serialized semantic execution
  and publication boundaries governed by the accepted architecture that
  emerges from RFC-002 and RFC-004.
- Backends, platforms, drivers, diagnostics, and hardware integrations MUST
  NOT acquire authority to mutate application state or dispatch client
  handlers.
- Memory, stack, binary-size, execution, and invalidation costs MUST be
  evaluated for constrained targets.
- Existing code and legacy documents MAY provide evidence but MUST NOT select
  the maintained architecture.
- Acceptance of this Proposal authorizes RFC work only. Major implementation
  still requires accepted ADRs and approved Specifications.

## Evidence and Assumptions

Observed evidence includes the established Signal Analyzer state surface,
the approved application contract's dependency on a separately governed
GiftUI observation feature, and the integrating RFCs' proposed semantic and
run-cycle seams. The proof of concept may supply feasibility evidence for
multiple runtime profiles but is not authoritative.

This Proposal assumes that the MVP needs observable changes to a preserved
reference model, not a general-purpose reactive programming system. RFC work
must test that boundary and compare viable dynamic and bounded static
realizations.

## Success Criteria

- The portable Signal Analyzer can preserve its presentation model across
  transient view evaluation and update all state-derived text, controls, and
  waveform inputs after admitted model changes.
- Start, Stop, Clear, error, capture, and visible-window mutations produce
  deterministic invalidation and published presentation revisions.
- Removing or replacing structurally identified presentation content has
  defined, testable state-lifetime behavior.
- Dynamic and static profiles pass shared semantic tests for preservation,
  mutation ordering, invalidation, removal, and re-evaluation.
- Static validation demonstrates finite state and observation storage with
  deterministic capacity-exhaustion behavior.
- External acquisition facts enter presentation state only through an
  explicit, testable application/runtime boundary and cannot mutate semantic
  state concurrently with a sealed update cycle.
- Downstream Specifications can define exact public and runtime contracts
  without choosing new ownership, identity, lifetime, synchronization,
  invalidation, resource, or failure architecture.

## Scope

The feature covers the public observable reference-state concept and the
framework behavior required to preserve a model, admit mutations, determine
affected presentation work, publish updates, remove state when its structural
lifetime ends, and realize equivalent behavior in dynamic and bounded static
profiles.

It includes the relationships with declarative view evaluation, semantic
identity, action dispatch, run-cycle execution, external Signal Analyzer
facts, diagnostics, and capacity failure. Exact declarations,
representations, algorithms, numeric capacities, and module assignments
belong to downstream RFCs, ADRs, and Specifications.

## Risks

- A design modeled too closely on desktop observation facilities may be
  unavailable or too expensive for Embedded Swift.
- Coarse invalidation may be simple and bounded but create unnecessary work;
  fine-grained dependency tracking may consume excessive memory and code size.
- Ambiguous structural identity or removal rules could preserve stale models
  or unexpectedly discard live application state.
- Unclear external-fact admission could allow mutation during derivation and
  break deterministic revision publication.
- Overlapping authority with RFC-002 or RFC-004 could create conflicting
  sources of truth unless the focused RFC states which constraints it inherits.

## Open Questions

- Which observable behaviors are essential for the fixed Signal Analyzer
  hierarchy, and which familiar conveniences can remain outside MVP?
- What evidence is needed to compare candidate dynamic and bounded static
  realizations fairly?

## Deferred and Follow-up Work

None. General reactive programming, persistence, distributed state, animation,
and retained lifecycle facilities are outside this Proposal and currently
lack a concrete MVP requirement.

## References

- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](proposal-002-signal-analyzer-reference-application.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [SPEC-001: Signal Analyzer Reference Application](../specs/spec-001-signal-analyzer-reference-application.md)
