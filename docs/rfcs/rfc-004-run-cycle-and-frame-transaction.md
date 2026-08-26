---
id: RFC-004
feature: giftui-mvp-architecture
title: Run Cycle and Frame Transaction Architecture
status: approved
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-005
  - RFC-006
  - RFC-007
related_adrs:
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-013
  - ADR-015
  - ADR-020
  - ADR-022
related_specs:
  - SPEC-002
  - SPEC-004
  - SPEC-005
  - SPEC-006
  - SPEC-009
  - SPEC-010
  - SPEC-011
related_future_work:
  - FW-010
  - FW-011
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
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
seal input and state-change facts
    -> apply the sealed mutation and action batch once
    -> freeze observable state for derivation
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

If any required phase fails or the backend refuses the handoff before making
an irreversible presentation effect, the frame aborts: the previous committed
logical frame remains authoritative, the failure is reported, and no admitted
client action is replayed. Once a backend begins irreversible output,
responsibility has transferred and the handoff outcome MUST be accepted even
if a later physical operation fails. Semantic publication and frame commit are
distinct; aborting a frame does not roll back semantic state that was already
published.

A derivation failure before semantic publication leaves the already-applied
state semantically dirty. A retryable refusal after publication instead leaves
the latest published revision presentation-pending. Both states request a
later host-scheduled cycle, which recomputes from current state without
replaying the admitted batch or refused frame payload. Presentation-pending
recovery is paced, coalesces newer revisions, and is governed by a finite
target policy that either reaches accepted handoff or explicitly makes the
required presentation facility unavailable and quiesces affected interaction.

This RFC defines ordering, observation, and payload lifetime. It does not
select the public observable-state mechanism, state-slot representation,
transaction journal, identifier widths, queue capacities, scheduler API, exact
recovery pacing and attempt limits, or backend operational retry policy after
accepted handoff. Backend/transport recovery after accepted handoff remains
deferred by FW-010. FW-011 records why handoff-refusal rescheduling became a
required part of this RFC during review.

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
under MVP Scope. This RFC establishes the run-cycle admission, serialization,
freeze, dirty-state, and publication boundaries that feature must satisfy, but
it MUST NOT select its storage, observation API, state-slot representation, or
public client syntax.

## Requirements

### R1 — Sealed deterministic admission

Each run cycle MUST seal an ordered, bounded batch of input, externally
produced state-change facts, and other runtime-relevant work before semantic
evaluation. Reentrant input and facts arriving after the seal MUST be deferred
to a later admission boundary.

### R2 — At-most-once semantic effects

An admitted state-change fact or semantic action MUST be applied at most once.
Frame abort, drop, rejection, supersession, presentation failure, or a later
dirty-state recovery cycle MUST NOT repeat action dispatch, admitted mutation,
or client side effects. A later recovery cycle MAY recompute reconciliation,
layout, and frame preparation from the current already-mutated state.

### R3 — Complete publication

GiftUI-managed runtime observers MUST see only complete published semantic
revisions, never notifications from intermediate mutations in the sealed
batch or a partially derived mixture. Mutation-driven invalidations MUST be
coalesced while the batch is applied. After evaluation, observed state MUST
remain stable until the cycle publishes the complete revision or records a
derivation failure. Semantic publication MAY precede frame commit, but
presentation-coupled routing and hit-test state MUST remain staged until the
corresponding logical frame commits.

This guarantee applies to GiftUI's observation and revision boundary. Direct
client observation of an underlying mutable reference outside that boundary
is not transactionally atomic and MUST NOT be presented as covered by this
guarantee. The separate observable-state lifecycle determines the concrete
API and storage mechanism while preserving this boundary.

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

Inputs, pending state-change facts, frames, backend-owned presentation data,
downstream work, and pending work MUST be bounded with deterministic overflow
or backpressure disposition. Capacity needed to honor an accepted handoff
MUST be reserved before `offer` returns success.

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
state freeze, dirty-state recovery, frame provenance, payload lifetime, and
presentation separation. They MUST also preserve input provenance validation,
per-source sequence cancellation, and activation revalidation behavior.

### R10 — Required handoff disposition

Every frame path MUST synchronously commit or abort at `offer`. Accepted
handoff MUST atomically commit the logical frame and its presentation-coupled
routing state. Abort MUST discard unpublished frame-local results, retain the
previous committed logical frame and routing state as authoritative, report
the pre-handoff failure through RFC-005, and leave the runtime in a
deterministic state. A backend MAY refuse only before making any irreversible
presentation effect. Once irreversible output begins, presentation
responsibility has transferred: the backend MUST consume or safely drain the
complete one-shot stream, return an accepted handoff disposition, and treat
any later device or transport condition as post-handoff operational health.

If a retryable refusal follows semantic publication, the runtime MUST retain
bounded presentation intent for the latest published revision and request a
later host-paced frame opportunity. That opportunity MUST rederive current
state without replaying admitted facts, actions, effects, or the refused
operation payload. Newer published revisions MUST coalesce over older pending
intent. The target composition MUST provide a finite retry and pacing policy;
exhaustion or a non-retryable refusal of the required presentation facility
MUST transition it to explicitly unavailable and quiesce affected interaction
rather than leave an apparently interactive stale UI.

### R11 — Dirty recovery after derivation failure

If an admitted mutation batch was applied but reconciliation, layout, or frame
preparation fails before semantic publication, the affected observable state
MUST remain dirty and the runtime MUST request a later run-cycle opportunity.
The later cycle MUST derive from current state without replaying the admitted
facts, actions, or side effects. Recovery MUST occur as a separately admitted
cycle and MUST NOT form an immediate, unbounded retry loop.

### R12 — Provenance-validated presentation-coupled input

Every presentation-coupled normalized input event MUST identify the eligible
physical-presentation revision against which it was sampled. The target-local
gate MUST forward the event only while that presentation is known to be
eligible, and runtime admission MUST validate that the provenance still
matches the authoritative committed routing revision. Failure of either check
MUST drop the event rather than retarget it against another revision.

The common MVP gate MUST NOT defer presentation-coupled pointer events. Losing
eligibility, receiving stale provenance, malformed or out-of-order phases, or
exhausting any gate, event, or admission capacity MUST cancel the affected
source's active pointer sequence and invalidate its bounded sequence identity.
No later move or up from that sequence may be forwarded or invoke an action;
the integration MAY observe and consume a terminal physical phase only to
resynchronize the source. Any later down begins a distinct sequence whose
identity lets Core discard older captured state before considering the new
press. An implementation MAY instead enqueue an explicit non-activating cancel
fact when capacity is available, but safety MUST NOT depend on that enqueue
succeeding. Bounded identity reuse MUST NOT alias a sequence from which a late
physical phase can still arrive; exhaustion or wrap ambiguity MUST fail closed
by cancelling and quiescing that source until it is safely resynchronized.

An admitted pointer down MAY capture a stable action identity from its
validated committed hit map only when that action is enabled in the down
revision. The capture MUST contain the action's stable semantic identity and
its committed action generation, and MUST NOT retain the callable payload.

Each committed action record consists of a stable semantic action identity, a
finite non-aliasing action generation, enabled state, and the currently
committed callable payload. Installing a newly derived callable payload at an
otherwise equal semantic action identity is action replacement and MUST
install a new generation. A runtime MUST NOT compare closures or infer payload
equivalence. It MAY preserve the generation only when it preserves the exact
previously committed payload rather than substituting the newly derived one.
An aborted or refused candidate frame MUST NOT change the committed action
record or generation.

A later admitted pointer up MAY invoke the current callable payload only if
the captured identity and generation both equal the then-current committed
action record, the release hits that same identity, and the action is enabled
in that revision. A generation mismatch cancels activation and MUST NOT invoke
either the former or replacement payload. The former payload need not remain
alive for pointer capture and MAY be released as soon as no separately
admitted action owns it. A committed revision MAY change during a press
without cancelling activation when that action record remains unchanged, but
each event is independently provenance-validated and release is always
revalidated.

Action-generation reuse MUST NOT alias any pair that can remain captured or
admitted. Exhaustion or ambiguous wrap MUST fail closed by cancelling affected
capture and quiescing the source until safe resynchronization. Exact
provenance, source-identity, and action-generation widths and capacities belong
in Specifications.

## Constraints

- A cycle may publish no semantic change and may produce no frame.
- A cycle does not correspond one-to-one with a hardware refresh.
- A refused handoff makes no irreversible presentation effect. A streaming
  backend that begins physical output has crossed the acceptance boundary and
  cannot subsequently describe that attempt as refused.
- After accepted handoff, streaming presentation may be delayed, partially
  written, or fail; logical commit does not claim physical visibility, physical
  rollback, or atomic display hardware.
- A target whose presentation and input share a physical user experience must
  coordinate them below Core. Presentation-coupled events are provenance-
  stamped and dropped when eligibility cannot be established; they are never
  held and later retargeted against another routing revision.
- External client side effects are not assumed reversible.
- Observable state mutation, cycle evaluation, derivation, and publication
  share one serialized execution domain. The cycle MUST NOT suspend or permit
  reentrant mutation between applying its sealed batch and publication or
  failure disposition.
- Producers outside that domain submit bounded facts rather than directly
  mutating GiftUI-observed state. The exact actor, executor, event-loop, or
  generated static mechanism is profile-specific.
- Arbitrary direct observation of a mutable client reference is outside the
  atomic GiftUI publication guarantee.
- Platform loops and interrupts may wake the runtime but do not decide cycle
  input membership.
- The common static path cannot require heap allocation, exceptions,
  reflection, unrestricted existentials, `Task`, or thread primitives.

## Proposed Design

### Serialized state admission and publication

All GiftUI-observed state mutations execute within the runtime's serialized
execution domain. External acquisition, interrupt, callback, or worker
contexts submit bounded state-change facts; they do not mutate observed state
directly. The next cycle seals those facts together with input and other
admitted work, then applies each fact and semantic action once.

Writes mark their observable owner dirty, but GiftUI-managed invalidation and
publication notifications are coalesced until the sealed mutation phase is
complete. State is then frozen against further mutation while the runtime
reconciles, lays out, and prepares a frame. Facts arriving during that interval
remain queued for a later cycle. A successful derivation publishes one
complete semantic revision. Direct observation of the underlying mutable
object is ordinary client access and does not acquire transactional guarantees
from GiftUI.

If derivation fails before publication, already-applied state is not rolled
back. It remains dirty, the failure is reported through RFC-005, and the
runtime requests another host-scheduled cycle. That later cycle recomputes
from current state; it does not re-admit or replay the mutation batch. The host
owns pacing and coalescing so repeated deterministic failure cannot cause
synchronous recursion or an unbounded immediate retry loop.

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
4. **Handoff-refusal convergence is required.** Semantic publication has
   already completed when a prepared frame reaches `offer`. A retryable
   refusal marks the latest published revision presentation-pending and
   requests a later host-paced opportunity. That opportunity performs new
   layout/render work from current state rather than replaying the refused
   payload. Newer revisions replace older pending intent. A finite target
   policy bounds attempts and pacing; exhaustion or non-retryable refusal
   makes a required presentation facility explicitly unavailable and quiesces
   affected interaction. FW-011 records the review-triggered return of this
   decision to MVP scope.

Semantic dirtiness and presentation-pending intent are distinct. Semantic
dirtiness means no complete revision was published. Presentation-pending means
a complete revision was published but no corresponding frame committed. The
runtime retains at most the latest pending revision/provenance and never the
refused operation stream.

Dirty recovery after a pre-publication derivation failure is not replay of the
failed frame or its admitted actions. It is a later, separately admitted
recomputation from current state. Because invalid geometry, unsupported
capability, and render-generation failures may be deterministic, the host MUST
pace requested opportunities and MUST NOT synchronously call the runtime in an
unbounded retry loop.

### Wake scheduling and presentation synchronization

The runtime MUST request a wake when observed state transitions from clean to
dirty, remains dirty after derivation failure, or becomes presentation-pending
after a retryable refusal. The target host MUST provide serialized run-cycle
opportunities in response to requested wakes, scheduled deadlines, or a
configured combination of both. Runtime execution MUST NOT require a
continuously ticking frame loop. The host owns wake coalescing, pacing,
missed-deadline policy, and enforcement of the configured finite retry policy.
Platform event loops, interrupts, backend-readiness notifications, and timer
facilities may implement those opportunities, but they do not decide the
membership of the cycle's sealed input batch.

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

### Presentation-coupled input admission

The target-local presentation/input gate observes physical input and the
eligibility of the presentation currently available to that user. When it can
establish eligibility, it lowers a physical sample into a backend-neutral
event carrying that presentation's provenance and offers it to the bounded
runtime input queue. When it cannot establish eligibility, it drops the event.
This fail-closed gate is below semantic admission: it cannot hit test, capture
an action, invoke a handler, or reinterpret an event after a newer frame.

Queueing after this check does not make provenance timeless. At the next
admission boundary, Core compares the event provenance with its current
committed routing revision before the event joins the sealed batch. A mismatch
drops the event and cancels the source's active sequence. This validation
closes the race in which a frame commits after target-local gating but before
runtime admission. The ordinary R1 rule still permits already-valid reentrant
input to wait for a later admission boundary; it does not permit stale input
to survive that later validation.

Pointer sequencing is fail-closed per bounded source identity. A validated
down with a new bounded sequence identity first clears any older capture for
that source, then hit-tests the committed map and may capture its stable action
identity and committed action generation only if it is enabled. Each validated
move may cancel capture according to the gesture rule. A validated up invokes
only the current payload associated with the same captured identity-generation
pair after checking the current committed hit map and disabled state. A
presentation revision may advance while a pointer remains down, so long as
the action record remains unchanged and each subsequent physical event belongs
to the same valid sequence, was sampled against an eligible presentation, and
passes the current semantic checks. Any dropped phase,
eligibility loss, stale revision, overflow, unavailable presentation facility,
missing or invalid sequence identity, missing action identity, action-
generation mismatch, changed hit, or disabled action cancels activation.
Orphaned move/up phases are consumed without semantic dispatch until the
source is physically synchronized.

This contract does not retain historical hit maps and does not ask the target
integration to understand action identity. Non-spatial controls whose meaning
is explicitly independent of presentation are not presentation-coupled input;
their mapping and sequencing remain separately specified.

### Logical phases

One cycle has these observation points:

1. **Begin:** select cycle-stable configuration and bounded workspaces.
2. **Admit:** validate queued input provenance and pointer-sequence state,
   drop or cancel stale input, and seal the remaining ordered input,
   state-change, and completion batch.
3. **Evaluate:** apply admitted state-change facts and dispatch semantic
   actions once while coalescing dirty notifications.
4. **Freeze, reconcile, and layout:** prevent later mutations from entering the
   cycle and derive a complete next hierarchy and geometry.
5. **Prepare frame:** create a stable one-shot synchronous stream source.
6. **Publish semantics:** make the complete resulting semantic revision
   observable while keeping frame-derived routing and hit-test state staged.
7. **Offer:** submit the prepared frame to the selected backend.
8. **Commit or abort:** if `offer` accepted the complete handoff, commit the
   logical frame together with its routing and hit-test state; otherwise abort
   it while preserving the prior committed logical frame and routing state as
   authoritative.
9. **Finalize:** clear semantic dirtiness represented by a published revision;
   clear presentation-pending intent on accepted handoff; retain semantic
   dirtiness after derivation failure; or retain/coalesce presentation-pending
   intent and request a later opportunity after retryable refusal. Then release
   cycle-local storage and record the cycle outcome. A non-retryable refusal or
   exhausted retry policy follows the required-facility unavailable/quiescence
   disposition instead of requesting another attempt.

Implementations may fuse phases but may not move the admission, publication,
state-freeze, handoff, or payload-lifetime boundaries. The cycle is
non-suspending across mutation, derivation, publication, and handoff
disposition. Backend-local asynchronous work after accepted handoff does not
re-enter Core to alter frame disposition.

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

- semantic result: unchanged, published, or dirty after failed derivation;
- presentation intent: satisfied, pending for the latest published revision,
  or unavailable after terminal policy;
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
| Target host | Provide serialized cycle opportunities from wake requests, deadlines, or both; assemble bounded pacing policy and adapters | Semantic input membership after admission begins or mutation of observed state |
| Semantic runtime | Validate input provenance, own bounded pointer-sequence and identity-generation capture state, commit bounded action records, seal facts and eligible input, apply admitted mutations and actions once, freeze derivation state, coordinate phases, publish complete revisions, and retain dirty state after derivation failure | Concrete backend, platform, physical eligibility mechanics, closure comparison, or observable-state storage mechanics |
| Observable-state feature | Define the public state API and bounded storage mechanism while coalescing mutation notification and preserving the RFC-004 publication boundary | Transactional guarantees for arbitrary direct object observation or presentation retry policy |
| Layout/render producer | Produce complete geometry and ordered payload from cycle-stable inputs | Backend health or semantic replay |
| Presentation coordinator | Offer frames, record synchronous handoff commit or abort, retain only latest-revision presentation-pending intent after retryable refusal, and request a separately paced opportunity | Client action dispatch, state rollback, refused-payload retention or replay, or target-specific attempt limits |
| Backend/display/transport integration | Consume the operation stream synchronously, refuse only before irreversible output, reserve capacity before acceptance, own derived presentation data and downstream health after acceptance, stamp and gate presentation-coupled input against locally established eligibility, and optionally report diagnostics | Retaining or replaying the GiftUI operation stream, deferring input for later retargeting, hit testing, action capture or replay, refusing after irreversible output, cycle admission, or semantic publication |

## Public API Impact

Ordinary views do not receive cycle IDs, frame tokens, queues, or presentation
callbacks. Semantic action generations and captured identity-generation pairs
remain package SPI and MUST NOT become client-visible identity. Later
Specifications define host-facing cycle invocation, frame payload lifetime,
outcomes, capacities, wake requests, and integration SPI.
The separate observable-state lifecycle defines how client code is isolated to
the serialized mutation domain and how external producers submit bounded
facts. Any public API that permits client side effects must state when the
effect occurs relative to the semantic publication boundary.

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
It may return a synchronous refusal only if it has made no irreversible
presentation effect and retains nothing from the frame. If it begins physical
output while consuming a direct stream, it has accepted responsibility; it
must finish consuming or safely drain the borrowed stream and return an
accepted disposition even when a later physical operation fails.

After accepted handoff, the backend/integration owns presentation ordering,
device and transport health, derived-data lifetime, and coordination with its
physical input path. It must stamp presentation-coupled events with the locally
eligible physical-presentation revision and drop them when eligibility is
stale, unavailable, unknown, or not yet established. It must cancel the local
pointer sequence on a dropped phase and must not retain an event for later
retargeting. It may emit optional operational diagnostics, but it may not hit
test, invoke semantic code, change the committed logical-frame disposition,
cause semantic or input replay, or ask GiftUI Core to retry a frame.
Backend/transport recovery and any replayable operation representation are not
MVP requirements and are preserved by FW-010.

## Static / Embedded Impact

Static implementations may use fixed rings, caller-owned workspaces, direct
phase calls, generated mutation slots, cooperative event-loop serialization,
fixed per-source pointer records, and synchronous operation streaming. Input
coherence requires event provenance plus bounded source, phase, and captured
identity-generation state, not historical hit maps, retained former action
payloads, or a deferred-event queue. The common contract does not require a
Swift actor, `Task`, thread, retained display list,
replayable frame pool, reversible client state, or duplicate semantic graph.
Exact observation and storage strategy belongs to the observable-state and
runtime Specifications and must be measured on nRF52840 before implementation
approval.

## Performance

Required measurements include cycle phase duration, input and state-change
fact coalescing, dirty-notification counts, dirty-to-cycle latency,
presentation-pending duration, recovery-cycle pacing and attempt counts,
operation production, handoff latency, backend presentation latency,
presentation/input gating, stale-input drops, gesture cancellations,
action-replacement cancellations, generation exhaustion, backpressure
behavior, and the 80-transition/second plus 250-millisecond presentation
workload. Transaction metadata should remain constant-cost per cycle and
frame; backend-local downstream metadata should remain constant-cost per
accepted slot and configured input source.

## Memory / Binary Size

Specifications account for input and state-change queues, dirty tracking,
latest-revision presentation-pending state and its finite-policy counters,
runtime and layout workspace, frame envelopes, backend-owned presentation
data, downstream slots, raster tiles, event provenance, per-source pointer
state including one captured action generation, committed action-record
generations, input-gating state, stack high-water, and specialization cost.
Input gating MUST NOT require historical hit-map or former callable-payload
retention or a deferred-event queue. Pending intent MUST NOT retain the refused
operation payload or require a second copy of the complete client state or
semantic graph. A dynamic queue is still configured and bounded; allocation is
not permission for unlimited work.

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

### Replay the failed mutation batch or frame

This reuses the normal path but may repeat client actions and side effects.
RFC-004 instead keeps already-applied state dirty and recomputes from that
state on a later host-paced cycle. After retryable handoff refusal, it retains
only latest-revision presentation intent and likewise rederives from current
state. It never replays the admitted batch or the failed frame payload.

### Guarantee periodic rederivation

A mandatory fixed tick would eventually provide another attempt without a
separate wake path, but it consumes work and power when no presentation is
pending and does not by itself distinguish retry exhaustion from permanent
failure. The MVP instead permits deadlines while requiring an explicit wake
for presentation-pending work and a finite target policy.

### Delay semantic publication until frame acceptance

This would reuse semantic dirtiness for every refusal, but it couples complete
state publication to backend availability and can stall non-presentation
observers behind display backpressure. The proposed design preserves semantic
publication independence and tracks the narrower presentation obligation
separately.

### Defer stale input and route it against the latest revision

This minimizes presentation-gate drops and needs no historical hit map, but it
can reinterpret an old coordinate against a different layout, action map, or
disabled state. Even a final enabled-state check cannot prove that the user
saw or targeted the resulting action. It is therefore unsafe for general
presentation-coupled activation.

### Retain historical hit maps for provenance routing

Core could retain every referenced committed hit map, route each event against
its sampled revision, and then revalidate the resulting action against current
state. This better preserves the originally visible target, but it adds a
second multi-revision lifetime, reference accounting, capacity policy, and
stale-action semantics. A bounded queue can still span many revisions, making
the storage cost especially unattractive on nRF52840. This alternative becomes
preferable only if measured input loss makes fail-closed cancellation
unacceptable and a future lifecycle explicitly authorizes the retention cost.

### Pin presentation while a pointer sequence is active

The integration could hold one interactive revision until every active pointer
reaches a terminal phase. That avoids multi-revision gesture validation, but a
held or failed pointer can block new presentation and couple user input
duration to backend progress. It is unsuitable as the common frame contract.

### Transactional observation of arbitrary mutable references

Staging every client write, journaling rollback, or copying the complete state
or semantic graph could make direct object observation atomic. It would impose
storage, interception, and rollback requirements not justified by the Signal
Analyzer and especially costly for nRF52840. The proposed contract guarantees
complete GiftUI revision publication while leaving arbitrary direct object
observation outside that guarantee.

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

The proposed MVP direction rejects backend-owned semantic scheduling,
universal retention or replay of operation streams, replay of admitted
mutations or client effects, transactional guarantees for arbitrary mutable
references, coupling logical commit to physical presentation completion,
retargeting deferred input against a later revision, retaining historical hit
maps for the common MVP path, and pinning presentation for an entire pointer
sequence. Those approaches either move semantic authority below the runtime
boundary, require unbounded or unjustified storage, repeat non-reversible
effects, let old input acquire new meaning, or make common progress depend on
input duration or target-specific presentation evidence.

Universal retained-frame replay and generalized post-handoff recovery remain
postponed through FW-010 rather than being rejected for all future
configurations. FW-011's narrower refusal-rescheduling trigger has fired and
its required MVP behavior is incorporated here.

## Compatibility

Ordinary portable view syntax should not change. Host, runtime, and backend
APIs that conflate invalidation with immediate drawing, retain unbounded work,
describe accepted handoff as proven physical presentation, omit input
provenance, or forward orphaned pointer phases will require migration. Input
may now be dropped where the proof of concept would have routed it against the
latest available hit map. No stable frame ABI or persistent serialized format
is proposed.

## Testing Strategy

- Inject input during every phase and verify later admission only while its
  provenance still matches the committed routing revision.
- Commit a newer frame between target-local gating and runtime admission;
  verify the queued event is dropped and cannot be retargeted.
- Drop down, move, and up independently because of ineligibility, stale
  provenance, malformed ordering, and every queue boundary; verify the active
  source sequence is cancelled and orphaned phases cannot invoke an action.
- Advance committed revisions during a press without changing the committed
  action record; verify release invokes the current payload only when the hit
  map still resolves the captured identity-generation pair and the action
  remains enabled.
- Install a newly derived callable payload at the same semantic action identity;
  verify its generation changes and a capture of the former generation invokes
  neither payload on release.
- Abort a candidate containing a replacement payload; verify the committed
  generation and payload remain unchanged and a valid existing capture can
  still activate normally.
- Remove, replace, move, or disable the captured action before release and
  verify no action is invoked and pointer capture retains no former payload.
- Exhaust and wrap the action-generation space; verify no captured or admitted
  pair aliases a replacement and the affected source fails closed until safe
  resynchronization.
- Begin a press over an action disabled in the down revision, enable it before
  release, and verify the disabled down never established capture.
- Saturate presentation/input gating and runtime input admission; verify
  deterministic drop/cancel behavior without deferred-input storage or
  historical hit-map retention.
- Exhaust and wrap the configured sequence-identity space; verify no late phase
  can alias a newer sequence and ambiguous sources remain quiescent until safe
  resynchronization.
- Submit state-change facts from outside the serialization domain and verify
  they are bounded, sealed, applied once, and never mutate observed state
  directly.
- Apply multiple related mutations in one sealed batch and verify GiftUI
  observers receive one complete revision without intermediate notifications.
- Inject a state-change fact during derivation and verify it remains pending
  for a later cycle while the current derivation observes stable state.
- Prove every admitted action executes at most once under preparation failure,
  handoff refusal, downstream presentation failure, drop, and supersession.
- Fail reconciliation, layout, and frame preparation after mutation; verify
  state is not rolled back, remains dirty, requests a later host opportunity,
  and is recomputed without replaying mutations, actions, or side effects.
- Reproduce a deterministic derivation failure and verify wake coalescing and
  host pacing prevent synchronous recursion or an unbounded immediate loop.
- Exercise wake-only, deadline-only, and combined host scheduling while
  preserving equivalent sealed-batch and publication behavior.
- Compare static and dynamic semantic results, geometry, operation order, and
  frame provenance for the same sealed inputs.
- Verify every backend accepts only after consuming the complete operation
  stream and reserving bounded downstream capacity, retains no operation or
  borrowed resource afterward, and keeps backend-owned derived presentation
  data valid for its local lifetime.
- Inject failure before and during `offer`; verify refusal retains nothing, the
  candidate frame aborts, no irreversible presentation effect occurred, and
  the previous logical frame and routing state remain authoritative.
- After a published revision is refused retryably, verify latest-revision
  presentation intent remains pending, a separately paced opportunity is
  requested, current state is rederived, and no mutation, action, effect, or
  refused operation payload is replayed.
- Publish newer revisions while presentation is pending and verify they
  coalesce over the older intent with constant-space state.
- Exhaust the configured retry policy and inject a non-retryable refusal;
  verify the required presentation facility becomes explicitly unavailable
  and affected interaction quiesces instead of remaining apparently usable.
- Begin irreversible physical output and then inject a failure; verify the
  backend consumes or safely drains the stream, returns an accepted handoff
  disposition, and handles the condition as post-handoff operational health.
- Inject failure after accepted handoff; verify the logical frame and routing
  remain committed, Core performs no replay or retry, and optional diagnostics
  do not acquire control-flow authority.
- Delay, partially complete, and fail downstream presentation while injecting
  physical input; verify the target integration does not admit input known to
  belong to a stale, unavailable, or not-yet-eligible presentation.
- Saturate every backend-owned downstream slot and verify `offer` applies
  deterministic backpressure before acceptance.
- Keep host, cross-build, simulator, and connected-device evidence distinct.

[SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
provides compatible host-fixture evidence for the tiled case: the disposable
prototype synchronously consumed each seven-operation borrowed stream once,
retained no lease after `offer`, and produced the reference RGB565 image from
bounded tile storage. This supports the proposed lifetime meaning but does not
replace eventual backend conformance tests or approve this RFC.

## Risks

- Client code may mistake direct observation of a mutable reference for
  GiftUI's atomic revision guarantee; the observable-state API and
  documentation must make the boundary explicit.
- A deterministic derivation failure can keep state dirty indefinitely; host
  pacing and diagnostics must prevent a hot retry loop while leaving recovery
  possible after state, resource, or configuration changes.
- A retryable refusal can repeatedly prevent presentation; finite target
  policy must bound attempts and transition required presentation to explicit
  unavailability instead of permitting an apparently interactive stale UI.
- Dynamic implementations may hide unbounded work behind tasks or references;
  conformance must enforce configured bounds.
- Accepted streaming presentation may leave a display delayed or partially
  updated while Core has committed newer routing; conformance therefore
  depends on target-local presentation/input gating and explicit bounded
  recovery behavior.
- A target unable to determine whether input corresponds to an eligible
  presentation cannot claim safe presentation-coupled input merely because
  `offer` succeeded.
- Conservative provenance validation may cancel presses when frames advance
  faster than queued input reaches admission; target measurements must expose
  this loss rather than weakening the safety rule or silently retargeting it.
- Declarative re-evaluation may produce a newly derived callable at an
  otherwise stable action identity. Installing it is replacement and cancels
  a press that captured the former generation; Interaction conformance must
  measure this conservative behavior rather than infer closure equivalence.
- Coordinated comparison with RFC-005 and RFC-006 currently finds compatible
  pre-handoff, operation-stream-lifetime, and post-handoff ownership meanings.
  Any review change to those shared meanings must be reconciled before the
  affected RFC advances to approval.
- Future retry work may accidentally reintroduce universal frame retention;
  FW-010 must justify its retention scope and bounds before coordinated RFC
  revision.

## Open Questions

None at the RFC level. Identifier, source, and provenance widths; queue and
payload capacities; timing and recovery-pacing budgets; concrete handoff
result types; observable-state API and storage; gesture-state representation;
action-generation width and exhaustion representation; and target-local
eligibility mechanisms are Specification inputs governed by the boundaries
above.

## Deferred and Follow-up Work

- [FW-010: Backend and Transport Post-Handoff Recovery](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves optional backend-local recovery using already-owned derived frame
  data after accepted handoff. It is excessive for MVP; revisit when a
  supported backend demonstrates a measured availability requirement that
  simple bounded abandonment or repair cannot handle acceptably.
- [FW-011: Handoff-Refusal Frame Rescheduling](../future-work/fw-011-failed-frame-rescheduling.md)
  records a review trigger that demonstrated rescheduling is necessary for MVP
  coherence. The item is closed as resolved into this RFC: retryable refusal
  retains only latest-revision presentation intent and requests bounded,
  separately paced rederivation; terminal policy makes a required facility
  explicitly unavailable and quiesces affected interaction.
- [FW-014: Replayable Operation Delivery for Future Raster Strategies](../future-work/fw-014-replayable-operation-delivery.md)
  preserves a possible bounded replayable representation for a future
  multi-pass raster strategy that cannot meet its accepted requirements through
  the common one-shot stream. It does not add replay to the MVP frame contract
  or duplicate FW-010's post-handoff recovery scope.

Animation transactions, lossless presentation, upper-layer remote
acknowledgement, and persistent frame capture remain outside current MVP scope.
Target-local acknowledgement MAY be used to coordinate a remote display with
its input path without changing the GiftUI handoff boundary. Broader work
requires a concrete accepted need or deferred artifact. Observable reference-
state architecture remains a separate required feature lifecycle rather than a
hidden sub-decision of this RFC.

## Decision Summary

This approved RFC is recorded by accepted ADRs for:

1. sealed run-cycle admission with at-most-once state-change and semantic
   action application, non-suspending serialized derivation, dirty recovery,
   and complete GiftUI revision publication boundaries;
2. semantic publication independent from presentation outcome;
3. synchronous handoff commit-or-abort semantics: refusal is permitted only
   before irreversible presentation output, while beginning output transfers
   responsibility and requires an accepted disposition;
4. one frame-envelope model whose ordered operations are consumed once during
   a synchronous backend offer, with backend-owned post-handoff presentation
   health and no MVP replayable-operation or asynchronous Core completion
   requirement;
5. constant-space latest-revision presentation intent after retryable refusal,
   with effect-free rederivation, finite target pacing/attempt policy, and an
   explicit unavailable/quiescent terminal disposition; and
6. provenance-validated, fail-closed presentation-coupled input admission with
   no stale-event retargeting, no common deferred-input queue or historical hit
   maps, sequence cancellation on every dropped phase, identity-generation
   capture without callable retention, generation change on committed payload
   replacement, and current-revision pair, hit, and disabled-state
   revalidation before activation.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [ADR-013: Provenance-Validated Presentation-Coupled Input](../adrs/adr-013-provenance-validated-input-admission.md)
- [SPEC-006: Declarative View Semantics Specification](../specs/spec-006-declarative-view-semantics.md)
- [FW-010: Backend and Transport Post-Handoff Recovery](../future-work/fw-010-backend-transport-submission-retry.md)
- [FW-011: Handoff-Refusal Frame Rescheduling](../future-work/fw-011-failed-frame-rescheduling.md)
- [FW-014: Replayable Operation Delivery for Future Raster Strategies](../future-work/fw-014-replayable-operation-delivery.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
