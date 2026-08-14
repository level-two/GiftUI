---
id: ADR-001
feature: signal-analyzer
title: Signal Analyzer Application Boundaries
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-14
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-001
related_adrs:
  - ADR-002
  - ADR-003
  - ADR-004
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-001: Signal Analyzer Application Boundaries

## Status

Proposed.

## Context

The Signal Analyzer must remain one coherent application while exercising
GiftUI across macOS, Raspberry Pi/Linux, and nRF52840. The macOS investigation
demonstrated separate Domain, Data, Presentation, and application-host targets,
but existing code is evidence rather than architectural authority. Without an
explicit ownership and dependency decision, UI, platform, timing, or hardware
concerns could leak into the portable application behavior as additional
targets are added.

[RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
approved an inward dependency structure and a target-host composition boundary.

## Decision

The Signal Analyzer MUST preserve four logical responsibilities with these
dependency rules:

- Domain owns signal and acquisition models, repository-facing contracts, and
  use-case semantics. It MUST NOT depend on Presentation, Data, GiftUI,
  SwiftUI, renderers, platforms, clocks, GPIO, or display hardware.
- Data owns concrete signal sources, source adaptation, capture accumulation,
  retention, and acquisition-state publication. It MUST depend on Domain only.
- Presentation owns screen state, user intents, visible-range calculation, and
  the portable GiftUI view hierarchy. It MAY depend on Domain and approved
  GiftUI client contracts but MUST NOT depend on concrete Data types.
- The target host is the composition root. It selects and connects concrete
  Data, Presentation, GiftUI runtime, backend, display, input, clock,
  scheduling, and hardware implementations.

The boundaries are logical and MUST be preserved even when a static build does
not realize every responsibility as a separate SwiftPM target.

## Rationale

Inward dependencies keep acquisition semantics independently testable and
allow materially different hosts and signal sources to reuse the same domain
and presentation concepts. Treating the host as the only composition root
localizes target-specific facilities without requiring dynamic packaging on
embedded systems. The decision follows GiftUI's backend-independence and
preserve-concepts-not-implementations principles.

## Consequences

### Positive

- Domain behavior can be tested without a UI framework, renderer, or hardware.
- Presentation can move from the SwiftUI investigation to GiftUI without
  changing concrete acquisition implementations.
- Mock, Raspberry Pi, and nRF52840 sources can be selected by their hosts while
  preserving application behavior.
- Static builds may flatten packaging without erasing ownership or dependency
  direction.

### Negative

- The application carries explicit contracts and composition wiring that an
  undivided executable would not need.
- Cross-boundary values and actions require conformance tests to prevent
  target-specific semantic drift.
- Static wiring may differ mechanically from dynamic dependency injection.

### Follow-up

- The Signal Analyzer Specification must define the exact module contracts and
  prohibited dependencies.
- Implementation planning must provide target-host composition for every MVP
  configuration.
- Conformance evidence must demonstrate that target-specific dependencies do
  not enter Domain or the portable Presentation hierarchy.

## Rejected Alternatives

### One undivided application module

An undivided executable was rejected because it permits UI and platform
dependencies to leak into signal semantics and weakens independent testing.

### Presentation owns the signal source

Direct source ownership in Presentation was rejected because it couples screen
state to acquisition, buffering, and target hardware.

## References

- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
