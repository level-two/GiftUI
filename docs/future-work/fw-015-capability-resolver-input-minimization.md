---
id: FW-015
feature: capability-system
title: Capability Resolver Input Minimization
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-20
source:
  - RFC-006
  - ADR-019
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-001
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-015: Capability Resolver Input Minimization

## Observation / Opportunity

RFC-006 requires canonical pixel encoding and downstream submission lifetime
as `rasterPresentation` resolver inputs because each crosses independently
owned producer and consumer boundaries and each can invalidate an MVP
configuration.

A future ownership model, typed composition boundary, or consolidated adapter
may make one of those incompatibilities impossible by construction. If so, the
fact might become selected-realization output or private component
configuration instead of a shared resolver input, reducing contribution,
snapshot, diagnostic, and test surface without weakening configuration safety.

## Why Deferred

The current four fixtures require independent negative tests for no common
pixel encoding and incompatible submission lifetime. Removing either input now
would move cross-component validation into target-specific wiring or make an
invalid configuration less explainable. No current measurement shows that the
two fields impose a material embedded cost.

## Potential Value

- Keep the capability vocabulary minimal as component ownership evolves.
- Reduce bounded record, adapter, diagnostic, and snapshot cost when a fact is
  already guaranteed at a lower typed boundary.
- Avoid preserving historical resolver inputs after their negative
  configuration can no longer be assembled.

## Current Non-goals

- No RFC-006 resolver input or negative fixture is removed for MVP.
- Output-only metadata must not replace a compatibility check that can still
  fail across independently selected components.
- Target, backend, board, or device identity checks are not an acceptable
  substitute for semantic validation.

## Revisit Triggers

- Two or more supported implementations guarantee encoding or submission
  lifetime compatibility through an accepted typed ownership boundary, making
  the corresponding cross-contributor negative fixture unconstructable.
- Measurements show that one resolver input and its provenance impose material
  RAM, stack, flash, initialization, or diagnostic cost on a constrained
  target.
- A future capability-catalogue review finds that a fact is consumed only to
  describe the selected realization and no longer participates in support,
  bounds, policy, or absence behavior.
- Repeated adapter code shows that the same compatibility invariant is already
  enforced authoritatively below `GiftUICapabilities` without target-specific
  probing.

## Disposition

Captured for post-MVP consideration. Promotion requires evidence that invalid
configurations remain rejected deterministically and lifecycle review of any
RFC/ADR change; simplification must not be introduced first in a Specification
or implementation.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
