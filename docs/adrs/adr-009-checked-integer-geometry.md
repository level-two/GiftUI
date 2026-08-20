---
id: ADR-009
feature: giftui-mvp-architecture
title: Checked Integer Geometry for MVP
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
related_adrs:
  - ADR-005
  - ADR-020
  - ADR-021
  - ADR-022
related_specs: []
related_future_work:
  - FW-005
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-009: Checked Integer Geometry for MVP

## Status

Proposed.

## Context

The Signal Analyzer needs stacks, frames, padding, text placement, and simple
Canvas line geometry across desktop, framebuffer, and constrained embedded
targets. A general constraint solver or multiple scalar models would add
algorithmic, storage, code-size, and conformance costs not required by that
fixed presentation.

## Decision Boundary

This record extracts RFC-002 Decision Summary item 8. It owns the common MVP
geometry scalar and the rejection of a general constraint solver as a core
layout dependency. It does not authorize or define the separately governed
public Canvas/Path API, nor does it select concrete widths, rounding, overflow
APIs, or workspace capacities.

## Decision

MVP layout and Canvas geometry MUST use checked integer coordinates,
dimensions, and scalar arithmetic. Layout MUST use the proposal/measurement
model required by the Signal Analyzer and MUST NOT depend on a general-purpose
constraint solver.

Overflow, invalid dimensions, and capacity exhaustion MUST be explicit and
deterministic rather than silently wrapping or producing partial geometry.

## Rationale

Checked integers provide one deterministic geometry model that is inexpensive
on constrained targets and sufficient for the MVP presentation. Proposal-based
layout matches the selected declarative model without introducing a solver
whose capabilities and costs are unused.

## Consequences

### Positive

- Geometry is deterministic and portable across the MVP profiles.
- Static storage, arithmetic, and failure bounds remain explicit.
- The common layout engine avoids a general solver dependency.

### Negative

- Fractional geometry and subpixel logical placement are unavailable in MVP.
- Specifications and tests must define checked arithmetic and failure at every
  boundary.

### Follow-up

- Layout Specifications, and any Canvas Specification that later passes its
  separate lifecycle gates, must define scalar widths, ranges, rounding,
  overflow, and invalid-geometry behavior.

## Deferred and Follow-up Work

- [FW-005](../future-work/fw-005-alternative-geometry-scalars.md) preserves
  fractional, floating-point, or fixed-point representations for a future
  demonstrated need.

## Rejected Alternatives

### General constraint solver as the core layout model

Rejected because its memory, algorithmic, and code-size costs are not
justified by the Signal Analyzer hierarchy.

### Multiple geometry scalar models in MVP

Rejected because they would complicate cross-profile conformance without a
current required behavior.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
