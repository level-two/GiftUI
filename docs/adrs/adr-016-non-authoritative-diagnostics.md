---
id: ADR-016
feature: giftui-mvp-architecture
title: Non-Authoritative Diagnostic Projection
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-010
  - ADR-014
  - ADR-015
  - ADR-017
related_specs: []
related_future_work:
  - FW-009
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-016: Non-Authoritative Diagnostic Projection

## Status

Accepted.

## Context

Dynamic hosts may want rich logging while static production firmware may omit
most diagnostics. Correctness cannot depend on whether a record was created,
filtered, buffered, delivered, or lost, and current operational health cannot
be reconstructed reliably from a lossy event history.

## Decision Boundary

This record extracts the diagnostic portion of RFC-005 Decision Summary item
3. It owns optional non-authoritative projection and the prohibition on using
diagnostic paths for semantic control. It does not define typed outcome
meaning (ADR-014), failure disposition (ADR-015), capability versus health
classification (ADR-017), or post-handoff frame responsibility (ADR-010).

## Decision

Diagnostics MUST be optional bounded projections derived from outcomes and
health transitions. They MAY be selected before construction, filtered,
discarded, buffered, streamed, counted, symbolized, or omitted. Diagnostic
presence, severity, loss, saturation, or sink failure MUST NOT alter typed
outcome propagation, explicit operational health, semantic state, capability
results, frame disposition, or failure policy.

Any approved asynchronous outcome allowed to affect Core MUST enter through
its own bounded sequenced admission contract. A diagnostic sink, callback,
interrupt, backend, or driver MUST NOT mutate semantic state or invoke client
actions.

Post-handoff presentation failures remain operational state under ADR-010 and
ADR-017; this ADR only permits their optional observation.

## Rationale

Separating observation from correctness permits inexpensive static builds and
rich debug targets to share identical behavior. Explicit health remains queryable
even when diagnostic events are dropped.

## Consequences

### Positive

- Diagnostics can be compiled out or bounded without changing behavior.
- Different projection volumes remain conformance-equivalent.
- Asynchronous observation cannot become an implicit control path.

### Negative

- Outcome and health storage must exist independently of logs.
- Tooling cannot assume a complete diagnostic history.

### Follow-up

- Specifications must define selectable categories, bounded records, sinks,
  saturation, correlation, and asynchronous admission where approved.

## Deferred and Follow-up Work

- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  preserves a possible shared diagnostic Service; MVP requires only a narrow
  consumer-specific observation seam.

## Rejected Alternatives

### Diagnostics as control flow

Rejected because correctness would depend on optional observation.

### Global error callback

Rejected because it leaves ordering, lifetime, reentrancy, and transaction
position ambiguous.

### Mandatory critical-only or all-event stream

Rejected because neither projection policy fits every target, and severity is
not the portable safety or disposition model.

## References

- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
