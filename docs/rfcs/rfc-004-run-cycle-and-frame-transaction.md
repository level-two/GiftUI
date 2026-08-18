---
id: RFC-004
feature: giftui-mvp-architecture
title: Run Cycle and Frame Transaction Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-18
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
    -> offer the frame for synchronous handoff
    -> commit on complete backend acceptance or abort on refusal
    -> let the backend advance presentation in its own bounded domain
```

A frame carries a one-shot ordered operation stream that every first-party MVP
backend consumes synchronously. The logical frame commits when the backend has
consumed the complete stream, reserved bounded downstream capacity, accepted
responsibility for ordered presentation, and returned success from `offer`.
The backend may advance presentation asynchronously only from its own derived
presentation data; it may not retain or replay the GiftUI operation stream.
Device, transport, compositor, or physical-display outcomes after this handoff
belong to the backend/integration's operational domain and do not abort or roll
back the committed logical frame.

If any required phase fails or the backend refuses the handoff, the frame
aborts: the previous committed logical frame remains authoritative, the
failure is reported, and no admitted client action is replayed. Semantic
publication and frame commit are distinct; aborting a frame does not roll back
semantic state that was already published.

This RFC defines ordering, observation, and payload lifetime. It does not
select the public observable-state mechanism, state-slot representation,
transaction journal, identifier widths, queue capacities, scheduler API,
backend operational retry policy, or pre-handoff frame-rescheduling policy.
Backend/transport recovery after accepted handoff and future rescheduling after
pre-handoff abort are deferred by FW-010 and FW-011 respectively.

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
derived pixel, transfer, or device data needed for the later work. It also owns
coordination with presentation-coupled input: it must not admit physical input
known to belong to a stale or unavailable presentation. These lifetime,
handoff, and input-coherence boundaries are architectural rather than
Specification detail.

Observable reference-state invalidation requires its own feature lifecycle
under MVP Scope. This RFC may require an observable publication boundary, but
it MUST NOT select that feature's storage, observation, rollback, or public API
architecture.

## Requirements

### R1 — Sealed deterministic admission

Each run cycle MUST seal an ordered, bounded input batch before semantic
evaluation. Reentrant input and other runtime-relevant asynchronous facts
arriving after the seal MUST be deferred to a later admission boundary.

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

### R4 — Logical commit occurs at accepted handoff

Once a semantic revision is published, later presentation outcomes MUST NOT
roll it back. The frame derived from that revision commits when `offer`
successfully transfers the complete frame into bounded backend-owned state and
the backend accepts responsibility for ordered downstream presentation.
Failure or refusal before that handoff MUST abort the frame and preserve the
previous committed logical frame as authoritative. Operational failure after
accepted handoff MUST NOT change the frame's committed disposition.

### R5 — Explicit frame provenance

Every frame MUST identify the semantic revision and presentation-relevant
resource state from which it was derived. Backend-owned downstream work MAY
retain that provenance for local ordering, health, diagnostics, and input
gating, but Core does not require a post-handoff attempt lifecycle.

### R6 — One-shot operation consumption

The MVP frame contract MUST expose a synchronous one-shot ordered operation
stream. During `offer`, every first-party MVP backend MUST either consume the
complete stream, reserve bounded downstream capacity, retain only its own
derived presentation data, and accept the handoff; or refuse the handoff and
retain no frame data or borrowed resource. It MUST NOT retain or replay the
GiftUI operation stream after the call returns.

### R7 — Bounded work and backpressure

Inputs, frames, backend-owned presentation data, downstream work, and pending
work MUST be bounded with deterministic overflow or backpressure disposition.
Capacity needed to honor an accepted handoff MUST be reserved before `offer`
returns success.

### R8 — Ownership preservation

The runtime owns admission and semantic dispatch; layout remains backend-
neutral; backends consume normalized operations; integrations own downstream
presentation health and presentation-coupled input gating. No backend or
callback may invoke client actions or replay semantic input. Post-handoff
operational facts MAY feed backend-local recovery or optional diagnostics but
MUST NOT mutate Core's logical-frame disposition.

### R9 — Profile-equivalent behavior

Static and dynamic profiles MAY fuse phases and use different storage, but
MUST preserve input membership, action ordering, publication boundaries,
frame provenance, payload lifetime, and presentation separation.

### R10 — Required handoff disposition

Every frame path MUST synchronously commit or abort at `offer`. Accepted
handoff MUST atomically commit the logical frame and its presentation-coupled
routing state. Abort MUST discard unpublished frame-local results, retain the
previous committed logical frame and routing state as authoritative, report
the pre-handoff failure through RFC-005, and leave the runtime in a
deterministic state. Core MUST NOT automatically retry the frame transaction
or require a later frame opportunity.

## Constraints

- A cycle may publish no semantic change and may produce no frame.
- A cycle does not correspond one-to-one with a hardware refresh.
- An attempted streaming handoff may make partial physical writes before
  synchronous refusal; abort preserves logical state but cannot physically
  roll those writes back.
- After accepted handoff, streaming presentation may be delayed, partially
  written, or fail; logical commit does not claim physical visibility, physical
  rollback, or atomic display hardware.
- A target whose presentation and input share a physical user experience must
  coordinate them below Core so input known to target a stale, unavailable, or
  not-yet-eligible presentation is not admitted as current GiftUI input.
- External client side effects are not assumed reversible.
- Platform loops and interrupts may wake the runtime but do not decide cycle
  input membership.
- The common static path cannot require heap allocation, exceptions,
  reflection, unrestricted existentials, `Task`, or thread primitives.

## Proposed Design

### Handoff and operational-recovery boundary

This RFC separates four mechanisms that must not be conflated:

1. **Pre-handoff abort is required.** Preparation failure, insufficient
   capacity, unsupported input, or backend refusal terminates the frame without
   replacing the previous committed logical frame or its routing state.
2. **Accepted handoff is the logical commit point.** Successful `offer` means
   the backend consumed the entire stream, owns all later presentation data,
   reserved bounded capacity, and accepted ordered downstream responsibility.
   Later operational failure does not reopen the frame transaction.
3. **Backend/transport recovery is deferred.** A future backend or delegated
   transport Service may use device-specific knowledge and backend-owned stable
   data to retry or repair downstream presentation after handoff. GiftUI Core
   neither observes nor mandates that policy; FW-010 owns its future
   evaluation. Replaying GiftUI operations remains outside the MVP contract.
4. **Pre-handoff frame rescheduling is deferred.** A future runtime policy may
   preserve invalidation after an aborted handoff and produce a new frame
   during a later run-cycle opportunity. That is new semantic/layout/render
   work; FW-011 owns its future evaluation.

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
8. **Commit or abort:** if `offer` accepted the complete handoff, commit the
   logical frame together with its routing and hit-test state; otherwise abort
   it while preserving the prior committed logical frame and routing state as
   authoritative.
9. **Finalize:** release cycle-local storage and record the cycle outcome.

Implementations may fuse phases but may not move the admission, publication,
handoff, or payload-lifetime boundaries. Backend-local asynchronous work after
accepted handoff does not re-enter Core to alter frame disposition.

### Frame ownership

The MVP frame's ordered operation stream is borrowed only for the synchronous
`offer` call and cannot be retained or replayed after the call returns. A
backend that continues asynchronously must finish consuming the operation
stream and reserve its bounded downstream slot before returning success. It
retains only its own derived pixel, transfer, or device data for the locally
required lifetime.

The frame envelope adds provenance and disposition to RFC-002's ordered
render-operation meaning rather than a second render IR. A replayable
operation representation is outside MVP scope and preserved by FW-010 only
when future retry requirements justify its storage and lifetime cost.

### Outcomes

The architecture distinguishes:

- semantic result: unchanged, published, or failed before publication;
- frame preparation: not needed, prepared, or failed;
- handoff: accepted, backpressured, rejected, or failed before acceptance;
- logical frame disposition: committed or aborted.

Post-handoff presentation progress, transport failure, device health, retry,
and abandonment are backend/integration operational state rather than further
GiftUI frame dispositions. Optional diagnostics may preserve frame provenance
without acquiring control-flow authority.

Exact value types and policy defaults belong in Specifications. RFC-005 owns
pre-handoff cross-layer failure meaning and optional post-handoff diagnostic
observation; RFC-006 owns whether payload and handoff facts participate in
capability resolution.

## Module Responsibilities

| Owner | Responsibility | Must not own |
| --- | --- | --- |
| Target host | Invoke cycles and assemble bounded policy and adapters | Semantic input membership after admission begins |
| Semantic runtime | Seal input, dispatch actions once, coordinate phases, publish complete results | Concrete backend or platform mechanics |
| Observable-state feature | Define state observation and publication implementation contract | Presentation retry policy |
| Layout/render producer | Produce complete geometry and ordered payload from cycle-stable inputs | Backend health or semantic replay |
| Presentation coordinator | Offer frames and record synchronous handoff commit or abort | Client action dispatch, state rollback, downstream recovery policy, or automatic rescheduling |
| Backend/display/transport integration | Consume the operation stream synchronously, reserve capacity before acceptance, own derived presentation data and downstream health, preserve presentation/input coherence, and optionally report diagnostics | Retaining or replaying the GiftUI operation stream, cycle admission, semantic publication, or action replay |

## Public API Impact

Ordinary views do not receive cycle IDs, frame tokens, queues, or presentation
callbacks. Later Specifications define host-facing cycle invocation, frame
payload lifetime, outcomes, capacities, and integration SPI. Any public API
that permits client side effects must state when the effect occurs relative to
the semantic publication boundary.

## Capabilities Impact

RFC-006 decides whether handoff form or backend-owned capacity limits are
Capabilities, Traits, policy, or ordinary configuration. One-shot synchronous
operation consumption and synchronous handoff disposition are the common MVP
contract rather than selectable capabilities. Runtime device health and
post-handoff recovery remain operational state, not silent mutation of the
capability declaration.

## Backend Impact

A first-party MVP backend must consume the ordered operation stream
synchronously during `offer` and must not retain or replay it. It may return
success only after consuming the complete stream, validating it, reserving
bounded downstream capacity, and owning any derived data needed after return.
Otherwise it returns a synchronous refusal and retains nothing from the frame.

After accepted handoff, the backend/integration owns presentation ordering,
device and transport health, derived-data lifetime, and coordination with its
physical input path. It must suppress or defer input known to target a stale,
unavailable, or not-yet-eligible physical presentation rather than exporting
that hardware condition into GiftUI semantic routing. It may emit optional
operational diagnostics, but it may not invoke semantic code, change the
committed logical-frame disposition, cause semantic replay, or ask GiftUI Core
to retry a frame. Backend/transport recovery and any replayable operation
representation are not MVP requirements and are preserved by FW-010.

## Static / Embedded Impact

Static implementations may use fixed rings, caller-owned workspaces, direct
phase calls, and synchronous operation streaming. They do not need a retained
display list, replayable frame pool, or duplicate semantic graph. Exact
publication strategy belongs to the observable-state and runtime
Specifications and must be measured on nRF52840 before implementation approval.

## Performance

Required measurements include cycle phase duration, input/coalescing counts,
operation production, handoff latency, backend presentation latency,
presentation/input gating, backpressure behavior, and the
80-transition/second plus 250-millisecond presentation workload. Transaction
metadata should remain constant-cost per cycle and frame; backend-local
downstream metadata should remain constant-cost per accepted slot.

## Memory / Binary Size

Specifications account for input queues, runtime and layout workspace, frame
envelopes, backend-owned presentation data, downstream slots, raster tiles,
input-gating state, stack high-water, and specialization cost. A dynamic queue
is still configured and bounded; allocation is not permission for unlimited
work.

## Alternatives

### Backend-owned frame loop

This integrates naturally with native event systems but lets backend timing
control input membership and semantic execution. It is suitable only when the
backend intentionally owns the entire semantic framework.

### Retain or replay every operation stream

Universal replay could simplify asynchronous ownership and later downstream
recovery, but it imposes RAM, copying, and a second bounded-capacity obligation
on every target. The MVP backends can consume operations synchronously and own
only any derived presentation data they need. Replayable operation storage is
therefore outside MVP scope and preserved by FW-010 for a future measured
recovery requirement.

### Automatically run a failed frame again

This reuses the normal path but may repeat client actions and side effects,
turn deterministic computation failures into loops, and require scheduler
policy not justified by the MVP. Any later pre-handoff frame rescheduling is
separate from backend-local post-handoff recovery and is deferred by FW-011.

### Couple semantic commit to physical presentation

This appears atomic on a reliable synchronous display but blocks application
progress on unavailable or asynchronous hardware and cannot generally roll
back external effects.

### Wait for the furthest observable presentation completion

This keeps logical routing aligned with stronger backend evidence when a
display, transport, compositor, or remote peer reports completion. The
observable point has materially different strength across framebuffer, UART,
SPI, remote, and GPU paths, however, and some paths cannot report physical
visibility at all. Waiting also exports device latency and failure into the
common frame transaction even though published semantic state cannot be rolled
back. The proposed handoff boundary instead keeps that coordination inside the
presentation/input integration that can interpret it.

## Rejected Approaches

No approach is formally rejected while this RFC remains `draft`. Review must
choose the admission, publication, and frame-lifetime model before ADR
extraction.

## Compatibility

Ordinary portable view syntax should not change. Host, runtime, and backend
APIs that conflate invalidation with immediate drawing, retain unbounded work,
or describe accepted handoff as proven physical presentation will require
migration. No stable frame ABI or persistent serialized format is proposed.

## Testing Strategy

- Inject input during every phase and verify later admission.
- Prove every admitted action executes at most once under preparation failure,
  handoff refusal, downstream presentation failure, drop, and supersession.
- Compare static and dynamic semantic results, geometry, operation order, and
  frame provenance for the same sealed inputs.
- Verify every backend accepts only after consuming the complete operation
  stream and reserving bounded downstream capacity, retains no operation or
  borrowed resource afterward, and keeps backend-owned derived presentation
  data valid for its local lifetime.
- Inject failure before and during `offer`; verify refusal retains nothing, the
  candidate frame aborts, and the previous logical frame and routing state
  remain authoritative.
- Inject failure after accepted handoff; verify the logical frame and routing
  remain committed, Core performs no replay or retry, and optional diagnostics
  do not acquire control-flow authority.
- Delay, partially complete, and fail downstream presentation while injecting
  physical input; verify the target integration does not admit input known to
  belong to a stale, unavailable, or not-yet-eligible presentation.
- Saturate every backend-owned downstream slot and verify `offer` applies
  deterministic backpressure before acceptance.
- Keep host, cross-build, simulator, and connected-device evidence distinct.

## Risks

- Publication language may accidentally predetermine observable-state storage;
  keep its mechanism in that feature lifecycle.
- Dynamic implementations may hide unbounded work behind tasks or references;
  conformance must enforce configured bounds.
- Accepted streaming presentation may leave a display delayed or partially
  updated while Core has committed newer routing; conformance therefore
  depends on target-local presentation/input gating and explicit bounded
  recovery behavior.
- A target unable to determine whether input corresponds to an eligible
  presentation cannot claim safe presentation-coupled input merely because
  `offer` succeeded.
- RFC-005 or RFC-006 may classify shared facts differently; reconcile terms
  before any coordinated RFC advances.
- Future retry work may accidentally reintroduce universal frame retention;
  FW-010 must justify its retention scope and bounds before coordinated RFC
  revision.

## Open Questions

1. Can the future observable-state contract provide complete publication
   semantics on both runtime profiles without requiring general reversible
   client state or duplicating the entire graph?

Identifier widths, queue and payload capacities, timing budgets, concrete
handoff result types, and target-local input-gating mechanisms are
Specification inputs once this architectural question is resolved.

## Deferred and Follow-up Work

- [FW-010: Backend and Transport Post-Handoff Recovery](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves optional backend-local recovery using already-owned derived frame
  data after accepted handoff. It is excessive for MVP; revisit when a
  supported backend demonstrates a measured availability requirement that
  simple bounded abandonment or repair cannot handle acceptably.
- [FW-011: Pre-Handoff Aborted-Frame Rescheduling](../future-work/fw-011-failed-frame-rescheduling.md)
  preserves the possibility of keeping invalidation pending after pre-handoff
  abort and offering a new frame on a later run-cycle iteration. It is not a
  tight retry loop and is not required by the MVP transaction guarantee;
  revisit when a supported host or reference flow requires recovery without a
  new external invalidation.

Animation transactions, lossless presentation, upper-layer remote
acknowledgement, and persistent frame capture remain outside current MVP scope.
Target-local acknowledgement MAY be used to coordinate a remote display with
its input path without changing the GiftUI handoff boundary. Broader work
requires a concrete accepted need or deferred artifact. Observable reference-
state architecture remains a separate required feature lifecycle rather than a
hidden sub-decision of this RFC.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. sealed run-cycle admission with at-most-once semantic action execution and
   complete publication boundaries;
2. semantic publication independent from presentation outcome;
3. synchronous handoff commit-or-abort semantics: complete accepted backend
   ownership commits the logical frame and routing, while refusal preserves the
   prior committed frame without automatic retry or rescheduling;
4. one frame-envelope model whose ordered operations are consumed once during
   a synchronous backend offer, with backend-owned post-handoff presentation
   health and no MVP replayable-operation or asynchronous Core completion
   requirement.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [FW-010: Backend and Transport Post-Handoff Recovery](../future-work/fw-010-backend-transport-submission-retry.md)
- [FW-011: Pre-Handoff Aborted-Frame Rescheduling](../future-work/fw-011-failed-frame-rescheduling.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
