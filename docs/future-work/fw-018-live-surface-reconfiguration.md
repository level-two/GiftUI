---
id: FW-018
feature: capability-system
title: Live Surface Reconfiguration
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
source:
  - RFC-006
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-018: Live Surface Reconfiguration

## Observation / Opportunity

A future host may need to continue running while its presentation surface
changes logical extent or orientation. Supporting that behavior would require
a coherent lifecycle across surface discovery, capability revalidation,
effective-snapshot replacement, layout and render invalidation, input
coordinate remapping, in-flight presentation, and possibly component
reassembly.

## Why Deferred

The four Signal Analyzer MVP fixtures use an extent and orientation fixed
before the first runtime cycle. RFC-006 deliberately freezes the effective
capability snapshot at that boundary, and no MVP requirement needs live
resize or rotation. Defining a mutation lifecycle now would expand runtime,
backend, input, failure, and capability scope without target-validation value.

## Potential Value

- Support resizable desktop windows, display rotation, foldable or hot-plugged
  surfaces, and other hosts whose presentation geometry changes while active.
- Preserve coherent layout, rendering, and input mapping across an approved
  surface transition.
- Make capability loss, revalidation failure, and component replacement
  explicit instead of allowing ad hoc snapshot mutation.

## Current Non-goals

- MVP does not support live surface resize or rotation after the first cycle.
- No reconfiguration event, transition state machine, capability
  renegotiation, snapshot replacement, layout invalidation, input remapping,
  frame-drain, or component-reassembly contract is selected.
- Static initial extent and orientation remain ordinary configuration facts
  used by the single `rasterPresentation` family; they are not separate MVP
  Capability families.

## Revisit Triggers

- An accepted post-MVP application or supported host requires an active GiftUI
  runtime to survive surface extent or orientation changes.
- A maintained desktop backend requires live window resizing for conformance,
  rather than using a fixed validation surface.
- A supported display or platform can change orientation or geometry after
  initialization and product requirements prohibit stopping and rebuilding
  the runtime.

## Disposition

Captured for post-MVP consideration. Promote to an Exploration when a concrete
host supplies transition requirements and failure cases; promote into the
authority-bearing lifecycle only after an accepted Proposal covers the
runtime, capability, backend, and input implications.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
