---
id: ADR-008
feature: giftui-mvp-architecture
title: Module Dependency Graph and MVP Package Topology
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-27
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-007
  - ADR-014
  - ADR-017
  - ADR-019
  - ADR-023
  - ADR-033
related_specs:
  - SPEC-002
  - SPEC-005
  - SPEC-006
  - SPEC-007
  - SPEC-008
  - SPEC-010
  - SPEC-011
related_future_work:
  - FW-016
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-008: Module Dependency Graph and MVP Package Topology

## Status

Accepted.

## Context

Logical layering alone cannot prevent portable modules from importing concrete
runtime, backend, platform, or hardware implementations. GiftUI also needs a
proportionate MVP distribution model that preserves those boundaries without
the release and dependency overhead of many independently versioned packages.

## Decision Boundary

This record extracts RFC-002 Decision Summary item 6. It owns compiler-visible
dependency direction, the one-package MVP distribution boundary, and the
portable `GiftUI` import surface. It does not fix candidate internal target or
product names, exact access control, or any post-MVP distribution topology.

## Decision

GiftUI MUST enforce logical ownership through an acyclic Swift target/module
import graph and dependency tests. For MVP, GiftUI MUST be distributed as one
Swift package containing the multiple targets and products required by the
approved ownership boundaries.

`GiftUI` MUST remain the portable declaration module and product and the sole
import required by portable Presentation. It MUST NOT become an umbrella that
imports or re-exports runtime, layout, render, backend, platform, driver, or
hardware implementations. Target hosts MAY import all selected components as
composition roots.

## Rationale

Multiple targets provide compiler-enforced isolation and testable dependency
direction. One distribution package avoids premature independent manifests,
versions, releases, and cross-package integration while retaining those
boundaries.

## Consequences

### Positive

- Prohibited imports fail mechanically rather than relying on convention.
- Portable clients keep a stable, narrow import surface.
- Static linking may specialize across targets without changing ownership.

### Negative

- More targets add build-graph, metadata, and specialization cost.
- Existing source placement and product names may require migration.

### Follow-up

- Specifications must finalize target names, products, access control, and
  dependency tests while preserving the approved graph.
- Static builds must measure module and linked-code cost.

## Deferred and Follow-up Work

- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
  preserves reconsideration of independently distributed packages when a
  concrete consumption, toolchain, versioning, or measured build need arises.

## Rejected Alternatives

### One undifferentiated target

Rejected because it permits dependency leaks and makes ownership boundaries
difficult to enforce or test.

### Multiple independently distributed packages for MVP

Not selected because it adds release and dependency overhead without a current
independent-distribution requirement.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI Principles](../PRINCIPLES.md)
