---
id: ADR-029
feature: canvas-drawing
title: Scoped Transient Path Snapshot Semantics
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
  - ADR-006
  - ADR-009
  - ADR-028
  - ADR-030
  - ADR-031
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
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

# ADR-029: Scoped Transient Path Snapshot Semantics

## Status

Accepted.

## Context

The Signal Analyzer needs mutable straight-line construction and may submit a
Path before mutating it again for another stroke. A retained or freely copyable
Path would require storage ownership, aliasing, capacity, and cross-cycle
lifetime rules unused by the MVP, while immediate per-segment commands would
lose explicit subpaths and canonical join meaning.

RFC-009 approved a uniquely owned Path construction handle scoped to one
Canvas invocation, with immutable snapshot behavior at stroke submission.
SPIKE-004 demonstrated equivalent snapshot semantics using both copy-to-plan
and unique-range sealing with finite static storage.

## Decision Boundary

This record extracts RFC-009 Decision Summary item 2. It owns the lifetime,
mutation ownership, construction subset, and snapshot meaning of MVP Path. It
does not own Canvas invocation and plan lifetime (ADR-028), normalized backend
payload semantics (ADR-030), or failure and capacity ownership (ADR-031).

## Decision

MVP `Path` construction MUST be valid only during an active Canvas invocation.
One live mutable Path MUST have unique construction ownership and MUST maintain
ordered checked-integer points, explicit open-subpath boundaries, and its
current-point state. It MUST support multiple subpaths through `move(to:)` and
`addLine(to:)`.

A Path MUST NOT persist across Canvas invocations or cycles, cross an
asynchronous boundary, own a backend resource, or expose shared mutable
storage. Copying or aliasing its mutable construction storage is not admitted.
Preconstructed retained paths, curves, and closed-fill semantics are outside
the MVP contract.

Every stroke submission MUST snapshot the submitted Path's complete ordered
geometry and subpath boundaries into the owning cycle-local plan. Later Path
mutation, reuse, or destruction MUST NOT alter an earlier submitted stroke.
Dynamic and static profiles MAY copy, move, seal, or transfer uniquely owned
storage differently, but MUST preserve the same observable Path and snapshot
semantics.

## Rationale

Scoped unique ownership gives the public concept deterministic mutation and
lifetime rules that fit fixed-capacity workspaces. Snapshot-at-stroke preserves
familiar reuse within one closure and painter order without letting mutable
client storage cross into the backend or frame lifetime.

## Consequences

### Positive

- Submitted strokes are immutable even when the client continues constructing
  with the same Path.
- Static implementations can use fixed arenas without requiring heap-backed
  value copying.
- Explicit subpaths preserve cap and join semantics across backends.
- Both profiles can share the same semantic and exhaustion fixtures.

### Negative

- Clients cannot cache, return, or reuse Path values across Canvas invocations.
- Copy-based implementations may temporarily duplicate point and subpath
  storage.
- The Swift API must make unique scoped ownership enforceable or report misuse
  explicitly.

### Follow-up

- The drawing Specification must define exact construction declarations,
  invalid-state behavior, default state, snapshot representation, and bounds.
- Static validation must measure simultaneous mutable-Path and snapshot
  storage, not only final plan size.

## Deferred and Follow-up Work

None. A standalone retained or copyable Path requires a future concrete use
case and normal feature lifecycle rather than an extension implied here.

## Rejected Alternatives

### Copyable or retained standalone Path values

Rejected because they add aliasing, copy-failure, capacity, and cross-cycle
lifetime semantics not required by the Signal Analyzer.

### Immediate per-segment context commands without Path

Rejected because they do not provide the accepted Path surface, explicit
subpath ownership, reusable stroke submission, or reliable round-join meaning.

### General-purpose Path with curves and fills

Rejected because it expands operation vocabulary, storage, failure, and
backend obligations beyond the accepted straight-line MVP scope.

## References

- [RFC-009: Canvas, Path, and Stroke Drawing Architecture](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [PROPOSAL-006: Canvas, Path, and Stroke Drawing](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [SPIKE-004: Canvas Path Plan Feasibility](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [ADR-009: Checked Integer Geometry for MVP](adr-009-checked-integer-geometry.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
