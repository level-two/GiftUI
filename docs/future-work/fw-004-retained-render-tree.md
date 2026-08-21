---
id: FW-004
feature: giftui-mvp-architecture
title: Retained Render Tree
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-21
source:
  - RFC-002
  - ADR-005
related_future_work:
  - FW-019
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-004: Retained Render Tree

## Observation / Opportunity

RFC-002 selects an ordered render-operation sink as the MVP's only canonical
render IR. A lightweight retained render tree could later provide stable
render identity, diffing, damage propagation, resource retention, or a more
natural adapter for painter-style and retained backends.

The MVP operation IR is intentionally designed so a retained representation
could be inserted as an alternative internal producer of the same ordered
operations without changing declarative, semantic-runtime, or layout
contracts.

## Why Deferred

The Signal Analyzer and current framebuffer and embedded display validation
paths do not require a second render representation. Requiring one now would
add storage, identity, diffing, copying or borrowing, capacity, and
cross-profile conformance costs before measurements show an MVP benefit.

## Potential Value

- Reduce repeated render-plan construction or improve damage propagation for
  larger or more frequently changing interfaces.
- Give a future painter-style, remote, or retained backend a stable
  intermediate representation without exposing the semantic view graph.
- Retain render resources across frames while preserving the ordered
  operation boundary used by existing backends.

## Current Non-goals

- No retained render tree, render-node identity model, diffing algorithm,
  damage-propagation model, or retained-resource cache is added to RFC-002 or
  the MVP.
- This item does not change the ordered render-operation IR selected for MVP.
- This item does not authorize a prototype, package, API, or implementation.

## Revisit Triggers

- A governed backend or feature cannot conform efficiently to the ordered
  operation sink without a retained representation.
- Measurements show that repeated operation generation, damage calculation,
  resource recreation, or display-list copying exceeds an approved frame,
  memory, or energy budget.
- An accepted Proposal requires partial render reconciliation, remote
  rendering, or retained backend resources whose identity cannot be expressed
  through the MVP producer boundary.
- A proposed change to frontend or layout contracts would foreclose inserting
  a retained producer without breaking those contracts.

## Disposition

Captured. Promote to an Exploration when one of the triggers supplies concrete
questions and competing retained representations. Use a bounded Spike only
after the Exploration identifies measurements or backend-adapter evidence that
implementation can answer.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [FW-019: Fine-Grained Observable Dependency Tracking](fw-019-fine-grained-observable-dependency-tracking.md)
