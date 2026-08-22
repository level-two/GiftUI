---
id: ADR-007
feature: giftui-mvp-architecture
title: Integration Ownership and Host Composition
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-22
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
related_adrs:
  - ADR-005
  - ADR-008
  - ADR-010
  - ADR-013
  - ADR-019
related_specs:
  - SPEC-002
related_future_work:
  - FW-009
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-007: Integration Ownership and Host Composition

## Status

Accepted.

## Context

GiftUI's target stacks combine semantic runtimes, render backends, operating-
system adapters, display and input drivers, and transport or HAL mechanisms.
Treating a platform module as the owner of the complete vertical stack would
make platform identity an architectural boundary and duplicate reusable
behavior.

## Decision Boundary

This record extracts RFC-002 Decision Summary items 4 and 5 together with the
approved explicit-environmental-contract rule. It owns component integration
boundaries and host composition, but not frame disposition (ADR-010), input
admission semantics (ADR-013), capability resolution (ADR-019), or a shared
delegated-Service foundation (FW-009).

## Decision

Backends, raster and surface adapters, display and input drivers, and
transport/HAL integrations MUST have separate ownership with dependencies
flowing strictly toward their lower contracts. A supported platform MUST be a
target-host composition or preset that selects and assembles those owners; it
MUST NOT own or introduce cross-cutting GiftUI semantics.

Environmental operations MUST be supplied explicitly through the narrowest
approved consumer-owned contract. Portable application code MUST NOT discover
or name concrete platforms, backends, drivers, transports, or hardware.

## Rationale

Narrow ownership preserves backend independence, permits reusable raster and
driver components, and prevents target-specific mechanics from leaking into
the portable Signal Analyzer presentation. The host is the only layer that
legitimately knows the complete selected stack.

## Consequences

### Positive

- Components can be tested and substituted at their actual boundaries.
- Platform presets remain convenient without becoming semantic authorities.
- Hardware and OS dependencies stay below portable framework code.

### Negative

- Hosts must assemble several explicit contracts.
- Some existing vertical platform modules must be split or adapted.

### Follow-up

- Specifications must define each integration SPI and host assembly contract.
- Dependency tests must reject upward imports and semantic ownership in
  platform presets.

## Deferred and Follow-up Work

- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  preserves a shared Service foundation until multiple approved consumers
  justify it.

## Rejected Alternatives

### Platform-owned vertical stacks

Rejected because they duplicate portable and reusable responsibilities and
turn deployment names into semantic architecture.

### Ambient platform lookup

Rejected because it hides dependencies and allows concrete target identity to
flow upward.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI Principles](../PRINCIPLES.md)
