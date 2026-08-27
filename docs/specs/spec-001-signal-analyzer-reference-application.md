---
id: SPEC-001
feature: signal-analyzer
title: Signal Analyzer Reference Application Contract
status: review
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-27
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-001
  - RFC-008
  - RFC-009
  - RFC-011
related_adrs:
  - ADR-001
  - ADR-003
  - ADR-004
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-027
  - ADR-028
  - ADR-029
  - ADR-030
  - ADR-031
  - ADR-033
related_specs:
  - SPEC-003
  - SPEC-010
  - SPEC-011
  - SPEC-012
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-001: Signal Analyzer Reference Application Contract

> **Review status:** Revised for ADR-024 through ADR-027 after ADR-027
> superseded ADR-002. Approval remains blocked by the prerequisite reusable
> GiftUI contracts and unresolved application-contract details listed under
> Open Issues. This Specification remains non-authoritative until those
> blockers are resolved and a human maintainer explicitly approves it again.

## Summary

This Specification defines the portable application contract for GiftUI's
four-channel low-frequency digital Signal Analyzer. It covers the analyzer's
domain values, acquisition and observation behavior, bounded transition
capture, presentation state, fixed view hierarchy, waveform semantics,
bounded Presentation-fact admission, observable-model ownership, target-host
obligations, SPEC-003-normalized failure handling, resource bounds, and
conformance evidence across the four MVP configurations.

The Specification adapts the completed macOS investigation into the governed
GiftUI lifecycle. The investigation remains implementation evidence, not
authority. Where it depends on desktop-only mechanisms such as SwiftUI,
Observation, `MainActor`, `Task`, or `ContinuousClock`, this contract specifies
portable behavior instead of preserving those mechanisms.

This Specification assumes GiftUI provides the complete client-facing MVP
surface defined by `docs/MVP_SCOPE.md`, including observable state-driven
invalidation and the Canvas/path/stroke operations needed by the waveform. It
does not define or approve those framework contracts.

## Scope

This Specification covers:

- four fixed digital channels, `CH1` through `CH4`;
- digital transition values and a bounded 30-second capture;
- idle, running, stopped, and failed acquisition states;
- start, stop, restart, and clear behavior;
- one capture sink and one acquisition-state sink;
- one target-composed Presentation admission adapter connecting those sinks to
  GiftUI's logically distinct mutation domain;
- bounded immutable capture, acquisition-state, and operational-failure facts;
- total normalization of analyzer producer conditions into SPEC-003 outcomes
  before any target-composition policy decision;
- deterministic synthetic signal generation for development and tests;
- a portable Presentation state model and GiftUI view hierarchy;
- selectable 1-, 2-, and 5-second visible windows;
- a time ruler, grid, and four data-driven digital traces;
- a 250-millisecond display refresh interval;
- dynamic and static application realizations;
- target-host composition for macOS, Raspberry Pi/Linux, and nRF52840;
- conformance, resource, platform, and connected-hardware evidence.

The contract applies to these MVP configurations:

| Platform | Profile | Required role |
| --- | --- | --- |
| macOS | Dynamic | Primary development and behavioral reference |
| macOS | Static | Static-composition and runtime constraint validation |
| Raspberry Pi/Linux | Dynamic | Linux, framebuffer, display, and input validation |
| nRF52840/TFT | Static | Embedded Swift, fixed-capacity, display, and resource validation |

Exact colors, typography, pixel dimensions, decorative styling, host window
chrome, and hardware signal acquisition are outside the normative visual
contract unless a requirement below states otherwise.

## Goals

- Provide one coherent application that exercises GiftUI composition, layout,
  rendering, state invalidation, interaction, disabled state, and drawing.
- Preserve substantially shared portable Presentation code across all MVP
  configurations.
- Keep Domain independent of UI, renderer, platform, clock, and hardware
  facilities.
- Preserve deterministic, serialized acquisition behavior across dynamic and
  static profiles.
- Keep observable ViewModel mutation inside GiftUI's sealed mutation phase and
  make cross-domain capacity and refusal explicit.
- Bound transition history for embedded execution without losing the level at
  the retained window's lower bound.
- Make every application behavior and MVP validation claim measurable.

## Non-goals

- Define any GiftUI client API, observation implementation, Canvas
  implementation, runtime architecture, renderer, or backend contract.
- Require SwiftUI source compatibility or identical platform hosting code.
- Provide hardware GPIO acquisition, protocol decoding, triggering,
  measurements, cursors, persistence, export, or capture playback.
- Support analog values, arbitrary channel counts, runtime channel
  configuration, or input signals above 10 Hz per channel.
- Support multiple capture or state observers, callback fan-out, background
  domain processing, or general asynchronous streams.
- Define GiftUI's reusable observable-state API, runtime cycle API, or generic
  failure API; this contract defines only the Signal Analyzer's required
  source shape, capacities, facts, adapter, and observable behavior.
- Require a rendered frame for every acquired transition.
- Set aggressive RAM, stack, binary-size, or rendering optimization targets
  beyond the explicit capacity and viable-execution requirements below.

## Dependencies

### Lifecycle dependencies

- [PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md)
  defines the accepted application problem.
- [RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
  preserves the approved application design and its post-approval authority
  update.
- [RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md)
  defines the approved observable-state and Presentation-admission design.
- ADR-001, ADR-003, ADR-004, ADR-011, ADR-014 through ADR-016, and ADR-024
  through ADR-027 are the accepted governing decisions. ADR-002 is superseded.

### GiftUI dependencies

Every claimed configuration MUST provide the complete Rank 0–2 and waveform
drawing surface from [GiftUI MVP Scope](../MVP_SCOPE.md). This includes the
view model, fixed child composition, custom views, modifier chaining, stacks,
spacer, spacing, alignment, padding, frame constraints, text, opaque RGB color,
foreground styling, rectangular backgrounds, buttons, disabled state,
observable state invalidation, Canvas, path construction, line stroking,
stroke style, and drawing geometry.

These GiftUI features are external dependencies. Their absence makes a target
configuration nonconforming; the analyzer MUST NOT replace them with
target-specific presentation code or silently omit required behavior.

### Target dependencies

Each target host MUST provide:

- one serialized application executor;
- one GiftUI serialized mutation domain and cycle driver logically distinct
  from the application executor;
- the bounded Signal Analyzer fact-admission storage and wake integration
  specified below;
- monotonic time and timer-scheduling capabilities;
- a GiftUI runtime appropriate to the selected dynamic or static profile;
- a renderer, display surface, and input integration;
- a concrete signal data source;
- the composition wiring needed to construct one analyzer object graph.

The host integration that consumes analyzer failures MUST import
`GiftUIFailureCore`. Analyzer-local producer results remain owned by this
Specification, but no local rejection or runtime-condition enum is a policy
input or a competing failure vocabulary.

The portable Domain and Presentation use `Swift.Duration` values. They MUST
NOT read a platform clock or schedule timers directly.

## Related ADRs

- [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
  governs Domain, Data, Presentation, and target-host ownership plus inward
  dependency direction.
- [ADR-003](../adrs/adr-003-transition-based-bounded-capture.md)
  governs transition storage, the 80-event-per-second bound, minimum capacity,
  oldest-first eviction, and per-channel baseline preservation.
- [ADR-004](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
  governs the shared fixed hierarchy, Presentation-owned visible range,
  250-millisecond refresh interval, target-specific host boundary, and assumed
  GiftUI MVP client surface.
- [ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md)
  governs sealed ordered admission, at-most-once fact and action application,
  freeze, dirty rederivation, and complete semantic publication.
- [ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md) and
  [ADR-015](../adrs/adr-015-layered-failure-disposition.md) govern bounded
  condition meaning, containment, mandatory coordinator behavior, and the
  residual target-policy seam.
- [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md) keeps diagnostic
  projection outside mutation, wake, and correctness paths.
- [ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md)
  governs structural ownership, identity, replacement, and removal of the
  observable presentation model.
- [ADR-025](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
  governs synchronous model-owned change reporting and coarse invalidation.
- [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
  governs equivalent bounded observable-state realization across profiles.
- [ADR-027](../adrs/adr-027-bounded-presentation-fact-admission.md)
  governs synchronous application delivery through bounded immutable fact
  admission into GiftUI's distinct mutation domain and supersedes ADR-002.

## Terminology

- **Application executor:** The serialized execution context on which source
  delivery, repository mutation, sink callbacks, and use cases run to
  completion. It does not own observable ViewModel mutation.
- **GiftUI mutation domain:** The non-suspending serialized phase that seals
  admitted work, applies each admitted fact or action at most once, mutates the
  ViewModel, coalesces change reports, freezes state, and publishes a complete
  semantic revision.
- **Presentation admission adapter:** The target-composed object installed as
  the repository's capture and acquisition-state sinks. It converts each
  synchronous publication into a bounded immutable Presentation fact and
  submits it without mutating the ViewModel.
- **Presentation fact:** A bounded immutable capture snapshot, capture
  mutation, acquisition-state replacement, or operational-failure value that
  may mutate the ViewModel only after GiftUI admits and applies it.
- **Admission outcome:** The bounded result returned synchronously by the
  adapter: accepted with a sequence number, or rejected with a stable
  capacity, availability, or sequence-exhaustion condition.
- **Normalized analyzer outcome:** The `GiftUIOutcome<Void>` constructed from
  an analyzer-local rejection or runtime condition according to the total
  tables in Error Handling. It is the only outcome form a coordinator or
  target-composition policy may consume.
- **Semantic analyzer diagnostic:** `SignalAnalyzerDiagnostic`, a bounded
  correctness-bearing Domain value used for acquisition failure and visible
  error state. It is not a SPEC-003 diagnostic projection.
- **Diagnostic projection:** An optional, non-authoritative
  `GiftUIDiagnosticRecord` derived only after the normalized outcome has
  propagated or authoritative health/semantic state has committed.
- **Observable registration:** The single live model-owned change endpoint
  associated with the root ViewModel's runtime-owned `@State` location.
- **Acquisition session:** The period beginning with the first successful
  `start` and continuing across stop/restart until the object graph is
  destroyed. Its monotonic source time does not run while a pausable mock
  source is stopped.
- **Capture epoch:** The time origin of the currently retained capture. Initial
  construction and each `clear` begin a new capture epoch at duration zero.
- **Transition:** A channel event that records the resulting digital level. A
  source transition timestamp is elapsed acquisition-session time; a retained
  capture transition is rebased to elapsed time within the current capture
  epoch.
- **Capture duration:** The greatest accepted transition timestamp in the
  current capture epoch, or zero when no transition has been accepted.
- **Retained lower bound:** The earliest time represented by the current
  capture after time trimming or capacity eviction.
- **Baseline level:** The digital level of a channel at the retained lower
  bound, used when the transition that established the level is no longer
  retained.
- **Visible range:** The Presentation-selected time interval rendered in the
  waveform panel.
- **Display refresh interval:** The nominal 250-millisecond interval between
  analyzer frame computations; application publication and fact admission may
  occur more frequently.

## Public Contract

The analyzer MUST present one screen containing:

- the title `DIGITAL SIGNAL ANALYZER`;
- the subtitle `Four-channel acquisition`;
- a visible acquisition status for Ready, Running, Stopped, or Failed;
- a time ruler;
- four explicit rows named `CH1`, `CH2`, `CH3`, and `CH4`;
- a visible HIGH or LOW label for every channel;
- a time grid and a data-driven digital trace for every channel;
- Start, Stop, and Clear controls;
- explicit `1 s`, `2 s`, and `5 s` visible-window controls;
- acquisition error text when startup or source processing fails.

The user-visible behavior MUST satisfy these rules:

- Start begins or resumes progressive transition acquisition.
- Start is disabled while acquisition state is running.
- Stop pauses an active acquisition and is disabled otherwise.
- Clear empties retained history and resets capture time without changing the
  acquisition state.
- Selecting a visible window changes the rendered range immediately; the
  selected window control is disabled.
- State and capture changes invalidate the portable Presentation through
  GiftUI's provided observation mechanism.
- The screen need not render more than once every 250 milliseconds, but the
  next produced frame MUST reflect every Presentation fact and semantic action
  applied before that frame's semantic derivation begins.
- Successful repository delivery means that the admission adapter accepted a
  fact for later ordered application; it MUST NOT imply that observable
  Presentation state already changed.
- Exact styling MAY differ across backends, but required text, controls,
  disabled behavior, grid, and trace semantics MUST remain equivalent.

## Module Contract

### SignalAnalyzerDomain

Domain MUST own:

- channel, level, transition, capture, and acquisition-state values;
- capture and acquisition-state sink contracts;
- the acquisition repository contract;
- observation, start, stop, and clear use cases.

Domain MUST NOT import or depend on Presentation, Data, GiftUI, SwiftUI,
rendering backends, platform hosts, display or input drivers, GPIO, clocks,
schedulers, or hardware APIs.

### SignalAnalyzerData

Data MUST own:

- the transition sink and signal-source contracts;
- deterministic mock signal generation;
- the default acquisition repository;
- transition validation, ordering, epoch rebasing, retention, baselines,
  capacity handling, and capture publication.

Data MUST depend on Domain only and MUST NOT depend on Presentation or a UI
framework.

### SignalAnalyzerPresentation

Presentation MUST own:

- `VisibleTimeWindow`;
- `SignalAnalyzerViewState` and `SignalAnalyzerViewModel`;
- `SignalAnalyzerPresentationFact`, capture-mutation values, admission
  outcomes, and the repository-sink admission adapter declarations;
- visible-range calculation;
- the fixed GiftUI hierarchy;
- time ruler, channel labels, control state, grid, and waveform construction.

Presentation MAY depend on Domain, `GiftUIFailureCore`, and the provided GiftUI
client surface. It MUST NOT depend on concrete Data types, platform hosts,
clocks, schedulers, GPIO, renderers, or display hardware. The dependency on
`GiftUIFailureCore` carries normalized outcome values only; policy
implementation and optional diagnostic projection remain downstream at the
target host.

The ViewModel MUST NOT implement either repository sink contract. The
Presentation admission adapter MUST implement both sink contracts, but it
MUST NOT own, borrow, observe, or directly mutate the ViewModel. It MAY depend
only on Domain values and the bounded fact-submission endpoint supplied at
target composition.

### Target host

The host MUST be the only composition root. It MUST construct exactly one
concrete source, repository, use-case set, Presentation admission adapter,
ViewModel, observable state location, and root view for an analyzer instance.
It MUST install the adapter as both repository sinks on the application
executor before starting acquisition. It MUST supply the application-executor
entry contract, GiftUI mutation domain, fact admission, runtime, backend,
display, input, clock, scheduler, wake path, and target-specific hardware
integration.

The host MUST start and stop repository observation explicitly. View
construction, `@State` materialization, body evaluation, and structural
removal MUST NOT call the observation use cases. A host MAY realize both
logical serialization domains on one thread or cooperative loop, but MUST
preserve admission, sealing, mutation-phase ownership, and bounded outcomes.

Dynamic implementations MAY realize the logical responsibilities as separate
SwiftPM targets and use reference/existential wiring. Static implementations
MAY use generated or typed wiring and flatten packaging. Both MUST preserve
the ownership and dependency rules above.

## Types / APIs

The declarations below specify logical names, values, and operation semantics.
Concrete static wiring MAY replace existential or reference-storage mechanics,
but it MUST preserve the same portable call behavior and values.

Analyzer declarations are package-visible by default. This Specification does
not create a public reusable-library API. A target's executable entry point MAY
use the visibility required by its toolchain without widening Domain, Data, or
Presentation contracts.

### Domain values

```swift
struct SignalChannelID: Hashable, Sendable {
    let rawValue: Int
}

struct SignalChannel: Identifiable, Equatable, Sendable {
    let id: SignalChannelID
    let name: String
}

enum DigitalLevel: Equatable, Sendable {
    case low
    case high
}

struct SignalAnalyzerDiagnostic: Equatable, Sendable {
    /* Valid UTF-8 payload with a maximum encoded length of 96 bytes. */
}

struct SignalTransition: Equatable, Sendable {
    let channelID: SignalChannelID
    let timestamp: Duration
    let level: DigitalLevel
}

enum AcquisitionState: Equatable, Sendable {
    case idle
    case running
    case stopped
    case failed(SignalAnalyzerDiagnostic)
}
```

`SignalAnalyzerDiagnostic` MUST preserve at most 96 UTF-8 bytes. A longer
source diagnostic MUST be truncated at a valid scalar boundary. Dynamic
profiles MAY use `String` internally; static profiles MUST use inline or
caller-supplied bounded storage and MUST NOT allocate to construct, copy, or
transport this value.

`SignalAnalyzerDiagnostic` is semantic application data. Its presence may set
`AcquisitionState.failed`, populate `SignalAnalyzerViewState.errorMessage`, and
therefore change published UI state. It MUST be admitted, ordered, retained,
and tested independently of SPEC-003 diagnostic selection, buffering, or sink
delivery. It MUST NOT be represented by, reconstructed from, or conditionally
omitted with `GiftUIDiagnosticRecord`. A target MAY optionally project a
normalized analyzer outcome after correctness-relevant propagation, but that
projection MUST NOT create, remove, or alter this value or any policy input.

`SignalChannel.standard` MUST contain exactly these ordered values:

| Index | Identifier | Name | Initial level |
| ---: | ---: | --- | --- |
| 0 | 1 | CH1 | low |
| 1 | 2 | CH2 | low |
| 2 | 3 | CH3 | low |
| 3 | 4 | CH4 | low |

`SignalChannelID` values outside `1...4` are invalid for this application.
Transition timestamps MUST be nonnegative. A transition delivered by a source
uses acquisition-session elapsed time. A transition exposed by
`SignalCapture.transitions` uses capture-epoch elapsed time after repository
rebasing.

### Capture value

`SignalCapture` MUST expose these semantics regardless of its concrete dynamic
or static storage representation:

```swift
struct SignalCapture: Equatable, Sendable {
    let channels: /* ordered collection of SignalChannel */
    let transitions: /* chronological collection of SignalTransition */
    let duration: Duration
    let retainedLowerBound: Duration

    func baselineLevel(for channelID: SignalChannelID) -> DigitalLevel
    static func empty() -> SignalCapture
}
```

The capture invariants are:

- `channels` equals `SignalChannel.standard` in standard order.
- `transitions` are ordered by timestamp and then stable arrival order.
- Every transition timestamp is in
  `retainedLowerBound...duration`.
- `duration >= retainedLowerBound >= .zero`.
- `baselineLevel(for:)` returns the level at `retainedLowerBound` before any
  retained transition strictly after that bound is applied.
- `empty()` has standard channels, no transitions, zero duration, zero retained
  lower bound, and low baseline levels.

### Capture publication values

The repository MUST publish either a complete current snapshot or an exact
bounded mutation that transforms the preceding published revision into the
current capture:

```swift
struct SignalChannelLevels: Equatable, Sendable {
    let ch1: DigitalLevel
    let ch2: DigitalLevel
    let ch3: DigitalLevel
    let ch4: DigitalLevel
}

enum SignalCaptureChange: Equatable, Sendable {
    case insertAndTrim(
        baseRevision: UInt32,
        insertionIndex: UInt16,
        transition: SignalTransition,
        evictedPrefixCount: UInt16,
        duration: Duration,
        retainedLowerBound: Duration,
        baselines: SignalChannelLevels
    )
    case reset(
        baseRevision: UInt32,
        baselines: SignalChannelLevels
    )
}

enum SignalCapturePublication: Equatable, Sendable {
    case snapshot(revision: UInt32, capture: SignalCapture)
    case mutation(revision: UInt32, change: SignalCaptureChange)
}

enum SignalSinkDeliveryRejection: UInt8, Equatable, Sendable {
    case snapshotCapacityExhausted
    case factCapacityExhausted
    case runtimeUnavailable
    case sequenceExhausted
}

enum SignalSinkDeliveryOutcome: Equatable, Sendable {
    case accepted(sequence: UInt32)
    case rejected(SignalSinkDeliveryRejection)
}
```

Revision zero identifies the initial empty capture. Each accepted transition
and each Clear MUST increment the revision exactly once. Revision arithmetic
MUST NOT wrap; attempting to advance `UInt32.max` is a contained application
failure that stops acquisition and requires a fresh analyzer object graph.

For `insertAndTrim`, `baseRevision` MUST equal the preceding publication's
revision. Applying the change first inserts `transition` at `insertionIndex`
in the preceding capture and then removes `evictedPrefixCount` entries from
the resulting prefix before replacing duration, lower bound, and all four
baselines. This ordering permits the newly inserted transition itself to be
evicted under capacity pressure. The result is the repository's current
capture at the publication revision. Both counts MUST be at most 2,404.
`reset` replaces the capture with no transitions,
zero duration and lower bound, and the supplied baselines. `.snapshot`
publication is required for immediate current-value delivery when observation
starts or restarts. Ordinary accepted transitions and Clear MUST use
`.mutation` publication so the static path does not copy a complete
2,404-entry capture per event.

### Sink and repository contract

```swift
protocol SignalCaptureSink {
    func receive(_ publication: SignalCapturePublication)
        -> SignalSinkDeliveryOutcome
}

protocol AcquisitionStateSink {
    func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome
}

protocol SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink)
    func stopObservingCapture()
    func startObservingAcquisitionState(sink: some AcquisitionStateSink)
    func stopObservingAcquisitionState()
    func start() throws
    func stop()
    func clear()
}
```

All operations MUST execute on the application executor. The repository MUST
support exactly one sink of each kind. A new sink replaces the previous sink
and immediately receives the current value before registration returns. The
capture callback MUST use a `.snapshot` publication. Each callback MUST return
the admission adapter's bounded outcome before registration or publication
continues.
Stopping observation detaches the sink before returning.

An implementation MUST NOT keep a dynamic application graph alive solely
through observation. Dynamic implementations SHOULD use weak sink ownership;
static implementations MAY use explicit lifetime wiring. Once a sink is gone
or detached, it MUST receive no later callback.

### Source contract

```swift
protocol SignalTransitionSink {
    func receive(_ transition: SignalTransition)
}

protocol SignalDataSource {
    func start(sink: some SignalTransitionSink) throws
    func stop()
}
```

`start` MUST install the sink and begin or resume event production. Repeated
`start` while active MUST be an idempotent no-op. `stop` MUST halt later
delivery before returning; repeated `stop` while inactive MUST be a no-op.
Delivery MUST be synchronous on the application executor and monotonically
nondecreasing by source timestamp. A source using interrupts, polling, or a
runtime task MUST adapt those mechanisms before entering this contract.

### Use cases

The Domain MUST expose logical use cases equivalent to:

```swift
struct ObserveSignalCaptureUseCase {
    func start(sink: some SignalCaptureSink)
    func stop()
}

struct ObserveAcquisitionStateUseCase {
    func start(sink: some AcquisitionStateSink)
    func stop()
}

struct StartSignalAcquisitionUseCase { func execute() throws }
struct StopSignalAcquisitionUseCase { func execute() }
struct ClearSignalCaptureUseCase { func execute() }
```

Each use case MUST delegate synchronously to its injected repository and MUST
add no platform, UI, timing, buffering, or concurrency behavior.

### Presentation values

```swift
enum VisibleTimeWindow: Equatable, Sendable {
    case oneSecond
    case twoSeconds
    case fiveSeconds

    var duration: Duration { get }
}

struct SignalAnalyzerViewState: Equatable, Sendable {
    var acquisitionState: AcquisitionState
    var capture: SignalCapture
    var visibleWindow: VisibleTimeWindow
    var errorMessage: SignalAnalyzerDiagnostic?
}

enum SignalAnalyzerPresentationFact: Equatable, Sendable {
    case captureSnapshot(revision: UInt32, capture: SignalCapture)
    case captureMutation(revision: UInt32, change: SignalCaptureChange)
    case acquisitionState(AcquisitionState)
    case operationalFailure(
        outcome: GiftUIOutcome<Void>,
        diagnostic: SignalAnalyzerDiagnostic
    )
}

enum SignalAnalyzerObservationStartOutcome: Equatable, Sendable {
    case started(captureSequence: UInt32, stateSequence: UInt32)
    case alreadyStarted
    case rejected(SignalSinkDeliveryRejection)
}

enum SignalAnalyzerResidualPolicyContext: UInt8, Equatable, Sendable {
    case observationStart
    case activeDelivery
    case initialModelAttachment
    case modelReplacement
    case modelChangeReport
    case captureFactApplication
}

protocol SignalAnalyzerFactAdmission {
    func submit(_ fact: SignalAnalyzerPresentationFact)
        -> SignalSinkDeliveryOutcome
}
```

The duration mapping MUST be exactly 1, 2, and 5 seconds. Initial view state
MUST be idle, empty capture, two-second window, and no error.
An `operationalFailure` fact MUST contain the `.failure` case produced by the
normalization table below; `.success` and `.operational` are invalid for that
fact and MUST be rejected before admission.

`SignalAnalyzerPresentationAdmissionAdapter` MUST:

- implement `SignalCaptureSink` and `AcquisitionStateSink`;
- own the two observation use cases and idempotent `startObserving()` and
  `stopObserving()` operations;
- receive one target-supplied `SignalAnalyzerFactAdmission` endpoint;
- convert `.snapshot` publications to `captureSnapshot`, `.mutation`
  publications to `captureMutation`, and state callbacks to
  `acquisitionState`;
- submit exactly one fact per callback and return the submission outcome;
- never attach a GiftUI observable registration, retain the ViewModel, mutate
  Presentation state, or use the model as admission storage; and
- report a rejection to the target-composed owner adapter, which MUST preserve
  the local rejection, normalize it to `GiftUIOutcome<Void>`, apply mandatory
  coordinator effects, and only then invoke residual policy when the tables in
  Error Handling leave a product choice.

The adapter MUST NOT send `SignalSinkDeliveryRejection` directly to a policy.
Every concrete analyzer residual policy MUST conform to
`GiftUIResidualFailurePolicy` with
`Context == SignalAnalyzerResidualPolicyContext` and MUST receive only a
successfully constructed `GiftUIResidualPolicyInput`. A policy seam MUST NOT
reinterpret rejection as acceptance or directly mutate the ViewModel.

`startObserving()` MUST return `SignalAnalyzerObservationStartOutcome`. It
returns `started` only after both immediate publications are accepted. If
either is rejected, the adapter MUST detach both sinks, preserve any already
accepted fact for at-most-once application, attempt the reserved operational
failure fact, and return the original rejection. `alreadyStarted` MUST perform
no registration or publication. `stopObserving()` MUST detach both sinks before
returning and be an idempotent no-op when already stopped.

`SignalAnalyzerViewModel` MUST:

- own exactly one `SignalAnalyzerViewState` value;
- receive the Start, Stop, and Clear use cases through the target-composed
  synchronous application-executor entry contract;
- expose `startTapped`, `stopTapped`, `clearTapped`, and
  `visibleDurationChanged` intents;
- expose package-scoped fact application callable only by the GiftUI mutation
  domain;
- expose the derived visible range;
- participate in GiftUI's provided observable invalidation contract without
  requiring the portable code to own a task, clock, queue, lock, actor, or
  scheduler; and
- never implement the repository sinks or accept direct application-executor
  mutation.

### Observable state and admission configuration

Portable Presentation MUST use this source-level ownership shape in every
profile:

```swift
struct SignalAnalyzerView: View {
    @State private var viewModel: SignalAnalyzerViewModel
}
```

The assembled analyzer MUST configure exactly one observable state location,
one active model registration, one dirty bit, one live bit, and capacity for
one transient replacement registration. The fixed root MUST use a generated
or runtime-provided `UInt32` structural identity and declaration-local
`UInt16` state identity. The registration token MUST contain a `UInt16` slot
and a nonzero `UInt32` generation. Generation arithmetic MUST NOT wrap; token
exhaustion MUST reject reuse and require a fresh runtime instance.

The static profile MUST provide one address-stable generated
`SignalAnalyzerViewModel` storage location. Copying its typed handle MUST
preserve that storage identity. The location record MUST contain the structural
and declaration identities, active registration token, live/staged/dirty
flags, and type/layout discriminator. The registration record MUST contain the
owning location, generation, and bounded model change endpoint. The transient
replacement record MUST be separate from the active record so failed
replacement leaves the active association unchanged.

Static target builds MUST generate this typed storage and direct change-sink
dispatch from an immutable Signal Analyzer profile descriptor containing the
model type, structural and declaration identities, and capacities in this
section. Generation MUST be deterministic and run before Swift compilation;
the emitted Swift source MUST be inspectable build input and MUST NOT perform
runtime reflection, platform discovery, or capacity negotiation. The generated
portable model declarations belong to the `GiftUI` import surface; generated
runtime storage and dispatch remain package-scoped below that surface. Dynamic
targets MUST compile the same portable Presentation source without consuming
the static storage implementation.

The dynamic profile MAY use heap-backed lookup and retained model storage, but
MUST enforce the same configured capacities, identifier widths, one-owner
cardinality, generation exhaustion, replacement behavior, and outcomes.

The package-scoped model/runtime integration MUST be semantically equivalent
to these bounded declarations; a static build MAY generate specialized direct
calls instead of protocol existentials:

```swift
struct SignalAnalyzerRegistrationToken: Equatable, Sendable {
    let slot: UInt16
    let generation: UInt32
}

enum SignalAnalyzerAttachOutcome: UInt8, Equatable, Sendable {
    case attached
    case stateLocationCapacityExhausted
    case registrationCapacityExhausted
    case replacementStagingExhausted
    case duplicateModelOwner
    case incompatibleStateAssociation
    case identityGenerationExhausted
}

enum SignalAnalyzerChangeReportOutcome: UInt8, Equatable, Sendable {
    case dirtied
    case coalesced
    case staleRegistration
    case mutationPhaseViolation
}

protocol SignalAnalyzerModelChangeSink {
    func reportChange(token: SignalAnalyzerRegistrationToken)
        -> SignalAnalyzerChangeReportOutcome
}
```

Initial attachment and replacement MUST return
`SignalAnalyzerAttachOutcome`. Detachment MUST require the exact active token
and be idempotent only for that token; any later report with it returns
`staleRegistration`. Each observable model mutator MUST hold its installed
token and synchronously call the model change sink before returning after a
change. The portable analyzer does not assign a replacement ViewModel after
initial materialization, but the configured runtime and shared conformance
fixtures MUST support the accepted atomic replacement behavior.

Fact admission MUST provide these independent fixed capacities per analyzer:

| Storage | Capacity | Contents |
| --- | ---: | --- |
| Capture snapshot slot | 1 | One complete capture of at most 2,404 transitions |
| Ordered compact-fact ring | 32 | Capture mutations and acquisition-state facts |
| Reserved operational-failure slot | 1 | One failure fact unavailable to ordinary traffic |

The 32 compact slots cover the maximum 20 capture publications in one
half-open 250-millisecond interval after initialization, four initial channel
publications, one acquisition-state publication, and seven additional
action-induced publications. A host MUST request a GiftUI cycle after the
first accepted fact and MUST demonstrate
that the ring does not saturate at the accepted 80-event-per-second workload.

Every accepted fact MUST receive a monotonically increasing nonzero `UInt32`
sequence. Snapshot, compact, and reserved slots MUST be sealed and applied in
sequence order even if their physical storage is separate. Sequence arithmetic
MUST NOT wrap. A fact arriving after cycle sealing waits for a later cycle.
The runtime MUST apply each accepted fact at most once and MUST NOT silently
replace, coalesce, or discard an accepted fact. Change reports and wake intent
MAY coalesce; the facts themselves MUST NOT.

The runtime and adapter MUST preserve these source-stable condition names in a
bounded `UInt8` representation; numeric values are build-local and MUST NOT be
persisted or treated as protocol identifiers:

```swift
enum SignalAnalyzerRuntimeCondition: UInt8 {
    case stateLocationCapacityExhausted
    case registrationCapacityExhausted
    case replacementStagingExhausted
    case duplicateModelOwner
    case incompatibleStateAssociation
    case staleRegistrationReport
    case mutationPhaseViolation
    case captureRevisionMismatch
    case reservedFailureCapacityExhausted
    case identityGenerationExhausted
}
```

`SignalAnalyzerRuntimeCondition` is a producer catalogue, not a policy or
diagnostic vocabulary. An admission rejection retains its specific
`SignalSinkDeliveryRejection`; it MUST NOT be collapsed into a generic
`factAdmissionRejected` identity.

## Behavior

### Serialized delivery

Every source delivery, repository mutation, sink callback, and use-case call
MUST run to completion on the application executor. A producer MUST NOT invoke
a second sink callback before the current callback returns. The callback MUST
terminate at the Presentation admission adapter and return its admission
outcome. It MUST NOT directly or reentrantly mutate the ViewModel.

Only the GiftUI mutation domain MAY apply an accepted fact or semantic action
to the ViewModel. It MUST seal an ordered batch, apply each member at most
once, coalesce model change reports, freeze observable mutation before
derivation, and publish only a complete semantic revision. No portable Domain
or Presentation contract may require an async stream, task, queue, lock,
actor, scheduler, or cross-actor handoff.

The repository MUST publish a capture synchronously after every accepted
transition and after every clear. It MUST publish acquisition state whenever a
state transition occurs. Publication updates repository state before invoking
the sink and MUST NOT roll repository state back if fact admission rejects the
resulting callback. GiftUI MAY coalesce the resulting model change reports and
view invalidations after facts are applied.

### Repository transition processing

For every received transition, the repository MUST perform these steps in
order:

1. Validate that the channel is one of the four standard channels and that the
   timestamp is nonnegative.
2. Translate the source session timestamp into the current capture epoch.
3. Insert the transition in timestamp order; equal timestamps retain arrival
   order, and the last equal-timestamp transition determines the resulting
   level.
4. Update capture duration to the greatest accepted epoch timestamp.
5. Compute the time retention cutoff as
   `max(.zero, duration - 30 seconds)`.
6. Evict transitions older than the cutoff, updating each channel baseline
   with the last evicted level for that channel.
7. If capacity still exceeds the concrete limit, evict the oldest transition
   repeatedly, update the relevant baseline, and advance the retained lower
   bound to the last evicted timestamp.
8. Increment the capture revision and publish one `.mutation` value containing
   the exact `insertAndTrim` change that produces the new current capture.

An out-of-order transition at or after the retained lower bound MUST be
inserted stably. A transition older than the retained lower bound is outside
the representable history and MUST be dropped without changing capture data;
the implementation MUST record this occurrence in target-appropriate
diagnostic evidence. Such a drop MUST NOT crash the application.

An invalid channel or negative timestamp is a source contract violation. The
repository MUST stop the source, publish `.failed` with a nonempty diagnostic,
and reject the transition without mutating the capture.

### Capture capacity and baselines

The maximum accepted workload is four channels × 10 cycles per second × two
transitions per cycle = 80 transitions per second. Static storage MUST provide
at least 2,404 transition entries, covering four initial levels plus 2,400
events in 30 seconds, and MUST maintain four channel baselines.

Time trimming and capacity eviction MUST preserve the newest representable
history. For any channel, reconstructing from its baseline and retained
transitions MUST produce the same level at every retained timestamp as the
untrimmed transition history would produce.

### Acquisition actions

`start` behavior:

- If already running, return successfully without starting another producer or
  publishing another state.
- Otherwise ask the source to start.
- If source start succeeds, publish `.running` before returning.
- If source start fails, leave the source inactive, publish `.failed(message)`,
  and throw the same failure or an error carrying the same diagnostic.

`stop` behavior:

- If not running, return without publishing a state.
- If running, stop the source, prevent later events from the stopped generation,
  then publish `.stopped` before returning.
- A later `start` resumes the acquisition session without duplicate producers
  and preserves the source's conceptual elapsed time and channel levels.

`clear` behavior:

- Remove every retained transition.
- Begin a new capture epoch with duration and retained lower bound equal to
  zero.
- Preserve each channel's current digital level as the new baseline.
- Preserve the current acquisition state and whether the source is active.
- Rebase future source timestamps to the new epoch.
- Increment the capture revision and publish one `.mutation` value containing
  the `reset` change synchronously before returning.

Before any source event has established a current level, the level is low.

### Mock source

The default mock source MUST be deterministic for a supplied seed and timing
scale and MUST emit four initial low baselines at timestamp zero on its first
start. It MUST model these patterns:

- CH1 toggles every 250 milliseconds.
- CH2 toggles every 400 milliseconds.
- CH3 repeats the interval sequence 80 ms, 80 ms, 80 ms, 1,200 ms, 75 ms,
  75 ms, and 900 ms.
- CH4 uses a seeded deterministic pseudo-random interval from 180 through
  599 milliseconds inclusive.

The source MUST provide live timing and an accelerated deterministic test
configuration. Stop MUST cancel or invalidate the active generation so it
cannot emit stale transitions. Restart MUST continue conceptual source time
and levels. Destroying the source MUST prevent later delivery.

The mock MAY use runtime-specific scheduling internally. That mechanism MUST
NOT appear in Domain or Presentation contracts.

### ViewModel behavior

- Host-started adapter observation installs both sinks at most once. Immediate
  capture and acquisition-state callbacks submit facts; starting observation
  MUST NOT claim that the ViewModel is current until those facts are applied
  and a complete semantic revision publishes.
- Host-stopped adapter observation detaches both sinks at most once and does
  not remove the runtime-owned ViewModel state location.
- Applying `captureSnapshot` replaces `state.capture` and its internal capture
  revision atomically.
- Applying `captureMutation` MUST validate `baseRevision`, reproduce the
  publication algorithm exactly, and replace the internal revision. A mismatch
  MUST leave the model unchanged and return the bounded incompatible-fact
  outcome described under Error Handling.
- Applying `acquisitionState` replaces `state.acquisitionState`. Applying
  `.failed(message)` also sets `state.errorMessage` to `message`.
- Applying `operationalFailure` sets acquisition state to failed and exposes
  its bounded diagnostic without applying any rejected ordinary fact.
- `startTapped` clears an old error inside the current GiftUI mutation phase,
  synchronously invokes Start through the application-executor entry contract,
  and maps a thrown failure to bounded error text. Any synchronous repository
  callback caused by Start becomes a later admitted fact and MUST NOT reenter
  the ViewModel.
- `stopTapped` invokes Stop.
- `clearTapped` invokes Clear.
- `visibleDurationChanged` replaces the selected window as an ordinary
  semantic action in the current GiftUI mutation phase.
- Repeated action calls preserve the repository idempotency rules.

Every fact or action that changes observable ViewModel state MUST synchronously
emit at least one model-owned change report before that fact or action returns.
A proven no-op MAY emit none. Reports MUST contain only owner-dirty meaning,
MUST NOT identify properties or values, and MUST coalesce to one dirty bit and
at most one pending wake requirement. Reports MUST NOT trigger reentrant
evaluation.

### Visible range

Presentation MUST compute the visible range as:

```text
window = selectedWindow.duration
end = max(window, capture.duration)
start = max(0, end - window)
visibleRange = start ..< end
```

The range MUST always span exactly the selected duration. An empty two-second
capture displays `0..<2 s`; a 17.3-second capture with a two-second selection
displays `15.3..<17.3 s`.

### Portable hierarchy

The hierarchy MUST be structurally equivalent to:

```text
SignalAnalyzerView
├── header
│   ├── title and subtitle
│   └── acquisition status
├── WaveformView
│   ├── time ruler
│   ├── ChannelWaveformView for CH1
│   ├── ChannelWaveformView for CH2
│   ├── ChannelWaveformView for CH3
│   └── ChannelWaveformView for CH4
├── controls
│   ├── Start
│   ├── Stop
│   ├── Clear
│   └── 1 s, 2 s, and 5 s window buttons
└── error text
```

The four channel rows and three window controls MUST be declared explicitly.
The portable hierarchy MUST NOT require dynamic collections, scrolling,
navigation, menus, animations, gestures, environment values, geometry readers,
gradients, shadows, clipping, opacity, or alpha compositing.

### Status and disabled state

| Acquisition state | Status text | Start | Stop |
| --- | --- | --- | --- |
| idle | READY | Enabled | Disabled |
| running | RUNNING | Disabled | Enabled |
| stopped | STOPPED | Enabled | Disabled |
| failed | FAILED | Enabled | Disabled |

Clear MUST remain enabled in every state. Exactly one visible-window control
MUST be disabled: the currently selected window.

### Waveform and ruler

The time ruler MUST display labels for the visible lower bound, midpoint, and
upper bound in seconds with two fractional digits.

For each channel:

1. Begin with `capture.baselineLevel(for:)` at the retained lower bound.
2. Apply all channel transitions through the visible lower bound to derive the
   starting visible level.
3. Begin the path at the left edge at that level.
4. For each channel transition where
   `visibleLowerBound < timestamp <= visibleUpperBound`, draw a horizontal
   segment to its x coordinate, a vertical segment to the resulting level, and
   continue from there.
5. Draw the final horizontal segment to the right edge.

Horizontal mapping MUST be:

```text
x = (timestamp - visibleLowerBound) / visibleSpan * canvasWidth
```

Low and high MUST map to visibly distinct horizontal levels with nonzero top
and bottom insets. The grid MUST include 11 evenly spaced vertical lines and
one horizontal center line. Exact colors, insets, stroke widths, caps, joins,
and row sizes are non-normative provided traces and grid remain legible.

The visible HIGH or LOW label MUST reflect the channel level at
`capture.duration`, not merely the last transition retained in the selected
visible window.

### Refresh behavior

The analyzer display refresh interval is 250 milliseconds. Acquisition and
fact admission MAY occur up to 80 times per second. GiftUI MAY apply and
coalesce up to 20 worst-case capture-fact change reports before one frame. A
rendered frame MUST use one internally consistent published model revision and
MUST include every fact and action applied before derivation for that revision
begins. An accepted fact not included in the sealed batch waits for a later
cycle and MUST NOT be reported as already visible.

## State / Lifecycle

The repository acquisition state machine is:

| Current state | Operation | Result | Published state |
| --- | --- | --- | --- |
| idle | start succeeds | Source active | running |
| idle | start fails | Source inactive | failed(message) |
| idle | stop | No change | None |
| running | start | No change | None |
| running | stop | Source inactive | stopped |
| running | clear | Source remains active; capture epoch resets | None |
| stopped | start succeeds | Source active, session resumes | running |
| stopped | start fails | Source inactive | failed(message) |
| stopped | stop | No change | None |
| failed | start succeeds | Source active | running |
| failed | start fails | Source inactive | failed(newMessage) |
| failed | stop | No change | None |
| any | clear | Capture epoch resets | Acquisition state unchanged |

Initial repository state is idle with an empty capture and low baselines.
Starting observation does not change acquisition state. Stopping observation
does not stop acquisition. Teardown MUST stop the source or otherwise prove
that no later callback can reach destroyed repository or Presentation state.

Source generations MUST be unique. A stopped, cancelled, replaced, or
destroyed generation MUST fail closed and produce no later transition.

The observable ViewModel location lifecycle is:

| Event | Required result |
| --- | --- |
| First successful root materialization | Install the provided model and one active registration |
| Repeated transient initializer at the same live identity | Preserve the installed model and registration; ignore the initializer for replacement |
| Admitted replacement succeeds | Stage and validate the candidate, atomically activate it, retire the old registration, and dirty the location |
| Replacement validation, capacity, or attachment fails | Remove partial candidate state and preserve the old model and registration without dirtying solely for the failed attempt |
| Candidate hierarchy omits the location but derivation fails | Preserve the previously published live location |
| A complete published hierarchy omits the location | Retire the registration and release or reset the location |
| Reinsertion after published removal | Materialize fresh state with a new nonaliasing generation |

One model MUST NOT own two locations or two registrations. Descendant reads
MAY borrow the installed model without registering. A successful replacement
remains installed and dirty if later derivation fails; retry MUST rederive
without replaying the replacement.

Application observation and GiftUI observable registration are independent
lifecycles. Stopping repository observation does not detach the live model's
GiftUI registration. Published structural removal detaches the GiftUI
registration but does not call repository observation use cases. Teardown MUST
explicitly stop repository observation, retire the root state location through
publication or runtime shutdown, and prove that stale callbacks and stale
model reports cannot affect a later object graph.

## Capability Requirements

The portable analyzer assumes every MVP configuration supplies all GiftUI
features listed in the MVP scope. It MUST NOT branch on platform identity,
renderer identity, or availability of an individual required UI feature.

If any required UI behavior is absent, initialization or target validation
MUST fail explicitly and that configuration MUST NOT claim Signal Analyzer
conformance. The application MUST NOT substitute a reduced screen.

Monotonic time and scheduling are target/backend capabilities. Their concrete
types and negotiation are outside this Specification. The host MUST provide
them to the concrete source without exposing them to Domain or Presentation.

## Backend Requirements

GiftUI backends used by the analyzer MUST realize the required layout, opaque
color, text, backgrounds, input, disabled state, state invalidation, and line
drawing behavior without analyzer-domain knowledge.

Each target host MUST:

- connect the appropriate dynamic or static GiftUI runtime;
- configure exactly the observable-state and fact capacities specified above;
- compose the repository sinks with the Presentation admission adapter rather
  than the ViewModel;
- schedule a GiftUI cycle after the first pending fact while coalescing later
  wake requests;
- provide a display size on which all four rows and controls are usable;
- translate input into the required button actions;
- compute analyzer frames no more frequently than once per 250 milliseconds;
  a platform MAY scan out the most recent completed frame more frequently
  without rebuilding the analyzer view;
- provide a deterministic mock source for behavioral conformance;
- confine platform, display, input, executor, timing, and hardware code outside
  the portable hierarchy.

The Raspberry Pi/Linux claim requires execution with framebuffer rendering and
PiScreen display/input evidence. The nRF52840 claim requires static execution
with the supported TFT display. A host simulator does not substitute for those
connected-hardware claims.

Real GPIO or peripheral acquisition MAY replace the mock behind
`SignalDataSource`, but hardware acquisition is not required for analyzer
application conformance unless a separate target validation explicitly
requires it.

## Error Handling

- Source startup failures MUST produce `.failed(nonemptyMessage)`, remain
  inactive, and reach ViewModel error text.
- A later successful Start MUST clear prior Presentation error text and publish
  running state.
- Invalid channel identifiers and negative timestamps MUST stop acquisition,
  reject the event, and publish failed state with a diagnostic.
- Events older than the retained lower bound MUST be dropped and diagnosed but
  MUST NOT corrupt the current capture or crash the application.
- Capacity overflow MUST use deterministic oldest-first eviction and MUST NOT
  become a fatal error at or below the accepted 80-event-per-second workload.
- Missing required GiftUI or backend behavior MUST fail target validation
  explicitly; it MUST NOT silently degrade the portable screen.
- Stale events from a stopped or replaced source generation MUST be ignored.
- Snapshot-slot, compact-ring, runtime-availability, and sequence exhaustion
  MUST reject admission synchronously with the corresponding
  `SignalSinkDeliveryRejection`. Rejection MUST NOT mutate the ViewModel,
  overwrite an accepted fact, or fall back to direct mutation.
- The adapter MUST reserve and attempt one `operationalFailure` fact containing
  the normalized non-success `GiftUIOutcome<Void>` after an ordinary admission
  rejection. If the reserved slot is unavailable, the host MUST quiesce
  acquisition and preserve the last complete published semantic revision. At
  the accepted workload, any admission rejection is a conformance failure.
- State-location, registration, or replacement-staging exhaustion MUST reject
  the candidate association, remove partial candidate state, and preserve an
  existing live association. Initial materialization failure prevents the
  analyzer root from publishing and requires target policy to quiesce that
  analyzer instance.
- Duplicate ownership or incompatible type/layout association MUST reject the
  new association without reinterpreting storage or adding a second
  registration.
- A stale registration report MUST be rejected and MUST NOT dirty either a
  retired location or a later occupant of the same slot.
- A capture-revision mismatch MUST leave ViewModel capture state unchanged,
  mark the analyzer Presentation scope operationally failed, and require a new
  snapshot through explicit observation restart; it MUST NOT guess or apply a
  partial delta.
- A report during freeze or another prohibited phase MUST mark the affected
  semantic scope dirty and return `mutationPhaseViolation`. If the runtime
  cannot prove stable state, containment is `safety not proven` and target
  policy MUST quiesce the analyzer rather than publish potentially torn state.
- Derivation failure after applied mutations MUST discard partial derived
  output, retain current state as dirty, request a later host-paced cycle, and
  MUST NOT replay or roll back facts, actions, or model replacement.

### Failure normalization and disposition

The owner adapter MUST normalize every analyzer condition that can reach a
coordinator or composition policy with the following total mapping. The
`Outcome` column supplies the exact SPEC-003 category and condition identity;
each failure row is enclosed as `GiftUIOutcome<Void>.failure`. The two phase
rows are selected by the detecting runtime's proof of stable state, not by
policy or diagnostics.

| Producer condition | Outcome | Origin | Affected scope | Containment |
| --- | --- | --- | --- | --- |
| `snapshotCapacityExhausted` | failure / `capacityExhausted` | `presentationIntegration` | `component` | `contained` |
| `factCapacityExhausted` | failure / `capacityExhausted` | `presentationIntegration` | `component` | `contained` |
| `runtimeUnavailable` | failure / `requiredFacilityUnavailable` | `execution` | `runtime` | `safetyNotProven` |
| `sequenceExhausted` | failure / `invalidProvenance` | `presentationIntegration` | `runtime` | `safetyNotProven` |
| `stateLocationCapacityExhausted` | failure / `capacityExhausted` | `observableState` | `component` | `contained` |
| `registrationCapacityExhausted` | failure / `capacityExhausted` | `observableState` | `component` | `contained` |
| `replacementStagingExhausted` | failure / `capacityExhausted` | `observableState` | `operation` | `contained` |
| `duplicateModelOwner` | failure / `invalidIdentity` | `observableState` | `component` | `contained` |
| `incompatibleStateAssociation` | failure / `invalidIdentity` | `observableState` | `component` | `contained` |
| `staleRegistrationReport` | failure / `invalidIdentity` | `observableState` | `operation` | `contained` |
| `identityGenerationExhausted` | failure / `invalidIdentity` | `observableState` | `runtime` | `safetyNotProven` |
| `captureRevisionMismatch` | failure / `invalidProvenance` | `presentationIntegration` | `component` | `contained` |
| `reservedFailureCapacityExhausted` | failure / `capacityExhausted` | `presentationIntegration` | `runtime` | `safetyNotProven` |
| `mutationPhaseViolation`, stable state proven | failure / `invalidPhase` | `execution` | `activeCycle` | `contained` |
| `mutationPhaseViolation`, stable state not proven | failure / `invalidPhase` | `execution` | `activeCycle` | `safetyNotProven` |

Unknown analyzer rejection or runtime-condition values MUST normalize to
`unknownProducerCondition`, preserve the known producer origin, use the
smallest scope the adapter can prove, and use `safetyNotProven`. Wrapping,
correlation, semantic diagnostics, and optional diagnostic projection MUST
preserve the normalized condition, origin, scope, and containment.

Disposition MUST then proceed in the SPEC-003 order below. A dash in
`Allowed residual dispositions` means mandatory detecting/coordinator work
leaves no product choice, so no `GiftUIResidualPolicyInput` is constructed and
policy is not invoked.

| Normalized condition and owning operation | Residual context | Mandatory mechanical and coordinator effects | Allowed residual dispositions | Signal Analyzer target selection |
| --- | --- | --- | --- | --- |
| Admission capacity failure during observation start | `observationStart` | Reject without overwrite, attempt the reserved normalized failure fact, and detach both observers | `quiesceAffectedScope` | `quiesceAffectedScope` |
| Admission capacity failure during active delivery | `activeDelivery` | Reject without overwrite, attempt the reserved normalized failure fact, and stop further acquisition delivery after the active callback | `quiesceAffectedScope` | `quiesceAffectedScope` |
| Runtime unavailable, sequence exhausted, or reserved failure slot unavailable | `observationStart` or `activeDelivery`, matching the rejected operation | Reject without wrap or alias, preserve the last complete revision, prevent another normal cycle, and require a fresh runtime/object graph | `quiesceAffectedScope`, `invokeFatalHook` | `quiesceAffectedScope` |
| Identity generation exhausted | `initialModelAttachment` or `modelReplacement`, matching the rejected operation | Reject without alias, preserve any existing live model and the last complete revision, prevent another normal cycle, and require a fresh runtime/object graph | `quiesceAffectedScope`, `invokeFatalHook` | `quiesceAffectedScope` |
| Initial state-location or registration capacity failure | `initialModelAttachment` | Remove partial candidate state and publish no analyzer root | `quiesceAffectedScope`, `invokeFatalHook` | `quiesceAffectedScope` |
| Replacement staging, duplicate owner, incompatible association, or state/registration capacity failure with an existing live model | `modelReplacement` | Remove partial candidate state and preserve the existing model and registration | `continueOperation`, `quiesceAffectedScope` | `continueOperation` |
| Stale registration report | `modelChangeReport` | Reject the report and preserve current dirty state without dirtying a retired or later slot occupant | `continueOperation` | `continueOperation` |
| Capture revision mismatch | `captureFactApplication` | Preserve current capture, mark the analyzer Presentation component failed, detach observation, and require explicit restart with a snapshot | `quiesceAffectedScope` | `quiesceAffectedScope` |
| Contained mutation phase violation | — | Preserve the last complete publication, retain dirty state, and schedule exactly one coordinator-owned retry no earlier than the next 250-millisecond host pace | — | — |
| Mutation phase violation with safety not proven | `modelChangeReport` | Discard partial publication and prevent another normal cycle | `quiesceAffectedScope`, `invokeFatalHook` | `quiesceAffectedScope` |

Every row with residual choices MUST construct
`GiftUIResidualPolicyInput<SignalAnalyzerResidualPolicyContext>` through its
only public initializer after the mandatory effects complete. Because this
target table has no residual retry choice, `attemptOrdinal` MUST be `0` and
`attemptLimit` MUST be `1`. The contained phase retry is coordinator-owned,
is attempted at most once, and does not enter policy. If it again encounters a
phase violation, the detecting runtime MUST report the safety-not-proven row.
The concrete policy MUST return a member of `allowed` and MUST produce the
target selection shown above for every enumerated input.

Unexpected policy-input construction failure or a policy result outside
`allowed` MUST use SPEC-003's exact host-composition invariant mapping: create
`.invariantViolation` from `.hostComposition` for `.runtime` with
`.safetyNotProven`, invoke no further policy, quiesce runtime health before any
configured fatal hook, and admit no later normal run cycle.

Policy MUST NOT consume `SignalSinkDeliveryRejection` or
`SignalAnalyzerRuntimeCondition`, narrow affected scope, reinterpret rejection
as success, retry without a bound, or bypass the reserved fact and normal
admission boundary.
Quiescence after admission failure MUST prevent later source callbacks without
publishing an ordinary `.stopped` fact that could overwrite the operational
failure. After the reserved failure fact publishes, the host MAY destroy and
recreate the complete analyzer object graph through normal explicit teardown.

Optional SPEC-003 diagnostic projection MAY use platform-appropriate reporting
only after normalized propagation or authoritative state commit. Projection
configuration and sink results MUST NOT affect normalization, mandatory
effects, residual input, policy selection, `SignalAnalyzerDiagnostic`, or
user-visible state. User-visible error text MUST NOT expose unstable
implementation type names or memory addresses and MUST satisfy the 96-byte
bound.

## Performance Requirements

- The acquisition graph MUST sustain 80 transition events per second for at
  least 30 continuous seconds without loss, reordering, duplicate delivery, or
  stale-generation events.
- The display MUST render a consistent latest state at a target cadence of four
  frames per second under the same workload.
- Fact admission and GiftUI mutation cycles MUST accept and apply all 80
  capture publications per second without snapshot-slot, compact-ring, or
  reserved-slot rejection under that workload.
- Up to 20 capture-fact model change reports between frames MUST coalesce to
  one dirty transition and at most one pending wake requirement without
  dropping the accepted facts.
- The implementation MUST NOT require one rendered frame per transition.
- Facts and actions applied before semantic derivation begins MUST appear no
  later than the next scheduled analyzer frame, absent a documented platform
  failure. Merely accepted but not yet sealed facts are not considered applied.
- Static capture storage MUST hold at least 2,404 transition entries plus four
  baselines.
- Static Presentation integration MUST additionally provide one 2,404-entry
  snapshot slot, 32 compact fact slots, one reserved failure slot, one model
  location, one active registration, and one replacement-staging record.
- Dynamic storage MAY allocate, but retained logical history MUST remain
  bounded to 30 seconds and equivalent capacity behavior.
- nRF52840 validation MUST record firmware binary size, static/global RAM,
  estimated or measured stack high-water mark where supported, transition
  storage size, and drawing workspace size.
- Raspberry Pi validation MUST record process memory and observed frame cadence
  under the sustained workload.
- The MVP imposes no smaller numeric memory or binary-size budget, but every
  claimed configuration MUST build, fit, launch, remain responsive, and finish
  the sustained workload without allocation failure or watchdog reset.
- Evidence MUST separately report model storage, state-location and
  registration records, stale-generation protection, snapshot storage,
  compact and reserved fact storage, maximum sealed batch, admission/application
  time, change-report time, dirty-to-publication latency, and dirty-to-frame
  latency.

## Compatibility

The governed implementation MUST preserve the observable application behavior
of the macOS investigation except where accepted ADRs replace desktop-specific
mechanisms or add bounded-baseline behavior.

ADR-027 intentionally changes one timing guarantee from the investigation:
repository sink return no longer means that ViewModel state changed. It means
that a bounded fact was accepted or explicitly rejected. Observable state
changes only when GiftUI later applies an accepted fact. Code in which the
ViewModel implements repository sinks or relies on immediate sink-to-model
mutation is incompatible and MUST migrate to the admission adapter.

The portable Presentation migrates from SwiftUI to GiftUI. Exact SwiftUI source
compatibility, exact pixel output, and identical host code are not required.
The title, status, controls, channel ordering, visible-range formula, waveform
semantics, and acquisition behavior are compatibility requirements.

Dynamic and static profiles MAY use different physical storage, executor,
observable-registration, dependency-wiring, clock, scheduling, and rendering
implementations. They MUST expose the same portable `@State` source shape,
configured capacities, outcomes, ordering, model identity behavior, Domain
values, and user-visible behavior.

No ABI stability, persistence format, capture export format, or migration of
saved data is promised by this Specification.

## Testing Requirements

### Domain and use-case tests

Tests MUST verify:

- standard channel identifiers, names, order, and initial levels;
- action use cases delegate exactly once;
- observation use cases attach and detach the correct sink;
- capture publication revisions and `.snapshot`, `insertAndTrim`, and `reset`
  values reproduce the repository's complete current capture;
- visible `Duration` values and transition invariants;
- Domain imports no prohibited module.

### Repository tests

Tests MUST verify:

- registration immediately delivers current capture and state;
- replacement and detachment of each single sink;
- synchronous, non-reentrant callback ordering and propagation of each bounded
  sink outcome;
- stable ordering for equal and out-of-order timestamps;
- capture duration and retained lower-bound calculation;
- 30-second time trimming;
- 2,404-entry minimum capacity and oldest-first overflow;
- per-channel baseline correctness after trimming and overflow;
- invalid-channel and negative-timestamp failure behavior;
- out-of-horizon event dropping and diagnosis;
- start, repeated start, stop, repeated stop, and restart;
- startup failure publication and propagation;
- clear while idle, running, stopped, and failed;
- clear rebases future timestamps and preserves current levels;
- stopped or replaced source generations cannot publish stale events.

### Mock-source tests

Tests MUST verify:

- four initial low baselines at time zero;
- each channel's documented deterministic timing pattern;
- repeatability for a fixed seed and time scale;
- monotonically nondecreasing timestamps;
- idempotent repeated start;
- stop prevents later delivery;
- restart preserves conceptual elapsed time and channel levels;
- teardown prevents later delivery;
- accelerated tests do not change conceptual timestamps.

### Presentation tests

Tests MUST verify:

- initial view state;
- the ViewModel implements neither repository sink;
- host-owned adapter observation start and stop are idempotent and immediate
  current values become admitted facts rather than direct mutation;
- snapshot, capture-mutation, acquisition-state, and operational-failure facts
  apply only inside the GiftUI mutation phase;
- capture mutation validates its base revision and exactly reproduces the
  repository publication;
- capture-revision mismatch preserves current ViewModel capture;
- each intent reaches its use case;
- a Button-triggered synchronous repository callback is admitted for a later
  cycle and cannot reenter the active ViewModel mutation;
- thrown and published failures appear as error text;
- visible-window selection and exact range calculation;
- the status and disabled-state table for every acquisition state;
- the four explicit channel rows and three explicit window controls;
- lower-bound baseline reconstruction and transition-to-path mapping;
- time-ruler lower, midpoint, and upper labels;
- grid line count and trace continuity to both canvas edges.

### Observable-state and admission tests

The same semantic fixtures MUST run against dynamic and static profiles and
verify:

- one root state location preserves one model identity across transient view
  reconstruction and ignores repeated initializers while live;
- successful atomic replacement changes the model and registration once;
- validation, state-location, registration, and staging failures preserve the
  old model and remove partial candidate state;
- failed derivation after replacement keeps the replacement dirty without
  replay or rollback;
- published removal detaches the registration, failed derivation preserves the
  old live set, and reinsertion creates fresh state;
- duplicate ownership and incompatible association fail deterministically;
- stale reports after detach and slot reuse cannot dirty a later occupant;
- report generation is synchronous, no-op omission is safe, 20 reports
  coalesce to one dirty transition and wake, and reports never trigger
  reentrant evaluation;
- snapshot capacity one, compact capacity 32, and reserved capacity one reject
  the next value with the exact bounded outcome and never fall back to direct
  mutation;
- sequence and registration generations never wrap or alias;
- facts from separate physical storage seal and apply in one sequence order,
  each accepted fact applies at most once, and post-seal facts wait;
- same-thread and distinct-executor hosts produce equivalent facts, outcomes,
  semantic revisions, and user-visible state; and
- freeze-phase reports, derivation failure, and publication clearing follow
  the specified dirty-state and containment behavior;
- every `SignalSinkDeliveryRejection` and
  `SignalAnalyzerRuntimeCondition` maps to the exact SPEC-003 outcome,
  condition identity, origin, affected scope, and containment row, while an
  unknown value maps conservatively without invoking policy;
- mandatory detecting and coordinator effects complete before any residual
  policy call, and conditions with no residual choice never invoke policy;
- every residual row constructs a valid
  `GiftUIResidualPolicyInput<SignalAnalyzerResidualPolicyContext>` with
  ordinal zero, limit one, and the exact allowed set, and the concrete target
  policy returns the specified allowed selection; and
- unexpected policy-input failure and an out-of-set policy result use
  SPEC-003's host-composition invariant mapping and prevent later normal
  cycles.

The diagnostic fixture matrix MUST also run with SPEC-003 projection omitted,
enabled, filtered, saturated, dropped, and failing. Every run MUST produce
value-equal normalized outcomes, mandatory effects, residual inputs, policy
results, `SignalAnalyzerDiagnostic` values, semantic revisions, and visible
error state.

### Cross-profile and platform tests

Tests MUST verify:

- one portable hierarchy builds for dynamic and static profiles;
- equivalent deterministic-source state traces on macOS dynamic, macOS static,
  Raspberry Pi/Linux dynamic, and nRF52840 static;
- 80 events per second for 30 seconds with four-frame-per-second presentation;
- all corresponding facts are admitted and applied without capacity rejection,
  while change reports and wake intent coalesce;
- required memory and binary evidence;
- framebuffer display and input on Raspberry Pi/PiScreen;
- TFT display and input on nRF52840;
- no platform or hardware dependency enters Domain or portable Presentation.

Rendering snapshots MAY supplement semantic assertions but MUST NOT replace
behavioral, resource, profile, or connected-hardware evidence.

## Acceptance Criteria

- [x] **SA-AC-001:** The feature manifest links the Signal Analyzer and
  observable-reference-state feature chain, accepted ADR-001, ADR-003,
  ADR-004, ADR-011, ADR-014 through ADR-016, ADR-024 through ADR-027,
  historical ADR-002, and this Specification.
- [x] **SA-AC-002:** The analyzer builds with logical Domain, Data,
  Presentation, and target-host responsibilities preserving ADR-001 dependency
  direction.
- [x] **SA-AC-003:** Domain imports no UI framework, GiftUI backend, platform,
  clock, scheduler, GPIO, display, or hardware API.
- [ ] **SA-AC-004:** Presentation imports no concrete Data, platform, clock,
  scheduler, GPIO, renderer, display, or hardware API.
- [ ] **SA-AC-005:** The screen visibly contains the required title, subtitle,
  status, time ruler, four ordered channel rows, controls, error region, grid,
  and four traces.
- [ ] **SA-AC-006:** The portable hierarchy uses fixed explicit channel and
  window composition and is substantially shared by all four configurations.
- [ ] **SA-AC-007:** Sink registration synchronously delivers revisioned
  current values through the adapter, replacement detaches the old sink, stop
  prevents later callbacks, and every callback returns its bounded outcome.
- [ ] **SA-AC-008:** The complete acquisition graph uses serialized synchronous
  application delivery through the admission adapter, logically distinct
  GiftUI mutation, and no async stream, task, queue, lock, actor, or scheduler
  requirement in portable Domain or Presentation.
- [x] **SA-AC-009:** Start, repeated Start, Stop, repeated Stop, restart, and
  startup failure match the specified state table without duplicate producers.
- [ ] **SA-AC-010:** Clear resets the capture epoch and retained history,
  preserves current channel levels and acquisition state, rebases later
  timestamps, and publishes one cleared capture.
- [ ] **SA-AC-011:** Four 10 Hz channels produce at most 80 accepted transition
  events per second and run for 30 seconds without loss or duplication.
- [ ] **SA-AC-012:** Static storage provides at least 2,404 transition entries
  and four baselines.
- [x] **SA-AC-013:** Time trimming and capacity overflow evict oldest entries
  while preserving correct levels at the retained lower bound.
- [x] **SA-AC-014:** Equal and out-of-order retained timestamps have stable,
  deterministic ordering; invalid and out-of-horizon events follow specified
  fail/drop behavior.
- [x] **SA-AC-015:** The deterministic mock produces the specified four channel
  patterns and no stale event after stop, restart, or teardown.
- [ ] **SA-AC-016:** Initial Presentation state is idle, empty, two seconds,
  and error-free; applied facts mutate it only in the GiftUI domain and produce
  synchronous model-owned change reports.
- [x] **SA-AC-017:** Start, Stop, Clear, and window controls match all specified
  enabled and disabled states.
- [x] **SA-AC-018:** Visible ranges for 1, 2, and 5 seconds follow the exact
  formula and always span the selected duration.
- [ ] **SA-AC-019:** Every channel waveform starts from the correct baseline,
  applies visible transitions, maps time to x coordinates, and extends to the
  right edge.
- [x] **SA-AC-020:** The ruler shows lower, midpoint, and upper seconds with two
  fractional digits, and the grid contains 11 vertical and one center line.
- [ ] **SA-AC-021:** At 80 events per second, frames use consistent latest
  state at a 250-millisecond target interval without requiring one frame per
  event.
- [ ] **SA-AC-022:** macOS dynamic and static configurations build and execute
  the deterministic conformance scenario.
- [ ] **SA-AC-023:** Raspberry Pi/Linux dynamically executes the analyzer with
  framebuffer output and connected PiScreen display/input evidence.
- [ ] **SA-AC-024:** nRF52840 statically executes the analyzer with connected
  TFT display/input evidence.
- [ ] **SA-AC-025:** nRF52840 evidence records binary, RAM, transition storage,
  drawing workspace, and stack measurements where supported and demonstrates
  that the application fits and runs.
- [ ] **SA-AC-026:** Replacing the mock source with another conforming source
  requires no change to Domain, use cases, admission adapter, ViewModel, or
  portable hierarchy.
- [ ] **SA-AC-027:** Missing required GiftUI behavior fails configuration
  conformance explicitly rather than producing a reduced target-specific UI.
- [ ] **SA-AC-028:** The host, not View construction or the ViewModel, starts
  and stops repository observation and installs the adapter as both sinks.
- [ ] **SA-AC-029:** One capture snapshot slot, 32 compact fact slots, and one
  reserved failure slot admit all required workload facts without rejection;
  the next value at each exact capacity returns the specified rejection.
- [ ] **SA-AC-030:** All accepted facts receive nonzero monotonic `UInt32`
  sequence numbers, seal across physical storage in sequence order, apply at
  most once, and are neither dropped nor replaced by invalidation coalescing.
- [ ] **SA-AC-031:** Capture publications carry exact revisions and bounded
  change descriptions; applying every change reproduces the complete
  repository capture, while a revision mismatch leaves ViewModel capture
  unchanged and fails closed.
- [ ] **SA-AC-032:** The same portable `@State` declaration preserves one
  ViewModel identity and registration across transient reconstruction in
  dynamic and static profiles.
- [ ] **SA-AC-033:** Atomic replacement, failed replacement, failed derivation,
  published removal, and reinsertion match the observable-location lifecycle
  table in both profiles.
- [ ] **SA-AC-034:** State-location, registration, and staging exhaustion,
  duplicate ownership, incompatible association, stale reports, generation
  exhaustion, and phase violations return deterministic bounded outcomes
  without fallback or aliasing.
- [ ] **SA-AC-035:** Twenty applied capture updates coalesce to one owner-dirty
  transition and at most one wake requirement while preserving every accepted
  fact and producing no intermediate semantic publication.
- [ ] **SA-AC-036:** A Button-triggered synchronous repository callback becomes
  a later fact and cannot reenter the active ViewModel mutation; same-thread
  and distinct-executor fixtures produce equivalent results.
- [ ] **SA-AC-037:** Embedded evidence shows one address-stable typed model
  location, the configured bounded records and fact storage, no forbidden
  heap/reflection/task/runtime dependencies, and measured assembled RAM,
  flash, stack, admission, mutation, publication, and frame costs.
- [ ] **SA-AC-038:** Exhaustive fixtures normalize every analyzer capacity,
  availability, sequence, identity, revision, and phase condition into the
  exact SPEC-003 outcome fields before composition policy; apply all mandatory
  coordinator effects first; construct only valid
  `GiftUIResidualPolicyInput<SignalAnalyzerResidualPolicyContext>` values for
  remaining choices; and prove optional diagnostic projection cannot change
  `SignalAnalyzerDiagnostic`, semantic state, policy inputs, or dispositions.

## Implementation Notes

This section is non-authoritative.

### Current implementation evidence

Implementation began with the import of the macOS investigation into
[`demo/SignalAnalyzer`](../../demo/SignalAnalyzer/) at commit `4e1b598`. The
import preserves the investigation's SwiftPM target structure, macOS target,
dependencies, sources, and tests as the baseline for later GiftUI integration.

The imported package built on macOS with eight passing baseline tests. Current
repository and mock-source regression coverage expands that suite to 17 tests,
including startup cleanup, stable ordering, invalid and out-of-horizon event
handling, time and capacity baseline preservation, stale-event rejection,
exact deterministic timing patterns, and teardown lifetime.

The current suite passes with:

```sh
swift test --package-path demo/SignalAnalyzer
```

Checked acceptance criteria above are supported by direct source inspection
and this macOS build/test result. They do not constitute cross-profile,
resource, performance, or connected-hardware conformance evidence. Unchecked
criteria remain required.

The existing SignalAnalyzer playground provides useful starting code and
tests. Migration work can retain its names and object graph while replacing
SwiftUI views with GiftUI and replacing `@MainActor`, Observation,
`ContinuousClock`, and task-based timing where a profile does not provide
them.

The current playground ViewModel directly implements both repository sinks,
starts observation from view construction, and mutates `@Observable` state on
the main actor. Those behaviors conform to superseded ADR-002, not this
revision. They provide historical evidence only and must be replaced by
host-owned observation, the target-composed admission adapter, bounded fact
storage, and GiftUI-phase model mutation before Presentation criteria may be
checked again.

The current dynamic repository retains per-channel lower-bound baselines and
rebases future source timestamps after Clear, and the macOS regression suite
exercises those behaviors. It still publishes unrevisioned complete snapshots
through direct sinks rather than the revisioned snapshot/mutation and bounded
admission contract required by this revision.

A ring buffer plus a four-element baseline array is a natural static storage
strategy. Dynamic profiles may keep array-backed values if measurements remain
viable. The 250-millisecond frame cadence is a useful boundary for coalescing
view invalidations without batching or dropping capture events.

## Open Issues

No unresolved Signal Analyzer architecture choice remains, but the following
Specification-approval blockers are open:

- The approved reusable contracts required by the MVP Specification Portfolio
  do not yet exist for execution/fact admission, observable reference state,
  interaction, drawing, runtime profiles, backend integration, and host
  configuration. The Canvas feature now has approved RFC-009 and accepted
  ADR-028 through ADR-031, but no approved drawing Specification. This
  Specification MUST be reconciled against the eventual approved drawing
  contract before it can be approved.
- The target-composed application-executor entry contract named by the
  ViewModel requirements has no exact operation, outcome, availability,
  ordering, or Button-callback contract here. That contract MUST either be
  defined by an approved prerequisite Specification and referenced here or be
  completed as an analyzer-owned contract without introducing architecture.
- Capture-revision exhaustion requires acquisition to stop and a fresh object
  graph, but it has no producer condition, normalization row, coordinator
  effects, residual-policy context, or acceptance fixture in the otherwise
  total failure contract.
- An `operationalFailure` fact containing `.success` or `.operational` MUST be
  rejected before admission, but the contract does not make those values
  unrepresentable or define the bounded rejection and normalization outcome.
- Cross-profile deterministic mock traces require an exact CH4 pseudo-random
  sequence contract, seed transformation, or normative golden vectors; the
  inclusive interval range alone is insufficient to guarantee equivalent
  traces.
- `SignalAnalyzerDiagnostic` lacks the construction, truncation-result,
  bounded byte-access, and text-projection operations needed to implement and
  test the stated 96-byte dynamic/static contract without guessing.
- The compact-ring capacity rationale assumes seven additional action-induced
  publications without defining that bound or a maximum admission service
  delay. The final capacity MUST be derived from approved execution and host
  pacing contracts and tested at every allowed boundary burst.

These are current-scope blockers, not deferred work. This Specification
defines the analyzer-specific source shape, configuration, adapter, facts,
capacities, and conformance obligations without defining reusable GiftUI APIs.

## Deferred and Follow-up Work

No deferred item originates from this Specification. For context, RFC-008
already keeps public binding/projection in
[FW-017](../future-work/fw-017-public-binding-abstraction.md) and fine-grained
property dependency tracking in
[FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md).
Neither is needed for correctness or approval of the fixed Signal Analyzer
contract, and this Specification does not create an additional relationship.

## References

- [ADR-001: Signal Analyzer Application Boundaries](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [ADR-002: Serialized Synchronous Acquisition Delivery](../adrs/adr-002-serialized-synchronous-acquisition-delivery.md)
- [ADR-003: Transition-Based Bounded Capture](../adrs/adr-003-transition-based-bounded-capture.md)
- [ADR-004: Portable Fixed Signal Analyzer Presentation](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-014: Bounded Cross-Layer Outcome Meaning](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015: Layered Failure Disposition Ownership](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016: Non-Authoritative Diagnostic Projection](../adrs/adr-016-non-authoritative-diagnostics.md)
- [ADR-024: Structurally Owned Observable Reference State](../adrs/adr-024-structurally-owned-observable-reference-state.md)
- [ADR-025: Coarse Model-Owned Observable Invalidation](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026: Profile-Equivalent Bounded Observable State Realization](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [ADR-027: Bounded Presentation-Fact Admission](../adrs/adr-027-bounded-presentation-fact-admission.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- External legacy source: `GIFTUI_SIGNAL_ANALYZER_SPEC.md` in the
  SignalAnalyzer playground repository.
- External legacy source: `GIFTUI_VIEW_FEATURE_PRIORITIES.md` in the
  SignalAnalyzer playground repository.
- External implementation evidence: the SignalAnalyzer playground source and
  tests.
- [SPIKE-003: Portable Observable Reference State Feasibility](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
