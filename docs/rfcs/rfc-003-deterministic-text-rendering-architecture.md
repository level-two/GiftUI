---
id: RFC-003
feature: giftui-mvp-architecture
title: Deterministic Text Rendering Architecture
status: review
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-19
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-006
related_adrs: []
related_specs: []
related_future_work:
  - FW-001
  - FW-002
  - FW-003
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-003: Deterministic Text Rendering Architecture

## Summary

This RFC is the independently reviewable text-boundary decision cluster under
PROPOSAL-003. It proposes that GiftUI layout own authoritative text geometry
and that backends rasterize already resolved text without remeasurement or
ambient font substitution.

```text
Text declaration and semantic style
    -> canonical text measurement and positioning
    -> backend-neutral resolved text operation
    -> exact-resource raster provider
    -> backend presentation
```

This RFC decides ownership, identity, and render-boundary meaning. It does not
select the reference face, public API spelling, shaping corpus, numeric field
widths, font package schema, compression, cache design, capacity values, or a
specific outline library. Those are later Specification or evidence tasks.

## Context

[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) requires layout to be
backend-neutral and resolved output to cross a normalized render boundary.
Text makes that boundary architecturally significant: if layout and a backend
use different metrics or font identities, intrinsic sizes, wrapping, clipping,
and downstream placement can diverge even though every layer locally appears
correct.

The Signal Analyzer requires titles, labels, numeric values, status, errors,
and button text on all four MVP configurations. The nRF52840 configuration
cannot be required to carry a desktop font-discovery or outline-rasterization
stack. Existing fixed-cell bitmap text proves a small static realization is
feasible, but it is evidence rather than authority.

## Scope and Decision Boundary

This RFC remains separate from RFC-002 because it compares independently
credible ownership models and may evolve without changing the whole layer
graph. It remains coordinated with RFC-005 for deterministic resource failure.
It owns the cross-profile meaning of logical text geometry, the resolved text
operation at the backend boundary, and the compatibility relationship between
metrics and raster data. It does not own public API spelling, concrete storage
formats, resource budgets, or raster-provider selection.

## Requirements

### R1 — One geometry authority

For the same admitted text, style, constraints, and exact font resources,
supported configurations MUST produce the same logical measurement, line
placement, glyph selection, and positioned geometry. Backend-specific
tolerance in logical text geometry is not permitted. Raster coverage and
antialiasing MAY differ without changing those logical results.

### R2 — Layout owns text decisions

Font resolution, admitted shaping, line breaking, measurement, and positioning
MUST occur above the backend boundary. A backend or raster provider MUST NOT
remeasure text, choose fallback, or change logical placement.

### R3 — Resolved render payload

Normal GiftUI text MUST cross the render boundary as a positioned-glyph
operation whose exact font identity, glyph identities, and logical positions
are complete. The operation MUST be streamable and MUST NOT require the
backend to interpret an authoritative raw string, derive successive logical
positions, or retain a complete run.

### R4 — Exact resource identity

Measurement data and raster payloads MUST refer to the same immutable font
resource identity. One identity MAY cover separately stored or generated
metric, outline, and bitmap assets, but build tooling MUST validate them as one
compatible resource set. Missing, mismatched, or unsupported resources MUST
have deterministic failure behavior and MUST NOT cause ambient substitution.

### R5 — Multiple raster realizations

The same logical text contract MUST permit a capable target to rasterize exact
packaged outlines and a constrained target to use exact precompiled bitmap
data. Raster quality MAY differ; logical geometry MUST NOT.

### R6 — Bounded static path

Static text input, shaping, positioning, render payload, raster scratch, and
resource storage MUST be fixed, generated, caller-owned, or otherwise
explicitly bounded. Resolved text MUST be streamable through RFC-002's ordered
sink without a mandatory retained display list.

### R7 — MVP proportionality

The implementation contract MUST cover only text needed by the Signal
Analyzer and target validation. Complex-script shaping, bidirectional or
vertical layout, editing, runtime font discovery, color glyphs, and advanced
raster delivery are outside MVP.

## Constraints

- RFC-002 owns checked integer layout geometry and the ordered render boundary.
- MVP paint is opaque RGB; general alpha and color glyphs are not required.
- Embedded Swift cannot require heap allocation, reflection, unrestricted
  existentials, runtime discovery, or desktop concurrency.
- A selected face and derived assets must have a compatible redistribution and
  derivation license before a Specification can authorize implementation.
- Pixel-identical antialiasing is not required across raster realizations.

## Proposed Design

### Ownership

The text layout subsystem consumes semantic text and a font-resource metrics
view. It resolves the admitted content into positioned glyph runs and logical
bounds. Measurement and rendering use that same resolved result; there is no
independent backend measurement path.

A font resource exposes two consistent views under one exact identity. The
identity names the complete compatible resource set rather than requiring one
physical file:

- canonical character mapping, metrics, and admitted shaping data for layout;
- outline or bitmap raster payloads for rasterization.

The render operation carries an exact font-instance identity, positioned glyph
identities, logical positions, opaque paint, and resolved clipping information
needed by the MVP renderer. It may emit those glyphs directly into the ordered
sink without first materializing an array. Exact fields, coordinate encoding,
and storage representation belong in a Specification.

### Lifetime

Resolved runs are immutable in meaning. A producer may borrow bounded
workspace for the synchronous one-shot sink call defined by RFC-004; every MVP
backend must finish consuming the positioned-glyph operation and its borrowed
resources before that call returns. Backends may cache derived raster images,
but they may not retain the operation or resolved run, and cache state and
raster dimensions cannot feed back into layout.

### Static and dynamic realizations

Dynamic hosts may use allocation-backed text input, run storage, and caches.
Static hosts may use generated tables, fixed-capacity workspaces, direct sink
emission, and precompiled strikes. Both realize the same geometry and failure
contract rather than separate text models.

## Module Responsibilities

| Owner | Responsibility | Prohibited dependency or decision |
| --- | --- | --- |
| `GiftUI` client surface | Declare text content and semantic style | No platform font handles or backend raster modes |
| Layout/text subsystem | Resolve identity, shape admitted content, measure, break lines, and position glyphs | No backend, platform text API, display, or raster-cache authority |
| Render core | Carry resolved text meaning and exact resource identity | No raw semantic reevaluation or font discovery |
| Raster provider | Produce glyph pixels for the exact requested identity | No measurement, fallback, or line-placement authority |
| Backend | Execute ordered operations, clip, composite, cache, and present | No text-layout or substitution authority |
| Build tooling/resources | Produce and validate exact metric and raster assets | No runtime semantic authority |

## Public API Impact

Portable `Text` remains part of `import GiftUI`. Later Specifications define
content forms, styles, admitted input behavior, fallback policy, and dynamic
conveniences. Font package and raster-provider contracts may be host API,
framework SPI, tooling formats, or internal; this RFC does not decide access
control.

## Capabilities Impact

RFC-006 may represent text support, admitted coverage, resource availability,
and relevant bounds. Capability policy cannot authorize a different font or
geometry than the resolved text contract, and missing required resources make
the configuration invalid or produce the approved deterministic failure.

## Backend Impact

Backends consume resolved text instead of choosing a font and drawing an
authoritative string. Existing raw-text operations require migration or a
temporary adapter. A platform API may rasterize an exact packaged face at
glyph level; it may not perform GiftUI line layout or substitute a system face.

## Static / Embedded Impact

The nRF52840 realization may compile exact bitmap assets and bounded lookup
tables into firmware. It must declare input, glyph, run, line, workspace,
raster scratch, and resource bounds and produce deterministic exhaustion. An
outline parser or runtime font registry is not a common-contract requirement.

## Performance

Specifications must measure layout, raster, cache, and transfer time
separately for representative and maximum admitted Signal Analyzer strings.
Text work must fit the 250-millisecond presentation interval while capture
continues. Cache state may improve cost but not change results.

## Memory / Binary Size

Specifications must account for metric tables, raster assets, text and glyph
workspace, raster scratch, stack high-water, caches if selected, and linked
provider code. The architecture permits build-time subsetting and alternate
exact raster realizations so unused general typography machinery is not linked.

## Alternatives

### Backend-owned text layout

Passing strings to each backend is initially small and may improve native
appearance, but it allows platform metrics, shaping, fallback, and rounding to
change GiftUI layout. It is preferable only if native text equivalence matters
more than shared cross-backend geometry.

### One complete outline stack everywhere

A universal shaping and raster stack could maximize consistency, but it may
impose unacceptable firmware and scratch cost. It becomes preferable only if
measured embedded costs fit or required text cannot be served by generated
assets.

### One fixed bitmap font everywhere

This is simple and deterministic but unnecessarily restricts capable targets.
It remains a valid exact realization, not the universal architecture.

### Raw text plus exact identity in the render plan

This preserves resource identity but still places shaping on both sides of the
layout boundary. It does not guarantee one authoritative geometry result.

### Backend-specific logical geometry tolerance

A documented tolerance could permit native platform measurement and rounding,
but even a small width or position difference can change wrapping, clipping,
alignment, and downstream stack placement. It is preferable only if native
layout variation matters more than one portable Signal Analyzer geometry.

### Resolved glyph IDs with backend-derived positions

A compact run could carry selected glyph IDs, advances, offsets, and a run
origin while asking each backend to accumulate final positions. This reduces
payload detail, but duplicates checked positioning arithmetic below the
geometry authority and makes conformance depend on backend reconstruction.

### Raster-ready masks or spans at the render boundary

GiftUI could rasterize resolved text before the backend boundary and send
pixel masks or spans. This simplifies backend text work, but increases
temporary-data and transfer costs and collapses the useful separation between
resolved logical text and target-selected exact raster realization.

### Separate metric and raster identities with compatibility metadata

Metric and raster assets could retain independent identities joined by a
manifest or fingerprint. This supports independently versioned packaging, but
adds a compatibility relationship that every loader and build path must
validate. One resource-set identity provides the needed packaging flexibility
with a smaller runtime failure surface.

## Rejected Approaches

The proposed direction rejects backend-owned layout, backend-specific logical
geometry tolerance, raw authoritative text at the render boundary,
backend-derived glyph positioning, raster-ready text as the only canonical
boundary, and independently compatible metric and raster identities. Each
either weakens one geometry authority, duplicates semantic work below the
boundary, or adds compatibility and resource cost without an MVP requirement.
These remain proposed conclusions subject to RFC review rather than accepted
architecture.

## Compatibility

Portable text syntax should remain familiar, but proof-of-concept metrics and
pixels are not authoritative. Existing backend APIs that accept raw strings
will require migration. The MVP establishes no font-package ABI or persistent
layout format.

## Testing Strategy

- Compare exact identities, glyph selection, positions, line placement, and
  logical bounds across dynamic and static profiles.
- Record resolved text operations independently of pixel backends.
- Test exact-resource mismatch, missing coverage, workspace exhaustion, and
  malformed package behavior.
- Run the same resolved operations through outline and bitmap providers while
  proving that raster variation cannot change layout.
- Verify dependency boundaries and confirm omitted typography facilities are
  absent from static firmware.
- Keep host, cross-build, simulator, and connected-display evidence distinct.

## Risks

- The contract may grow into a general typography platform; keep the admitted
  corpus and behavior tied to the Signal Analyzer.
- Exact resources may consume excessive flash; measure and subset only after
  coverage is specified.
- Borrowed runs may accidentally outlive workspace; test stream and replay
  lifetimes explicitly.
- RFC-002 geometry or render-plan decisions may change; reconcile the shared
  boundary before either RFC receives approval.

## Open Questions

None at the architectural level. This draft proposes identical logical text
geometry across MVP configurations, a streamable positioned-glyph operation
as the canonical backend boundary, and one immutable resource-set identity
joining metrics with every approved raster realization.

Reference-face selection, admitted corpus, malformed-input and fallback
behavior, numeric widths, package schema, compression, provider library,
capacities, and concrete budgets are downstream Specification or evidence
prerequisites. They do not decide which layer owns text geometry.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves complex-script, bidirectional, vertical, variable-font, and rich
  text work.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  preserves selection, carets, editing, and accessibility geometry.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  preserves runtime registration, resampling, distance fields, compression,
  and advanced shared caches.

Before a text Specification can be approved, evidence must identify a licensed
reference resource and demonstrate bounded static storage and raster viability.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. layout ownership of identical canonical text geometry across MVP
   configurations, with no backend-specific logical tolerance and no backend
   remeasurement or substitution;
2. a streamable positioned-glyph operation as the backend-neutral text
   boundary, carrying complete glyph selection and logical positions;
3. one immutable font-resource identity joining canonical metrics with
   selectable exact outline or bitmap raster realizations.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
