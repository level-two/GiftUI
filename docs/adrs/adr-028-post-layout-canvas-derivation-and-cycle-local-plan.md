---
id: ADR-028
feature: canvas-drawing
title: Post-Layout Canvas Derivation and Cycle-Local Plan
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-25
updated: 2026-08-26
proposal:
  - PROPOSAL-006
related_rfcs:
  - RFC-009
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-010
  - ADR-011
  - ADR-029
  - ADR-030
  - ADR-031
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-004
  - SPEC-006
  - SPEC-012
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-028: Post-Layout Canvas Derivation and Cycle-Local Plan

## Status

Accepted.

## Context

The Signal Analyzer must construct waveform geometry from cycle-stable state
and the Canvas's resolved local size. The drawing closure therefore cannot run
during ordinary declarative construction or layout, and it cannot run while a
backend is consuming a frame without coupling client execution to irreversible
presentation work.

[RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
approved post-layout derivation into a bounded immutable plan. SPIKE-004 showed
that both measured plan candidates fit the supported hardware-free nRF52840
build, while direct emission could expose partial output after late sink
exhaustion.

## Decision Boundary

This record extracts RFC-009 Decision Summary item 1. It owns Canvas closure
timing, scoped invocation lifetime, deterministic occurrence order, and the
cycle-local plan lifetime. It does not define Path snapshot semantics
(ADR-029), the normalized stroke payload (ADR-030), or failure and startup-gate
ownership (ADR-031).

## Decision

`Canvas` MUST be a laid-out semantic leaf. GiftUI MUST retain its client drawing
closure only until post-layout derivation of the owning cycle-stable revision,
then invoke it synchronously, non-suspending, and at most once per Canvas
occurrence in one derivation attempt. Canvas occurrences MUST be invoked in
deterministic resolved render order.

The closure MUST receive a scoped backend-independent graphics context and the
resolved checked local size. The context and every borrowed workspace view MUST
NOT escape the invocation. The closure MUST NOT suspend, initiate a reentrant
cycle, dispatch an action, or mutate GiftUI-observed state. GiftUI MUST release
the stored closure no later than finalization of the owning cycle and MUST NOT
retain it in published semantic state, presentation-pending intent, or a frame
payload, or pass it below the render-producer boundary.

The closure MUST produce a bounded cycle-local immutable Canvas plan before
frame offer. The plan MUST preserve the Canvas occurrence's position in
painter's order and MUST live only from its complete derivation through that
revision's synchronous one-shot offer. GiftUI MUST discard it after accepted or
refused handoff and MUST NOT treat it as a retained display list or replay
payload.

## Rationale

Post-layout invocation supplies the size required by the client while keeping
state observation inside ADR-011's frozen derivation. A complete plan separates
client execution from backend consumption, supports pre-offer validation, and
preserves ADR-010's one-shot boundary. The short scoped lifetime permits
profile-specific bounded storage without creating a retained rendering model.

## Consequences

### Positive

- Canvas code observes one resolved size and one frozen semantic revision.
- Backends never execute client code or retain its closure and workspace.
- Static and dynamic profiles may use different plan storage beneath one
  invocation and lifetime model.
- Canvas strokes remain ordered with surrounding normalized operations.

### Negative

- Core must reserve cycle-local storage for the complete Canvas plan.
- The client closure cannot suspend, escape its context, or be reinvoked for
  preflight.
- Implementations must track and release the closure at a precise cycle phase.

### Follow-up

- The drawing Specification must define exact Swift declarations, phase and
  lifetime enforcement, closure storage, plan representation, and conformance
  fixtures.
- The final Embedded Swift closure and scoped-context source shape must compile
  and link without unavailable runtime support.

## Deferred and Follow-up Work

None. Retained rendering, replay, asynchronous drawing, and animation remain
outside the accepted MVP scope rather than being requirements of this record.

## Rejected Alternatives

### Execute the client closure during backend frame consumption

Rejected because it couples client behavior to backend transaction timing and
cannot guarantee complete pre-offer validation without retaining work or
observably reinvoking the closure.

### Invoke the closure during declarative construction or layout

Rejected because the resolved Canvas size and complete cycle-stable derivation
are not yet available.

### Retain a replayable Canvas plan

Rejected because it adds cross-frame identity, ownership, storage, and replay
semantics that the Signal Analyzer does not require and ADR-010 does not impose.

## References

- [RFC-009: Canvas, Path, and Stroke Drawing Architecture](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [PROPOSAL-006: Canvas, Path, and Stroke Drawing](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [SPIKE-004: Canvas Path Plan Feasibility](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
