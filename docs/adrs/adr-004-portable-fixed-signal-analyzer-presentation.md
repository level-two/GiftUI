---
id: ADR-004
feature: signal-analyzer
title: Portable Fixed Signal Analyzer Presentation
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
  - ADR-001
  - ADR-002
  - ADR-003
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-004: Portable Fixed Signal Analyzer Presentation

## Status

Proposed.

## Context

The Signal Analyzer exists to prove that GiftUI can express one substantially
shared application presentation across dynamic desktop, static macOS,
Raspberry Pi/Linux, and nRF52840. Target-specific screens would avoid pressure
on GiftUI but would not validate a common application model. Conversely,
runtime-sized collections and general-purpose drawing would expand the MVP
surface beyond the fixed four-channel workload.

[RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
approved a fixed portable hierarchy and confined target differences to
hosting, source, executor, timing, backend, display, input, and hardware
integration.

## Decision

The Signal Analyzer MUST use one substantially shared portable Presentation
hierarchy for all MVP configurations. It MUST contain a header and acquisition
status, a waveform panel with a time ruler and four explicit channel rows,
Start, Stop, Clear, explicit 1-, 2-, and 5-second window controls, and error
text.

The hierarchy MUST use fixed child composition rather than runtime-sized
channel or control collections. Visible-range calculation MUST remain in
Presentation. The display interval is 250 milliseconds, and the runtime MAY
coalesce intervening state invalidations rather than render once per
transition.

Target-specific application code MUST remain outside the portable hierarchy
and MAY supply hosting, concrete signal sources, the serialized executor,
monotonic time and scheduling, GiftUI runtime, renderer, display, input, and
hardware integration. The portable API MUST exchange `Duration` values but
MUST NOT obtain time or schedule timers directly.

The required Observation and Canvas/path/stroke contracts MUST be established
through their own GiftUI feature lifecycles before the analyzer Specification
depends on them.

## Rationale

A fixed hierarchy proves the MVP's portability hypothesis while limiting
client APIs and static-composition costs to the actual analyzer workload.
Keeping clocks, scheduling, hardware, and platform bootstrap outside
Presentation preserves backend independence. Coalescing at four frames per
second separates the 80-event-per-second ingestion requirement from display
performance.

## Consequences

### Positive

- The same presentation structure validates dynamic and static runtimes.
- Platform and hardware details remain outside client view code.
- Fixed composition avoids requiring dynamic collections for the MVP.
- Acquisition can preserve all events without demanding one frame per event.

### Negative

- The MVP presentation does not support runtime channel configuration.
- Target hosts require explicit composition and timing adapters.
- Observation and Canvas remain prerequisite feature lifecycles.
- Exact visual styling may differ across backends even when behavior is shared.

### Follow-up

- Create and approve separate Observation and Canvas feature lifecycles.
- The Signal Analyzer Specification must define the hierarchy, control states,
  visible-range formula, refresh behavior, and target-host obligations.
- Conformance tests must compare portable behavior across all MVP profiles and
  require connected-hardware evidence where applicable.

## Rejected Alternatives

### Target-specific presentation forks

Separate screens were rejected because they could hide missing GiftUI
abstractions and would not prove a common application model.

### Runtime-sized channel and control collections

Dynamic collections were rejected because the fixed four-channel and
three-window MVP does not justify their API or embedded runtime cost.

### Platform timing inside Presentation

Direct clock and timer ownership in Presentation was rejected because it would
couple portable code to runtime and backend facilities.

## References

- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
