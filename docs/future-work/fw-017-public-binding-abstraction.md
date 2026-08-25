---
id: FW-017
feature: giftui-mvp-architecture
title: Public Binding Abstraction
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-25
source:
  - RFC-002
  - RFC-008
  - SPEC-006
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-017: Public Binding Abstraction

## Observation / Opportunity

Future GiftUI controls and reusable view APIs may need a public two-way
`Binding` abstraction that projects readable and writable state without
exposing runtime-owned storage. Such an abstraction would need explicit
ownership, lifetime, mutation, invalidation, identity, and static-profile
semantics.

## Why Deferred

The Signal Analyzer MVP uses observable reference state for publication and
actions for mutation. It does not require a public two-way binding or a
binding-dependent control such as `Toggle` or `Slider`. Defining `Binding` now
would add public API and runtime lifetime decisions without an MVP use case.

## Potential Value

- Support reusable controls and view APIs that can read and mutate projected
  state through one portable value.
- Preserve familiar SwiftUI-inspired composition when a concrete post-MVP
  feature demonstrates a need for two-way state projection.
- Establish safe dynamic and bounded static realizations without exposing
  runtime state slots.

## Current Non-goals

- No public `Binding` type, property wrapper projection, dynamic-member lookup,
  collection projection, or binding-dependent control is added to MVP.
- RFC-002 does not select binding ownership, lifetime, invalidation, mutation,
  identity, or concurrency semantics.
- This item does not change the separately governed MVP observable
  reference-state requirement.

## Revisit Triggers

- An accepted Proposal for a control or reusable view API requires portable
  two-way state projection.
- An accepted observable-state design identifies a concrete public projection
  requirement that cannot be satisfied by MVP reference-state publication and
  action dispatch.
- Dynamic and static profile evidence demonstrates a bounded binding lifetime
  model worth evaluating through the normal architecture lifecycle.

## Disposition

Captured for post-MVP consideration. Promote through a Proposal when GiftUI is
ready to evaluate a concrete binding-dependent feature need; any public API or
runtime architecture must then pass the normal RFC, ADR, and Specification
gates.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Milestones](../roadmap/MVP_MILESTONES.md)
