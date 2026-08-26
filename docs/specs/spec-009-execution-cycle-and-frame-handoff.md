---
id: SPEC-009
feature: giftui-mvp-architecture
title: Execution Cycle and Frame Handoff Contract
status: review
authors:
  - codex
created: 2026-08-26
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-005
related_adrs:
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-013
  - ADR-014
  - ADR-015
  - ADR-016
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-007
  - SPEC-008
related_future_work:
  - FW-010
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-009: Execution Cycle and Frame Handoff Contract

> **Approval status:** Review draft. The governing Proposal and RFCs, accepted
> architectural decisions, and approved Foundation, Failure, Declarative,
> Layout, and Rendering contracts are authoritative prerequisites. This draft
> does not authorize implementation until a maintainer explicitly approves it.

## Summary

This Specification defines the Wave 4 `EXECUTION` contract in the MVP
Specification Portfolio. It freezes the bounded serialized run cycle, sealed
admission, at-most-once mutation and action application, complete semantic
publication, dirty rederivation, cycle/frame identity and provenance,
synchronous one-shot frame handoff, retryable-refusal convergence, and
presentation-coupled input admission machinery.

The contract supplies recording and scripted seams that verify these behaviors
without a concrete runtime profile, backend, platform loop, pixel surface, or
connected hardware.

## Scope

This contract applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840/Zephyr static configurations. It owns:

- finite execution identifiers and their fail-closed exhaustion rules;
- the ordered non-suspending run-cycle phase machine;
- bounded admission and sealing of normalized pointer events, state-change
  facts, semantic actions, completions, and rederivation intent;
- at-most-once application and complete semantic publication;
- separation of semantic dirtiness, published revision, candidate frame,
  committed frame, and presentation-pending intent;
- cycle and frame failure correlation above SPEC-003;
- the synchronous one-shot offer boundary and commit/abort disposition;
- constant-space latest-revision recovery after retryable refusal;
- generic presentation-provenance validation, per-source pointer sequencing,
  and stable action identity-generation capture; and
- coalesced wake requests for later host-paced opportunities.

The public portable `GiftUI` client surface is unchanged by this Specification.
All declarations below are package SPI unless explicitly stated otherwise.

## Goals

- Give all MVP runtime profiles one deterministic execution meaning.
- Apply every admitted mutation and semantic action at most once.
- Publish only complete semantic revisions while keeping presentation-coupled
  routing staged until accepted handoff.
- Permit direct, bounded, one-shot operation consumption without retaining or
  replaying a render stream.
- Fail closed when provenance, sequence, generation, phase, or capacity cannot
  be proven valid.
- Make refusal recovery finite, paced, constant-space, and independent of
  mutation or frame-payload replay.
- Provide hardware-free fixtures for every phase, race, capacity, and failure
  boundary.

## Non-goals

- Define `@State`, observable-model registration, model storage, or concrete
  state-change fact payloads; `OBSERVABLE` owns those contracts.
- Define `Button`, `disabled`, hit testing, action-payload lowering, or gesture
  policy; `INTERACTION` owns those contracts.
- Define semantic expansion, layout, rendering production, Canvas drawing,
  backend rasterization, surfaces, pixel encoding, physical presentation, or
  target-specific input normalization.
- Select dynamic or static runtime storage, queues, executors, actors, threads,
  tasks, event loops, clocks, timers, or scheduler implementations.
- Select production capacities, retry delays, attempt limits, deadlines, or
  target fatal hooks; later `RUNTIME-PROFILES` and `HOST-CONFIGURATION`
  Specifications own assembled values and policy.
- Guarantee physical visibility, tear-free presentation, transactional client
  reference observation, lossless input, or replay of an operation stream.
- Define post-acceptance backend/transport retry or a replayable render form.

## Dependencies

### Lifecycle prerequisites

- PROPOSAL-003 is accepted.
- RFC-002, RFC-004, and RFC-005 are approved.
- ADR-010 through ADR-016 are accepted.
- MVP Scope requires shared state-driven presentation, interaction, and
  bounded execution across all four target configurations.

### Contract prerequisites

- [SPEC-002](spec-002-portable-foundation.md) owns checked geometry and the
  exact normalized pointer event, source, sequence, ordinal, and presentation-
  revision declarations.
- [SPEC-003](spec-003-failure-outcomes-and-containment.md) owns bounded
  outcomes, failure facts, annotations, correlation, residual policy,
  operational health, and diagnostics.
- [SPEC-006](spec-006-declarative-view-semantics.md) owns structural and stable
  semantic action identity and atomic semantic expansion.
- [SPEC-007](spec-007-layout.md) owns resolved occurrence bounds, clips, and
  layout atomicity.
- [SPEC-008](spec-008-rendering.md) owns atomic normalized render production
  and the one-attempt operation-sink lifetime.

All five prerequisites are approved. This Specification MUST NOT redefine
their types, local errors, atomicity, or ownership.

## Related ADRs

- **ADR-010** requires exactly one synchronous offer of a borrowed ordered
  operation stream, complete reservation before acceptance, atomic logical
  frame/routing commit, and no borrowed data retention after return.
- **ADR-011** requires sealed ordered admission, serialized non-suspending
  mutation and derivation, at-most-once effects, complete semantic publication,
  and dirty rederivation without replay.
- **ADR-012** requires constant-space latest-revision presentation intent,
  separately paced finite refusal recovery, and explicit unavailable/quiescent
  terminal behavior.
- **ADR-013** requires two-stage provenance validation, bounded source
  sequencing, fail-closed cancellation, stable identity-generation capture,
  no callable retention in capture, and release-time revalidation.
- **ADR-014** requires bounded outcomes, conservative containment, exact
  affected scopes, and one-way execution correlation above the failure core.
- **ADR-015** orders mechanical containment, mandatory coordinator effects,
  and only then total residual target policy.
- **ADR-016** makes diagnostics optional and non-authoritative and prohibits
  callbacks, interrupts, backends, and diagnostic sinks from mutating semantic
  state or invoking actions.

## Terminology

**Serialized domain**: The one logical non-suspending execution domain in
which a sealed batch is applied, semantic results are derived, publication
occurs, and the frame offer receives its synchronous disposition.

**Opportunity**: One host-provided invocation in which the runtime may start a
cycle. A wake requests an opportunity but does not itself run a cycle.

**Admission epoch**: The bounded interval in which queued work is selected and
sealed for one cycle. Work arriving after sealing belongs to a later epoch.

**Semantic revision**: The finite identity of one complete published semantic
result. It advances only on complete publication.

**Candidate frame**: One cycle-local frame derived from a published semantic
revision and not yet accepted by an endpoint.

**Presentation revision**: SPEC-002's finite provenance identity for the
committed logical frame and routing state against which presentation-coupled
input may be eligible.

**Presentation intent**: Constant-space knowledge that the latest published
semantic revision still requires a new frame opportunity. It is not a retained
frame, operation stream, semantic graph, or mutation batch.

**Committed action record**: A stable semantic action identity, a finite
generation, enabled state, and current callable payload owned by the later
Interaction contract. Execution owns generation and capture rules, not the
public control or lowering that creates the record.

**Captured action reference**: Only a stable identity-generation pair. It does
not own or retain a callable payload.

## Public Contract

This Specification adds no public declaration to `GiftUI`. Portable views MUST
NOT observe cycle, semantic revision, frame, presentation revision, retry,
queue, wake, action-generation, or backend-offer identities.

The host, runtime profiles, Interaction, Observable State, backends, and
integration targets consume the package SPI below. A public application action
continues to be ordinary synchronous client behavior when invoked by the later
Interaction contract; this Specification does not expose a scheduler or
transaction object to client code.

## Module Contract

`GiftUIExecution` MUST own the execution identities, phase values, limits,
cycle and frame result values, wake seam, admission/capture state machines,
frame envelope, synchronous offer protocol, and scripted recording fixtures.

It MUST depend only on `GiftUI` and `GiftUIRenderCore`. Runtime coordinators
that join semantic, layout, rendering, and execution contracts live above
these owners; the focused execution contract does not import semantic or
layout authority. `GiftUIExecution` MUST NOT import `GiftUIFailureCore`,
`GiftUIFailureExecution`, a runtime-profile implementation, observable-state
implementation, Interaction implementation, capability implementation,
backend, raster provider, platform, driver, OS/RTOS, HAL, or hardware target.

`GiftUIFailureExecution` imports `GiftUIFailureCore` and `GiftUIExecution` and
owns mapping and correlation of execution-local results to SPEC-003 facts.
`GiftUIExecution` MUST NOT import back upward into either failure module.

Dynamic and static runtimes import `GiftUIExecution` and implement its
profile-neutral protocols using their own bounded storage. Backends import
`GiftUIExecution` and `GiftUIRenderCore`; they MUST NOT import a runtime-profile
implementation. Platform input adapters import `GiftUI` and `GiftUIExecution`
but MUST NOT import semantic-runtime storage.

The later `GiftUIInteraction` owner may import `GiftUIExecution` to supply
committed action records, hit resolution, enabled-state checks, and callable
invocation. The later observable-state owner may import `GiftUIExecution` to
submit and apply bounded facts. Neither relationship permits Execution to
import those downstream implementations.

## Types / APIs

Names, raw widths, cases, field meanings, visibility, and behavior in this
section are normative. Layout of generic storage is profile-owned unless a
maximum is stated.

### Execution identities and phases

```swift
package struct RunCycleID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package struct SemanticRevision: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package struct CandidateFrameID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package struct ActionGeneration: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package enum ExecutionPhase: UInt8, Equatable, Sendable {
    case idle = 0
    case admitting = 1
    case mutating = 2
    case deriving = 3
    case publishing = 4
    case offering = 5
    case finalizing = 6
}
```

All raw bit patterns are valid opaque values. No value is a sentinel. Each
identity namespace is local to one assembled runtime lifetime and is neither a
persistent format nor stable across builds. Allocation MUST advance without
aliasing any value that remains queued, admitted, staged, committed, captured,
or pending. Exhaustion or ambiguous wrap returns `identityExhausted`, admits no
new work in that namespace, cancels affected pointer captures when applicable,
and requests target disposition; it MUST NOT silently wrap.

`RunCycleID`, `SemanticRevision`, `CandidateFrameID`, `ActionGeneration`, and
SPEC-002's `PresentationRevision` MUST each occupy exactly four bytes.
`ExecutionPhase` MUST occupy exactly one byte.

### Limits and phase context

```swift
package struct ExecutionLimits: Equatable, Sendable {
    package let maximumInputEvents: UInt16
    package let maximumStateChangeFacts: UInt16
    package let maximumCompletionFacts: UInt16
    package let maximumSemanticActions: UInt16
    package let maximumActiveInputSources: UInt16
    package let maximumCommittedActions: UInt16

    package init?(
        maximumInputEvents: UInt16,
        maximumStateChangeFacts: UInt16,
        maximumCompletionFacts: UInt16,
        maximumSemanticActions: UInt16,
        maximumActiveInputSources: UInt16,
        maximumCommittedActions: UInt16
    )
}

package struct ExecutionContext: Equatable, Sendable {
    package let cycle: RunCycleID
    package let semanticRevision: SemanticRevision?
    package let candidateFrame: CandidateFrameID?
    package let phase: ExecutionPhase
    package init(cycle: RunCycleID,
                 semanticRevision: SemanticRevision?,
                 candidateFrame: CandidateFrameID?,
                 phase: ExecutionPhase)
}
```

All limits except `maximumCompletionFacts` MUST be nonzero for the MVP
interactive runtime. `maximumCompletionFacts` MAY be zero when the assembled
configuration declares no completion producer. An invalid set returns `nil`
and produces no partial value. Production values are selected and validated by
later runtime-profile and host-configuration contracts. A count equal to a
limit is valid; the next reservation is refused before changing ownership or
phase state.

`ExecutionContext` is SPEC-003's focused correlation `Context`. Before the
first complete publication, `semanticRevision` is `nil`; afterward it names
the latest complete revision visible to that cycle. Before a candidate exists,
`candidateFrame` is `nil`; after allocation it retains that identity through
offer and finalization. A failure adapter MUST preserve the detecting phase
and identities exactly.

### Wake requests and pending presentation

```swift
package struct ExecutionWakeReasons: OptionSet, Equatable, Sendable {
    package let rawValue: UInt8
    package init(rawValue: UInt8)

    package static let admittedWork: Self
    package static let semanticDirty: Self
    package static let presentationPending: Self
}

package protocol ExecutionWakeRequester {
    mutating func requestWake(for reasons: ExecutionWakeReasons)
}

package struct PresentationPendingIntent: Equatable, Sendable {
    package let semanticRevision: SemanticRevision
    package let attemptOrdinal: UInt8
    package init(semanticRevision: SemanticRevision, attemptOrdinal: UInt8)
}
```

Only the low three reason bits are valid. The runtime coalesces reasons into at
most one outstanding wake requirement. Calling `requestWake` is non-suspending
and may be repeated after a new clean-to-dirty or not-pending-to-pending
transition; it MUST NOT synchronously invoke the runtime, decide cycle
membership, mutate state, or report successful scheduling back into semantic
control flow. A host may coalesce duplicate requests.

`PresentationPendingIntent` is the complete retained state after retryable
refusal. It MUST NOT retain a root declaration, semantic/layout result, render
workspace, operation, sink, frame envelope, callable, or borrowed resource.
`attemptOrdinal` is zero for the first refused attempt and advances only when a
later separately paced recovery opportunity is itself refused retryably.

### Frame provenance and disposition

```swift
package struct FrameProvenance: Equatable, Sendable {
    package let cycle: RunCycleID
    package let semanticRevision: SemanticRevision
    package let candidateFrame: CandidateFrameID
    package init(cycle: RunCycleID,
                 semanticRevision: SemanticRevision,
                 candidateFrame: CandidateFrameID)
}

package enum FrameOfferDisposition: UInt8, Equatable, Sendable {
    case accepted = 0
    case backpressured = 1
    case retryableRefusal = 2
    case nonRetryableRefusal = 3
    case failed = 4
}

package enum LogicalFrameDisposition: UInt8, Equatable, Sendable {
    case notProduced = 0
    case committed = 1
    case aborted = 2
}

package enum FrameStreamResult: UInt8, Equatable, Sendable {
    case complete = 0
    case producerFailed = 1
    case insufficientCapacity = 2
    case endpointRefused = 3
    case contractViolation = 4
}

package struct FrameOfferResult: Equatable, Sendable {
    package let disposition: FrameOfferDisposition
    package let failure: FrameOfferFailure?
    package init?(
        disposition: FrameOfferDisposition,
        failure: FrameOfferFailure?
    )
}

package enum FrameOfferFailure: UInt8, Equatable, Sendable {
    case invalidEnvelope = 0
    case insufficientCapacity = 1
    case producerFailed = 2
    case contractViolation = 3
}
```

`failure` MUST be non-`nil` exactly when disposition is `.failed`. Operational
backpressure and retryable refusal carry no failure value. Non-retryable
refusal maps to SPEC-003's shared `nonRetryableRefusal`; it is not `.failed`
because the endpoint preserved the refusal contract and retained nothing.
`FrameStreamResult` is the narrow adapter result between a runtime's SPEC-008
producer call and this focused contract; it does not erase the producer's
separately retained local error before failure correlation.

Every accepted candidate receives a fresh `PresentationRevision` at commit.
That revision atomically identifies the committed logical frame, committed hit
map, committed action records, and presentation-coupled routing state. A
candidate frame ID never becomes input provenance and a semantic revision does
not substitute for a presentation revision.

### One-shot frame endpoint

```swift
package protocol SynchronousFrameEndpoint {
    associatedtype Sink: RenderOperationSink

    mutating func offer(
        provenance: FrameProvenance,
        body: (inout Sink) -> FrameStreamResult
    ) -> FrameOfferResult
}
```

The execution coordinator calls `offer` at most once for a candidate. An
endpoint MAY return `.backpressured` or `.retryableRefusal` without calling
`body` when it can prove before consumption that no downstream slot is
available. Otherwise it calls `body` exactly once before returning. The body
synchronously produces SPEC-008's complete atomic stream into the endpoint-
owned sink. The endpoint MUST NOT escape the closure, sink borrow, operation,
glyph, font-resource borrow, provenance borrow, or any other producer-owned
value.

Before returning `.accepted`, the endpoint MUST have consumed the complete
stream, verified its supported vocabulary, reserved all bounded downstream
capacity, copied or derived every value needed later into endpoint-owned
storage, and accepted ordered presentation responsibility. Before returning
any other disposition it MUST have made no irreversible presentation effect
and MUST retain no candidate data or borrow.

The runtime adapter maps successful SPEC-008 production to `.complete`, a
pre-begin producer error to `.producerFailed`, a reported sink-capacity
shortfall to `.insufficientCapacity`, an idle-sink `begin` refusal to
`.endpointRefused`, and a post-begin sink refusal or stream-protocol breach to
`.contractViolation`. It preserves the exact SPEC-008 local error separately
for owner failure mapping. The endpoint maps each non-complete body result
exactly and MUST NOT return `.accepted` for it:

| Body result | Required offer result |
| --- | --- |
| `producerFailed` | `.failed(.producerFailed)` |
| `insufficientCapacity` | `.failed(.insufficientCapacity)` |
| `endpointRefused` | `.nonRetryableRefusal` with no failure payload |
| `contractViolation` | `.failed(.contractViolation)` |

If irreversible output begins while `body` is active, responsibility has
transferred. The endpoint MUST consume or safely drain the complete stream and
return `.accepted`; a later device or transport condition is operational
health and cannot alter the result. Endpoint behavior after acceptance belongs
to later backend/integration contracts.

### Admission and action-capture views

```swift
package enum AdmissionKind: UInt8, Equatable, Sendable {
    case pointer = 0
    case stateChange = 1
    case completion = 2
    case semanticAction = 3
    case dirtyRederivation = 4
    case presentationRecovery = 5
}

package struct AdmissionSummary: Equatable, Sendable {
    package let inputEventCount: UInt16
    package let stateChangeFactCount: UInt16
    package let completionFactCount: UInt16
    package let semanticActionCount: UInt16
    package let includesDirtyRederivation: Bool
    package let includesPresentationRecovery: Bool
    package init(inputEventCount: UInt16,
                 stateChangeFactCount: UInt16,
                 completionFactCount: UInt16,
                 semanticActionCount: UInt16,
                 includesDirtyRederivation: Bool,
                 includesPresentationRecovery: Bool)
}

package protocol ExecutionActionView {
    associatedtype Identity: Equatable, Sendable

    func generation(for identity: Identity) -> ActionGeneration?
    func isEnabled(_ identity: Identity) -> Bool?
    func hit(at point: Point) -> Identity?
}

package struct CapturedAction<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let generation: ActionGeneration
    package init(identity: Identity, generation: ActionGeneration)
}
```

The action-view identity MUST be the exact SPEC-006 semantic action identity;
it MUST NOT be translated, hashed, stringified, or reconstructed. The view is
borrowed from the currently committed routing state and exposes no callable.
`CapturedAction` contains exactly the identity-generation pair and MUST NOT
retain a callable payload, declaration, view, hit map, or committed revision.

The later Interaction contract owns the committed action table and exact
action invocation seam. It MUST install a new `ActionGeneration` whenever a
newly derived callable replaces the payload at an otherwise stable identity.
It MAY preserve the generation only by preserving the exact already committed
payload. Candidate publication or frame refusal MUST NOT replace the committed
record. Execution never compares closures.

### Local results

```swift
package enum ExecutionError: UInt8, Equatable, Sendable {
    case invalidValue = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case identityExhausted = 3
    case invalidProvenance = 4
    case invalidPhase = 5
    case reentrancyViolation = 6
    case requiredFacilityUnavailable = 7
    case invariantViolation = 8
}

package enum SemanticCycleDisposition: UInt8, Equatable, Sendable {
    case unchanged = 0
    case published = 1
    case dirty = 2
}

package enum ExecutionOperational: UInt8, Equatable, Sendable {
    case noChange = 0
    case backpressured = 1
    case retryableRefusal = 2
    case superseded = 3
    case deferredToLaterAdmission = 4
}

package struct RunCycleSummary: Equatable, Sendable {
    package let cycle: RunCycleID
    package let admission: AdmissionSummary
    package let semanticRevision: SemanticRevision?
    package let semanticDisposition: SemanticCycleDisposition
    package let logicalFrameDisposition: LogicalFrameDisposition
    package let committedPresentationRevision: PresentationRevision?
    package let presentationPending: PresentationPendingIntent?
    package init(cycle: RunCycleID,
                 admission: AdmissionSummary,
                 semanticRevision: SemanticRevision?,
                 semanticDisposition: SemanticCycleDisposition,
                 logicalFrameDisposition: LogicalFrameDisposition,
                 committedPresentationRevision: PresentationRevision?,
                 presentationPending: PresentationPendingIntent?)
}

package enum RunCycleResult: Equatable, Sendable {
    case success(RunCycleSummary)
    case operational(ExecutionOperational, RunCycleSummary)
    case failure(ExecutionContext, ExecutionError)
}
```

`.operational` is used only when the cycle completed its mandatory mechanical
effects but ended in its named expected SPEC-003 operational condition. The
owner adapter maps that closed value exactly; the local result does not import
the failure module. `semanticRevision` is `nil` only before any complete
revision has been published. A `.failure` contains the detecting context and
publishes no partial summary.

## Behavior

### Opportunity and sealing

An opportunity starts a cycle only while the coordinator is idle. Reentrant
entry returns `.reentrancyViolation` before inspecting or removing queued
work. A started cycle allocates one non-aliased `RunCycleID`, snapshots the
cycle-stable limits and configuration, enters `.admitting`, and seals one
ordered batch.

Admission order is:

1. validate queued pointer provenance and per-source sequence state;
2. select eligible normalized pointer events in queue order;
3. select state-change facts in producer admission order;
4. select completion facts in producer admission order;
5. include already-admitted semantic actions in their pointer-dispatch order;
6. include at most one dirty-rederivation intent; and
7. include at most one presentation-recovery intent for the latest published
   semantic revision.

Work admitted after the seal stays queued for a later cycle. A producer may
request a wake, but cannot change membership. Each selected count MUST fit its
limit before the item leaves producer-owned pending state. Failure to seal the
complete selected batch returns `.capacityExhausted`; no selected item may be
partly applied or lost.

### Mutation, freeze, derivation, and publication

After sealing, the coordinator enters `.mutating` and applies each admitted
state-change fact and semantic action exactly once in sealed order. A later
failure, refusal, retry, or supersession MUST NOT replay them. Their client
side effects are not assumed reversible.

Mutation-driven invalidations coalesce while the batch is applied. The
coordinator then freezes admission to the active cycle, enters `.deriving`,
and performs semantic expansion, layout, and render preparation from stable
observed state. It MUST NOT suspend or permit reentrant mutation before
publication or failure disposition. Newly arriving work remains pending.

If derivation produces no semantic change and there is no dirty or pending
presentation obligation, the cycle is `.unchanged` and produces no frame. A
complete changed result receives the next non-aliased `SemanticRevision` and
is published atomically in `.publishing`. Publication makes the semantic
revision observable, but keeps candidate hit geometry, action records, and
routing state staged.

A semantic, layout, or render failure before publication discards every
partial downstream result, leaves already-applied observable state dirty,
requests one coalesced `.semanticDirty` wake, and returns failure. Recovery is
a later separately admitted cycle from current state. It MUST NOT replay the
sealed batch or recursively invoke another cycle.

### Candidate frame and handoff

After publication, or when a pending latest revision is rederived, the
coordinator allocates a fresh `CandidateFrameID`, constructs `FrameProvenance`,
and enters `.offering`. Rendering is produced atomically into the endpoint's
sink during the single synchronous `offer` call.

An accepted result atomically:

- commits the logical frame;
- allocates the next non-aliased `PresentationRevision`;
- commits candidate hit geometry, action records, and routing state under that
  revision;
- clears presentation-pending intent for the represented semantic revision;
  and
- leaves later endpoint health outside Core frame disposition.

A non-accepted result aborts the candidate, discards every staged routing and
action change, retains the previous committed logical frame and presentation
revision unchanged, and releases all cycle-local storage. No non-accepted
result may be reported after an irreversible presentation effect.

### Refusal recovery

`.backpressured` and `.retryableRefusal` after semantic publication preserve
only `PresentationPendingIntent` for the latest published revision and request
one coalesced `.presentationPending` wake. A newer published semantic revision
replaces the older pending revision and resets its attempt ordinal to zero.
The refused payload is never retained.

Each recovery opportunity rederives semantic/layout/render output from current
state and creates a fresh candidate frame. It does not apply an old mutation,
invoke an old action, repeat an effect, or replay an operation. A finite host
policy decides pacing and the maximum attempts through SPEC-003's residual
policy seam.

Policy exhaustion, `.nonRetryableRefusal`, or loss of a required presentation
facility marks that facility explicitly unavailable, clears pending retry
intent, cancels active captures, and quiesces affected presentation-coupled
interaction. Mandatory coordinator effects occur before residual policy. A
policy cannot reinterpret refusal as success or preserve an apparently active
stale UI.

### Presentation-coupled pointer admission

The target-local integration first stamps an event with a locally eligible
`PresentationRevision`. If eligibility is stale, unknown, unavailable, or not
yet established, it drops the event and cancels the source sequence without
requiring a queue insertion.

At runtime admission, Execution validates the revision again against the
currently committed routing revision. This closes the race between target
gating and admission. A mismatch is dropped, never deferred or retargeted, and
cancels the source sequence.

For each bounded `InputSourceID`:

- a valid `down` must begin a fresh non-aliased sequence, clear older capture,
  and have the first valid ordinal for that sequence;
- repeated/down-without-resynchronization, missing, duplicate, decreasing, or
  wrapped/ambiguous ordinals are invalid;
- `move` and `up` must match the active sequence and strictly advance ordinal;
- a dropped, malformed, out-of-order, or capacity-refused phase cancels the
  complete source sequence;
- orphaned later phases are consumed without semantic dispatch until a safe
  terminal phase or new unambiguous down resynchronizes the source; and
- sequence or ordinal exhaustion that could alias a late phase quiesces the
  source until resynchronization can be proven.

A validated down may capture the hit action only when the committed action
view reports one exact identity, a current generation, and enabled state. Move
may cancel according to the later Interaction gesture rule. Up invokes no
callable itself; it yields an activation candidate only if provenance remains
valid, the release resolves the same identity, the current generation equals
the captured generation, and the action remains enabled. Any failed check
cancels activation and retains no former payload.

A committed revision may advance during a press without cancelling it when
the exact committed identity-generation record remains unchanged and every
event independently passes provenance validation. Replacement, removal,
movement away from the release hit, disabled state, unavailable presentation,
or ambiguous generation reuse cancels activation.

### Finalization

Every started cycle enters `.finalizing` exactly once and returns to `.idle`.
Finalization releases all cycle-local borrows and scratch storage, records one
local result, and requests any required coalesced wake. It cannot invoke a
client action, endpoint offer, diagnostic sink, or nested cycle.

## State / Lifecycle

The legal phase graph is:

```text
idle -> admitting -> mutating -> deriving -> publishing -> offering
  ^          |          |          |            |            |
  |          +----------+----------+------------+------------+
  |                              failure/operational
  +------------------------- finalizing
```

`publishing` may be skipped for unchanged rederivation, and `offering` may be
skipped when no frame is required or derivation fails. No phase may move
backward, repeat, suspend, or reenter. Endpoint-owned asynchronous work begins
only after accepted return and is not an Execution phase.

The authoritative state axes are independent:

| Axis | Values | Owner |
| --- | --- | --- |
| Semantic | clean, dirty, complete published revision | execution/runtime |
| Candidate | absent, staged, offered | one active cycle |
| Logical frame | previous committed or newly committed | execution/runtime |
| Presentation intent | satisfied, latest revision pending, unavailable | execution plus host policy |
| Physical presentation | endpoint-specific progress/health | backend/integration |
| Input source | synchronized, active sequence/capture, cancelled, quiescent | execution plus target gate |

No transition on the physical-presentation axis may roll back another axis.

## Capability Requirements

This Specification declares no capability and performs no capability
resolution. Synchronous one-shot handoff is common MVP behavior, not a
selectable capability. The host must validate required capabilities before
runtime admission under SPEC-004 and later host contracts.

Capability absence or later operational loss MUST NOT change cycle ordering,
operation vocabulary, identity, or outcome meaning. Loss of a previously
configured required facility is operational health and maps through
`requiredFacilityUnavailable`; it is not silent capability mutation.

## Backend Requirements

A conforming endpoint MUST implement `SynchronousFrameEndpoint`, expose one
finite sink capacity per attempt, and obey the complete reservation, borrow,
and disposition rules above. It MUST NOT evaluate a view, run semantic or
layout work, invoke client behavior, admit input, mutate observable state,
retain the GiftUI stream, or return refusal after irreversible output.

Recording endpoints MUST verify offer/body call counts, exact provenance,
complete stream order, reservation-before-acceptance, no-retention probes, and
post-return borrow invalidation. Backend raster meaning and physical surface
contracts remain downstream.

## Error Handling

Execution detects local errors in this precedence order when multiple
conditions are visible at one boundary: reentrancy, phase, identity/provenance,
value/arithmetic, capacity, required-facility state, then invariant failure.
It stops at the first failure, performs mandatory mechanical containment, and
returns no partial successful summary.

The `GiftUIFailureExecution` adapter MUST map local failures exactly:

| Execution error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| invalid value | `invalidValue` | `execution` | `operation` | `contained` |
| arithmetic overflow | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| capacity exhausted before publication | `capacityExhausted` | `execution` | `activeCycle` | `contained` |
| capacity exhausted during candidate preparation/offer | `capacityExhausted` | detecting producer or `backend` | `candidateFrame` | `contained` |
| identity exhausted | `invalidIdentity` | `execution` | smallest affected scope | `contained` unless safe reuse cannot be proven |
| invalid provenance | `invalidProvenance` | `execution` | `operation` | `contained` |
| invalid phase | `invalidPhase` | `execution` | `activeCycle` | `contained` |
| reentrancy violation | `reentrancyViolation` | `execution` | `activeCycle` | `safetyNotProven` |
| required facility unavailable | `requiredFacilityUnavailable` | detecting integration or `execution` | `runtime` | `contained` |
| invariant violation | `invariantViolation` | `execution` | `runtime` | `safetyNotProven` |

`smallest affected scope` is `.operation` for one rejected new allocation,
`.activeCycle` when the active cycle cannot continue, and `.runtime` when
alias-free future allocation cannot be proven. An adapter MUST NOT narrow the
scope or improve containment without contract evidence.

Expected outcomes map as follows:

| Local event | SPEC-003 operational kind | origin | scope |
| --- | --- | --- | --- |
| no semantic change | `noChange` | `execution` | `activeCycle` |
| bounded endpoint pressure | `backpressured` | `backend` | `candidateFrame` |
| retryable endpoint refusal | `retryableRefusal` | `backend` | `candidateFrame` |
| newer pending revision replaces older intent | `superseded` | `execution` | `candidateFrame` |
| valid work arrived after the seal | `deferredToLaterAdmission` | `execution` | `activeCycle` |

After mapping, the adapter wraps the exact fact and `ExecutionContext` in
`GiftUICorrelatedFailure`. Optional annotations or diagnostics cannot replace
or alter either. Mechanical containment and mandatory cycle/frame effects run
before residual target policy.

Diagnostics MAY observe outcomes and health transitions, but diagnostic
selection, saturation, loss, or sink failure MUST NOT change admission,
publication, wake state, frame disposition, retry count, input cancellation,
or client action behavior.

## Performance Requirements

The shared contract MUST support the Signal Analyzer workload of 80 admitted
state-change facts per second with nominal 250-millisecond presentation
opportunities without requiring one cycle or frame per fact.

For the independent approval fixture, all profiles MUST accept:

- `maximumInputEvents: 32`;
- `maximumStateChangeFacts: 32` per cycle;
- `maximumCompletionFacts: 8` per cycle;
- `maximumSemanticActions: 32` per cycle;
- `maximumActiveInputSources: 4`; and
- `maximumCommittedActions: 32`.

These are fixture limits, not production host capacities. The fixture runs 20
state-change facts between each of four presentation opportunities, proves one
coalesced wake and one publication per opportunity, and never exceeds one
pending presentation intent.

The following value ceilings apply on every supported compiler:

- `ExecutionLimits` exactly 12 bytes;
- `ExecutionContext` no greater than 24 bytes;
- `FrameProvenance` exactly 12 bytes;
- `PresentationPendingIntent` no greater than 8 bytes; and
- `FrameOfferResult` no greater than 2 bytes.

Static fixtures MUST allocate zero heap bytes in admission, sequencing, cycle
coordination, refusal recovery, wake coalescing, correlation construction, and
one-shot offer. Dynamic fixtures remain bounded by configured limits and MUST
report queue/workspace high-water marks.

The contract driver MUST record per-phase duration, seal-to-publication and
offer latency, dirty-to-opportunity latency, retry pacing/attempt count, queue
high-water marks, stale-input drops, sequence and activation cancellations,
operation count, stack high-water, heap allocation count, and linked-section
delta. Measurements are evidence, not alternate requirements.

## Compatibility

Portable view source is unchanged. Existing proof-of-concept APIs that draw
immediately on invalidation, let platforms or backends dispatch actions,
route input against the newest hit map without provenance, retain unbounded
input/work, compare closures, retain frame operations, or equate frame commit
with physical visibility are incompatible and require migration.

Raw execution identities are not ABI, persisted data, wire formats, or stable
diagnostic codes. Profile implementations may use different internal storage
only when all observable order, equality, failure, lifetime, and limit behavior
is identical.

## Testing Requirements

### Required fixtures

`Tests/ContractFixtures/SPEC009/` MUST contain:

- `cycles.yaml` for phase, ordering, publication, dirty recovery, and
  at-most-once cases;
- `handoff.yaml` for complete acceptance, each refusal, irreversible-output,
  reservation, discard, and post-return lifetime cases;
- `input.yaml` for every phase, ordinal, stale provenance, race, cancellation,
  replacement, movement, disabled, exhaustion, and resynchronization case;
- `recovery.yaml` for pending-intent coalescing, newer-revision supersession,
  finite attempts, non-retryable refusal, unavailability, and quiescence; and
- `signal-analyzer.yaml` for the 80-facts/second and 250-millisecond workload.

Fixtures compare exact numeric fields and symbolic stable identity tokens;
they MUST NOT compare pointers, closure identity, strings, metatype addresses,
hash collisions, enum memory bytes, or profile-private raw semantic identity.

### Contract tests

Tests MUST:

- inject work before sealing, during every active phase, during offer, and
  during finalization and verify exact current/later admission membership;
- apply mutations and actions, fail each later phase, refuse offers, supersede
  pending work, and inject post-handoff failure while proving at-most-once
  effects;
- verify complete publication and that no partial semantic/layout/render or
  routing result becomes current;
- fail derivation after mutation and prove dirty wake/rederivation without
  replay or synchronous recursion;
- verify semantic publication survives every presentation outcome;
- script every endpoint disposition and prove exact commit/abort state,
  operation/body call counts, complete reservation, no retention, and accepted
  responsibility after irreversible output;
- publish newer revisions while pending and prove constant-space latest-only
  coalescing and finite terminal policy;
- race target-local input gating with a newer commit and prove the stale event
  drops at runtime admission;
- drop each pointer phase at every capacity and validation boundary and prove
  complete sequence cancellation and no orphan activation;
- preserve one capture over an unrelated committed revision, then remove,
  move, disable, or replace the action and prove release behavior;
- exhaust every identity and capacity at exactly the bound and one over;
- compare recording, dynamic, and static transcripts field by field; and
- fault diagnostic selection and sinks and prove identical correctness.

### Dependency and target evidence

Import tests MUST enforce the exact `GiftUIExecution` dependency boundary and
the one-way `GiftUIFailureExecution -> GiftUIExecution` edge. They MUST reject
execution imports of failure, runtime profiles, downstream state/interaction,
capabilities, backends, platforms, and drivers; reject backend imports of
runtime implementations; and reject input adapters importing semantic-runtime
storage.

The contract suite MUST run as macOS dynamic, macOS static, Raspberry Pi ARMv6
cross-build, and nRF52840 Embedded Swift cross-build fixtures. The nRF build
MUST verify the Cortex-M4F hard-float VFP calling convention. Cross-build
success is not connected-hardware evidence, and no connected board is required
for Specification approval.

## Acceptance Criteria

- [ ] **EX-001:** All execution identities, phase values, limits, contexts,
  wake reasons, pending intent, frame provenance/results, and local results
  match the exact declarations, raw widths, construction, and value-layout
  bounds in this contract.
- [ ] **EX-002:** Scripted cycles seal exact ordered membership, defer all
  after-seal work, apply every mutation/action at most once, freeze derivation,
  publish only complete revisions, and always finalize to idle.
- [ ] **EX-003:** Every semantic/layout/render failure after mutation leaves
  state dirty, requests one paced wake, publishes no partial result, and
  rederives from current state without replay or immediate recursion.
- [ ] **EX-004:** Every frame is offered at most once; acceptance occurs only
  after complete stream consumption and reservation, atomically commits frame
  plus routing state, and retains no borrowed operation or resource.
- [ ] **EX-005:** Every pre-acceptance refusal has no irreversible effect,
  aborts the candidate, preserves the previous committed frame/routing state,
  and retains no payload; every post-output condition remains accepted
  endpoint health and cannot reopen Core disposition.
- [ ] **EX-006:** Retryable refusal retains only the latest constant-space
  presentation intent, coalesces newer revisions, requests separately paced
  recovery, and reaches accepted handoff or explicit unavailable/quiescent
  terminal state under finite policy.
- [ ] **EX-007:** Target and runtime provenance checks, pointer phase/ordinal
  sequencing, drop cancellation, resynchronization, and identity exhaustion
  pass the complete `input.yaml` corpus without deferred input or historical
  hit-map storage.
- [ ] **EX-008:** Captures contain only the exact SPEC-006 identity-generation
  pair; stable records survive unrelated revision changes, while removal,
  movement, disabled state, payload replacement, generation mismatch, or
  ambiguous reuse invokes neither former nor replacement payload.
- [ ] **EX-009:** Every local error and operational event maps to the exact
  SPEC-003 fact, scope, containment, and `ExecutionContext`; mandatory
  containment precedes total residual policy and diagnostics never affect
  correctness.
- [ ] **EX-010:** Recording, dynamic, and static fixtures produce equal sealed
  membership, phase order, identities, results, frame dispositions, input
  cancellations, and failure mappings for the same inputs and limits.
- [ ] **EX-011:** The Signal Analyzer fixture sustains its required admission
  and presentation workload within the declared fixture limits, with
  coalesced wakes/publications and at most one pending presentation intent.
- [ ] **EX-012:** Static paths allocate zero heap bytes, all value-layout and
  high-water requirements pass, package dependency tests preserve the focused
  execution boundary, and both cross-build configurations produce the required
  non-hardware evidence.
- [ ] **EX-013:** Review finds no public observable-state syntax/storage,
  Button/disabled or callable-lowering contract, concrete runtime-profile
  storage, capability catalogue, rasterization/backend realization, host
  production capacity/pacing choice, platform driver, or connected-hardware
  requirement in this Specification.

## Implementation Notes

This section is non-authoritative. Existing `DynamicRuntime`, `StaticRuntime`,
`GiftUIApplication`, platform loops, hit-region storage, and framebuffer
application code are migration evidence only. A conforming migration should
first provide the recording coordinator and endpoint fixtures, then adapt both
runtime profiles to the same execution values and scripted corpus.

The synchronous endpoint may expose its sink from fixed storage, a bounded
dynamic buffer, or direct streaming storage. Its representation does not alter
the rule that acceptance follows complete validation/reservation and that the
GiftUI operation borrow ends when `offer` returns.

## Open Issues

None. Production capacities, concrete retry pacing, observable-state fact
payloads/storage, committed action-table storage and callable invocation,
runtime-profile workspace ownership, backend raster realization, and target
eligibility evidence are deliberately owned by later portfolio Specifications.
If any of those requires changing this phase, identity, ownership, or handoff
architecture, work MUST return to RFC/ADR review.

## Deferred and Follow-up Work

- [FW-010](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves optional post-handoff recovery using backend-owned derived data.
  It remains outside MVP execution correctness until a supported backend
  demonstrates its recorded revisit trigger.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  future bounded replayable delivery form. MVP remains synchronous and
  one-shot; this Specification adds no replay storage.

Current MVP scope is unchanged.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-012](../adrs/adr-012-bounded-handoff-refusal-recovery.md)
- [ADR-013](../adrs/adr-013-provenance-validated-input-admission.md)
- [ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-006](spec-006-declarative-view-semantics.md)
- [SPEC-007](spec-007-layout.md)
- [SPEC-008](spec-008-rendering.md)
- [SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [Legacy GiftUI Framework Specification](../GiftUI_Framework_Spec.md)
