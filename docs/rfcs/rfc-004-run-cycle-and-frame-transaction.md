---
id: RFC-004
feature: giftui-mvp-architecture
title: Run Cycle and Frame Transaction Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
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

This RFC proposes that GiftUI treat each runtime invocation as a bounded run
cycle over a sealed input batch and a stable set of resources. A cycle applies
semantic updates, reconciles the declarative hierarchy, computes layout,
prepares presentation work, commits semantic state, and then attempts to
present a frame. Semantic commit and presentation are distinct outcomes: a
committed user-state transition is never rolled back or replayed because
rendering, display, or transport fails.

The run-cycle boundary is the common observation and propagation point for
inputs, state changes, invalidations, failures, diagnostics, deferred work,
and frame disposition. Backends may complete presentation synchronously or
asynchronously, but every completion is associated with a stable cycle and
frame identity and is admitted as ordered runtime input. Dropping or retrying
presentation never replays semantic work.

This proposal refines the frame and event flow in
[RFC-002](rfc-002-giftui-mvp-layered-architecture.md). It preserves that RFC's
layer ownership and ordered backend-neutral render-operation boundary. A frame
is an immutable logical envelope, but its render payload may be either a
replayable bounded representation or a one-shot synchronous stream. The latter
allows the static profile to avoid a mandatory retained display list.

These are candidate architectural choices for review. This draft does not
approve architecture, define final public API spellings, choose numerical
capacity budgets, or authorize implementation.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
accepts the need to establish an explicit MVP architecture before substantial
framework migration or feature work. The architecture must support the same
portable Signal Analyzer presentation on macOS dynamic, macOS static,
Raspberry Pi 1/Linux dynamic, and nRF52840 static configurations.

[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) proposes the ownership
and dependency direction relevant to this RFC:

```text
portable declarations
    -> semantic runtime and state
    -> proposal-based layout
    -> ordered backend-neutral render operations
    -> backend
    -> display/input driver and transport/OS/HAL
```

It also assigns runtime serialization, reentrancy, action ordering, and
invalidation to the semantic runtime while leaving scheduler invocation to the
target host. It does not yet define the transaction boundary shared by those
responsibilities.

Without that boundary, implementations can accidentally:

- apply an input twice after retrying a failed frame;
- roll back application state because a display is unavailable;
- expose partially updated semantic or layout state;
- admit events at scheduler-dependent points during evaluation;
- let backend timing change which inputs belong to a frame;
- confuse direct operation streaming with an unbounded retained display list;
- accumulate unbounded pending work when presentation is slower than updates;
  or
- diverge between a desktop event loop and an Embedded Swift polling loop.

The Signal Analyzer makes this concern concrete. It may ingest up to 80 signal
transitions per second while presenting at approximately four frames per
second. Input, invalidation, and presentation therefore cannot be equated
one-to-one. The runtime needs deterministic admission and coalescing, while
the display path needs bounded frame ownership and an explicit policy for
superseding stale work.

### Terminology

- **Run cycle:** One bounded semantic runtime evaluation with a stable
  `CycleId`, sealed input batch, and resource snapshot.
- **Semantic revision:** A monotonically ordered committed version of
  GiftUI-observable semantic state.
- **Semantic commit:** Atomic publication, from an external observer's
  perspective, of the semantic mutations produced by a successful cycle.
- **Frame:** An immutable logical presentation envelope derived from one
  semantic revision and one set of presentation-relevant resource revisions.
- **Replayable frame:** A frame whose render payload remains available and
  stable for more than one presentation attempt.
- **Streaming frame:** A frame whose ordered render operations are consumed
  synchronously from stable cycle or runtime state and are not retained for
  retry after the offer returns.
- **Presentation attempt:** Consumption of a frame through a backend, display,
  and optional transport.
- **Presentation success:** Confirmation at the configured boundary, such as
  backend acceptance, buffer-swap acceptance, completed device transfer, or a
  remote acknowledgement.
- **Dropped frame:** A frame that reaches a terminal state without presentation
  at the configured boundary.
- **Retry:** Another presentation attempt of the same replayable frame; it is
  never another semantic evaluation.
- **Quiescent:** A runtime state in which new cycles are not admitted, normally
  after a fatal failure.

## Requirements

### R1 — Deterministic admission

Each cycle MUST seal an ordered input batch before semantic evaluation. Inputs
that arrive after the seal, including reentrant events and asynchronous
presentation completions, MUST be deferred to a later cycle or an equivalent
bounded completion path with the same ordering rules.

### R2 — Atomic semantic publication

External runtime observers MUST see either the prior committed semantic
revision or the next complete committed revision, never a partially applied
mixture. A recoverable failure before commit MUST preserve the prior revision.

### R3 — At-most-once semantic effects

An admitted semantic input MUST be applied at most once. Presentation retry,
drop, supersession, rejection, or failure MUST NOT repeat semantic event
handling, reconciliation, layout, or other user-visible semantic effects.

### R4 — Separate semantic and presentation outcomes

Semantic commit MUST be independent from eventual presentation success. A
post-commit presentation outcome MUST NOT roll back the semantic revision from
which the frame was derived.

### R5 — Stable frame identity and provenance

Every produced frame MUST have a stable `FrameId` and identify its source
semantic revision plus presentation-relevant viewport and resource revisions.
Every accepted asynchronous presentation attempt MUST have a bounded token
that can be matched to exactly one frame and attempt.

### R6 — RFC-002 ownership preservation

The semantic runtime MUST own admission, evaluation, reconciliation, state
publication, and frame scheduling policy. Layout MUST remain backend-neutral.
Backends MUST consume the ordered render-operation contract and MUST NOT own
semantic state, re-run view evaluation, or decide to replay semantic input.
The target host MUST remain the composition root for scheduling and policy.

### R7 — Streamable and retainable render boundary

The frame contract MUST permit both direct ordered operation streaming and
bounded replayable storage. It MUST NOT require a retained render tree or
heap-backed display list. A pipeline that retains a frame asynchronously or
retries it MUST use replayable storage with a lifetime extending through its
terminal disposition.

### R8 — Bounded presentation work

Every supported profile MUST bound in-flight frames, pending frames, retained
render payloads, completion records, and retry attempts. Capacity exhaustion
and overflow MUST have deterministic dispositions.

### R9 — Profile-equivalent behavior

Static and dynamic profiles MAY use different storage, dispatch, scheduling,
and phase fusion. They MUST preserve the same logical phase order, admission
and commit boundaries, frame provenance, and externally observable
transaction semantics.

### R10 — Explicit presentation boundary

Each assembled backend/display/transport path MUST declare what presentation
success means. Submission or ownership transfer MUST NOT be reported as
physical presentation when the configured boundary occurs later.

### R11 — Deterministic failure attribution

Failures MUST be attributed to a cycle phase, frame, or presentation attempt.
Pre-commit failure affects the semantic transaction; post-commit failure
affects frame disposition only. Diagnostics MUST NOT decide commit, rollback,
retry, or fatal behavior by themselves.

### R12 — MVP proportionality

The MVP implementation MUST support the serialized Signal Analyzer update and
presentation path and the four validation configurations. It need not provide
animation transactions, distributed display transactions, a lossless capture
pipeline, arbitrary user-code rollback, or a general scheduler.

## Constraints

- The portable presentation must remain substantially shared across macOS
  dynamic, macOS static, Raspberry Pi/Linux dynamic, and nRF52840 static.
- The nRF52840 path cannot require heap allocation, exceptions, reflection,
  unrestricted existentials, strings for correctness, unbounded collections,
  desktop concurrency, or runtime backend discovery.
- The canonical render boundary is RFC-002's ordered render-operation sink;
  this RFC does not introduce a second semantic or retained render tree.
- A static backend may need to rasterize and transfer bounded tiles directly;
  a full-screen 480 x 320 RGB565 frame buffer is not a universal assumption.
- Platform event loops, polling loops, interrupts, and clocks may wake the
  runtime, but they do not own input membership or semantic commit.
- User code and external I/O are not automatically reversible. Any API that
  permits external side effects must define whether they happen before commit,
  after commit, or through a deferred effect queue.
- MVP rendering remains limited to the opaque rectangles, text, backgrounds,
  and line-based Canvas drawing required by the Signal Analyzer.
- The MVP has no stable public ABI or persistent serialized frame format.
- A cycle need not correspond to a hardware refresh, and a cycle may commit
  without producing a frame.

## Proposed Design

### 1. Transaction model

A run cycle contains one semantic transaction and may create one frame
transaction:

```text
seal inputs and resources
          |
          v
evaluate -> reconcile -> layout -> prepare frame
          |                         |
          +------ semantic commit --+
                                      committed revision R
                                               |
                                               v
                              offer -> backend -> display/transport
                                               |
                                      presentation disposition
```

The semantic transaction ends at `Commit`. The frame transaction begins when
the runtime prepares an immutable frame envelope and ends when that frame is
presented, dropped, rejected, superseded, or permanently failed.

For a replayable frame, preparation materializes the ordered render operations
or another bounded replayable representation before commit. For a streaming
frame, preparation instead freezes the semantic, layout, viewport, resource,
and operation-order inputs from which the sink will consume operations
synchronously after commit. The offer MUST complete consumption before it
returns and MUST NOT retain references to cycle-local scratch storage.

This distinction preserves RFC-002's direct streaming option. It also makes
the cost explicit: asynchronous retention and presentation retry require a
replayable payload; a one-shot streaming pipeline cannot promise retry.

The runtime does not expose a half-applied semantic revision. It may stage
changes with double buffering, a mutation journal, copy-on-write values,
fixed-capacity scratch storage, or another conforming strategy. The precise
representation belongs in downstream Specifications.

### 2. Normative logical phases

Each cycle follows this logical order:

1. **Begin.** Advance `CycleId`, snapshot cycle-stable configuration, and
   prepare bounded cycle-local storage.
2. **Admit.** Seal the ordered inputs eligible for the cycle. Later arrivals
   are deferred.
3. **Evaluate.** Apply admitted semantic events and dependency invalidations
   to staged semantic state.
4. **Reconcile.** Resolve declarative identity and produce the next semantic
   hierarchy or equivalent traversal state.
5. **Layout.** Compute geometry from staged semantics and the stable resource
   snapshot.
6. **Prepare frame.** If presentation is needed, freeze a frame envelope and
   either materialize replayable render operations or establish a stable
   one-shot streaming source.
7. **Commit.** Publish the semantic revision and associated derived state
   atomically from the runtime observer's perspective.
8. **Offer.** Offer the frame to the presentation pipeline under the selected
   bounded policy. A streaming offer consumes the payload synchronously.
9. **Finalize.** Record the cycle outcome, propagate failures and diagnostics,
   release cycle-local scratch storage, and schedule later work.

An implementation may fuse adjacent phases, inline generic calls, or perform
no work for an unchanged result. It MUST preserve the same observation
boundaries and phase attribution. In particular, no backend callback may add
an input to the already sealed batch.

Asynchronous completion occurs after `Offer`, possibly after `Finalize`. It is
converted into sequenced runtime input and never reopens the originating
cycle.

### 3. Cycle and frame state

```text
idle
  |
  v
begun -> admitted -> evaluated -> reconciled -> laidOut -> framePrepared
  |          |           |             |             |
  +----------+-----------+-------------+-------------+--> aborted
                                                        (no commit)
                                      |
                                      v
                                  committed
                                  /       \
                     finalizedWithoutFrame  offered
                                                |
                       presented | pending | dropped | rejected | failed
                                                |
                                         retrying | superseded

fatal failure -> quiescent -> composition-root fatal action
```

A recoverable failure through `Prepare frame` aborts staged semantics and
preserves the prior committed revision. Failure during `Offer` or asynchronous
presentation is post-commit and changes only frame disposition. A fatal
failure prevents admission of another cycle after the configured fatal policy
is applied.

### 4. Core value contracts

The following names and field shapes are illustrative. Their relationships and
behavior are architectural; exact Swift declarations belong in a
Specification.

```text
CycleId          = monotonically ordered runtime-local identifier
InputSequence    = monotonically ordered admission identifier
SemanticRevision = monotonically ordered committed-state identifier
FrameId          = monotonically ordered frame identifier
PresentationToken = bounded attempt identifier

CycleInputBatch {
  cycleId
  firstSequence
  count
  orderedInputs
}

ResourceSnapshot {
  viewportRevision
  environmentRevision
  renderResourceRevisionSet
  capabilityRevision
}

FrameEnvelope {
  frameId
  semanticRevision
  resourceSnapshot
  payloadKind              // replayable | synchronousStream
  orderedRenderPayload
  damage
  presentationMetadata
}

CycleOutcome {
  cycleId
  priorRevision
  committedRevision?       // absent after pre-commit abort
  frameId?                  // absent when no frame was prepared
  semanticDisposition      // committed | unchanged | aborted
  presentationDisposition  // notNeeded | pending | presented | dropped | failed
  failureSummary
  diagnosticSummary
}
```

The MVP may use fixed-width integers and fixed-capacity collections for these
values. Identifier wrap behavior and concrete capacity values must be defined
before an approved implementation Specification.

### 5. Input admission

Every input source supplies a stable source-local order. The runtime combines
sources into one total admission order using declared source priority,
source-local sequence, and a deterministic tie breaker. Wall-clock arrival is
not sufficient when it cannot be reproduced.

At the end of `Admit`:

- batch membership and order are sealed;
- reentrant input is queued for a later cycle;
- asynchronous presentation completion is an ordered input source;
- bounded queues apply a configured overflow policy; and
- tests can reproduce the cycle from its initial revision, admitted batch,
  resource snapshot, capability outcomes, and policy.

Coalescing is permitted only for input or invalidation kinds whose contracts
declare it. Coalescing must be deterministic. When it intentionally loses
intermediate values, that disposition must be observable through bounded
diagnostics where diagnostics are enabled.

Signal samples and UI invalidations are not necessarily the same input kind.
The reference application's bounded capture model remains governed by its own
accepted architecture; this RFC only defines how changes visible to GiftUI are
admitted into a UI cycle.

### 6. Semantic commit

Semantic commit obeys these invariants:

1. A cycle publishes at most one new semantic revision.
2. An admitted semantic input is applied at most once.
3. A failed pre-commit cycle does not publish staged mutations.
4. A published revision is never rolled back due to presentation outcome.
5. Layout and frame metadata identify the revision and resources from which
   they were derived.
6. External observers see the prior or new revision, never a mixture.
7. A committed revision may have no frame or may have a frame that is never
   displayed.

If evaluation proves the semantic result unchanged and no presentation input
changed, the runtime may retain the prior revision and omit layout or frame
preparation. That decision must depend on declared semantic and resource
invalidations, not incidental cache contents.

### 7. Frame ownership and lifetime

A `FrameEnvelope` is immutable after preparation. It contains values or stable
references whose lifetime matches its payload kind:

- A synchronous streaming payload remains valid until `offer` returns. The
  pipeline consumes it inline and cannot retain or retry it.
- A replayable payload remains valid from acceptance through the frame's
  terminal disposition, including every permitted retry.

Neither payload kind may retain a pointer to released cycle-local scratch
storage. Render operations remain RFC-002's normalized ordered vocabulary;
the frame envelope adds identity, revisions, ownership, and disposition rather
than a second render representation.

Retrying a replayable frame retains the same `FrameId` and semantic revision
and advances a bounded attempt counter. Re-encoding creates a new `FrameId`,
even when it uses an unchanged semantic revision after a viewport, resource,
or backend reset.

### 8. Presentation contract

```text
PresentationPipeline.offer(FrameEnvelope) ->
  completed(PresentationOutcome)
  | accepted(PresentationToken)
  | backpressured
  | rejected(PresentationFailure)

PresentationCompletion {
  token
  frameId
  attempt
  outcome: presented | retryableFailure | permanentFailure | superseded
}
```

`completed` is the synchronous path and is the only valid result for a
one-shot streaming frame. `accepted` transfers ownership of a replayable frame
according to the pipeline's lifetime contract; it does not necessarily mean
pixels became visible. `backpressured` and `rejected` leave ownership with the
runtime and receive deterministic frame dispositions from policy.

Late, duplicate, or stale completions must not mutate semantic state or revive
a terminal frame. They are ignored or reported according to bounded failure
and diagnostic policy.

The target composition declares the success boundary. Examples include a
successful buffer swap, completed TFT transfer, or acknowledged remote frame.
Tests must not infer presentation from submission when the declared boundary
occurs later.

### 9. Backpressure, drop, and retry policy

The composition root selects a bounded presentation policy. It defines:

- maximum in-flight and pending frames;
- permitted payload kinds;
- whether a pending replayable frame may be superseded;
- which presentation failures are retryable;
- maximum attempts or a deadline in deterministic scheduler units;
- whether the latest frame or every frame must be preserved; and
- which ordered input schedules another attempt.

All policies obey these invariants:

- retry resubmits only the same replayable frame;
- retry never re-runs semantic handlers, reconciliation, layout, or encoding;
- a newer semantic cycle may proceed while an older frame is pending only
  while all configured storage bounds remain satisfied;
- dropping or superseding a frame does not roll back its semantic revision;
- every accepted frame reaches exactly one terminal disposition;
- retry order and exhaustion are deterministic for the same completion and
  input sequence; and
- storage remains bounded in every profile.

The proposed MVP default is a latest-frame policy with at most one in-flight
replayable frame and one replaceable pending replayable frame. If the selected
static pipeline supports only synchronous streaming, it instead allows no
in-flight or pending frame after `offer` returns and no retry. A failure causes
that frame to terminate; policy may schedule a later cycle to encode a new
frame from the current committed revision.

A lossless every-frame pipeline is not required by the Signal Analyzer and is
not proposed as an MVP implementation. The architecture does not prohibit a
future bounded lossless policy.

### 10. Resource invalidation and re-encoding

Retry is valid only while the frame's viewport, resources, capabilities, and
backend epoch remain compatible. If resize, resource invalidation, capability
change, or backend reset makes the frame stale, the runtime records the
original frame as failed or superseded and schedules new frame preparation.
The new artifact receives a new `FrameId`; it is not mislabeled as a retry.

Cache hits and eviction may not alter semantic results. Any cache state that
can affect layout or ordered render output is a declared, versioned input to
the cycle or is derived deterministically from such input.

### 11. State ownership

| State | Owner | Publication or lifetime rule | Must not be owned by |
| --- | --- | --- | --- |
| Committed semantic state | Semantic runtime | Published only at `Commit`; survives presentation failure | Layout, backend, display, transport |
| Staged semantic state | Active cycle | Exists until commit or abort; bounded by profile policy | Backend callbacks |
| Reconciliation identity | Semantic runtime | Versioned with semantic state | Render sink or backend |
| Layout result | Runtime/layout subsystem | Bound to semantic and resource revisions | Display or transport |
| Frame envelope | Runtime/render-core boundary | Immutable after preparation | Semantic event handlers |
| Replayable render payload | Render core/runtime frame pool | Stable through terminal frame disposition | Cycle-local scratch after finalize |
| Streaming render source | Runtime/render-core boundary | Valid only during synchronous offer | Asynchronous pipeline |
| Presentation state | Presentation pipeline | From accepted offer through terminal completion | Layout subsystem |
| Device/display state | Display capability | Changes enter through explicit status/completion inputs | Semantic transaction |
| Transport state | Transport capability | Independently versioned; failures carry stable tokens | Render operations |
| Admission/presentation/failure policy | Target host | Stable for a cycle | Individual leaf layers |
| Diagnostic storage/sink | Target-host Service | Bounded and optional | Semantic correctness logic |

### 12. Deterministic observation boundaries

GiftUI defines these boundaries:

1. **Admission:** fixes the ordered input batch.
2. **Resource snapshot:** fixes viewport, environment, capabilities, and
   versioned resources used by the cycle.
3. **Commit:** publishes semantic state and revision identity.
4. **Frame:** freezes envelope identity, provenance, payload kind, ordered
   operations or streaming source, and resource lifetimes.
5. **Propagation:** finalizes synchronous failures and diagnostics for policy.
6. **Completion:** converts asynchronous presentation outcomes into sequenced
   runtime inputs.

Determinism means that identical initial committed state, admitted inputs,
resource snapshots, capability outcomes, and policy produce the same semantic
disposition, revision contents, ordered render operations, frame provenance,
and ordered failure summary. It does not require equal wall-clock duration or
byte-identical pixels across different conforming rasterizers.

Parallel evaluation, layout, or encoding is allowed only when its merge order
produces the canonical result and failure ordering. A main-thread-only host may
enforce affinity. Static targets may remain single-threaded and require no
thread primitives.

### 13. Failure interaction

This RFC defines failure timing and ownership, not a complete failure payload
taxonomy:

- failure in `Begin` through `Prepare frame` is pre-commit;
- recoverable pre-commit failure aborts staged state and offers no frame;
- failure in `Offer` or asynchronous presentation is post-commit and affects
  only frame disposition;
- diagnostics report facts but do not choose commit, retry, or rollback;
- the propagation boundary selects one deterministic control-flow outcome
  when multiple failures occur; and
- fatal policy moves the runtime to quiescent behavior before the target
  host's fatal action when the platform permits it.

[RFC-005](rfc-005-failure-diagnostics-propagation.md) proposes the concrete
failure taxonomy, values, diagnostic separation, arbitration, and policy
payloads. The two drafts must preserve the phase and ownership boundaries
defined here and RFC-002's restriction against backend semantic ownership.

### 14. Examples

#### Successful synchronous frame

```text
Cycle 41 admits [buttonPressed#93]
  evaluate/reconcile/layout/frame preparation succeeds
  commit semantic revision 18
  offer streaming frame 77(revision 18)
  backend completes presentation synchronously
Outcome: committed revision 18, frame 77 presented
```

#### Transport failure after commit

```text
Cycle 42 commits semantic revision 19 and replayable frame 78
  transport accepts frame 78 as token 12
Cycle 42 finalizes with presentation pending

Later: token 12 reports transient link failure
Cycle 43 admits that completion
  policy retries frame 78 without evaluating Cycle 42 inputs
  semantic revision remains 19
```

#### Newer frame supersedes a retry

```text
frame 78(revision 19) is retry-pending
Cycle 44 commits revision 20 and prepares frame 79
latest-frame policy marks frame 78 superseded
frame 79 becomes the next pending presentation
```

The event that produced revision 19 remains applied exactly once even though
frame 78 was never displayed.

#### Static capacity exhaustion before commit

```text
Cycle 11 stages semantic changes
layout exceeds the configured node capacity
cycle reports capacityExceeded(layoutNodes)
staged state is discarded
committed revision and visible output remain unchanged
```

The runtime does not implicitly replay Cycle 11. A later distinct input or
explicit policy wakeup may begin a new cycle.

## Module Responsibilities

| Logical module or family | Responsibility | Dependency impact |
| --- | --- | --- |
| Target host/composition root | Invoke cycles; choose admission, presentation, failure, and diagnostic policies; bind scheduler wakeups | May depend on selected layers; exports no new portable semantics |
| Semantic runtime | Seal admission, stage evaluation, reconcile identity/state, commit revisions, and coordinate cycle phases | Depends on portable semantic and layout contracts; never on a concrete backend |
| Layout subsystem | Produce geometry and hit regions from staged semantics and stable resources | Remains backend-neutral as required by RFC-002 |
| Render core | Define frame identity/provenance, ordered operation payloads, bounded storage, and synchronous stream contracts | Extends RFC-002's render boundary without adding semantic view types |
| Presentation policy | Select bounded offer, supersession, drop, and retry behavior | Consumes capabilities and outcomes; cannot mutate semantic state |
| Backend SPI | Consume synchronous streams or replayable operations and report offer/completion outcomes | Depends downward on render contracts; cannot trigger semantic replay |
| Display/transport integration | Perform device or OS presentation and return sequenced completion facts | Owns device mechanics, not cycle admission or commit |
| Capability resolver | Describe supported payload kinds, bounds, completion modes, and presentation boundary | Supplies facts to composition; does not choose policy |
| Diagnostics/failure support | Record bounded phase, frame, attempt, and disposition facts | Observes outcomes; does not determine semantic correctness |

These are ownership boundaries, not required SwiftPM targets. Static builds
may fuse them through generic specialization while preserving dependency
direction and testable contracts.

## Public API Impact

The portable `GiftUI` view API should not expose cycle IDs, frame tokens,
backend completion, or presentation queues for ordinary view composition.
The transaction model is primarily runtime and backend SPI.

Later Specifications are expected to define:

- how a target host requests or polls one cycle;
- profile-neutral cycle and semantic disposition values;
- bounded input-source and completion-source contracts;
- frame envelope, payload lifetime, and presentation result contracts;
- configuration of capacities and presentation policy; and
- which diagnostics are public, package SPI, build-time-only, or omitted from
  static configurations.

APIs that permit user-visible side effects during evaluation must document
their commit relation. This RFC does not propose a general public transaction
API, animation transaction, or user-managed rollback facility.

## Capabilities Impact

Frame-policy configuration needs facts such as the following where applicable:

- synchronous streaming support;
- replayable frame support and maximum retained payload size;
- synchronous versus asynchronous presentation completion;
- maximum accepted in-flight attempts;
- deterministic cancellation or supersession support;
- retry support and resource-validity restrictions;
- presentation boundary and completion-token capacity; and
- viewport, resource, and backend revision or epoch behavior.

Whether and how these become capability values belongs to
[RFC-006](rfc-006-capability-system-architecture.md), not RFC-002 or this RFC.
RFC-002 fixes the MVP stack composition as immutable after assembly. For
example, asynchronous replayable presentation may be configured while the
Signal Analyzer still selects one in-flight frame and one latest pending
frame. Absence of replayable storage disables retry rather than silently
retaining unbounded work.

Runtime device loss is operational state, sequenced as input through the
failure and completion contracts. It may advance a backend or resource epoch
and invalidate incompatible frames, but it does not mutate the assembled stack
or rewrite the meaning of a cycle already committed.

## Backend Impact

Backends continue to consume RFC-002's ordered backend-neutral operations. The
additional obligations are lifecycle and ownership contracts:

- declare whether an offer consumes synchronously or takes ownership of a
  replayable frame;
- declare the configured presentation-success boundary;
- return stable bounded tokens for asynchronous attempts;
- produce exactly one terminal completion for each accepted attempt, or allow
  the runtime to deterministically synthesize one after reset/exhaustion;
- never retain a streaming payload after `offer` returns;
- never mutate semantic state or dispatch application actions directly; and
- report backpressure, resource invalidation, and failure without initiating
  semantic replay.

A framebuffer path may complete after a successful swap or copy. An embedded
TFT path may synchronously stream bounded raster tiles and complete after the
configured transfer boundary. A remote transport may require replayable frame
storage and asynchronous acknowledgement. These paths share transaction
semantics without sharing storage strategy.

Input adapters remain below semantic ownership. They lower device or OS events
into sequenced input records; they cannot bypass `Admit` because a callback
happened during layout or presentation.

## Static / Embedded Impact

The static profile implements the full transaction contract with bounded
representations:

- fixed-capacity input and completion rings with explicit overflow behavior;
- caller-owned or statically allocated staging and layout workspaces;
- monotonically ordered fixed-width identifiers with specified wrap handling;
- direct/generic phase calls that may be fused;
- synchronous render-operation streaming where retention is not affordable;
- optional fixed frame pools when asynchronous ownership or retry is selected;
- fixed retry counters and scheduler-unit deadlines;
- numeric failure and diagnostic records, or diagnostics compiled out; and
- no requirement for exceptions, heap allocation, strings, reflection,
  dynamic dispatch, `Task`, or thread primitives.

The architecture does not require double-buffering the whole semantic graph or
display. A journal, arena generation, caller-owned scratch space, bounded
snapshot, or other strategy may satisfy atomic semantic publication. A
downstream Specification must select and budget the strategy for each
supported static configuration.

Interrupt handlers may append bounded source records but may not execute a
cycle, publish semantic state, or call a backend directly. A polling loop may
both provide wakeups and invoke the cycle, but admission still seals before
evaluation.

## Performance

The principal hot path is admission, semantic evaluation, complete-root
reconciliation where used, layout, ordered operation production, rasterization,
and device transfer. Transaction metadata should remain constant-cost per
cycle, frame, and presentation attempt.

Validation should measure per supported configuration:

- admitted records and coalesced invalidations per cycle;
- cycle phase duration and invalidation-to-presentation latency;
- semantic, layout, and render operation counts;
- operation-production cost for streaming and replayable modes;
- raster and transport time separately from semantic work;
- backpressure and supersession behavior during permanent backend stall;
- sustained Signal Analyzer ingestion at 80 transitions per second with a
  250-millisecond presentation interval; and
- worst-case interrupt-to-admission latency where hardware input is involved.

No universal frame-rate or retry-delay budget is proposed here. Downstream
Specifications must allocate measurable budgets within the Signal Analyzer's
end-to-end requirements.

## Memory / Binary Size

Each target configuration must account for:

- staged semantic state and commit metadata;
- cycle-local reconciliation and layout scratch storage;
- input and presentation-completion queues;
- frame envelopes and presentation records;
- replayable render payload capacity, if selected;
- synchronous streaming state and raster tiles;
- in-flight and pending frame slots;
- diagnostic/failure buffers;
- stack high-water across the deepest fused phase path; and
- code-size cost from generic specialization and multiple policy variants.

The proposed static streaming path adds no mandatory retained display list.
The proposed latest-frame replayable policy requires no more than one
in-flight and one pending frame payload, with exact byte bounds supplied by
the target configuration. Dynamic hosts may use managed storage but remain
subject to configured bounds; reference counting is not permission for an
unbounded queue.

Optional lossless queues, animation histories, frame capture, rich traces, and
remote retransmission buffers must not be linked into the MVP embedded
configuration merely because the architecture can describe them.

## Alternatives

### Alternative A — Commit only after presentation succeeds

This makes semantic and visible state appear atomic on a reliable synchronous
display. It becomes unbounded for asynchronous or unavailable displays and
holds application progress hostage to backend timing. It is preferable only
for a closed system whose semantic contract explicitly defines the display as
the commit medium, which is not GiftUI's cross-platform MVP.

### Alternative B — Roll back semantics after presentation failure

This can hide a failed visual update when every effect is reversible. General
event handlers and external I/O are not reversible, and rollback would make
application behavior depend on backend reliability. GiftUI would also need a
distributed transaction across software and physical display state.

### Alternative C — Treat retry as a new run cycle

This reuses the ordinary rendering path but may repeat event handling,
dependency reads, layout, and side effects. It is only appropriate when the
new cycle creates a new frame with a new identity; it is not a retry of the
original presentation attempt.

### Alternative D — Require every frame to be a retained display list

This simplifies asynchronous ownership and retry and is attractive for
desktop recording or remote transports. It conflicts with RFC-002's bounded
direct-streaming path and can impose unacceptable RAM and copy cost on the
nRF52840. It is preferable only for a configuration that selects and budgets
replayable storage.

### Alternative E — Permit only one-shot streaming frames

This minimizes storage and maps cleanly to a synchronous embedded display. It
cannot support asynchronous ownership, delayed completion, or retry without
regenerating a new frame. It is a valid configuration-selected realization, not
a sufficient universal contract.

### Alternative F — Let each backend own its frame loop

Backend-owned loops are convenient integrations with native event systems,
but backend timing would then control input membership and semantic commit.
A backend may provide wakeups; the semantic runtime must retain cycle
authority.

### Alternative G — Unbounded input or frame queues

Unbounded queues can preserve every value on a desktop until memory is
exhausted. They are invalid on constrained targets and turn slow presentation
into stale latency and uncontrolled growth. Product-specific lossless capture
requires explicit bounded capacity or deterministic producer throttling.

## Rejected Approaches

No approach is formally rejected while this RFC remains a draft. The
alternatives above are candidates for review. Approval should record which
ones were rejected and why before ADR extraction.

## Compatibility

### Source compatibility

Ordinary portable view source should not change solely because cycle and frame
transactions become explicit. Existing host, runtime, and backend APIs may
need migration where they conflate invalidation with immediate presentation,
retain unbounded callbacks, or expose presentation success as a Boolean return
without a stable boundary.

### Behavioral compatibility

Existing behavior that applies the same semantic input more than once,
admits reentrant events mid-cycle, rolls back on backend failure, or leaves
accepted frames without a terminal disposition is intentionally incompatible.
Shared conformance fixtures should preserve valid observable behavior across
static and dynamic profiles.

### Backend and platform compatibility

Synchronous backends can adapt through `completed`; asynchronous backends need
bounded tokens and replayable lifetime ownership. Platform loops remain free
to choose their native wakeup mechanism while invoking the same logical cycle
contract. Drivers continue to own hardware mechanics and do not acquire
semantic responsibilities.

### ABI and data compatibility

No stable ABI or serialized frame format is promised for MVP. Identifiers,
dispositions, and operation fixtures should initially be versioned as source
contracts and test data. Persistent or network serialization requires a
separate contract.

## Testing Strategy

### Deterministic cycle conformance

Run identical initial revisions, admitted batches, resource snapshots,
capability outcomes, and policy through static and dynamic runtimes. Compare
semantic disposition, revision contents, layout, ordered render operations,
frame provenance, and ordered failure summary.

### Admission and reentrancy

Inject input during every logical phase and prove it is deferred beyond the
sealed batch. Exercise source ties, queue overflow, declared coalescing, late
completion, duplicate completion, and stale token handling.

### Commit and fault injection

Inject recoverable and fatal failures in every phase. Verify that pre-commit
failure preserves the prior revision and offers no frame, while post-commit
failure leaves the committed revision intact and terminates only presentation
work.

### Frame lifecycle

Verify that every accepted frame reaches exactly one terminal disposition.
Prove that retry uses the same replayable frame identity and never invokes
semantic handlers, reconciliation, layout, or encoding. Prove that streaming
payloads are neither retained nor retried.

### Backpressure and resources

Stall each backend indefinitely and confirm configured input, frame, token,
completion, and retry bounds. Test supersession, retry exhaustion, viewport
invalidation, resource invalidation, backend epoch reset, and capacity
exhaustion.

### Layer and ownership enforcement

Use dependency checks and test doubles to prove that backends, display
drivers, and transports cannot mutate committed semantic state or inject input
past admission. Confirm that frame envelopes contain no semantic view types or
released cycle-local pointers.

### Supported configurations

Validate in the MVP progression: macOS dynamic, macOS static, Raspberry Pi
1/Linux dynamic, and nRF52840 static. Hardware-free builds and host tests are
useful evidence but do not substitute for connected-device presentation and
resource measurements. Raspberry Pi evidence must confirm `armv6l`; nRF52840
firmware must retain the required hard-float ELF attributes.

## Risks

- **Semantic and visible state can diverge temporarily.** Report presentation
  disposition explicitly and let product policy surface unavailable output;
  do not promise impossible rollback.
- **The frame envelope is mistaken for a required display list.** Keep payload
  kind and lifetime explicit and test the synchronous streaming path on the
  embedded configuration.
- **Streaming hides irreversible partial device writes.** Treat device output
  after commit as presentation work; backend failure terminates the frame and
  may require a later full redraw or device reset.
- **Dynamic implementations hide unbounded work behind tasks or references.**
  Require configured queue and payload bounds in conformance tests.
- **Staging duplicates too much semantic state.** Permit journals, arenas, and
  other atomic-publication strategies and measure RAM, stack, and copy cost.
- **Backend completion timing leaks into admission order.** Sequence completion
  at the runtime boundary and test identical completion orders independently
  of wall-clock timing.
- **Phase fusion obscures failure attribution.** Require logical phase labels
  in test and diagnostic contracts even when calls are inlined.
- **Lossless needs are assumed from a UI policy.** Keep the MVP latest-frame
  policy separate from any future capture or audit product requirement.

## Open Questions

The following questions block approval because they affect the proposed
architecture or its implementability:

1. Is the proposed split between replayable and synchronous-stream frame
   payloads sufficient for both the existing static sink and the first-party
   dynamic backends, or is a third ownership mode required? Backend adapters
   and a static RAM/lifetime audit are needed to close this question.
2. Can each first-party backend name an observable presentation-success
   boundary and produce exactly one terminal disposition without adding
   semantic ownership? Backend contract sketches and failure-path tests are
   required.
3. Which atomic semantic-publication strategies are viable for the current
   dynamic and static runtime representations? A bounded nRF52840 memory/stack
   analysis and a dynamic reentrancy prototype are needed; the observable
   contract is fixed, but feasibility is not yet demonstrated.
4. What minimum fixed-width identifier and token representations can provide
   deterministic wrap behavior for every MVP target? Target lifetime and
   maximum outstanding-work bounds are needed before Specification.

Numerical queue, payload, retry, and timing budgets are required by downstream
Specifications and target validation, but they do not change the ownership or
transaction model proposed here.

## Deferred and Follow-up Work

No deferred artifact is created by this draft. Animation time sampling,
lossless presentation, distributed acknowledgement protocols, and persistent
frame capture are explicit non-goals without an accepted MVP requirement.
If a concrete requirement arises, it must enter the lifecycle or deferred
track with its own source and revisit trigger rather than expanding this RFC.

After approval and ADR extraction, downstream Specifications will need to
select concrete cycle values, staging representations, capacities, backend
presentation boundaries, and conformance fixtures. Those contracts are not
architectural authority in this draft.

## Decision Summary

If this RFC is approved in substantially its proposed form, the following
architecturally significant choices should be extracted into ADRs:

1. GiftUI owns a deterministic run-cycle boundary that seals inputs and
   resources before evaluation and publishes at most one semantic revision.
2. Semantic commit is independent from presentation success; presentation
   retry, drop, supersession, or failure never replays or rolls back semantic
   effects.
3. A frame is an immutable logical envelope over RFC-002's ordered render
   operations, with configuration-selected replayable or synchronous-stream
   payload ownership.
4. Asynchronous presentation and retry require bounded replayable storage and
   stable tokens; every accepted frame reaches one terminal disposition.
5. Admission, frame, propagation, and completion boundaries preserve the same
   observable transaction semantics across static and dynamic profiles.
6. The target host composes bounded admission and presentation policy, while
   semantic runtime, layout, backend, display, and transport ownership remain
   separated as proposed by RFC-002.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](rfc-006-capability-system-architecture.md)
- [RFC-007: GiftUI Delegated Services Architecture](rfc-007-delegated-services-architecture.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
- [GiftUI Runtime Profile Migration Plan](../GiftUI_Runtime_Profile_Migration_Plan.md)
- [GiftUI Embedded Layer Inventory](../GiftUI_Embedded_Layer_Inventory.md)
- Maintainer-provided Run Cycle and Frame Transaction draft attached to the
  RFC authoring request on 2026-08-15.
