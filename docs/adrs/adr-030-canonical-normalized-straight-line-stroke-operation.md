---
id: ADR-030
feature: canvas-drawing
title: Canonical Normalized Straight-Line Stroke Operation
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-25
updated: 2026-08-27
proposal:
  - PROPOSAL-006
related_rfcs:
  - RFC-009
related_adrs:
  - ADR-005
  - ADR-009
  - ADR-010
  - ADR-020
  - ADR-022
  - ADR-028
  - ADR-029
  - ADR-031
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-004
  - SPEC-006
  - SPEC-012
  - SPEC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-030: Canonical Normalized Straight-Line Stroke Operation

## Status

Accepted.

## Context

GiftUI's backend-neutral render boundary must carry enough resolved information
to draw the Signal Analyzer grid and traces consistently without giving a
backend the client closure, mutable Path, semantic view, or application data.
Independent segment records would lose subpath joins and endpoint meaning,
while Core rasterization would make the portable layer own pixel-format and
tiling decisions.

RFC-009 approved one canonical logical straight-line-stroke meaning carried in
the normalized ordered operation stream and consumed through ADR-010's
synchronous borrowed lifetime.

## Decision Boundary

This record extracts RFC-009 Decision Summary item 3. It owns the complete
logical stroke meaning at the normalized render boundary, Canvas-local
coordinate resolution, Canvas-edge clipping behavior, and backend consumption
lifetime. It does not own Canvas closure or plan lifetime (ADR-028), mutable
Path construction (ADR-029), or startup and failure sequencing (ADR-031).

## Decision

GiftUI MUST lower every admitted Canvas stroke to one normalized
straight-line-stroke operation, or an equivalent bounded operation sequence
whose grouping preserves the same canonical cap and join semantics. The
normalized payload MUST carry or synchronously expose:

- every checked-integer point in order and every explicit subpath boundary;
- opaque RGB paint;
- positive checked-integer line width;
- canonical segment cap and join values including `round`;
- the resolved surface origin for the Canvas-local coordinate space;
- the resolved inherited clip.

GiftUI MUST resolve Canvas-local coordinates, checked translation, drawing
order, paint, style, and inherited clip before the operation reaches a concrete
backend. Canvas bounds MUST NOT contribute an implicit clip; geometry outside
those bounds remains visible unless an inherited ancestor clip excludes it.
The operation's position in the ordered stream MUST preserve painter's order.
Splitting a path into independent segment operations MUST NOT change join,
endpoint, or subpath meaning, and a backend MUST NOT infer subpath boundaries
from duplicate points.

The backend MUST consume the complete immutable borrowed payload during
ADR-010's synchronous frame offer and MUST NOT retain the operation, its Path
snapshot, or any borrowed Core storage after the call returns. It MAY retain
only backend-owned derived pixels, spans, tiles, or transfer data after
acceptance. Concrete raster algorithms and storage MAY differ but MUST preserve
the accepted logical geometry, style, order, clip, and opaque color.

## Rationale

A complete logical stroke record preserves one semantic authority above the
backend boundary while allowing full-surface and bounded tiled rasterizers to
choose target-appropriate algorithms. Borrowed synchronous payloads avoid a
mandatory retained maximum-sized array in every operation and remain
compatible with the common one-shot frame contract.

## Consequences

### Positive

- Recording backends can compare exact normalized stroke meaning across
  profiles before rasterization.
- Backends remain independent of client Canvas, Path, layout, and application
  state.
- Full-surface and tiled targets may use different raster implementations.
- Drawing beyond Canvas edges has one explicit cross-backend meaning.

### Negative

- The operation vocabulary must preserve complete subpath and style data.
- Backends without native round caps or joins must implement them in software
  or fail startup conformance.
- Pixel quantization and degenerate geometry require exact Specification
  vectors even though they do not change the architectural boundary.

### Follow-up

- The drawing Specification must define operation fields, batching or borrowed
  views, default styles, degenerate geometry, quantization, clipping vectors,
  and pixel tolerances.
- Backend conformance must prove synchronous consumption and absence of
  retained borrowed addresses.

## Deferred and Follow-up Work

None. Fills, curves, images, text in Canvas, public clipping, transforms,
alpha, and effects remain outside the accepted Proposal.

## Rejected Alternatives

### Give the backend the Canvas closure or mutable Path

Rejected because it transfers semantic execution, lifetime, and checked
geometry authority below the normalized render boundary.

### Emit every segment as an independent operation

Rejected when segmentation changes cap, join, endpoint, or subpath semantics.

### Rasterize or tessellate strokes in Core

Rejected because it moves pixel quantization, raster format, tiling, and
workspace policy above the backend boundary.

### Add an implicit Canvas-bounds clip

Rejected because RFC-009 approved inherited clipping without making Canvas
bounds an additional clip source.

## References

- [RFC-009: Canvas, Path, and Stroke Drawing Architecture](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [PROPOSAL-006: Canvas, Path, and Stroke Drawing](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [ADR-005: Semantic, Layout, and Render Boundary](adr-005-semantic-layout-render-boundary.md)
- [ADR-010: Synchronous One-Shot Frame Handoff](adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-020: Composite Raster Presentation Capability](adr-020-raster-presentation-capability.md)
- [SPIKE-004: Canvas Path Plan Feasibility](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
