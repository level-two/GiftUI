---
id: ADR-020
feature: capability-system
title: Composite Raster Presentation Capability
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-004
  - RFC-006
related_adrs:
  - ADR-005
  - ADR-009
  - ADR-010
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-022
  - ADR-023
related_specs: []
related_future_work:
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-020: Composite Raster Presentation Capability

## Status

Accepted.

## Context

The four MVP stacks use materially different full-surface and tiled raster
paths. End-to-end presentation support depends on facts owned by the render
producer, raster/backend, surface/display adapter, and host resource policy;
no one contributor can establish it independently.

## Decision Boundary

This record extracts the capability-specific portion of RFC-006 Decision
Summary item 4. It owns the single MVP `rasterPresentation` family's semantic
promise, contributing fact classes, compatibility inputs, bounds, and absence
result. It inherits normalized operation meaning, checked geometry, and the
one-shot lifetime from ADR-005, ADR-009, and ADR-010; it does not create another
operation payload lifetime or govern runtime health.

## Decision

The MVP capability catalogue MUST contain exactly one composite family,
`rasterPresentation`. It MUST resolve whether the assembled stack can present
the Signal Analyzer's required normalized opaque rectangles, positioned text,
straight-line strokes, clipping, and damage semantics at the required logical
extent.

Resolution MUST combine contributor-owned facts for operation coverage,
conformance to ADR-010's synchronous one-shot stream, canonical pixel encoding,
downstream submission lifetime, extent, raster and payload bounds, in-flight
storage, and host policy. Canonical pixel encoding and submission lifetime
MUST be compatibility inputs, not output-only metadata; lack of a common
encoding or compatible lifetime MUST resolve to unavailable with a stable
reason.

The effective value MAY identify capability-level realization properties and
bounds but MUST NOT expose concrete target, backend, driver, or device identity
as portable feature flags. Runtime backpressure and post-handoff device health
MUST NOT mutate the result.

## Rationale

The Raspberry Pi and nRF52840 fixtures prove that presentation conformance
requires a shared intersection across multiple owners. One composite family
captures that semantic path without turning every selected component or
hardware difference into a separate Capability.

## Consequences

### Positive

- Full-surface and bounded tiled paths can satisfy one semantic promise.
- Encoding, lifetime, and storage incompatibilities fail before runtime.
- The minimum catalogue remains directly justified by MVP fixtures.

### Negative

- Contributors must translate owned facts into a closed capability vocabulary.
- The composite resolver and negative matrix require explicit tests and
  resource accounting.

### Follow-up

- Specifications must define the family vocabulary, fields, contribution
  adapters, stable absence reasons, exact bounds, and four normalized fixtures.

## Deferred and Follow-up Work

- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  second payload lifetime only for a future measured raster requirement.

## Rejected Alternatives

### Backend Boolean bag

Rejected because it cannot express cross-component encoding, lifetime, extent,
and storage compatibility.

### Feature-local concrete probing

Rejected because it duplicates intersection rules and turns implementation
identity into the capability model.

### Replayable tiled payload mode

Rejected because all first-party MVP tiled fixtures can use ADR-010's common
stream and retain only backend-owned derived data.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
- [SPIKE-002: nRF52840 Capability Path Resource Evidence](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
