---
id: SPEC-001
feature: signal-analyzer
title: Signal Analyzer Reference Application Contract
status: implementing
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-14
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-001
related_adrs:
  - ADR-001
  - ADR-002
  - ADR-003
  - ADR-004
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-001: Signal Analyzer Reference Application Contract

## Summary

This Specification defines the portable application contract for GiftUI's
four-channel low-frequency digital Signal Analyzer. It covers the analyzer's
domain values, acquisition and observation behavior, bounded transition
capture, presentation state, fixed view hierarchy, waveform semantics,
target-host obligations, resource bounds, and conformance evidence across the
four MVP configurations.

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
- Require a rendered frame for every acquired transition.
- Set aggressive RAM, stack, binary-size, or rendering optimization targets
  beyond the explicit capacity and viable-execution requirements below.

## Dependencies

### Lifecycle dependencies

- [PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md)
  defines the accepted application problem.
- [RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
  defines the approved design.
- ADR-001 through ADR-004 are the accepted governing decisions.

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
- monotonic time and timer-scheduling capabilities;
- a GiftUI runtime appropriate to the selected dynamic or static profile;
- a renderer, display surface, and input integration;
- a concrete signal data source;
- the composition wiring needed to construct one analyzer object graph.

The portable Domain and Presentation use `Swift.Duration` values. They MUST
NOT read a platform clock or schedule timers directly.

## Related ADRs

- [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
  governs Domain, Data, Presentation, and target-host ownership plus inward
  dependency direction.
- [ADR-002](../adrs/adr-002-serialized-synchronous-acquisition-delivery.md)
  governs synchronous sink delivery, one observer per value, immediate current
  value delivery, and the serialized executor.
- [ADR-003](../adrs/adr-003-transition-based-bounded-capture.md)
  governs transition storage, the 80-event-per-second bound, minimum capacity,
  oldest-first eviction, and per-channel baseline preservation.
- [ADR-004](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
  governs the shared fixed hierarchy, Presentation-owned visible range,
  250-millisecond refresh interval, target-specific host boundary, and assumed
  GiftUI MVP client surface.

## Terminology

- **Application executor:** The single serialized execution context on which
  source delivery, repository mutation, sink callbacks, use cases, and
  Presentation state mutation run to completion.
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
  analyzer frame computations; state delivery may occur more frequently.

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
  next produced frame MUST reflect the latest completely delivered state.
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
- visible-range calculation;
- the fixed GiftUI hierarchy;
- time ruler, channel labels, control state, grid, and waveform construction.

Presentation MAY depend on Domain and the provided GiftUI client surface. It
MUST NOT depend on concrete Data types, platform hosts, clocks, schedulers,
GPIO, renderers, or display hardware.

### Target host

The host MUST be the only composition root. It MUST construct exactly one
concrete source, repository, use-case set, ViewModel, and root view for an
analyzer instance. It MUST supply runtime, backend, display, input, executor,
clock, scheduler, and target-specific hardware integration.

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

struct SignalTransition: Equatable, Sendable {
    let channelID: SignalChannelID
    let timestamp: Duration
    let level: DigitalLevel
}

enum AcquisitionState: Equatable, Sendable {
    case idle
    case running
    case stopped
    case failed(String)
}
```

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

### Sink and repository contract

```swift
protocol SignalCaptureSink {
    func receive(_ capture: SignalCapture)
}

protocol AcquisitionStateSink {
    func receive(_ state: AcquisitionState)
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
and immediately receives the current value before registration returns.
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
    var errorMessage: String?
}
```

The duration mapping MUST be exactly 1, 2, and 5 seconds. Initial view state
MUST be idle, empty capture, two-second window, and no error.

`SignalAnalyzerViewModel` MUST:

- own exactly one `SignalAnalyzerViewState` value;
- implement or adapt both sink contracts;
- receive the five use cases at initialization;
- expose idempotent `startObserving()` and `stopObserving()` operations;
- expose `startTapped`, `stopTapped`, `clearTapped`, and
  `visibleDurationChanged` intents;
- expose the derived visible range;
- participate in GiftUI's provided observable invalidation contract without
  requiring the portable code to own a task or clock.

## Behavior

### Serialized delivery

Every source delivery, repository mutation, sink callback, use-case call, and
ViewModel state mutation MUST run to completion on the application executor.
A producer MUST NOT invoke a second sink callback before the current callback
returns. No portable Domain or Presentation contract may require an async
stream, task, queue, lock, or cross-actor handoff.

The repository MUST publish a capture synchronously after every accepted
transition and after every clear. It MUST publish acquisition state whenever a
state transition occurs. GiftUI MAY coalesce the resulting view invalidations.

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
8. Publish one complete current capture.

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
- Publish the cleared capture synchronously before returning.

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

- `startObserving` installs both sinks at most once. Because registration
  immediately delivers current values, state is current when it returns.
- `stopObserving` detaches both sinks at most once.
- Receiving a capture replaces `state.capture` synchronously.
- Receiving an acquisition state replaces `state.acquisitionState`
  synchronously.
- Receiving `.failed(message)` also sets `state.errorMessage` to `message`.
- `startTapped` clears an old error, invokes Start, and maps a thrown failure to
  error text.
- `stopTapped` invokes Stop.
- `clearTapped` invokes Clear.
- `visibleDurationChanged` replaces the selected window.
- Repeated observation or action calls preserve the repository idempotency
  rules.

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
ViewModel state delivery MAY occur up to 80 times per second. GiftUI MAY
coalesce up to 20 worst-case transition invalidations into a frame. A rendered
frame MUST use one internally consistent view-state snapshot and MUST include
every state mutation completed before that frame begins.

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

Diagnostics MAY use platform-appropriate reporting. User-visible error text
MUST not expose unstable implementation type names or memory addresses.

## Performance Requirements

- The acquisition graph MUST sustain 80 transition events per second for at
  least 30 continuous seconds without loss, reordering, duplicate delivery, or
  stale-generation events.
- The display MUST render a consistent latest state at a target cadence of four
  frames per second under the same workload.
- The implementation MUST NOT require one rendered frame per transition.
- State completed before a frame begins MUST appear no later than the next
  scheduled analyzer frame, absent a documented platform failure.
- Static capture storage MUST hold at least 2,404 transition entries plus four
  baselines.
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

## Compatibility

The governed implementation MUST preserve the observable application behavior
of the macOS investigation except where accepted ADRs replace desktop-specific
mechanisms or add bounded-baseline behavior.

The portable Presentation migrates from SwiftUI to GiftUI. Exact SwiftUI source
compatibility, exact pixel output, and identical host code are not required.
The title, status, controls, channel ordering, visible-range formula, waveform
semantics, and acquisition behavior are compatibility requirements.

Dynamic and static profiles MAY use different storage, executor, observation,
dependency-wiring, clock, scheduling, and rendering implementations. They MUST
produce equivalent Domain values and user-visible behavior.

No ABI stability, persistence format, capture export format, or migration of
saved data is promised by this Specification.

## Testing Requirements

### Domain and use-case tests

Tests MUST verify:

- standard channel identifiers, names, order, and initial levels;
- action use cases delegate exactly once;
- observation use cases attach and detach the correct sink;
- visible `Duration` values and transition invariants;
- Domain imports no prohibited module.

### Repository tests

Tests MUST verify:

- registration immediately delivers current capture and state;
- replacement and detachment of each single sink;
- synchronous, non-reentrant delivery ordering;
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
- idempotent observation start and stop;
- capture and acquisition-state delivery replace view state synchronously;
- each intent reaches its use case;
- thrown and published failures appear as error text;
- visible-window selection and exact range calculation;
- the status and disabled-state table for every acquisition state;
- the four explicit channel rows and three explicit window controls;
- lower-bound baseline reconstruction and transition-to-path mapping;
- time-ruler lower, midpoint, and upper labels;
- grid line count and trace continuity to both canvas edges.

### Cross-profile and platform tests

Tests MUST verify:

- one portable hierarchy builds for dynamic and static profiles;
- equivalent deterministic-source state traces on macOS dynamic, macOS static,
  Raspberry Pi/Linux dynamic, and nRF52840 static;
- 80 events per second for 30 seconds with four-frame-per-second presentation;
- required memory and binary evidence;
- framebuffer display and input on Raspberry Pi/PiScreen;
- TFT display and input on nRF52840;
- no platform or hardware dependency enters Domain or portable Presentation.

Rendering snapshots MAY supplement semantic assertions but MUST NOT replace
behavioral, resource, profile, or connected-hardware evidence.

## Acceptance Criteria

- [x] **SA-AC-001:** The feature manifest links accepted ADR-001 through
  ADR-004 and this Specification.
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
- [x] **SA-AC-007:** Sink registration synchronously delivers current values,
  replacement detaches the old sink, and stop prevents later callbacks.
- [ ] **SA-AC-008:** The complete acquisition graph uses serialized synchronous
  delivery without requiring async streams, tasks, queues, locks, or actors in
  portable Domain or Presentation.
- [ ] **SA-AC-009:** Start, repeated Start, Stop, repeated Stop, restart, and
  startup failure match the specified state table without duplicate producers.
- [ ] **SA-AC-010:** Clear resets the capture epoch and retained history,
  preserves current channel levels and acquisition state, rebases later
  timestamps, and publishes one cleared capture.
- [ ] **SA-AC-011:** Four 10 Hz channels produce at most 80 accepted transition
  events per second and run for 30 seconds without loss or duplication.
- [ ] **SA-AC-012:** Static storage provides at least 2,404 transition entries
  and four baselines.
- [ ] **SA-AC-013:** Time trimming and capacity overflow evict oldest entries
  while preserving correct levels at the retained lower bound.
- [ ] **SA-AC-014:** Equal and out-of-order retained timestamps have stable,
  deterministic ordering; invalid and out-of-horizon events follow specified
  fail/drop behavior.
- [ ] **SA-AC-015:** The deterministic mock produces the specified four channel
  patterns and no stale event after stop, restart, or teardown.
- [x] **SA-AC-016:** Initial Presentation state is idle, empty, two seconds,
  and error-free; delivered captures and states invalidate the view.
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
- [x] **SA-AC-026:** Replacing the mock source with another conforming source
  requires no change to Domain, use cases, ViewModel, or portable hierarchy.
- [ ] **SA-AC-027:** Missing required GiftUI behavior fails configuration
  conformance explicitly rather than producing a reduced target-specific UI.

## Implementation Notes

This section is non-authoritative.

### Current implementation evidence

Implementation began with the import of the macOS investigation into
[`demo/SignalAnalyzer`](../../demo/SignalAnalyzer/) at commit `4e1b598`. The
import preserves the investigation's SwiftPM target structure, macOS target,
dependencies, sources, and tests as the baseline for later GiftUI integration.

The imported package builds on macOS and its eight tests pass with:

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

The current playground repository does not retain per-channel lower-bound
baselines and does not rebase future source timestamps after Clear. Those are
known conformance gaps relative to ADR-003 and this Specification, not reasons
to weaken the governed contract.

A ring buffer plus a four-element baseline array is a natural static storage
strategy. Dynamic profiles may keep array-backed values if measurements remain
viable. The 250-millisecond frame cadence is a useful boundary for coalescing
view invalidations without batching or dropping capture events.

## Open Issues

None for Specification review. Availability and conformance of the required
GiftUI MVP client features are external delivery dependencies, not unresolved
Signal Analyzer architecture or contract questions.

## References

- [ADR-001: Signal Analyzer Application Boundaries](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [ADR-002: Serialized Synchronous Acquisition Delivery](../adrs/adr-002-serialized-synchronous-acquisition-delivery.md)
- [ADR-003: Transition-Based Bounded Capture](../adrs/adr-003-transition-based-bounded-capture.md)
- [ADR-004: Portable Fixed Signal Analyzer Presentation](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
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
