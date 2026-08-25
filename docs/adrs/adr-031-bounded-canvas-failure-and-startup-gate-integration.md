---
id: ADR-031
feature: canvas-drawing
title: Bounded Canvas Failure and Startup-Gate Integration
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-25
updated: 2026-08-25
proposal:
  - PROPOSAL-006
related_rfcs:
  - RFC-009
related_adrs:
  - ADR-010
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
  - ADR-028
  - ADR-029
  - ADR-030
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-004
  - SPEC-006
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-031: Bounded Canvas Failure and Startup-Gate Integration

## Status

Accepted.

## Context

Canvas construction combines client geometry, bounded Path and plan storage,
checked coordinate translation, normalized operation capacity, and a backend
whose presentation support is resolved across several owners. If ordinary
exhaustion is discovered after irreversible output begins, a frame may become
partially visible. If Canvas storage is added to the capability vocabulary,
structural configuration and semantic support become conflated.

RFC-009 approved complete pre-offer validation, explicit bounded failure, and
two independent startup gates. SPIKE-004 showed that cycle-local plans can
detect producer and sink exhaustion before offer, while direct emission can
leave partial output after late exhaustion.

## Decision Boundary

This record extracts RFC-009 Decision Summary item 4. It owns Canvas-specific
pre-offer validation and failure sequencing plus the division between B2
structural validation and the existing composite `rasterPresentation`
capability. It inherits general outcome, disposition, capability, cycle, and
frame semantics from ADR-010, ADR-011, and ADR-014 through ADR-020.

## Decision

Before the first run cycle, RFC-002 B2 structural validation MUST prove the
selected Canvas and Path producer's point, subpath, stroke-record, plan, and
normalized-operation capacities for the approved configured workload.
Separately, SPEC-004 capability resolution MUST prove the assembled render
producer, backend, surface, encoding, raster and derived-payload bounds,
in-flight storage, one-shot lifetime, and host policy satisfy the existing
`rasterPresentation` semantic path, including canonical straight-line-stroke
operation coverage. Both gates MUST pass; neither substitutes for the other.

Canvas, Path, plan, and producer-operation capacities MUST remain structural B2
inputs and MUST NOT be added as feature-local fields to SPEC-004's closed
capability vocabulary. Portable Canvas code MUST NOT probe concrete
implementations, branch on target identity, or silently omit required strokes
when either startup gate fails.

Within a cycle, GiftUI MUST validate local geometry and style, reserve Path
capacity, snapshot each submitted stroke into plan capacity, resolve checked
surface geometry and inherited clip, and validate normalized operation and
payload bounds before frame offer. Invalid geometry or path state, invalid
phase or scoped-lifetime use, arithmetic overflow, Path exhaustion, plan
exhaustion, and operation exhaustion MUST produce explicit bounded outcomes.
They MUST NOT silently wrap, truncate, drop a stroke, substitute a style, trap
for ordinary exhaustion, or publish a partial Canvas result.

A pre-handoff Canvas failure MUST invalidate the incomplete Canvas and frame
scope, discard the whole incomplete cycle-local plan, and follow ADR-011's
dirty-rederivation behavior without replaying admitted mutations, actions, or
effects. A backend that passed startup validation but cannot realize an
admitted canonical style represents an invariant or configuration failure, not
ordinary client-data failure or a permitted runtime fallback. Failure after
accepted handoff remains backend operational state under ADR-010 and ADR-017.

## Rationale

Complete validation before offer protects the no-partial-output boundary while
preserving at-most-once client effects. Separating structural capacity from
semantic capability keeps SPEC-004's closed vocabulary coherent and assigns
each startup fact to the owner that can prove it.

## Consequences

### Positive

- Ordinary Canvas failure cannot expose a partially accepted frame.
- Capacity and capability failures are deterministic and attributable to their
  actual startup gate.
- Static and dynamic profiles share outcome categories and transaction effects.
- Portable clients cannot convert missing support into silent feature loss.

### Negative

- Hosts must configure and validate two conjunctive startup gates.
- Core must reserve enough plan storage to complete validation before offer.
- Exact condition mapping and affected scopes add Specification and fault-test
  obligations.

### Follow-up

- The drawing Specification must map Canvas conditions into SPEC-003's closed
  outcome vocabulary and define the B2 capacity contract.
- SPEC-004 conformance must cover canonical straight-line-stroke support
  without adding Canvas-plan capacity fields.
- First-party target configuration must derive production capacities from the
  approved Signal Analyzer workload and report RAM, stack, flash, and runtime
  evidence.

## Deferred and Follow-up Work

None. Exact production capacities and failure declarations are required
downstream contract work, not deferred architectural choices.

## Rejected Alternatives

### Direct emission with late failure

Rejected because exhaustion after an earlier successful stroke can leave
partial irreversible output.

### Put Canvas-plan capacity in `rasterPresentation`

Rejected because producer construction storage is a structural configuration
fact, while the capability family describes the assembled semantic
presentation path.

### Runtime probing or silent stroke omission

Rejected because it leaks implementation identity, bypasses deterministic
startup validation, and changes portable behavior by target.

### Reinvoke the client closure for preflight

Rejected because invocation count is observable and would violate at-most-once
derivation effects.

## References

- [RFC-009: Canvas, Path, and Stroke Drawing Architecture](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [PROPOSAL-006: Canvas, Path, and Stroke Drawing](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [ADR-010: Synchronous One-Shot Frame Handoff](adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](adr-011-serialized-run-cycle-and-publication.md)
- [ADR-014: Bounded Cross-Layer Outcome Meaning](adr-014-bounded-cross-layer-outcomes.md)
- [ADR-020: Composite Raster Presentation Capability](adr-020-raster-presentation-capability.md)
- [SPIKE-004: Canvas Path Plan Feasibility](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
