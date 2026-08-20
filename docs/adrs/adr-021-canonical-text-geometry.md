---
id: ADR-021
feature: giftui-mvp-architecture
title: Canonical Text Geometry Ownership
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-003
related_adrs:
  - ADR-005
  - ADR-009
  - ADR-022
  - ADR-023
related_specs: []
related_future_work:
  - FW-001
  - FW-002
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-021: Canonical Text Geometry Ownership

## Status

Proposed.

## Context

Text affects intrinsic size, line breaking, clipping, alignment, and
downstream layout. If layout and backends use different metrics, shaping,
fallback, or rounding, the same portable Signal Analyzer hierarchy can produce
different logical geometry even when raster output is locally valid.

## Decision Boundary

This record extracts RFC-003 Decision Summary item 1. It owns canonical text
measurement, shaping, glyph selection, and logical positioning above the
render boundary. It inherits the common checked geometry from ADR-009 and does
not select the positioned-glyph payload (ADR-022) or exact resource identity
and physical ownership (ADR-023).

## Decision

GiftUI layout MUST be the sole authority for admitted text resource
resolution, shaping, line breaking, measurement, glyph selection, and logical
positioning. Given the same text, style, constraints, and exact resources, all
supported configurations MUST produce identical logical measurement, line
placement, glyph selection, and positioned geometry.

Backends and raster providers MUST NOT remeasure, reshape, substitute a font,
choose fallback, reconstruct final positions, or otherwise change logical
geometry. Raster coverage and antialiasing MAY differ when they preserve the
resolved geometry.

## Rationale

One geometry authority prevents small platform differences from changing
wrapping, clipping, stack placement, or hit geometry. It preserves one
portable layout contract while allowing capable and constrained targets to use
different exact raster realizations.

## Consequences

### Positive

- Logical text layout is deterministic across all MVP configurations.
- Backends can vary raster quality without changing application geometry.
- Geometry conformance can be tested independently from pixels.

### Negative

- Native platform text layout and ambient font fallback cannot be authoritative.
- GiftUI must provide canonical metrics and admitted shaping above the backend.

### Follow-up

- Specifications must define the reference resources, admitted corpus,
  shaping, line breaking, numeric encoding, failure behavior, and golden
  geometry fixtures.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves complex-script, bidirectional, vertical, variable-font, and rich
  text expansion.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  preserves selection, editing, caret, and accessibility geometry.

## Rejected Alternatives

### Backend-owned text layout or logical tolerance

Rejected because platform metrics and even small tolerated differences can
change wrapping, clipping, and surrounding layout.

### Backend-derived glyph positions

Rejected because it duplicates checked positioning arithmetic below the sole
geometry authority.

## References

- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
