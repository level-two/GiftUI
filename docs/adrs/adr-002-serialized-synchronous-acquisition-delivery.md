---
id: ADR-002
feature: signal-analyzer
title: Serialized Synchronous Acquisition Delivery
status: accepted
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
  - ADR-003
  - ADR-004
related_specs:
  - SPEC-001
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-002: Serialized Synchronous Acquisition Delivery

## Status

Accepted.

## Context

The analyzer has one low-frequency transition source, one capture consumer,
and one acquisition-state consumer. The macOS investigation used synchronous
sink callbacks on the main actor. Static Embedded Swift is assumed not to
provide Observation, `MainActor`, `Task`, or desktop timer facilities, so the
portable contract cannot make those mechanisms mandatory.

[RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
approved synchronous delivery on one serialized application executor while
allowing target-specific realization of that executor.

## Decision

Signal source, repository, use-case, and presentation delivery MUST use
synchronous sink calls that run to completion on one serialized application
executor.

The repository MUST support one capture sink and one acquisition-state sink.
Installing a sink MUST immediately deliver the current value, installing a new
sink MUST replace the previous sink for that value, and stopping observation
MUST detach it.

Suspension, interrupts, or polling MAY occur inside a target-specific source,
but the source MUST enter the serialized application executor before invoking
the sink. Domain and Presentation contracts MUST NOT require asynchronous
sequences, task ownership, queues, locks, or cross-actor handoff.

Dynamic macOS MAY use the main actor. Static embedded targets MUST preserve the
same ordering and non-concurrency semantics through an available
single-threaded mechanism without requiring `MainActor` or `Task`.

## Rationale

The accepted input limit is small enough that a synchronous single-consumer
graph is easier to reason about and test than a general asynchronous pipeline.
It makes ordering and state mutation deterministic, avoids buffering and task
lifetime in portable contracts, and permits dynamic and static runtimes to use
different mechanisms while preserving one application behavior.

## Consequences

### Positive

- Each event has deterministic delivery and mutation ordering.
- Domain and Presentation remain independent of concurrency runtime features
  unavailable on the embedded path.
- Immediate current-value delivery gives Presentation a complete initial state
  without a separate query contract.
- Tests can assert delivery synchronously.

### Negative

- Slow repository or presentation work blocks later source delivery on the
  serialized executor.
- The contract supports only one consumer for capture and one for state.
- Interrupt- or task-based sources need an adapter before entering the graph.
- Future high-rate or multi-consumer applications may require a different
  architecture.

### Follow-up

- The Specification must define sink lifetime, reentrancy, start/stop ordering,
  immediate delivery, failure propagation, and stale-event suppression.
- Target integrations must identify their serialized executor mechanism.
- Tests must sustain 80 transition events per second while the UI renders at
  four frames per second.

## Rejected Alternatives

### Asynchronous sequences across every boundary

An `AsyncSequence` pipeline was rejected for the MVP because task lifetime,
continuation buffering, cancellation, actor handoff, and runtime dependencies
are unnecessary for the bounded single-consumer workload.

### Concurrent sink delivery

Concurrent delivery was rejected because it would require synchronization in
Domain and Presentation and make transition and state ordering
nondeterministic.

## References

- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
