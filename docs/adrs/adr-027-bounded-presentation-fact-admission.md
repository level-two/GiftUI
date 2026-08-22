---
id: ADR-027
feature: signal-analyzer
title: Bounded Presentation-Fact Admission
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-22
proposal:
  - PROPOSAL-002
  - PROPOSAL-005
related_rfcs:
  - RFC-001
  - RFC-004
  - RFC-008
related_adrs:
  - ADR-001
  - ADR-002
  - ADR-004
  - ADR-007
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-024
  - ADR-025
  - ADR-026
related_specs:
  - SPEC-001
related_future_work: []
related_explorations: []
related_spikes: []
supersedes:
  - ADR-002
superseded_by: []
target_milestone: MVP
---

# ADR-027: Bounded Presentation-Fact Admission

## Status

Accepted. Supersedes ADR-002.

## Context

ADR-002 places signal source, repository, use-case, and Presentation delivery
on one serialized application executor and currently requires synchronous
ViewModel mutation there. Observable GiftUI state, however, must mutate only
inside RFC-004's serialized mutation phase so derivation observes a frozen,
internally consistent revision. Direct application-executor mutation would
couple external producers to that phase and permit reentrant mutation when a
Button-triggered use case synchronously calls back.

## Decision Boundary

This record extracts RFC-008 Decision Summary item 4 and supersedes ADR-002.
It preserves ADR-002's synchronous single-consumer
application pipeline through a target-composed Presentation adapter while
replacing direct Presentation-model mutation with bounded immutable fact
admission. It does not redefine RFC-004 cycle ordering or the observable model
contract of ADR-024 through ADR-026.

## Decision

The Signal Analyzer application executor and GiftUI mutation domain MUST be
logically distinct serialization domains. Signal source, repository, use-case,
and repository sink delivery MUST remain synchronous and run to completion on
the application executor through a target-composed Presentation admission
adapter. The repository MUST retain one capture sink and one
acquisition-state sink with immediate current-value delivery, replacement,
and detachment semantics.

The admission adapter MUST copy or construct a bounded immutable Presentation
fact and submit it through RFC-004 admission. Returning from the synchronous
application callback means that the adapter returned an admission outcome; it
MUST NOT mean that the observable ViewModel has already changed. Only later
ordered application of an admitted fact during GiftUI's serialized mutation
phase MAY mutate the observable model.

Admission capacity, sequencing, and rejection MUST be explicit and bounded.
Saturation or rejection MUST NOT fall back to direct or reentrant ViewModel
mutation. External producers, repository sinks, and the adapter MUST NOT
attach semantic observers or use the model itself as a cross-domain queue.

A Button action MAY synchronously invoke a Signal Analyzer use case through
the target-composed application-executor contract. Any synchronous capture or
acquisition callback produced by that call MUST terminate at the admission
adapter and become a fact for a later GiftUI admission boundary; it MUST NOT
reenter the active cycle to mutate the ViewModel. Presentation-only action
effects MAY remain ordinary admitted model mutations in the GiftUI domain.

A host MAY realize both logical domains on one thread or cooperative event
loop, but co-location MUST NOT erase admission, phase ownership, or bounded
outcomes. Portable Domain and Presentation contracts MUST NOT require tasks,
async sequences, queues, locks, actors, or scheduler types.

## Rationale

The explicit fact boundary preserves the simple synchronous application graph
while giving GiftUI sole authority over observable mutation, freeze, and
publication. It accommodates callbacks, interrupts, timers, and hosts with
different execution mechanisms without leaking those mechanisms into portable
code. Bounded admission makes backpressure and one-cycle presentation latency
visible rather than permitting unsafe concurrent mutation.

## Consequences

### Positive

- Observable state cannot be mutated by external delivery during derivation.
- The source, repository, and use-case contracts remain synchronous and
  portable.
- Same-thread and distinct-executor hosts preserve the same phase semantics.
- Button-triggered synchronous callbacks cannot nest semantic mutation.

### Negative

- Successful application delivery no longer means immediate ViewModel
  mutation.
- The host must provision and handle bounded fact-admission capacity.
- Presentation may gain up to one admission-cycle of latency.
- SPEC-001 must return to review because its current direct sink-to-ViewModel
  mutation contract conforms to ADR-002.

### Follow-up

- ADR-002 has transitioned to `superseded`. SPEC-001 must be revised and
  approved again before implementation relies on the new boundary.
- The revised Specification must define fact types, capacities, admission
  outcomes, ordering, adapter ownership, executor entry, and Button callback
  behavior.
- Tests must cover immediate sink delivery into admission, saturation,
  same-thread co-location, later ordered application, and reentrant callbacks.

## Deferred and Follow-up Work

None. The bounded admission seam and Specification revision are required
consequences of this decision rather than deferred work.

## Rejected Alternatives

### One shared application and GiftUI serialization domain

Rejected because it couples external delivery to GiftUI mutation phases and
makes co-location an architectural requirement rather than a host choice.

### Direct ViewModel mutation followed by an observation report

Rejected because notification does not make an already-concurrent or frozen
mutation safe.

### Asynchronous sequences across all application boundaries

Rejected because task lifetime, cancellation, buffering, and actor handoff are
unnecessary for the bounded single-consumer workload and unavailable on some
targets.

### Admission rejection followed by direct-mutation fallback

Rejected because it silently abandons serialization and makes capacity
exhaustion change observable semantics.

## References

- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [ADR-002: Serialized Synchronous Acquisition Delivery](adr-002-serialized-synchronous-acquisition-delivery.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [SPEC-001: Signal Analyzer Reference Application](../specs/spec-001-signal-analyzer-reference-application.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
