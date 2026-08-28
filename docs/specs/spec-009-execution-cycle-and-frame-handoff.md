---
id: SPEC-009
feature: giftui-mvp-architecture
title: Execution Cycle and Frame Handoff Contract
status: review
authors:
  - codex
created: 2026-08-26
updated: 2026-08-28
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-011
related_adrs:
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-033
  - ADR-014
  - ADR-015
  - ADR-016
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-007
  - SPEC-008
  - SPEC-010
  - SPEC-011
  - SPEC-013
  - SPEC-014
  - SPEC-012
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

> **Review status:** The previously approved contract was amended on
> 2026-08-28 with a bounded generic focused-owner failure carrier required by
> SPEC-013. The amendment is not authoritative until renewed human approval.

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
- ADR-010 through ADR-012 and ADR-014 through ADR-016 are accepted; ADR-033 is
  accepted and supersedes ADR-013.
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

SPEC-002, SPEC-003, SPEC-006, SPEC-007, and SPEC-008 are approved. This
Specification MUST NOT redefine their types, local errors, atomicity, or
ownership.

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
- **ADR-033** requires two-stage provenance validation, bounded source
  sequencing, fail-closed cancellation, stable identity-generation capture,
  no action/callable/model retention in capture, release-time revalidation,
  and final model-target generation validation before dispatch.
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

**Committed bound action record**: A stable semantic action identity, finite
action generation, enabled state, bounded application-action value, and opaque
observable-model target generation owned by the later Interaction contract.
Execution owns action-generation and capture rules, not the public control,
target binding, or dispatch that creates and consumes the record.

**Captured action reference**: Only a stable identity-generation pair. It does
not own or retain an action value, target generation, callable, handler, or
model.

## Public Contract

This Specification adds no public declaration to `GiftUI`. Portable views MUST
NOT observe cycle, semantic revision, frame, presentation revision, retry,
queue, wake, action-generation, or backend-offer identities.

The host, runtime profiles, Interaction, Observable State, backends, and
integration targets consume the package SPI below. A public application action
is a bounded typed value dispatched synchronously by the later Interaction
contract; this Specification does not expose a scheduler or transaction object
to client code.

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
committed bound action records, hit resolution, enabled-state checks, and the
dispatch admission seam. The later observable-state owner may import
`GiftUIExecution` to
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

package struct ObservableTargetGeneration: Equatable, Hashable, Sendable {
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

Every raw bit pattern of these five four-byte identity structs is a valid
opaque value; no identity value is a sentinel. Each identity namespace is
local to one assembled runtime lifetime and is neither a persistent format nor
stable across builds. `GiftUIExecution` owns only the opaque
`ObservableTargetGeneration` value declaration so downstream focused modules
can exchange it through their existing Execution dependency; SPEC-010 owns its
allocation, semantic meaning, replacement, retirement, and lookup rules.
`RunCycleID`,
`SemanticRevision`, `CandidateFrameID`, SPEC-002's `PresentationRevision`, and
the runtime-wide `ActionGeneration` namespace each allocate raw value `0`
first and then the exact checked successor. No execution-owned raw value is
reused during that runtime lifetime. Failure to form the successor returns
`identityExhausted`, admits or commits no new work in that namespace, cancels
affected pointer captures when applicable, and requests target disposition;
it MUST NOT silently wrap.

An identity needed before an irreversible boundary MUST be reserved before
that boundary. In particular, the candidate's presentation revision and every
new action generation are reserved before `offer`. Reservation makes the raw
value unavailable to later allocations but does not publish or commit it; an
aborted candidate permanently retires the reservation. This bounded monotonic
rule avoids live-alias discovery and makes exhaustion equivalent in dynamic
and static profiles.

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
    package let cycle: RunCycleID?
    package let semanticRevision: SemanticRevision?
    package let candidateFrame: CandidateFrameID?
    package let phase: ExecutionPhase
    package init(cycle: RunCycleID?,
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
limit is valid. Queue or committed-storage reservation beyond its configured
capacity is refused before changing ownership or phase state; pending work
beyond a per-cycle selection limit is deferred by the prefix rule under
Opportunity and sealing.

`ExecutionContext` is SPEC-003's focused correlation `Context`. `cycle` is
`nil` whenever no cycle is active, including an ordinary idle admission result
and an idle opportunity that cannot allocate a non-aliased cycle ID; reentrant
entry names the already-active cycle. Before the first complete publication,
`semanticRevision` is `nil`; afterward it names the latest complete revision
visible at detection. Before a candidate exists, `candidateFrame` is `nil`;
after allocation it retains that identity through offer and finalization. A
failure adapter MUST preserve the detecting phase and identities exactly.

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
    package let retryableRefusalCount: UInt8
    package init(semanticRevision: SemanticRevision,
                 retryableRefusalCount: UInt8)
}
```

`admittedWork`, `semanticDirty`, and `presentationPending` have raw values
`0x01`, `0x02`, and `0x04` respectively.
`ExecutionWakeReasons.init(rawValue:)` MUST mask its input with `0x07`; only the
normalized low three bits are stored, compared, or forwarded. The runtime owns
one accumulated reason set and one `wakeOutstanding` bit. On the empty-to-
nonempty transition it sets the bit and calls `requestWake` exactly once. Entry
to an idle opportunity acknowledges the preceding request by atomically taking
the accumulated reasons, clearing them, and clearing `wakeOutstanding` before
`.admitting`. A new reason arising after that take, including during an active
cycle or finalization, performs a new empty-to-nonempty transition and cannot
be lost behind the acknowledged request. A redundant host opportunity is
permitted and produces the ordinary no-change result.

Calling `requestWake` is non-suspending and MUST NOT synchronously invoke the
runtime, decide cycle membership, mutate state, or report successful scheduling
back into semantic control flow. A host may coalesce duplicate requests but
MUST eventually provide an opportunity for each observed empty-to-nonempty
transition unless the runtime has become quiescent.

`PresentationPendingIntent` is the complete retained state after backpressure
or retryable refusal. It MUST NOT retain a root declaration, semantic/layout
result, render workspace, operation, sink, frame envelope, action value, target
generation, callable, handler, model, or borrowed resource.
`retryableRefusalCount` is `0` when pending intent was created only by
backpressure and otherwise equals the number of retryable refusals recorded
for this semantic revision. The first retryable refusal stores `1`. A host
configuration MUST choose a maximum in `1...255`. After incrementing for a
retryable refusal, a count equal to the configured maximum is exhausted and is
not retained; the coordinator performs the terminal unavailable/quiescent
transition. Checked increment failure is treated identically and never wraps.
Backpressure neither increments nor resets this counter. A newer published
semantic revision replaces the complete intent and starts again at `0` or `1`
according to the outcome of its first offer.

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

package enum FrameRefusalOrigin: UInt8, Equatable, Sendable {
    case renderProducer = 0
    case endpoint = 1
}
```

`failure` MUST be non-`nil` exactly when disposition is `.failed`. Operational
backpressure and retryable refusal carry no failure value. Non-retryable
refusal maps to SPEC-003's shared `nonRetryableRefusal`; it is not `.failed`
because the endpoint preserved the refusal contract and retained nothing.
`FrameStreamResult` is the narrow adapter result between a runtime's SPEC-008
producer call and this focused contract; it does not erase the producer's
separately retained local error before failure correlation.

Every candidate reserves a fresh `PresentationRevision` before `offer`; only
acceptance commits it. That revision atomically identifies the committed
logical frame, committed hit map, committed bound action records, and presentation-
coupled routing state. An aborted reservation is retired and never reused. A
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
endpoint returns `.backpressured` without calling `body` only when its
currently configured bounded downstream slots are full. It returns
`.retryableRefusal` without calling `body` only for another explicitly
retryable pre-consumption condition whose retry budget is owned by the host.
It returns `.nonRetryableRefusal` without calling `body` only when it can
deterministically reject the valid envelope while preserving the refusal
contract. These meanings are mutually exclusive; lack of a slot is always
`.backpressured`, never `.retryableRefusal`.

After accepting the envelope for consumption, the endpoint calls `body`
exactly once before returning. The body synchronously produces SPEC-008's
complete atomic stream into the endpoint-owned sink. The endpoint MUST NOT
escape the closure, sink borrow, operation, glyph, font-resource borrow,
provenance borrow, or any other producer-owned value.

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
for owner failure mapping. The endpoint maps every body result exactly:

| Body result | Required offer result |
| --- | --- |
| `complete` | `.accepted` |
| `producerFailed` | `.failed(.producerFailed)` |
| `insufficientCapacity` | `.failed(.insufficientCapacity)` |
| `endpointRefused` | `.nonRetryableRefusal` with no failure payload |
| `contractViolation` | `.failed(.contractViolation)` |

`.failed(.invalidEnvelope)` and a direct
`.failed(.contractViolation)` are permitted only before `body`. The remaining
`.failed` payloads are legal only as the matching body-result mapping above.
Any other call/result combination is itself an endpoint contract violation and
is normalized by the coordinator to `.failed(.contractViolation)`. In
particular, a complete body cannot later become backpressure or refusal.

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

package enum ExecutionAdmissionResult: UInt8, Equatable, Sendable {
    case queued = 0
    case capacityRefused = 1
    case unavailable = 2
    case invalidValue = 3
    case invalidProvenance = 4
}

package struct ExecutionAdmissionOutcome: Equatable, Sendable {
    package let result: ExecutionAdmissionResult
    package let context: ExecutionContext
    package init(result: ExecutionAdmissionResult,
                 context: ExecutionContext)
}

package protocol ExecutionAdmissionSink {
    associatedtype StateChangeFact: Sendable
    associatedtype CompletionFact: Sendable

    mutating func submit(pointer: NormalizedPointerEvent)
        -> ExecutionAdmissionOutcome
    mutating func submit(stateChange: StateChangeFact)
        -> ExecutionAdmissionOutcome
    mutating func submit(completion: CompletionFact)
        -> ExecutionAdmissionOutcome
}

package protocol ExecutionOpportunityRunner {
    associatedtype OwnerFailure: Equatable & Sendable
    mutating func runOpportunity() -> RunCycleResult<OwnerFailure>
}

package struct AdmissionSummary: Equatable, Sendable {
    package let inputEventCount: UInt16
    package let stateChangeFactCount: UInt16
    package let completionFactCount: UInt16
    package let semanticActionCount: UInt16
    package let includesDirtyRederivation: Bool
    package let includesPresentationRecovery: Bool
    package init?(inputEventCount: UInt16,
                  stateChangeFactCount: UInt16,
                  completionFactCount: UInt16,
                  semanticActionCount: UInt16,
                  includesDirtyRederivation: Bool,
                  includesPresentationRecovery: Bool,
                  limits: ExecutionLimits)
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
borrowed from the currently committed routing state and exposes no action
value, target generation, callable, handler, or model. `CapturedAction`
contains exactly the identity-generation pair and MUST NOT retain any of those
values, a declaration, view, hit map, or committed revision.

`ExecutionAdmissionSink` is the complete profile-neutral producer seam. Every
return carries an `ExecutionContext` snapshot: it names the active cycle and
phase when one exists, or uses `cycle == nil`, `candidateFrame == nil`, and
`.idle` otherwise; its semantic revision is the latest complete published
revision, or `nil` before the first publication. A `.queued` result means the
runtime copied or moved the complete value into its bounded pending storage,
owns that queued copy, accumulates `.admittedWork` using the wake reason-set
empty-to-nonempty rule, and will consider it only at a later seal. It does not
promise membership in the currently active cycle. A `.capacityRefused` result
changes no state-change or completion ownership and applies no semantic
effect; the runtime retains no copy and the caller may retry only as permitted
by the payload owner's at-most-once contract. For pointer input it additionally
performs the mandatory source-sequence cancellation before returning.
`.unavailable` means the runtime or presentation-coupled input facility is
quiescent; it queues nothing and pointer submission cancels the source.
`.invalidValue` means the submission family is disabled by the cycle-stable
configuration or the supplied owner value failed its owning value contract; it
queues nothing, requests no wake, and applies no effect.
`.invalidProvenance` is returned only for pointer submission whose presentation
revision does not match the then-current committed routing revision or whose
source, sequence, or ordinal is inadmissible against the bounded producer-order
state. It queues nothing and performs complete source-sequence cancellation.

Complete source-sequence cancellation removes every already queued phase of
that sequence, clears any staged or active capture and activation, retains no
former action value, target generation, callable, handler, or model, and
advances only sequence state whose validity was already
proven. Later phases cannot dispatch semantically. A numerically invalid
sequence never becomes a trusted resynchronization baseline.

Pointer submission performs that immediate runtime validation before queue
reservation. A queued pointer is independently revalidated when selected for
a later seal because a newer frame may have committed in the meantime.

When `maximumCompletionFacts == 0`, `submit(completion:)` always returns
`.invalidValue` and does not request a wake. A quiescent runtime returns
`.unavailable` for every submission. Otherwise queue saturation returns
`.capacityRefused`; the result does not depend on whether a host opportunity
is already pending.

Concrete state-change and completion payload declarations and storage belong
to their owning downstream Specifications. They MUST be finite `Sendable`
values with owner-defined application seams; this protocol neither stores an
existential nor invokes them at submission time. `ExecutionOpportunityRunner`
is the complete host entry seam. Hosts invoke it only as a serialized
opportunity; wake callbacks never invoke it synchronously. Dynamic and static
coordinators MUST conform to these same protocols, and the recording fixture
MUST drive them through these protocols rather than profile-private entry
points.

`AdmissionSummary.init?` rejects a count above its corresponding supplied
limit, a nonzero completion count when completions are disabled, or a semantic
action count greater than the admitted pointer-event count. The stored value
does not retain `limits`. The two Boolean fields are true exactly when the
corresponding one-bit intent joined the sealed batch; a dropped or deferred
intent is false.

The later Interaction contract owns the committed bound action table and exact
dispatch seam. It MUST install a new `ActionGeneration` whenever the bounded
action value, observable-model target generation, or any other binding field
changes at an otherwise stable identity. It MAY preserve the generation only
by preserving the exact already committed complete bound record. Candidate
publication or frame refusal MUST NOT replace the committed record. Execution
never compares action behavior, handlers, models, or closures.

`ActionGeneration` is allocated from the one runtime-wide monotonic namespace
defined above, not from an independent per-action counter. A staged candidate
reserves generations for all replacements before publication and offer.
Exhaustion discards the staged action table, prevents publication of that
candidate, cancels every capture whose non-aliasing can no longer be proven,
and reports `identityExhausted`; it never preserves a replacement under the
former generation.

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

package struct ExecutionOperationalEvents: OptionSet, Equatable, Sendable {
    package let rawValue: UInt8
    package init(rawValue: UInt8)

    package static let noChange: Self
    package static let backpressured: Self
    package static let retryableRefusal: Self
    package static let superseded: Self
    package static let deferredToLaterAdmission: Self
}

package enum PresentationIntentState: UInt8, Equatable, Sendable {
    case satisfied = 0
    case pending = 1
    case unavailable = 2
}

package enum RunCycleFailure<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable
{
    case execution(ExecutionError)
    case renderProduction(RenderProductionError)
    case frameOffer(FrameOfferFailure)
    case nonRetryableRefusal(FrameRefusalOrigin)
    case focusedOwner(OwnerFailure)
}

package struct RunCycleSummary: Equatable, Sendable {
    package let cycle: RunCycleID
    package let admission: AdmissionSummary
    package let semanticRevision: SemanticRevision?
    package let semanticDisposition: SemanticCycleDisposition
    package let logicalFrameDisposition: LogicalFrameDisposition
    package let committedPresentationRevision: PresentationRevision?
    package let presentationIntentState: PresentationIntentState
    package let presentationPending: PresentationPendingIntent?
    package let operationalEvents: ExecutionOperationalEvents
    package init?(cycle: RunCycleID,
                  admission: AdmissionSummary,
                  semanticRevision: SemanticRevision?,
                  semanticDisposition: SemanticCycleDisposition,
                  logicalFrameDisposition: LogicalFrameDisposition,
                  committedPresentationRevision: PresentationRevision?,
                  presentationIntentState: PresentationIntentState,
                  presentationPending: PresentationPendingIntent?,
                  operationalEvents: ExecutionOperationalEvents)
}

package enum RunCycleResult<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable
{
    case success(RunCycleSummary)
    case operational(ExecutionOperational, RunCycleSummary)
    case failure(
        ExecutionContext,
        RunCycleFailure<OwnerFailure>,
        RunCycleSummary?
    )
}
```

`OwnerFailure` is the coordinator's finite, statically known sum of exact
focused errors from owners that participate in the assembled run cycle but do
not belong to `GiftUIExecution`. It MUST be an inline value with no existential,
reference, closure, string, or diagnostic payload. A runtime-profile
coordinator uses the exact sum declared by its approved Specification; a
focused standalone Execution fixture uses an uninhabited or one-case fixture
value. `GiftUIExecution` stores and returns the value without inspecting,
mapping, re-ranking, or translating it.

`.focusedOwner(error)` is selected when such an owner has already chosen its
exact local failure. The accompanying `ExecutionContext` is captured at that
owner boundary after mandatory mechanical containment and before SPEC-003
mapping. The first adapter that imports the focused owner and failure modules
maps the retained value; diagnostics are never the carrier. Later cleanup
cannot replace the selected focused error.

`noChange`, `backpressured`, `retryableRefusal`, `superseded`, and
`deferredToLaterAdmission` have raw values `0x01`, `0x02`, `0x04`, `0x08`, and
`0x10` respectively. `ExecutionOperationalEvents.init(rawValue:)` masks its
input with `0x1f`. Every event observed by the cycle is retained in
`operationalEvents`.

A failure always selects `.failure` even when its complete summary records
operational events observed earlier in the cycle. Otherwise a nonempty set
selects `.operational`, with its primary value chosen in this precedence order:
`retryableRefusal`, `backpressured`, `superseded`,
`deferredToLaterAdmission`, `noChange`. The owner adapter maps only that
primary value to the one SPEC-003 operational outcome; the complete set remains
deterministic transcript evidence and MAY be projected diagnostically.
`.success` is used exactly when there is no failure and the set is empty.

`semanticRevision` names the latest complete published revision after the
cycle and is `nil` only before any publication. `committedPresentationRevision`
names the authoritative committed routing revision after the cycle, including
the unchanged previous revision after an abort; it is `nil` only before any
frame commit. `presentationPending` is non-`nil` exactly when
`presentationIntentState == .pending`, and its semantic revision MUST equal
`semanticRevision`. It is `nil` for `.satisfied` and `.unavailable`.

The failable `RunCycleSummary` initializer rejects any intrinsic violation of
those rules, `.published` with no semantic revision, `.committed` with no
committed presentation revision, `.committed` with pending or unavailable
intent, any pending intent whose revision is not the latest semantic revision,
simultaneous backpressure and retryable-refusal events, or a `noChange` event
combined with backpressure, retryable refusal, or supersession. Admission
counts are validated against the cycle-stable limits before construction.
`noChange` additionally requires unchanged semantics, no produced frame, and
satisfied intent; backpressure requires an aborted frame and pending intent;
retryable refusal requires an aborted frame and pending or unavailable intent;
and supersession requires a newly published semantic revision. The coordinator
additionally compares the entry state, reserved identities, local result, and
completed summary and MUST reject any transition not present in the exhaustive
lifecycle matrix below; those historical facts are intentionally not
duplicated in the summary value.

A started cycle always returns a complete summary after mandatory mechanical
effects, including a `.dirty` summary for pre-publication failure and an
`.aborted` summary for post-publication offer failure. The summary is `nil`
only when entry was rejected before a new cycle started: reentrant entry uses
the active context, while cycle-identity exhaustion uses an idle context with
`cycle == nil`. A failure summary is completed state evidence, not a partial
success, and cannot weaken or replace its failure.

## Behavior

### Opportunity and sealing

An opportunity starts a cycle only while the coordinator is idle. Reentrant
entry returns `.failure(activeContext,
.execution(.reentrancyViolation), nil)` before acknowledging a wake or
inspecting or removing queued work. Idle entry acknowledges wake state as
specified above and allocates one non-aliased `RunCycleID`. Allocation failure
returns `.failure(idleContextWithNilCycle,
.execution(.identityExhausted), nil)`, queues no new work, and routes the
runtime-scoped terminal disposition. That context has `cycle == nil`, the
latest published semantic revision, `candidateFrame == nil`, and
`phase == .idle`. A started cycle snapshots the cycle-
stable limits and configuration, enters `.admitting`, and seals one ordered
batch.

Admission order is:

1. select a prefix of queued pointer events and validate provenance and
   per-source sequence state in queue order;
2. stage the resulting source/capture transitions and same-cycle activation
   candidates in pointer order;
3. select state-change facts in producer admission order;
4. select completion facts in producer admission order;
5. include the staged activation candidates as semantic actions in their
   pointer-dispatch order;
6. include at most one dirty-rederivation intent; and
7. include at most one presentation-recovery intent for the latest published
   semantic revision.

For each queued category, the cycle selects at most its cycle-stable limit; a
valid suffix beyond that limit stays queued, records
`.deferredToLaterAdmission`, and requests the next admitted-work wake. Work
submitted after the seal likewise stays queued and records that event. A
producer may request a wake but cannot change current membership.

Seal-time pointer validation is staged until the complete seal succeeds. On
the first stale, malformed, or invalid selected pointer, the coordinator
removes every queued phase of that source sequence, commits mandatory
cancellation, leaves all other selected work queued in original order,
requests another admitted-work wake when any remains, and returns
`.failure(context, .execution(.invalidProvenance), summary)`, where the
complete summary has zero admission counts and preserves the authoritative
entry state. The rejected sequence contributes nothing to `inputEventCount`.
If a valid pointer would create a semantic action beyond
`maximumSemanticActions`, the same all-sequence removal and other-work
preservation applies, but the failure is
`.execution(.capacityExhausted)`. A new source beyond
`maximumActiveInputSources` is rejected synchronously by pointer submission as
`.capacityRefused`. No application action is dispatched in `.admitting`.

The coordinator verifies before removal that its batch storage can represent
all selected counts and staged pointer transitions. Storage shortfall returns
`.capacityExhausted` and leaves every otherwise valid selected pointer or fact
queued and unapplied. Pointer validation or action-capacity refusal has already
returned through the exact earlier path, so storage failure manufactures no
additional cancellation. A count equal to its limit succeeds. Queue capacity
at `submit` and per-cycle selection capacity are distinct: queue refusal is
reported synchronously by `ExecutionAdmissionResult`, while a per-cycle
suffix is deferred rather than failed.

### Mutation, freeze, derivation, and publication

After sealing, the coordinator commits the staged pointer state, enters
`.mutating`, and applies each admitted state-change fact, completion fact, and
semantic action exactly once in that category order and in producer or pointer
order within its category. A completion fact may dirty semantics only when its
owning downstream contract says so. Each activation dispatches the current
bounded action only through the later coordinator-owned dispatcher after it
revalidates identity, action generation, enabled state, and observable-model
target generation immediately before borrowing the current model. A
later failure, refusal, retry, or supersession MUST NOT replay any fact,
action, or effect. Their client side effects are not assumed reversible.

Mutation-driven invalidations coalesce while the batch is applied. The
coordinator then freezes admission to the active cycle, enters `.deriving`,
and performs semantic expansion, layout, hit/routing derivation, action-table
staging, and validation of the immutable inputs required by SPEC-008 from
stable observed state. It does not call `RenderProducer.produce` or inspect an
endpoint sink in this phase. It MUST NOT suspend or permit reentrant mutation
before publication or failure disposition. Newly arriving work remains
pending.

The staged action table may contain at most `maximumCommittedActions` records.
The first record beyond that bound returns
`.execution(.capacityExhausted)` before publication and leaves the prior
committed table unchanged. Replacement-generation reservation follows the
identity rule above and precedes the capacity-successful staged table's
publication.

If derivation produces no semantic change and there is no dirty or pending
presentation obligation, the cycle is `.unchanged` and produces no frame. A
complete changed result receives the next non-aliased `SemanticRevision` and
is published atomically in `.publishing`. Publication makes the semantic
revision observable, but keeps candidate hit geometry, action records, and
routing state staged.

A semantic, layout, action-table, routing, or pre-offer input-validation
failure before publication discards every partial downstream result, leaves
already-applied observable state dirty, requests one coalesced
`.semanticDirty` wake, and returns a failure summary with
`.semanticDisposition == .dirty`. Recovery is a later separately admitted
cycle from current state. It MUST NOT replay the sealed batch or recursively
invoke another cycle. SPEC-008 render production begins only after
publication, inside `offer`; its failures therefore follow the post-publication
rules below and never roll back or dirty the published revision.

### Candidate frame and handoff

Action-generation reservations are part of pre-publication action-table
staging. After publication, or when a pending latest revision is rederived
without a semantic change, the coordinator allocates a fresh
`CandidateFrameID` and then reserves the next `PresentationRevision`.
Allocation occurs at the end of `.publishing` for a new revision and at the
end of `.deriving` for unchanged presentation recovery; the detecting context
preserves that phase. Candidate-ID failure produces no candidate, while
presentation-revision failure aborts the allocated candidate. Both occur
before `offer`, make no endpoint call, and return the exact identity failure
while preserving an already completed publication. The coordinator then constructs
`FrameProvenance` and enters `.offering`. SPEC-008 rendering is produced
atomically into the endpoint's sink during the single synchronous `offer`
call.

Loss of the required presentation facility after publication or unchanged
recovery sets intent unavailable and makes no endpoint call. If detected
before candidate allocation it produces no candidate; if detected after
candidate allocation it aborts that candidate. In both cases it preserves the
published semantic revision and prior committed routing revision and returns
`.execution(.requiredFacilityUnavailable)` with the detecting context.

An accepted result atomically:

- commits the logical frame;
- commits the already-reserved non-aliased `PresentationRevision`;
- commits candidate hit geometry, action records, and routing state under that
  revision;
- clears presentation-pending intent for the represented semantic revision;
  and
- leaves later endpoint health outside Core frame disposition.

A non-accepted result aborts the candidate, discards every staged routing and
action change, retains the previous committed logical frame and presentation
revision unchanged, and releases all cycle-local storage. No non-accepted
result may be reported after an irreversible presentation effect.

An offer-time `renderProduction` or `frameOffer` failure occurs after any new
semantic revision has been completely published. It aborts the candidate,
preserves that publication, clears presentation-pending intent for the failed
attempt, requests no automatic presentation retry, and routes the exact
failure through layered disposition. Only explicit backpressure or retryable
refusal creates presentation-pending intent. Non-retryable refusal performs
the terminal behavior below.

### Refusal recovery

`.backpressured` after semantic publication preserves only
`PresentationPendingIntent` for the latest published revision and requests one
coalesced `.presentationPending` wake. It preserves the existing
`retryableRefusalCount` for the same revision or starts at `0` for a newer
revision. Backpressure recovery is paced by endpoint readiness or the host and
does not consume the finite retryable-refusal budget.

`.retryableRefusal` checked-increments the count for the latest revision. If
the new count is below the configured maximum, the coordinator retains only
that intent and requests one coalesced `.presentationPending` wake. If it
equals the maximum or cannot be represented, the coordinator retains no
pending intent and performs terminal exhaustion; the subsequent residual-
policy input MUST NOT allow `requestPacedRetry`. A newer published semantic
revision records `.superseded`, replaces the older intent, and starts its own
count as defined above. No path retains the refused payload.

Each recovery opportunity rederives semantic, layout, routing, and render
inputs from current state and creates a fresh candidate frame. It does not
apply an old mutation, invoke an old action, repeat an effect, or replay an
operation. The finite host policy supplies pacing and the configured maximum
when assembling the runtime; the maximum is immutable for that runtime
lifetime and is snapshotted with cycle-stable configuration. Pacing controls
when the requested opportunity occurs but cannot alter the counter or the
checked terminal transition. For a retryable refusal whose prior stored count
is `c`, any SPEC-003 residual-policy input uses `attemptOrdinal == c` and
`attemptLimit == configuredMaximum`; after terminal exhaustion its allowed set
MUST exclude `requestPacedRetry`.

Retryable-policy exhaustion, `.nonRetryableRefusal`, or loss of a required
presentation facility sets `presentationIntentState` to `.unavailable`, clears
pending intent, cancels active captures, and quiesces affected presentation-
coupled interaction. A non-retryable refusal caused by SPEC-008's idle-sink
`begin` refusal returns
`.nonRetryableRefusal(.renderProducer)`; a refusal returned without calling
the body returns `.nonRetryableRefusal(.endpoint)`. Mandatory coordinator
effects occur before residual policy. A policy cannot reinterpret refusal as
success or preserve an apparently active stale UI.

### Presentation-coupled pointer admission

The target-local integration first stamps an event with a locally eligible
`PresentationRevision`. If eligibility is stale, unknown, unavailable, or not
yet established, it drops the event and cancels the source sequence without
requiring a queue insertion.

At pointer submission, Execution validates the revision again against the
currently committed routing revision. This closes the race between target
gating and queue ownership; mismatch returns `.invalidProvenance`. Seal-time
revalidation closes a later commit race; mismatch returns the complete cycle
failure defined above. Both paths drop rather than defer or retarget the event
and perform complete source-sequence cancellation.

For each bounded `InputSourceID`, the target gate allocates a runtime-visible
sequence only for a down it submits. A wholly target-local physical sequence
from which no phase is submitted consumes no runtime-visible sequence value;
the gate MUST abandon all of its phases before reusing the still-unsubmitted
value. Once any phase of a sequence has been submitted, that value is consumed
even if runtime admission later refuses or drops it. Subject to that rule:

- the first submitted sequence in one runtime lifetime has raw value `0`; each
  later submitted sequence is the exact checked successor of the last
  submitted sequence for that source;
- a valid `down` has ordinal raw value `0`, begins that fresh sequence, and
  clears older capture before hit resolution;
- `move` and `up` must match the active sequence and use the exact checked
  successor of the last admitted ordinal; gaps, duplicates, decreases, and
  wrap are invalid;
- a new down may replace an active or cancelled non-exhausted prior sequence
  and resynchronize the source only when its target-local gate has completed
  or abandoned the prior physical sequence, can prove that no older phase
  remains submit-able, and supplies the exact successor sequence with ordinal
  zero; runtime admission then retires the prior sequence and clears its
  capture before hit resolution;
- a dropped, malformed, out-of-order, or capacity-refused phase cancels the
  complete source sequence;
- orphaned later phases are consumed without semantic dispatch until a safe
  terminal phase or new unambiguous down resynchronizes the source; and
- ordinal exhaustion cancels the current sequence and permits only the safe
  successor-down resynchronization above; sequence exhaustion quiesces the
  source for the remainder of the runtime lifetime and requires runtime
  reassembly before another sequence can be admitted.

The target gate MUST enforce its resynchronization proof before submission;
runtime admission independently enforces the numeric sequence and ordinal
rules. A target that cannot prove the gate condition drops the down and keeps
the source cancelled. No sequence or ordinal raw value wraps or aliases.

A validated down may capture the hit action only when the committed action
view reports one exact identity, a current generation, and enabled state. Move
may cancel according to the later Interaction gesture rule. Up dispatches no
action itself; it yields an activation candidate only if provenance remains
valid, the release resolves the same identity, the current generation equals
the captured generation, and the action remains enabled. Any failed check
cancels activation and retains no former bound action or model target.

That activation candidate joins the semantic-action segment of the same cycle
before the seal closes. It is invoked once in `.mutating` after the admitted
state-change and completion facts. It is never queued as a new external action
and never deferred independently from the pointer event that produced it.

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

The following matrix is exhaustive for every started cycle. “Prior” means the
authoritative value on entry; “derived” is `.published` when the cycle
published a new revision and `.unchanged` when it reused the latest complete
revision during presentation recovery.

| Terminal condition | Semantic disposition | Logical frame | Committed presentation revision | Presentation intent |
| --- | --- | --- | --- | --- |
| no semantic change and no presentation obligation | `unchanged` | `notProduced` | prior | `satisfied` |
| pre-publication failure before any dirty work exists | `unchanged` | `notProduced` | prior | prior intent |
| pre-publication failure after mutation or during dirty recovery | `dirty` | `notProduced` | prior | prior intent |
| derived candidate accepted | derived | `committed` | reserved new revision | `satisfied` |
| derived candidate backpressured | derived | `aborted` | prior | `pending`, count preserved or zero |
| derived candidate retryably refused below limit | derived | `aborted` | prior | `pending`, checked increment |
| retryable-refusal limit reached | derived | `aborted` | prior | `unavailable` |
| non-retryable refusal | derived | `aborted` | prior | `unavailable` |
| post-publication render/offer failure | derived | `aborted` | prior | `satisfied`, unless residual policy separately marks the facility unavailable |
| pre-offer candidate-ID failure after publication/recovery | derived | `notProduced` | prior | `satisfied`, unless residual policy separately marks the facility unavailable |
| pre-offer presentation-identity failure after candidate allocation | derived | `aborted` | prior | `satisfied`, unless residual policy separately marks the facility unavailable |
| required presentation facility lost before candidate allocation | derived | `notProduced` | prior | `unavailable` |
| required presentation facility lost after candidate allocation and before acceptance | derived | `aborted` | prior | `unavailable` |

“Satisfied” in this matrix means that Core retains no automatic presentation-
recovery obligation; it does not claim that the latest semantic revision was
physically displayed. A later admitted semantic change may create another
candidate when the facility remains available. `.unavailable` prevents such a
candidate until later host configuration reassembles a healthy facility.

Within a row, `superseded` is recorded when a new publication replaces older
pending intent, and `deferredToLaterAdmission` is recorded whenever valid work
remains after the seal. Backpressure or retryable refusal adds its own event;
`noChange` is recorded only for the first row. These event combinations use the
primary precedence defined with `RunCycleResult<OwnerFailure>` and never depend on profile-
private scheduling.

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

Execution detects local errors in this exact precedence order when multiple
conditions are visible at one boundary: `reentrancyViolation`, `invalidPhase`,
`identityExhausted`, `invalidProvenance`, `invalidValue`,
`arithmeticOverflow`, `capacityExhausted`,
`requiredFacilityUnavailable`, then `invariantViolation`. It stops at the first
failure, performs mandatory mechanical containment, and returns no partial
successful summary. A lower producer's already-selected local error is not
re-ranked by this list; its owning Specification's precedence remains exact.

Admission outcomes map independently of `RunCycleResult<OwnerFailure>`:

| Admission result | SPEC-003 outcome | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| `queued` | success | — | — | — |
| `capacityRefused` | failure `capacityExhausted` | `execution` | `operation` | `contained` |
| `unavailable` | failure `requiredFacilityUnavailable` | `execution` | `runtime` | `contained` |
| `invalidValue` | failure `invalidValue` | `execution` | `operation` | `contained` |
| `invalidProvenance` | failure `invalidProvenance` | `execution` | `operation` | `contained` |

The admission adapter correlates each failure with the outcome's exact context
after mandatory pointer cancellation. It does not create a run-cycle summary
or allocate a new cycle merely to report submission failure.

The `GiftUIFailureExecution` adapter MUST map
`.execution(error)` failures exactly:

| Execution error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| invalid value | `invalidValue` | `execution` | `operation` | `contained` |
| arithmetic overflow | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| capacity exhausted before publication | `capacityExhausted` | `execution` | `activeCycle` | `contained` |
| capacity exhausted during execution-owned candidate staging | `capacityExhausted` | `execution` | `candidateFrame` | `contained` |
| identity exhausted | `invalidIdentity` | `execution` | smallest affected scope | `contained` unless safe reuse cannot be proven |
| invalid provenance | `invalidProvenance` | `execution` | `operation` | `contained` |
| invalid phase | `invalidPhase` | `execution` | `activeCycle` | `contained` |
| reentrancy violation | `reentrancyViolation` | `execution` | `activeCycle` | `safetyNotProven` |
| required facility unavailable | `requiredFacilityUnavailable` | `execution` | `runtime` | `contained` |
| invariant violation | `invariantViolation` | `execution` | `runtime` | `safetyNotProven` |

`smallest affected scope` is `.operation` for one rejected new allocation,
`.activeCycle` when the active cycle cannot continue, and `.runtime` when
alias-free future allocation cannot be proven. An adapter MUST NOT narrow the
scope or improve containment without contract evidence.

`.renderProduction(error)` preserves the exact SPEC-008 local error and uses
SPEC-008's approved mapping without reinterpretation:

| Render error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| `invalidInput` | `invalidValue` | `rendering` | `candidateFrame` | `contained` |
| `arithmeticOverflow` | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| `capacityExhausted` | `capacityExhausted` | `rendering` | `candidateFrame` | `contained` |
| `incompatibleTextResource` | `invalidValue` | `rendering` | `candidateFrame` | `contained` |
| `reentrancyViolation` | `reentrancyViolation` | `rendering` | `activeCycle` | `safetyNotProven` |
| `invariantViolation` | `invariantViolation` | `rendering` | `runtime` | `safetyNotProven` |

SPEC-008's `sinkRefused` is represented by
`.nonRetryableRefusal(.renderProducer)`, which implicitly and uniquely
preserves that local error and maps to `nonRetryableRefusal`, origin
`rendering`, scope `candidateFrame`, containment `contained`.

`.frameOffer(.invalidEnvelope)` maps to `invalidValue`, origin `backend`, scope
`candidateFrame`, containment `contained`. `.frameOffer(.contractViolation)`
maps to `invariantViolation`, origin `backend`, scope `runtime`, containment
`safetyNotProven`. `.frameOffer(.insufficientCapacity)` and
`.frameOffer(.producerFailed)` are not legal coordinator failures: a matching
body result must instead preserve the exact `.renderProduction` error, and an
unmatched endpoint payload normalizes to
`.frameOffer(.contractViolation)`.

`.nonRetryableRefusal(.endpoint)` maps to `nonRetryableRefusal`, origin
`backend`, scope `candidateFrame`, containment `contained`. The
`.renderProducer` case uses the distinct rendering mapping above. Both perform
the same mandatory abort and unavailable/quiescent transition before mapping.

`.focusedOwner(error)` preserves `error` without reinterpretation. The owning
adapter MUST switch exhaustively over the concrete `OwnerFailure` sum and use
the mapping, affected scope, containment, and mandatory effects fixed by that
focused owner's approved Specification. `GiftUIFailureExecution` neither owns
nor provides a fallback mapping for this case. A generic invalid-value,
invariant, or diagnostic translation is nonconforming.

The coordinator's exhaustive offer normalization is:

| Body observation | Endpoint result | Local cycle result |
| --- | --- | --- |
| not called | `backpressured` | operational `backpressured` |
| not called | `retryableRefusal` | operational `retryableRefusal`, or the same primary event plus terminal exhaustion |
| not called | `nonRetryableRefusal` | failure `nonRetryableRefusal(.endpoint)` |
| not called | `failed(.invalidEnvelope)` | failure `frameOffer(.invalidEnvelope)` |
| not called | `failed(.contractViolation)` | failure `frameOffer(.contractViolation)` |
| `complete` | `accepted` | success or another recorded operational event with a committed summary |
| `producerFailed` with retained error | `failed(.producerFailed)` | failure `renderProduction(retainedError)` |
| `insufficientCapacity` with retained `.capacityExhausted` | `failed(.insufficientCapacity)` | failure `renderProduction(.capacityExhausted)` |
| `endpointRefused` with retained `.sinkRefused` | `nonRetryableRefusal` | failure `nonRetryableRefusal(.renderProducer)` |
| `contractViolation` with retained `.invariantViolation` | `failed(.contractViolation)` | failure `renderProduction(.invariantViolation)` |
| any other pairing | any | failure `frameOffer(.contractViolation)` |

Expected outcomes map as follows:

| Local event | SPEC-003 operational kind | origin | scope |
| --- | --- | --- | --- |
| no semantic change | `noChange` | `execution` | `activeCycle` |
| bounded endpoint pressure | `backpressured` | `backend` | `candidateFrame` |
| retryable endpoint refusal | `retryableRefusal` | `backend` | `candidateFrame` |
| newer pending revision replaces older intent | `superseded` | `execution` | `candidateFrame` |
| valid work arrived after the seal | `deferredToLaterAdmission` | `execution` | `activeCycle` |

After failure mapping, the adapter wraps the exact fact and
`ExecutionContext` in `GiftUICorrelatedFailure`. For an operational result it
constructs the exact `GiftUIOperationalFact` and carries the same context to
the owning coordinator/policy seam without manufacturing a failure envelope.
Optional annotations or diagnostics cannot replace or alter either path.
Mechanical containment and mandatory cycle/frame effects run before residual
target policy.

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
- `PresentationPendingIntent` no greater than 8 bytes;
- `FrameOfferResult` no greater than 2 bytes;
- `ExecutionAdmissionOutcome` no greater than 28 bytes;
- `AdmissionSummary` no greater than 12 bytes;
- `RunCycleSummary` no greater than 40 bytes;
- every conforming `OwnerFailure` no greater than 4 bytes;
- `RunCycleFailure<OwnerFailure>` no greater than 8 bytes;
- `RunCycleResult<OwnerFailure>` no greater than 72 bytes;
- `ExecutionPhase`, `AdmissionKind`, `FrameOfferDisposition`,
  `LogicalFrameDisposition`, `FrameStreamResult`, `FrameOfferFailure`,
  `ExecutionAdmissionResult`, `FrameRefusalOrigin`, `PresentationIntentState`,
  `ExecutionError`, `SemanticCycleDisposition`, and `ExecutionOperational`
  exactly 1 byte each;
- `ExecutionWakeReasons` and `ExecutionOperationalEvents` exactly 1 byte each;
  and
- the non-generic raw-value and option-set ceilings remain unchanged by the
  owner-failure specialization.

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

### Reproducible evidence configuration

The compilers, target triples, SDKs, and optimization modes are exactly those
fixed by SPEC-002's current `Reproducible evidence configuration`.
Implementation MUST provide one checked-in driver at
`scripts/contracts/run-spec-009.sh` with these exact invocations:

```text
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
scripts/contracts/run-spec-009.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-009.sh --profile nrf52840-embedded
```

The driver MUST fail on an unavailable compiler or SDK, unknown or duplicate
fixture case, missing required field, unreferenced fixture data, transcript or
result mismatch, value-layout violation, allocation violation, dependency-
graph violation, or target-inspection failure. It records the complete command
line, compiler identity, repository revision, fixture-manifest digest, value
layouts, queue/workspace and stack high-water values, allocation count, timing
method and samples, section deltas, and link maps.

### Required fixtures

`Tests/ContractFixtures/SPEC009/` MUST contain:

- `cycles.yaml` for phase, ordering, publication, dirty recovery, and
  at-most-once cases;
- `handoff.yaml` for complete acceptance, each refusal, irreversible-output,
  reservation, discard, and post-return lifetime cases;
- `input.yaml` for every phase, ordinal, stale provenance, race, cancellation,
  replacement, movement, disabled, exhaustion, and resynchronization case;
- `recovery.yaml` for pending-intent coalescing, newer-revision supersession,
  finite attempts, non-retryable refusal, unavailability, and quiescence;
- `owner-failures.yaml` for a finite fixture `OwnerFailure`, every case,
  first-failure precedence, exact context, cleanup, mapping, and static layout;
  and
- `signal-analyzer.yaml` for the 80-facts/second and 250-millisecond workload.

Every case has the shared fields `name`, `initialState`, `limits`,
`preOpportunityAdmissions`, `phaseInjections`, `endpointScript`,
`expectedPhaseTranscript`, `expectedAdmissionSummary`, `expectedResult`,
`expectedAuthoritativeState`, `expectedWakeTransitions`, and
`expectedFailureOrOperationalMapping`. A file may add domain-specific fields,
but none of the shared fields may be omitted; a domain-inapplicable field uses
an explicit `none` value. `endpointScript` records whether
the body is called, its exact `FrameStreamResult` and retained SPEC-008 local
error when applicable, the returned `FrameOfferResult`, and whether
irreversible output began. Input cases additionally record initial and final
per-source sequence, ordinal, capture, cancellation, and quiescence state.
Recovery cases record the configured maximum, count before and after, pacing
opportunity, supersession, and terminal availability. Signal Analyzer cases
record fact timestamps, opportunity timestamps, publications, offers, wakes,
and high-water values.

Fixtures compare exact numeric fields and symbolic stable identity tokens;
they MUST NOT compare pointers, closure identity, strings, metatype addresses,
hash collisions, enum memory bytes, or profile-private raw semantic identity.
The canonical loader rejects a case whose declared primary operational result
does not match the required precedence or whose summary violates the legal
state matrix.

### Contract tests

Tests MUST:

- drive pointer, state-change, and completion submission plus host opportunity
  entry only through `ExecutionAdmissionSink` and
  `ExecutionOpportunityRunner`;
- exercise every admission result for every submission family and prove exact
  ownership, wake, pointer-cancellation, context, and SPEC-003 mapping;
- race pointer submission and sealing against separate frame commits and prove
  the exact synchronous admission rejection and seal-time cycle-failure paths;
- exercise every legal and rejected `RunCycleSummary` combination, every
  simultaneous operational-event combination, and exact primary precedence;
- inject every fixture `OwnerFailure` at its focused boundary and prove the
  specialized result preserves the exact value/context without an existential,
  diagnostic carrier, generic translation, or replacement by cleanup failure;
- acknowledge a wake at opportunity entry, inject a new wake reason during
  every later phase and finalization, and prove no request is lost or emitted
  more than once per empty-to-nonempty transition;
- inject work before sealing, during every active phase, during offer, and
  during finalization and verify exact current/later admission membership;
- apply mutations and actions, fail each later phase, refuse offers, supersede
  pending work, and inject post-handoff failure while proving at-most-once
  effects;
- admit an activating up with state-change and completion facts, prove its
  activation joins the same seal after both fact categories, and prove no
  application action is dispatched during submission or admission;
- verify complete publication and that no partial semantic, layout,
  action-table, routing, or immutable-render-input result becomes current;
- fail derivation after mutation and prove dirty wake/rederivation without
  replay or synchronous recursion;
- verify semantic publication survives every presentation outcome;
- script every legal and illegal endpoint/body pairing and prove exact local
  result, commit/abort state, operation/body call counts, complete reservation,
  no retention, and accepted responsibility after irreversible output;
- publish newer revisions while pending and prove constant-space latest-only
  coalescing and finite terminal policy;
- race target-local input gating with a newer commit and prove the stale event
  drops at runtime admission;
- drop each pointer phase at every capacity and validation boundary and prove
  complete sequence cancellation and no orphan activation;
- drop a complete physical sequence only at the target gate, prove it consumes
  no runtime-visible sequence identity, then replace both active and cancelled
  runtime-visible sequences with the exact successor down and prove capture is
  cleared before hit resolution;
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
  wake reasons, pending intent/count, frame provenance/results, admission and
  opportunity protocols, operational-event set, presentation-intent state,
  and local failures/results match the exact declarations, construction,
  normalization, raw widths, and value-layout bounds in this contract.
- [ ] **EX-002:** Scripted cycles seal exact ordered membership, defer all
  after-seal work, apply every mutation/action at most once, freeze derivation,
  publish only complete revisions, and always finalize to idle.
- [ ] **EX-003:** Every pre-publication semantic, layout, action-table, routing,
  or immutable-render-input failure after mutation leaves state dirty,
  requests one paced wake, publishes no partial result, and rederives from
  current state without replay or immediate recursion; every offer-time render
  failure preserves an already complete publication and follows the exhaustive
  abort/failure table.
- [ ] **EX-004:** Every candidate reserves its presentation revision and action
  generations before offer, every frame is offered at most once, and
  acceptance occurs only after complete stream consumption and downstream
  reservation, atomically commits frame plus routing state, and retains no
  borrowed operation or resource.
- [ ] **EX-005:** Every pre-acceptance refusal has no irreversible effect,
  aborts the candidate, preserves the previous committed frame/routing state,
  retains no payload, and produces the exact call/result/failure mapping;
  every post-output condition remains accepted endpoint health and cannot
  reopen Core disposition.
- [ ] **EX-006:** Retryable refusal retains only the latest constant-space
  presentation intent, checked-increments its count without wrap, coalesces
  newer revisions, requests separately paced recovery, and reaches accepted
  handoff or explicit unavailable/quiescent terminal state at the configured
  `1...255` bound; backpressure remains distinct and does not consume that
  count.
- [ ] **EX-007:** Target and runtime provenance checks, pointer phase/ordinal
  zero/start and exact-successor sequencing, drop cancellation, proven
  resynchronization, and no-wrap exhaustion pass the complete `input.yaml`
  corpus without deferred input or historical hit-map storage.
- [ ] **EX-008:** Captures contain only the exact SPEC-006 identity-generation
  pair; stable records survive unrelated revision changes, while removal,
  movement, disabled state, bound-record replacement, generation mismatch, or
  ambiguous reuse dispatches neither the former nor replacement action/model
  binding.
- [ ] **EX-009:** Every admission outcome, specialized `RunCycleFailure`, legal offer/body
  pairing, illegal pairing, and primary operational event maps to the exact
  SPEC-003 fact, origin, scope, containment, and `ExecutionContext`; mandatory
  containment precedes total residual policy and diagnostics never affect
  correctness.
- [ ] **EX-010:** Recording, dynamic, and static fixtures produce equal sealed
  membership, phase order, identities, results, frame dispositions, input
  cancellations, operational-event sets, and failure mappings for the same
  inputs and limits through the common admission and opportunity protocols.
- [ ] **EX-011:** The Signal Analyzer fixture sustains its required admission
  and presentation workload within the declared fixture limits, with
  coalesced wakes/publications and at most one pending presentation intent.
- [ ] **EX-012:** All four exact `run-spec-009.sh` commands pass the canonical
  schema and complete corpus; static paths allocate zero heap bytes, all value-
  layout and high-water requirements pass, package dependency tests preserve
  the focused execution boundary, and both cross-build configurations produce
  the required non-hardware evidence.
- [ ] **EX-013:** Review finds no public observable-state syntax/storage,
  Button/disabled or action-lowering/handler contract, concrete runtime-profile
  storage, capability catalogue, rasterization/backend realization, host
  production capacity/pacing choice, platform driver, or connected-hardware
  requirement in this Specification.
- [ ] **EX-014:** A focused-owner fixture returns each case of a finite
  coordinator-supplied `OwnerFailure` through the common opportunity seam,
  preserves its exact value and context through owner mapping, selects the
  first failure despite later cleanup, and allocates zero heap bytes statically.

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

No unresolved contract or architectural choice remains in this amendment.
Production capacities, concrete retry pacing, observable-state fact
payloads/storage, committed bound-action-table storage and handler dispatch,
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
- [RFC-011](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-012](../adrs/adr-012-bounded-handoff-refusal-recovery.md)
- [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
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
