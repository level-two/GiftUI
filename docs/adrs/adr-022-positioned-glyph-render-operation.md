---
id: ADR-022
feature: giftui-mvp-architecture
title: Positioned-Glyph Render Operation
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-003
  - RFC-004
related_adrs:
  - ADR-005
  - ADR-009
  - ADR-010
  - ADR-020
  - ADR-021
  - ADR-023
related_specs: []
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-022: Positioned-Glyph Render Operation

## Status

Proposed.

## Context

The backend-neutral render boundary must carry complete text meaning without
asking backends to interpret an authoritative raw string or repeat layout. It
also must remain streamable for the bounded one-shot frame path and avoid a
mandatory retained run.

## Decision Boundary

This record extracts RFC-003 Decision Summary item 2. It owns the canonical
text payload crossing the normalized render boundary. It inherits checked
geometry, the common one-shot stream lifetime, canonical text authority, and
exact resource identity from ADR-009, ADR-010, ADR-021, and ADR-023; it does not redefine
any of those decisions or require a retained glyph run.

## Decision

Normal GiftUI text MUST cross the backend-neutral render boundary as a
streamable positioned-glyph operation. The operation MUST carry the exact
font-instance identity, complete glyph selection, explicit logical glyph
positions, opaque paint, and resolved clipping information required by the MVP
renderer.

The operation MAY emit glyphs directly into ADR-010's ordered one-shot sink
without first materializing a complete array. A backend MUST finish consuming
the operation and its borrowed resources during the synchronous offer and MUST
NOT derive authoritative glyph selection or positions, retain the operation,
or reinterpret a raw string.

## Rationale

Positioned glyphs preserve canonical text decisions across the render boundary
while permitting exact outline and bitmap raster providers. Direct emission
fits constrained storage and keeps text as part of the common operation stream.

## Consequences

### Positive

- Backend recordings fully describe the logical text placement.
- Static producers need not retain complete glyph runs.
- Raster providers can vary without acquiring layout authority.

### Negative

- The operation vocabulary must carry more resolved data than a raw string.
- Existing backends that accept strings require migration or a temporary
  non-authoritative adapter.

### Follow-up

- Specifications must define fields, coordinate encoding, batching or
  streaming shape, workspace bounds, clipping, and malformed-resource failure.

## Deferred and Follow-up Work

None. Advanced raster delivery remains outside the canonical MVP render
boundary unless separately approved.

## Rejected Alternatives

### Raw text plus font identity

Rejected because it leaves shaping and positioning below the geometry
authority.

### Resolved glyph IDs with backend-derived positions

Rejected because it makes backends reconstruct checked logical geometry.

### Raster-ready masks or spans as the canonical boundary

Rejected because it increases temporary and transfer costs and removes the
separation between resolved text and target-selected exact rasterization.

## References

- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
