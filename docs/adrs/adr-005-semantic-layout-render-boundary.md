---
id: ADR-005
feature: giftui-mvp-architecture
title: Semantic, Layout, and Render Boundary
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-25
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
related_adrs:
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-013
  - ADR-020
  - ADR-021
  - ADR-022
  - ADR-023
related_specs:
  - SPEC-002
  - SPEC-005
  - SPEC-006
related_future_work:
  - FW-004
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-005: Semantic, Layout, and Render Boundary

## Status

Accepted.

## Context

The Signal Analyzer must use one portable declarative presentation across
dynamic desktop, static macOS, Raspberry Pi/Linux, and nRF52840 stacks. If a
backend consumes the semantic graph, it acquires knowledge of view expansion,
identity, state, containers, and layout and must reproduce those semantics for
each target.

## Decision Boundary

This record extracts RFC-002 Decision Summary items 1 and the render-boundary
portion of item 3. It owns semantic/layout authority, the normalized operation
boundary, and compatibility with a possible future retained producer. It does
not own operation-stream lifetime or frame disposition (ADR-010), concrete
text payloads (ADR-022), or font-resource identity (ADR-023).

## Decision

GiftUI MUST own declarative semantic expansion, identity, state, interaction,
and proposal-based layout above a backend-neutral render boundary. Resolved UI
MUST lower to one normalized ordered render-operation vocabulary. Backends
MUST consume that vocabulary and MUST NOT evaluate `View.body`, interpret
containers, perform GiftUI layout, own semantic state, or invoke client
actions.

The render boundary MUST remain streamable and MUST permit a future retained
producer without changing frontend or layout contracts.

## Rationale

One semantic and layout authority preserves portable behavior while allowing
different raster and presentation realizations. A normalized operation
boundary is independently testable and supports direct bounded emission on the
static path without making a retained render tree mandatory.

## Consequences

### Positive

- Semantic, layout, and render-operation conformance can be tested without a
  concrete backend.
- Backends remain replaceable and do not duplicate GiftUI semantics.
- Static producers may emit directly into a bounded sink.

### Negative

- GiftUI must define and maintain a normalized operation vocabulary and
  lowering boundary.
- Native backends cannot reinterpret GiftUI layout through native widget
  semantics.

### Follow-up

- Specifications must define the operation contracts, bounds, failure
  behavior, and import restrictions.
- Proof-of-concept code must migrate toward this boundary rather than define
  it.

## Deferred and Follow-up Work

- [FW-004](../future-work/fw-004-retained-render-tree.md) preserves a future
  retained producer if concrete evidence justifies its storage and identity
  costs.

## Rejected Alternatives

### Backends consume or directly traverse the semantic graph

Rejected because it duplicates semantic interpretation, exposes profile-
specific graph representation, and weakens cross-backend conformance.

### Mandatory retained render tree and display list

Rejected for MVP because it adds two intermediate representations and two
bounded-storage obligations when the required paths can consume streamed
operations.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
