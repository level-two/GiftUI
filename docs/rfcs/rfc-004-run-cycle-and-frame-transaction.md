---
id: RFC-004
feature: giftui-mvp-architecture
title: Run Cycle and Frame Transaction Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-17
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-005
  - RFC-006
  - RFC-007
related_adrs: []
related_specs: []
related_future_work:
  - FW-010
  - FW-011
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
    -> commit the logical frame or abort it
    -> admit asynchronous completion as later input
```

A frame carries a one-shot ordered operation stream that every first-party MVP
backend consumes synchronously. A backend may complete presentation
asynchronously only from its own derived presentation data; it may not retain
or replay the GiftUI operation stream. If any required phase fails before the
frame commit point, the frame aborts:
the previous committed logical frame remains authoritative, the failure is
reported, and no admitted client action is replayed. Semantic publication and
frame commit are distinct; aborting a frame does not roll back semantic state
that was already published.

This RFC defines ordering, observation, and payload lifetime. It does not
select the public observable-state mechanism, state-slot representation,
transaction journal, identifier widths, queue capacities, scheduler API,
backend retry policy, frame-rescheduling policy, or concrete backend commit
point. Backend/transport retry and future frame rescheduling are deferred by
FW-010 and FW-011 respectively.

## Context

RFC-002 assigns semantics, layout, rendering, backends, and integrations to
different owners but needs one execution boundary connecting them. The Signal
Analyzer may ingest up to 80 transitions per second while presenting about
four times per second, so input, invalidation, semantic evaluation, and frame
presentation cannot be treated as one callback or one-to-one event sequence.

The nRF52840 path needs direct operation streaming and cannot be required to
retain a full display list. All first-party MVP backends can consume the
ordered GiftUI operation stream synchronously. An integration may still finish
device presentation asynchronously after that consumption, but it owns any
derived pixel, transfer, or device data needed for the later completion. These
lifetime and presentation boundaries are architectural rather than
Specification detail.

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

An admitted semantic action MUST execute at most once. Frame abort, drop,
rejection, supersession, or presentation failure MUST NOT repeat action
dispatch, client side effects, reconciliation, or layout for that frame.

### R3 — Complete publication

External runtime observers MUST see only complete published semantic and
derived results, never a partially updated mixture. Semantic publication MAY
precede frame commit, but presentation-coupled routing and hit-test state MUST
remain staged until the corresponding logical frame commits. The separate
observable-state lifecycle determines how implementations satisfy the semantic
publication contract.

### R4 — Presentation is a separate outcome

Once a semantic revision is published, later presentation outcomes MUST NOT
roll it back. The frame derived from that revision is not committed until its
required presentation commit point succeeds. Failure before that point MUST
abort the frame and preserve the previous committed logical frame as
authoritative.

### R5 — Explicit frame provenance

Every frame MUST identify the semantic revision and presentation-relevant
resource state from which it was derived. Asynchronous attempts MUST have
stable bounded correlation until terminal disposition.

### R6 — One-shot operation consumption

The MVP frame contract MUST expose a synchronous one-shot ordered operation
stream. Every first-party MVP backend MUST consume that stream during the
`offer` call and MUST NOT retain or replay it after the call returns. An
integration that completes presentation asynchronously MUST own any derived
presentation data for the necessary lifetime; that data is not a retained
GiftUI operation stream.

### R7 — Bounded work and backpressure

Inputs, completions, frames, backend-owned presentation data, in-flight
attempts, and pending work MUST be bounded with deterministic overflow or
backpressure disposition.

### R8 — Ownership preservation

The runtime owns admission and semantic dispatch; layout remains backend-
neutral; backends consume normalized operations; integrations report facts.
No backend or callback may invoke client actions or replay semantic input.

### R9 — Profile-equivalent behavior

Static and dynamic profiles MAY fuse phases and use different storage, but
MUST preserve input membership, action ordering, publication boundaries,
frame provenance, payload lifetime, and presentation separation.

### R10 — Required frame abort

Every frame path MUST have a terminal commit or abort disposition. Abort MUST
discard unpublished frame-local results, retain the previous committed logical
frame and its presentation-coupled routing state as authoritative, report the
failure through RFC-005, and leave the runtime in a deterministic state. Core
MUST NOT automatically retry the frame transaction or require a later frame
opportunity.

## Constraints

- A cycle may publish no semantic change and may produce no frame.
- A cycle does not correspond one-to-one with a hardware refresh.
- Streaming presentation may make partial physical writes before terminal
  failure; the committed logical-frame guarantee does not claim physical
  rollback or atomic display hardware.
- External client side effects are not assumed reversible.
- Platform loops and interrupts may wake the runtime but do not decide cycle
  input membership.
- The common static path cannot require heap allocation, exceptions,
  reflection, unrestricted existentials, `Task`, or thread primitives.

## Proposed Design

### Failed-frame recovery boundary

This RFC separates three mechanisms that must not be conflated:

1. **Frame abort is required.** Any failure before the selected commit point
   terminates the frame without replacing the previous committed logical frame
   or its routing state.
2. **Backend/transport submission retry is deferred.** A future backend or
   delegated transport Service may use its device-specific knowledge and a
   future replayable operation representation or backend-owned stable payload
   to retry a recoverable transient submission failure. GiftUI Core neither
   performs nor mandates that policy; FW-010 owns both the required retention
   model and its future evaluation.
3. **Frame rescheduling is deferred.** A future runtime policy may preserve
   invalidation and produce a new frame during a later run-cycle opportunity.
   That is new semantic/layout/render work, not resubmission of the same
   payload; FW-011 owns its future evaluation.

Deterministic semantic evaluation, layout, invalid geometry, unsupported
capability, and render-generation failures are not candidates for automatic
retry. Given identical admitted inputs and state, repeating them would normally
repeat the failure and could create an unbounded loop.

### Wake scheduling and presentation synchronization

The target host MUST request serialized run cycles in response to pending work
or scheduled deadlines. Runtime execution MUST NOT require a continuously
ticking frame loop. Platform event loops, interrupts, and timer facilities may
request a wake, but they do not decide the membership of the cycle's sealed
input batch.

Backends MAY synchronize presentation with hardware refresh or transport
opportunities, but MUST NOT directly control semantic admission or evaluation.
A timer MAY provide a frame opportunity when no hardware synchronization
source exists; timer cadence alone does not establish tear-free presentation.
The Signal Analyzer's nominal 250-millisecond display interval is application
frame pacing rather than a claim about the physical display refresh rate.

Later Specifications define the concrete host wake API, coalescing and missed-
deadline policy, and target-specific presentation synchronization. These
profile-specific mechanisms MUST preserve the admission, ordering,
publication, and payload-lifetime boundaries defined by this RFC.

### Logical phases

One cycle has these observation points:

1. **Begin:** select cycle-stable configuration and bounded workspaces.
2. **Admit:** seal the ordered input batch.
3. **Evaluate:** dispatch admitted semantic actions and invalidations once.
4. **Reconcile and layout:** derive a complete next hierarchy and geometry.
5. **Prepare frame:** create a stable one-shot synchronous stream source.
6. **Publish semantics:** make the complete resulting semantic revision
   observable while keeping frame-derived routing and hit-test state staged.
7. **Offer:** submit the prepared frame to the selected backend.
8. **Commit or abort:** commit the logical frame at the backend contract's
   required success point together with its routing and hit-test state, or
   abort it while preserving the prior committed logical frame and routing
   state as authoritative.
9. **Finalize:** release cycle-local storage and record the cycle outcome.

Implementations may fuse phases but may not move the admission, publication,
or payload-lifetime boundaries. Asynchronous completion occurs after offer and
re-enters through a later sealed input batch.

### Frame ownership

The MVP frame's ordered operation stream is borrowed only for the synchronous
`offer` call and cannot be retained or replayed after the call returns. A
backend that accepts asynchronous presentation must finish consuming the
operation stream before returning and retain only its own derived pixel,
transfer, or device data through terminal disposition.

The frame envelope adds provenance and disposition to RFC-002's ordered
render-operation meaning rather than a second render IR. A replayable
operation representation is outside MVP scope and preserved by FW-010 only
when future retry requirements justify its storage and lifetime cost.

### Outcomes

The architecture distinguishes:

- semantic result: unchanged, published, or failed before publication;
- frame preparation: not needed, prepared, or failed;
- presentation: completed, accepted asynchronously, backpressured, rejected,
  dropped, superseded, or failed;
- logical frame disposition: committed or aborted.

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
| Presentation coordinator | Offer frames, correlate completion, and record logical-frame commit or abort | Client action dispatch, state rollback, retry policy, or automatic rescheduling |
| Backend/display/transport | Consume the operation stream synchronously, own any derived presentation data, define its required commit point, and report outcomes | Retaining or replaying the operation stream, cycle admission, semantic publication, or action replay |

## Public API Impact

Ordinary views do not receive cycle IDs, frame tokens, queues, or presentation
callbacks. Later Specifications define host-facing cycle invocation, frame
payload lifetime, outcomes, capacities, and integration SPI. Any public API
that permits client side effects must state when the effect occurs relative to
the semantic publication boundary.

## Capabilities Impact

RFC-006 decides whether completion mode or in-flight limits are Capabilities,
Traits, policy, or ordinary configuration. One-shot synchronous operation
consumption is the common MVP contract rather than a selectable capability.
Runtime device health and backpressure remain operational state, not silent
mutation of the capability declaration.

## Backend Impact

A first-party MVP backend must consume the ordered operation stream
synchronously during `offer`, must not retain or replay it, and must declare
what outcome satisfies the logical-frame commit point. If presentation remains
in flight after `offer`, the backend owns the derived presentation data and
reports exactly one terminal disposition asynchronously. It may not invoke
semantic code, cause semantic replay, or ask GiftUI Core to retry a frame.
Backend/transport retry and any replayable operation representation are not
MVP requirements and are preserved as future work in FW-010.

## Static / Embedded Impact

Static implementations may use fixed rings, caller-owned workspaces, direct
phase calls, and synchronous operation streaming. They do not need a retained
display list, replayable frame pool, or duplicate semantic graph. Exact
publication strategy belongs to the observable-state and runtime
Specifications and must be measured on nRF52840 before implementation approval.

## Performance

Required measurements include cycle phase duration, input/coalescing counts,
operation production, presentation latency, backpressure behavior, and the
80-transition/second plus 250-millisecond presentation workload. Transaction
metadata should remain constant-cost per cycle, frame, and attempt.

## Memory / Binary Size

Specifications account for input/completion queues, runtime and layout
workspace, frame envelopes, backend-owned presentation data, raster tiles,
in-flight slots, stack high-water, and specialization cost. A dynamic queue is
still configured and bounded; allocation is not permission for unlimited work.

## Alternatives

### Backend-owned frame loop

This integrates naturally with native event systems but lets backend timing
control input membership and semantic execution. It is suitable only when the
backend intentionally owns the entire semantic framework.

### Retain or replay every operation stream

Universal replay could simplify asynchronous ownership and later submission
retry, but it imposes RAM, copying, and a second bounded-capacity obligation on
every target. The MVP backends can consume operations synchronously and own
only any derived presentation data they need. Replayable operation storage is
therefore outside MVP scope and preserved by FW-010 for a future measured
retry requirement.

### Automatically run a failed frame again

This reuses the normal path but may repeat client actions and side effects,
turn deterministic computation failures into loops, and require scheduler
policy not justified by the MVP. Any later frame rescheduling is separate from
backend submission retry and is deferred by FW-011.

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
- Prove every admitted action executes at most once under presentation abort,
  failure, drop, and supersession.
- Compare static and dynamic semantic results, geometry, operation order, and
  frame provenance for the same sealed inputs.
- Verify every backend consumes the operation stream exactly once during
  `offer`, retains no operation or borrowed resource afterward, and keeps any
  backend-owned derived presentation data valid through terminal disposition.
- Inject failure before every frame commit point and verify the new frame
  aborts, unpublished frame-local work is discarded, the previous committed
  logical frame and routing state remain authoritative, and the failure is
  reported once.
- Stall and fault every backend boundary and verify configured bounds and one
  terminal outcome for accepted work.
- Keep host, cross-build, simulator, and connected-device evidence distinct.

## Risks

- Publication language may accidentally predetermine observable-state storage;
  keep its mechanism in that feature lifecycle.
- Dynamic implementations may hide unbounded work behind tasks or references;
  conformance must enforce configured bounds.
- Streaming may leave a display partially updated; a later full redraw or
  reset is not implied by frame abort and requires separate presentation or
  rescheduling policy.
- RFC-005 or RFC-006 may classify shared facts differently; reconcile terms
  before any coordinated RFC advances.
- Future retry work may accidentally reintroduce universal frame retention;
  FW-010 must justify its retention scope and bounds before coordinated RFC
  revision.

## Open Questions

1. What minimum presentation-success boundary can every first-party path state
   without claiming physical display evidence it cannot observe?
2. Can the future observable-state contract provide complete publication
   semantics on both runtime profiles without requiring general reversible
   client state or duplicating the entire graph?

Identifier widths, queue and payload capacities, timing budgets, and concrete
backend commit points are Specification inputs once these architectural
questions are resolved.

## Deferred and Follow-up Work

- [FW-010: Backend and Transport Submission Retry](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves optional retry of an already-produced frame payload at the
  backend/transport boundary. It is excessive for MVP; revisit when a supported
  backend demonstrates recoverable transient submission failures that aborting
  and reporting alone cannot handle acceptably.
- [FW-011: Failed-Frame Rescheduling](../future-work/fw-011-failed-frame-rescheduling.md)
  preserves the possibility of keeping invalidation pending and offering a new
  frame on a later run-cycle iteration. It is not a tight retry loop and is not
  required by the MVP transaction guarantee; revisit when a supported host or
  reference flow requires recovery without a new external invalidation.

Animation transactions, lossless presentation, remote acknowledgement, and
persistent frame capture remain outside current MVP scope. They require a
concrete accepted need or deferred artifact before work begins. Observable
reference-state architecture remains a separate required feature lifecycle
rather than a hidden sub-decision of this RFC.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. sealed run-cycle admission with at-most-once semantic action execution and
   complete publication boundaries;
2. semantic publication independent from presentation outcome;
3. required frame commit-or-abort semantics that preserve the prior committed
   logical frame after pre-commit failure without automatic retry or
   rescheduling;
4. one frame-envelope model whose ordered operations are consumed once during
   a synchronous backend offer, with explicit terminal disposition and no MVP
   replayable-operation requirement.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [FW-010: Backend and Transport Submission Retry](../future-work/fw-010-backend-transport-submission-retry.md)
- [FW-011: Failed-Frame Rescheduling](../future-work/fw-011-failed-frame-rescheduling.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
