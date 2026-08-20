---
id: PROPOSAL-006
feature: canvas-drawing
title: Canvas, Path, and Stroke Drawing
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal: []
related_rfcs:
  - RFC-001
  - RFC-002
related_adrs: []
related_specs:
  - SPEC-001
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# PROPOSAL-006: Canvas, Path, and Stroke Drawing

## Summary

GiftUI should provide a minimal portable custom-drawing surface for the Signal
Analyzer's time grid and four digital traces. The feature should let portable
presentation code describe straight-line paths and solid opaque strokes while
remaining backend-independent and viable in dynamic and bounded static
configurations.

## Problem

The Signal Analyzer cannot satisfy the MVP outcome using only text, controls,
and rectangular backgrounds. It must visualize data-driven waveform geometry,
but GiftUI does not yet have an approved architecture or public contract for
Canvas execution, path construction, or line stroking.

RFC-002 proposes where resolved drawing intent belongs in the layered render
pipeline, but it intentionally does not establish the public drawing feature.
Without a focused lifecycle, client closure behavior, path and resource
lifetime, stroke semantics, geometry bounds, static workspace obligations,
and feature-specific failure behavior could be chosen accidentally in a
Specification, backend, or proof-of-concept implementation.

## Motivation

Canvas, Path, and Stroke are explicit full-MVP requirements. The portable
Signal Analyzer must draw a time grid and four data-driven digital traces on
macOS dynamic, macOS static, Raspberry Pi/Linux dynamic, and nRF52840 static
configurations.

Establishing this feature now allows render-core, backend, raster, and static
workspace contracts to evolve against a reviewed client drawing boundary.
The deliberately narrow waveform requirement provides a concrete way to
validate custom drawing without committing GiftUI to a general-purpose
graphics framework.

## Users / Use Cases

- Signal Analyzer Presentation needs to construct a time grid and four
  straight-line digital traces from current capture data and resolved size.
- Application developers need backend-independent drawing concepts that fit
  the same portable hierarchy as standard GiftUI views.
- Backend and raster implementers need deterministic resolved drawing intent
  without receiving semantic view or application-state objects.
- Embedded integrators need bounded path, operation, and raster workspace
  obligations with deterministic failure behavior.
- Test authors need shared semantic fixtures that distinguish portable drawing
  behavior from backend-specific pixel realization.

## Goals

- Establish the minimal custom-drawing behavior required by the Signal
  Analyzer's time grid and digital traces.
- Preserve one portable Canvas/path/stroke concept across dynamic and static
  profiles and all MVP backends.
- Define reviewable execution, ownership, lifetime, bounds, stroke, resource,
  and failure expectations for downstream contracts.
- Keep public drawing independent of renderer, surface, platform, display
  controller, transport, and hardware identity.
- Support bounded deterministic realization on the nRF52840 static profile.
- Integrate with RFC-002's backend-neutral ordered render boundary without
  expanding the public surface into a general graphics framework.

## Non-goals

- Provide arbitrary fills, curves, images, text drawing inside Canvas,
  transforms, gradients, alpha compositing, shadows, filters, blend modes, or
  advanced path operations.
- Add public Canvas clipping unless a later concrete requirement establishes
  it; backend clip or damage handling remains a separate render concern.
- Guarantee SwiftUI source compatibility or reproduce its complete Canvas,
  GraphicsContext, Path, ShapeStyle, or StrokeStyle APIs.
- Select concrete Swift declarations, path representation, operation encoding,
  raster algorithm, workspace layout, or capacity values in this Proposal.
- Define retained rendering, replayable display lists, animation, or
  asynchronous drawing execution.
- Authorize implementation or migration of proof-of-concept drawing code.

## Constraints

- MVP drawing work MUST remain limited to the time grid and four digital
  traces required by the Signal Analyzer.
- Portable drawing behavior MUST remain equivalent across macOS dynamic,
  macOS static, Raspberry Pi/Linux dynamic, and nRF52840 static configurations.
- Public drawing concepts MUST NOT expose concrete backend, surface, platform,
  driver, transport, operating-system, RTOS, or hardware types.
- The feature MUST fit the semantic, layout, ordered render, frame-handoff,
  and failure boundaries established by accepted GiftUI architecture.
- The embedded path MUST NOT assume heap allocation, reflection, unrestricted
  existential use, unbounded path storage, or a full-frame pixel buffer.
- Geometry, path, operation, raster-workspace, stack, binary-size, and
  execution costs MUST be evaluated on constrained targets.
- Backend-specific quantization and raster details MUST NOT redefine portable
  path or stroke semantics.
- Existing code and legacy documents MAY provide evidence but MUST NOT select
  the maintained architecture.
- Acceptance of this Proposal authorizes RFC work only. Major implementation
  still requires accepted ADRs and approved Specifications.

## Evidence and Assumptions

Observed evidence includes the MVP waveform requirements, the fixed Signal
Analyzer hierarchy and trace count, the approved application contract's
dependency on separately governed GiftUI drawing, and RFC-002's proposed
backend-neutral line-operation seam. Existing framebuffer and embedded proof-
of-concept renderers may supply feasibility evidence but are not authoritative.

This Proposal assumes that straight-line construction and solid opaque
stroking are sufficient for the MVP waveform. RFC work must validate that
assumption against the reference application and supported backends.

## Success Criteria

- The portable Signal Analyzer draws its time grid and four data-driven
  digital traces using only the approved GiftUI client drawing contract.
- The drawing code remains substantially shared across all four MVP
  configurations and contains no backend, platform, display, or hardware
  identity checks.
- Canvas execution receives the information required by the MVP and has a
  defined, testable invocation and lifetime model.
- Straight-line path construction and solid opaque strokes have deterministic,
  backend-independent semantics for the line widths, round caps, and round
  joins required by the analyzer.
- Dynamic and static profiles pass shared tests for drawing order, geometry,
  path lifetime, stroke behavior, and bounded failure cases.
- Static validation demonstrates finite path, render-operation, raster,
  stack, and related workspace obligations with deterministic exhaustion
  behavior.
- Supported backends can consume the resulting drawing intent without
  evaluating client views or retaining borrowed semantic state.
- Downstream Specifications can define exact public and internal contracts
  without choosing new execution, ownership, lifetime, resource, stroke,
  backend-boundary, or failure architecture.

## Scope

The feature covers the minimal public custom-drawing experience and framework
behavior needed for Canvas execution, resolved drawing size, mutable straight-
line path construction, solid opaque stroking, the required line-width and
round cap/join behavior, drawing order, bounded realization, and lowering into
GiftUI's backend-neutral render boundary.

It includes the relationship between client drawing, layout geometry, render
operations, backend consumption, static workspace, diagnostics, and capacity
failure. Exact declarations, representations, algorithms, numeric capacities,
module assignments, pixel quantization, and backend implementations belong to
downstream RFCs, ADRs, and Specifications.

## Risks

- A public surface modeled too closely on desktop graphics APIs may be too
  costly or unavailable for Embedded Swift.
- An overly generic path model may increase memory, code size, and backend
  complexity without helping the Signal Analyzer.
- Backend-specific stroke or quantization choices may cause semantic drift
  across validation configurations.
- Unclear closure, path, or borrowed-resource lifetimes could force hidden
  allocation or unsafe retention.
- Overlapping authority with RFC-002's render boundary could create competing
  sources of truth unless the focused RFC clearly inherits its constraints.

## Open Questions

- Which exact drawing behaviors are required to express the reference time
  grid and digital traces without admitting speculative graphics scope?
- What evidence is required to compare bounded path construction and direct
  emission approaches across the static and dynamic profiles?

## Deferred and Follow-up Work

None. Richer fills, curves, images, Canvas text, public clipping, transforms,
effects, retained rendering, and animation remain outside this Proposal and
currently lack a concrete MVP requirement.

## References

- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](proposal-002-signal-analyzer-reference-application.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [SPEC-001: Signal Analyzer Reference Application](../specs/spec-001-signal-analyzer-reference-application.md)
