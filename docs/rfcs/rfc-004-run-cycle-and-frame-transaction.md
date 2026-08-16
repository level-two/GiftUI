---
id: RFC-004
feature: giftui-mvp-architecture
title: Run Cycle and Frame Transaction Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-16
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-005
  - RFC-006
  - RFC-007
related_adrs: []
related_specs: []
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-004: Run Cycle and Frame Transaction Architecture

## Summary

This RFC is the independently reviewable execution-boundary decision cluster
under PROPOSAL-003. It proposes a serialized, bounded run cycle that seals
inputs before semantic work and separates at-most-once semantic effects from
frame presentation outcomes.

```text
seal input
    -> apply semantic work once
    -> reconcile and layout
    -> prepare frame payload
    -> publish the resulting semantic revision
    -> offer presentation
    -> admit asynchronous completion as later input
```

A frame may carry replayable bounded storage or a one-shot synchronous stream.
Presentation failure, retry, drop, or supersession never replays an admitted
client action or rolls back a published semantic revision.

This RFC defines ordering, observation, and payload lifetime. It does not
select the public observable-state mechanism, state-slot representation,
transaction journal, identifier widths, queue capacities, retry counts,
scheduler API, or backend-specific success point.

## Context

RFC-002 assigns semantics, layout, rendering, backends, and integrations to
different owners but needs one execution boundary connecting them. The Signal
Analyzer may ingest up to 80 transitions per second while presenting about
four times per second, so input, invalidation, semantic evaluation, and frame
presentation cannot be treated as one callback or one-to-one event sequence.

The nRF52840 path may need direct operation streaming and cannot be required to
retain a full display list. Dynamic backends may accept asynchronous work and
need stable payload ownership. These alternatives make frame lifetime and
presentation semantics architectural rather than Specification detail.

Observable reference-state invalidation requires its own feature lifecycle
under MVP Scope. This RFC may require an observable publication boundary, but
it MUST NOT select that feature's storage, observation, rollback, or public API
architecture.

## Requirements

### R1 — Sealed deterministic admission

Each run cycle MUST seal an ordered, bounded input batch before semantic
evaluation. Reentrant input and asynchronous completions arriving after the
seal MUST be deferred to a later admission boundary.

### R2 — At-most-once semantic effects

An admitted semantic action MUST execute at most once. Frame retry, drop,
rejection, supersession, or presentation failure MUST NOT repeat action
dispatch, client side effects, reconciliation, or layout for that frame.

### R3 — Complete publication

External runtime observers MUST see only complete published semantic and
derived results, never a partially updated mixture. The separate observable-
state lifecycle determines how implementations satisfy this contract.

### R4 — Presentation is a separate outcome

Once a semantic revision is published, later presentation outcomes MUST NOT
roll it back. A new evaluation after failure creates new work; it is not a
retry of the prior semantic transaction.

### R5 — Explicit frame provenance

Every frame MUST identify the semantic revision and presentation-relevant
resource state from which it was derived. Asynchronous attempts MUST have
stable bounded correlation until terminal disposition.

### R6 — Streaming and replayable payloads

The frame contract MUST support a synchronous one-shot ordered stream and a
bounded replayable payload. A consumer that retains or retries a payload MUST
own replayable storage for the necessary lifetime.

### R7 — Bounded work and backpressure

Inputs, completions, frames, retained payloads, in-flight attempts, pending
work, and retries MUST be bounded with deterministic overflow or backpressure
disposition.

### R8 — Ownership preservation

The runtime owns admission and semantic dispatch; layout remains backend-
neutral; backends consume normalized operations; integrations report facts.
No backend or callback may invoke client actions or replay semantic input.

### R9 — Profile-equivalent behavior

Static and dynamic profiles MAY fuse phases and use different storage, but
MUST preserve input membership, action ordering, publication boundaries,
frame provenance, payload lifetime, and presentation separation.

## Constraints

- A cycle may publish no semantic change and may produce no frame.
- A cycle does not correspond one-to-one with a hardware refresh.
- Streaming presentation may make partial physical writes before terminal
  failure; software state is not a distributed transaction with the display.
- External client side effects are not assumed reversible.
- Platform loops and interrupts may wake the runtime but do not decide cycle
  input membership.
- The common static path cannot require heap allocation, exceptions,
  reflection, unrestricted existentials, `Task`, or thread primitives.

## Proposed Design

### Logical phases

One cycle has these observation points:

1. **Begin:** select cycle-stable configuration and bounded workspaces.
2. **Admit:** seal the ordered input batch.
3. **Evaluate:** dispatch admitted semantic actions and invalidations once.
4. **Reconcile and layout:** derive a complete next hierarchy and geometry.
5. **Prepare frame:** create replayable payload ownership or a stable
   synchronous stream source.
6. **Publish:** make the complete resulting semantic revision and derived
   routing state observable.
7. **Offer:** submit the prepared frame under bounded presentation policy.
8. **Finalize:** release cycle-local storage and record the cycle outcome.

Implementations may fuse phases but may not move the admission, publication,
or payload-lifetime boundaries. Asynchronous completion occurs after offer and
re-enters through a later sealed input batch.

### Frame ownership

- A **streaming frame** is borrowed only for the synchronous `offer` call. It
  cannot be retained or retried after the call returns.
- A **replayable frame** owns or references stable storage through its terminal
  disposition and may support bounded retry without semantic reevaluation.

Both forms carry the same ordered render-operation meaning from RFC-002. The
frame envelope adds provenance, ownership, and disposition rather than a
second render IR.

### Outcomes

The architecture distinguishes:

- semantic result: unchanged, published, or failed before publication;
- frame preparation: not needed, prepared, or failed;
- presentation: completed, accepted asynchronously, backpressured, rejected,
  dropped, superseded, or failed.

Exact value types and policy defaults belong in Specifications. RFC-005 owns
cross-layer failure meaning; RFC-006 owns whether payload and completion facts
participate in capability resolution.

## Module Responsibilities

| Owner | Responsibility | Must not own |
| --- | --- | --- |
| Target host | Invoke cycles and assemble bounded policy and adapters | Semantic input membership after admission begins |
| Semantic runtime | Seal input, dispatch actions once, coordinate phases, publish complete results | Concrete backend or platform mechanics |
| Observable-state feature | Define state observation and publication implementation contract | Presentation retry policy |
| Layout/render producer | Produce complete geometry and ordered payload from cycle-stable inputs | Backend completion or semantic replay |
| Presentation coordinator | Offer frames, apply bounded drop/retry policy, correlate completion | Client action dispatch or state rollback |
| Backend/display/transport | Consume or retain payload under declared lifetime and report outcomes | Cycle admission, semantic publication, or action replay |

## Public API Impact

Ordinary views do not receive cycle IDs, frame tokens, queues, or presentation
callbacks. Later Specifications define host-facing cycle invocation, frame
payload lifetime, outcomes, capacities, and integration SPI. Any public API
that permits client side effects must state when the effect occurs relative to
the semantic publication boundary.

## Capabilities Impact

RFC-006 decides whether streaming support, replayable capacity, completion
mode, or in-flight limits are Capabilities, Traits, policy, or ordinary
configuration. Runtime device health and backpressure remain operational
state, not silent mutation of the capability declaration.

## Backend Impact

A backend must declare whether it consumes synchronously or accepts stable
replayable ownership, what its observable presentation-success boundary is,
and how accepted asynchronous work reaches one terminal disposition. It may
not retain a streaming payload, invoke semantic code, or cause semantic replay.

## Static / Embedded Impact

Static implementations may use fixed rings, caller-owned workspaces, direct
phase calls, synchronous operation streaming, and optional fixed frame pools.
They do not need a retained display list or duplicate semantic graph. Exact
publication strategy belongs to the observable-state and runtime
Specifications and must be measured on nRF52840 before implementation approval.

## Performance

Required measurements include cycle phase duration, input/coalescing counts,
operation production, presentation latency, backpressure behavior, and the
80-transition/second plus 250-millisecond presentation workload. Transaction
metadata should remain constant-cost per cycle, frame, and attempt.

## Memory / Binary Size

Specifications account for input/completion queues, runtime and layout
workspace, frame envelopes, replayable payloads where selected, raster tiles,
in-flight slots, stack high-water, and specialization cost. A dynamic queue is
still configured and bounded; allocation is not permission for unlimited work.

## Alternatives

### Backend-owned frame loop

This integrates naturally with native event systems but lets backend timing
control input membership and semantic execution. It is suitable only when the
backend intentionally owns the entire semantic framework.

### Retain every frame

Universal replay simplifies asynchronous presentation and retry but imposes
RAM and copy cost on embedded targets. It remains a configuration choice, not
the common requirement.

### Stream every frame

Universal streaming minimizes storage but cannot support asynchronous
ownership or retry. It remains a valid realization, not the whole contract.

### Retry by running semantics again

This reuses the normal path but may repeat client actions and side effects. A
new cycle may produce a replacement frame; it is not retry of the old frame.

### Couple semantic commit to physical presentation

This appears atomic on a reliable synchronous display but blocks application
progress on unavailable or asynchronous hardware and cannot generally roll
back external effects.

## Rejected Approaches

No approach is formally rejected while this RFC remains `draft`. Review must
choose the admission, publication, and frame-lifetime model before ADR
extraction.

## Compatibility

Ordinary portable view syntax should not change. Host, runtime, and backend
APIs that conflate invalidation with immediate drawing, retain unbounded work,
or report submission as physical presentation will require migration. No
stable frame ABI or persistent serialized format is proposed.

## Testing Strategy

- Inject input during every phase and verify later admission.
- Prove every admitted action executes at most once under presentation retry,
  failure, drop, and supersession.
- Compare static and dynamic semantic results, geometry, operation order, and
  frame provenance for the same sealed inputs.
- Verify streaming payloads are not retained and replayable payloads remain
  valid through terminal disposition.
- Stall and fault every backend boundary and verify configured bounds and one
  terminal outcome for accepted work.
- Keep host, cross-build, simulator, and connected-device evidence distinct.

## Risks

- Publication language may accidentally predetermine observable-state storage;
  keep its mechanism in that feature lifecycle.
- Dynamic implementations may hide unbounded work behind tasks or references;
  conformance must enforce configured bounds.
- Streaming may leave a display partially updated; a later full redraw or
  reset is presentation policy, not semantic rollback.
- RFC-005 or RFC-006 may classify shared facts differently; reconcile terms
  before any coordinated RFC advances.

## Open Questions

1. Do the first-party MVP backends require only synchronous streaming and
   replayable payloads, or is another ownership mode architecturally necessary?
2. What minimum presentation-success boundary can every first-party path state
   without claiming physical display evidence it cannot observe?
3. Can the future observable-state contract provide complete publication
   semantics on both runtime profiles without requiring general reversible
   client state or duplicating the entire graph?

Identifier widths, queue and payload capacities, retry counts, timing budgets,
and concrete backend success points are Specification inputs once these
architectural questions are resolved.

## Deferred and Follow-up Work

Animation transactions, lossless presentation, remote acknowledgement,
persistent frame capture, and a general scheduler remain outside current MVP
scope. They require a concrete accepted need or deferred artifact before work
begins. Observable reference-state architecture remains a separate required
feature lifecycle rather than a hidden sub-decision of this RFC.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. sealed run-cycle admission with at-most-once semantic action execution and
   complete publication boundaries;
2. semantic publication independent from presentation outcome;
3. one frame envelope model supporting bounded replayable ownership and
   one-shot synchronous streaming with explicit terminal disposition.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
