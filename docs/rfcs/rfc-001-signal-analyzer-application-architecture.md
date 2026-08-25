---
id: RFC-001
feature: signal-analyzer
title: Signal Analyzer Application Architecture
status: approved
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-25
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-008
  - RFC-009
related_adrs:
  - ADR-001
  - ADR-002
  - ADR-003
  - ADR-004
  - ADR-027
  - ADR-028
  - ADR-029
  - ADR-030
  - ADR-031
related_specs:
  - SPEC-001
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-001: Signal Analyzer Application Architecture

## Post-Approval Authority Update

RFC-001 preserves the architectural reasoning that produced ADR-001 through
ADR-004. ADR-027, extracted from RFC-008 and accepted on 2026-08-22,
supersedes ADR-002's single-domain Presentation-mutation decision. Statements
in this RFC that place repository sink delivery and observable ViewModel
mutation together on one serialized application executor are therefore
historical rather than current architecture.

The current accepted boundary preserves synchronous source, repository,
use-case, and sink work on the application executor, but terminates that work
at a target-composed Presentation admission adapter:

```text
Signal Analyzer application executor
    source -> repository -> capture/state sink (Presentation admission adapter)
                                      |
                                      | bounded immutable fact
                                      v
RFC-004 admission -> GiftUI serialized mutation domain
                         -> ViewModel mutation
                         -> synchronous change report
                         -> owner dirtiness
                         -> frozen derivation and publication
```

Returning from the synchronous application callback means that the adapter
returned an admission outcome, not that the ViewModel already changed. The
application executor and GiftUI mutation domain remain logically distinct
even when one host thread or cooperative event loop realizes both.

This update qualifies the following historical parts of the approved RFC
without rewriting their original reasoning:

- the Summary and Requirements statements that describe direct propagation
  into Presentation state on one executor;
- the Data and Control Flow diagram and its single-executor prose;
- the Observation and Actions and Presentation State descriptions of direct,
  synchronous sink-to-ViewModel mutation;
- the singular executor wording in Module Responsibilities, Static / Embedded
  Impact, Performance, Compatibility, and Risks; and
- the synchronous-ordering and Presentation-test expectations in Testing
  Strategy.

Current testing must additionally cover bounded fact conversion and
admission, ordering, saturation and rejection, later ordered application,
same-thread preservation of the logical domain boundary, and reentrant
Button-triggered callbacks. Current performance and risk analysis must include
admission capacity, explicit refusal, and up to one admission-cycle of
Presentation latency. Exact fact types, capacities, outcomes, adapter
ownership, and executor-entry contracts belong in the reviewed revision of
SPEC-001.

## Summary

This RFC proposes the application architecture for the Signal Analyzer that
serves as GiftUI's MVP reference application. It separates portable analyzer
behavior from target-specific composition, signal acquisition, and hosting;
represents digital input as time-stamped transitions in a bounded capture;
and propagates acquisition values through a serialized, synchronous callback
graph into observable presentation state.

The design is intentionally application-specific. It identifies the GiftUI
client surface exercised by the analyzer, but it does not define GiftUI's
framework architecture or approve individual GiftUI APIs. Those contracts
remain governed by the MVP architecture and feature lifecycles.

This is a retroactive RFC. The macOS investigation application and its legacy
specification provide implementation evidence, not authority. The RFC makes
the evidenced choices and unresolved portability work reviewable before they
are extracted into ADRs or converted into a governed Specification.

## Context

[PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md)
accepts the Signal Analyzer as the coherent application-level workload used to
validate GiftUI. [The MVP scope](../MVP_SCOPE.md) requires a substantially
shared presentation on macOS dynamic and static configurations, Raspberry
Pi/Linux with framebuffer output, and nRF52840 with a TFT display.

The completed investigation produced a working SwiftUI macOS application with
four SwiftPM targets: application host, presentation, domain, and data. It also
produced a detailed legacy application specification and a ranked inventory of
the GiftUI view features needed to port the presentation. That evidence shows
that the application behavior is coherent and that a small client-facing UI
surface is sufficient on macOS. It does not yet prove that the application
contracts, concurrency facilities, storage strategy, or observation mechanism
compile and execute in every MVP configuration.

The current GiftUI repository already separates client-facing view concepts,
dynamic and static runtimes, rendering backends, display integration, and
platform hosts. Those modules are implementation evidence only until the MVP
architecture lifecycle establishes their authoritative boundaries. This RFC
therefore constrains the analyzer side of the integration and treats GiftUI
framework contracts as dependencies.

## Requirements

- The analyzer MUST remain one coherent four-channel digital-signal
  application with start, stop, restart, clear, status, error, and visible-time
  window behavior.
- The portable presentation MUST remain substantially shared across all four
  MVP configurations.
- The presentation MUST consume application state and intents without knowing
  whether transitions originate from a mock source, Raspberry Pi GPIO, an MCU
  peripheral, or another target-specific source.
- Domain behavior MUST remain independent of GiftUI, SwiftUI, rendering
  backends, display hardware, GPIO APIs, and platform application frameworks.
- Platform-specific hosting, display/input bootstrap, clocks, and concrete
  signal-source construction MUST remain outside the portable presentation.
- Signal acquisition MUST preserve monotonic transition time, deterministic
  ordering, current acquisition state, and a bounded capture history.
- State changes MUST reach the presentation in deterministic order on one
  serialized application executor.
- The design MUST support both dynamic and static composition without requiring
  fundamentally different portable view code.
- Execution and connected-hardware claims MUST be supported by evidence from
  the claimed configuration.
- The analyzer MUST NOT expand GiftUI's public surface beyond features justified
  by the MVP scope merely for application convenience.

## Constraints

- The reference behavior has exactly four channels named `CH1` through `CH4`.
- Each input channel supports signal frequencies through 10 Hz. For a digital
  square wave, the storage design MUST allow two transitions per cycle, or up
  to 80 transition events per second across all four channels.
- Visible windows are 1, 2, and 5 seconds; 2 seconds is the initial selection.
- The default retained history is 30 seconds.
- The display refresh interval is 250 milliseconds. Acquisition MAY publish
  state more frequently, but the UI need not render more than four frames per
  second and MAY coalesce intervening invalidations.
- Signal values are digital levels represented by transitions, not periodic
  analog or digital sample buffers.
- The portable view hierarchy uses fixed child composition and does not require
  dynamic collections.
- The complete analyzer needs only straight-line custom drawing for its time
  grid and four traces.
- The macOS investigation uses Swift 6.0, macOS 14, SwiftUI, Observation,
  `@MainActor`, `Task.sleep`, `ContinuousClock`, and dynamically allocated
  arrays. The static embedded realization MUST NOT depend on Observation,
  `MainActor`, `Task`, or desktop clock and timer facilities.
- `Swift.Duration` is the portable value representation for elapsed time and
  intervals. Obtaining monotonic time and scheduling future work are backend
  capabilities rather than responsibilities of `Duration` or Presentation.
- The MVP requires bounded memory and evidence that the analyzer fits on the
  nRF52840, but it does not set aggressive RAM, stack, or binary-size
  optimization targets.

## Proposed Design

### Responsibility and dependency structure

The analyzer is divided into four logical responsibilities:

```text
Target host / composition root ───────► Presentation ───────► Domain
              │                                               ▲
              └──────────────────────► Data / source adapter ──┘
```

The Domain responsibility owns signal and acquisition concepts plus the use
case-facing acquisition contract. Presentation owns observable screen state,
intent handling, visible-range derivation, and the portable view hierarchy.
Data owns concrete signal production and accumulation into the domain capture.
The target host selects concrete implementations and connects GiftUI runtime,
backend, display, input, clock, and hardware facilities.

Dependencies point inward. Domain imports no Presentation, Data, UI framework,
renderer, platform, or hardware module. Presentation depends on Domain but not
on concrete Data types. Data depends on Domain but not on Presentation. Only
the target host may construct the complete object graph.

These are logical boundaries. Whether each responsibility is a separate SwiftPM
target in every static configuration remains an implementation choice provided
the dependency direction and ownership are preserved.

### Data and control flow

Concrete sources emit individual `SignalTransition` values. A repository
receives them, restores chronological order if required, updates the greatest
observed acquisition duration, removes history older than the configured
retention window, and publishes a current `SignalCapture`. The same repository
owns acquisition lifecycle state and publishes it separately.

```text
signal source
    │ transition
    ▼
repository and bounded capture
    │ capture + acquisition state
    ▼
use cases
    │ synchronous sink calls
    ▼
observable presentation state
    │ invalidation
    ▼
portable view description
```

Calls across source, repository, use-case, and presentation boundaries are
synchronous and run to completion on one serialized application executor.
Suspending work may be used internally by a target-specific source to wait for
time or hardware, but suspension does not enter the domain or presentation
contracts. A source must re-enter the application executor before delivery.

The macOS realization uses the main actor as that executor. The static and
embedded realization must preserve the ordering and non-concurrency semantics;
it uses a target-specific single-threaded mechanism and does not require
`MainActor` or `Task`.

The source obtains monotonic timestamps and schedules mock or hardware polling
through capabilities supplied by the target backend. Domain and Presentation
exchange `Duration` values but do not read clocks or create timers directly.

### Domain model

The architecture uses these application concepts:

- `SignalChannelID` and `SignalChannel` identify the fixed channels;
- `DigitalLevel` is either low or high;
- `SignalTransition` records channel, monotonic elapsed timestamp, and the
  resulting level;
- `SignalCapture` contains channels, ordered transitions, and greatest observed
  duration;
- `AcquisitionState` is idle, running, stopped, or failed with a diagnostic;
- `VisibleTimeWindow` selects 1, 2, or 5 seconds.

The current capture is a value snapshot. Storage ownership remains inside the
repository, so a static implementation may use fixed-capacity storage while a
dynamic implementation uses an array. Both must expose equivalent ordering,
retention, clear, and visible-range behavior.

The embedded repository provides capacity for at least 2,404 transitions:
four initial channel levels plus 30 seconds × 10 cycles per second × two
transitions per cycle × four channels. When time-window trimming or capacity
pressure removes old entries, the repository evicts the oldest transitions
first and preserves a baseline level for each channel at the retained lower
bound. This keeps the newest 30-second window renderable without inventing a
level when the transition that established it has been evicted.

### Observation and actions

The repository provides one capture observation and one acquisition-state
observation, with weak ownership where reference semantics are available.
Installing an observer immediately delivers the current value. Replacing an
observer replaces the prior observer for that value, and stopping observation
detaches it.

Start is idempotent while already running. A successful start publishes
running state; a failed start publishes failed state and returns the failure to
the caller. Stop is idempotent while inactive and publishes stopped state when
it stops an active source. Clear resets transitions and capture duration
without changing acquisition state, then publishes the empty capture.

Use cases expose repository observation and actions to Presentation so the
ViewModel does not depend on the repository or source implementation.

### Presentation state and views

The ViewModel owns acquisition state, current capture, selected visible window,
and optional error text. It converts user intents into use-case calls and
updates the state synchronously when sinks deliver values.

Visible-range calculation remains a Presentation responsibility because it is
a screen-window concern rather than acquisition-domain behavior.

For a selected window `window`, the presented range is:

```text
end = max(window, capture.duration)
start = max(0, end - window)
range = start ..< end
```

The portable hierarchy contains a header and status, a waveform panel with a
time ruler and four explicit channel rows, controls, and error text. Start is
disabled while running, Stop is disabled while not running, and the selected
window button is disabled. Waveform views receive capture values and a visible
range; they have no acquisition or source lifecycle knowledge.

The client-facing GiftUI surface is the Rank 0–2 and waveform-drawing surface
already established by `docs/MVP_SCOPE.md`. This RFC does not redefine that
surface. Missing GiftUI contracts must be supplied by their own approved
Specifications before the analyzer Specification can depend on them.

## Module Responsibilities

| Module or responsibility | Responsibility | Dependency impact |
| --- | --- | --- |
| Signal Analyzer Domain | Models, acquisition contract, and use-case semantics | Imports no UI, renderer, platform, or hardware module |
| Signal Analyzer Data | Signal-source contract, mock/hardware adapters, capture accumulation, retention | Depends on Domain only |
| Signal Analyzer Presentation | Observable view state, intents, visible range, portable GiftUI hierarchy and waveform construction | Depends on Domain and approved GiftUI client contracts, never concrete Data |
| Target host | Composition root, executor/bootstrap, runtime/backend/display/input selection, concrete source and clock | May depend on Domain, Data, Presentation, and target integration modules |
| GiftUI modules | Provide separately governed composition, layout, rendering, interaction, state, drawing, runtime, backend, and platform contracts | Must not acquire analyzer-domain knowledge |

## Public API Impact

The analyzer does not add public GiftUI API by itself. It consumes the bounded
client surface listed in the MVP scope. Any missing `View`, composition,
layout, styling, interaction, observation, or drawing API requires its own
governed GiftUI contract rather than definition in this application RFC.

Observable reference-state invalidation and Canvas/path/stroke drawing are
separate major GiftUI features. The Canvas lifecycle now has accepted
[PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md), approved
[RFC-009](rfc-009-canvas-path-stroke-drawing-architecture.md), and accepted
[ADR-028](../adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md)
through [ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md).
The Signal Analyzer Specification may rely on that accepted architecture, but
its exact public Canvas contract remains blocked on an approved drawing
Specification.

Analyzer types may initially remain package-scoped. If the reference
application is later distributed as a reusable library, its visibility and
source-compatibility policy require separate review.

## Capabilities Impact

Every MVP target configuration is required to provide the composition, layout,
text, opaque color, rectangular background, button, disabled-state,
state-invalidation, and line-drawing behavior used by the analyzer. The
portable view must not branch on renderer, display, GPIO, or platform identity.

Capability declaration, propagation, and absence behavior belong to the MVP
architecture feature. For the Signal Analyzer, absence of a required client
capability means that a configuration cannot claim analyzer conformance; it
does not justify silently dropping controls, state updates, or traces.

Signal-source availability is a host composition concern rather than a GiftUI
rendering capability. A deterministic mock source may validate UI behavior
where real acquisition hardware is not under test, but it cannot substitute
for connected-hardware evidence required by the MVP exit criteria.

Monotonic time acquisition and timer scheduling are backend capabilities. The
portable API exchanges `Duration` values; a backend supplies the clock origin,
current monotonic time, and scheduling mechanism appropriate to its runtime.

## Backend Impact

The analyzer emits only backend-independent GiftUI view and drawing concepts.
Backends must realize the required opaque colors, text, rectangular
backgrounds, input hit regions and disabled behavior, and straight-line
strokes. They must not know about signal channels, captures, or acquisition.

Platform hosts connect input and frame presentation through GiftUI's governed
backend and platform boundaries. The macOS SwiftUI investigation is behavioral
evidence and a visual reference; it is not an alternate backend contract and
does not make SwiftUI part of the portable implementation.

## Static / Embedded Impact

- Four channel rows and three time-window buttons are composed explicitly, so
  the portable hierarchy does not require runtime-sized child collections.
- The 30-second history supports four 10 Hz channels at two transitions per
  cycle. Static storage provides at least 2,404 transition entries plus four
  retained baseline levels.
- Dynamic array growth, sorting, and snapshot copying in the macOS reference
  implementation are not accepted as the embedded storage design.
- Observation macros, `MainActor`, `Task`, and desktop clock/timer APIs are not
  required implementation mechanisms on the static embedded path. The
  separately governed observation feature must provide an equivalent
  invalidation contract without relying on those facilities.
- Static implementations may substitute generated wiring, fixed-capacity
  buffers, typed state slots, and a single-threaded scheduler if observable
  application behavior and dependency direction remain equivalent.
- The portable model uses `Duration` for timestamps and intervals, while the
  target backend provides monotonic time and scheduling.
- Hardware interrupt code must not invoke presentation state concurrently; an
  adapter must serialize delivery before entering the application graph.

## Performance

The hot path begins at transition delivery and ends after capture publication
and view invalidation. In the dynamic investigation, in-order append is
constant-time before retention and publication; out-of-order input may trigger
a full sort, trimming scans the retained collection, and value publication may
copy storage. Rendering additionally filters transitions per channel and maps
them into line segments.

The acquisition path supports up to 80 transition events per second across the
four channels. The display targets a 250-millisecond refresh interval, so the
runtime may coalesce as many as 20 worst-case transition invalidations into one
frame. It must preserve ordered capture state but does not promise one rendered
frame per transition or a source-to-frame latency tighter than the next refresh
opportunity.

Before Specification approval, measurements must verify that retention,
four-channel path construction, and rendering complete reliably at that input
rate and refresh cadence on each target. The MVP records observed latency but
does not impose a tighter latency optimization goal.

## Memory / Binary Size

At the accepted maximum input rate, the 30-second history requires at least
2,404 transition entries, including four initial channel levels. Static storage
uses a fixed capacity no smaller than that value. On overflow it deterministically
evicts the oldest entries and retains the level of each channel at the new
lower bound so the current window remains correct.

Dynamic profiles may retain array-backed value snapshots. Static and embedded
profiles should prefer fixed-capacity transition storage and bounded drawing
workspace. The design must account for channel metadata, transitions, current
and previous state, path construction, view/runtime state, stack usage, and
the code-size cost of observation and timing mechanisms. MVP validation must
measure and report RAM, stack where measurable, and binary size and must show
that the application fits and runs on the supported board. No stronger numeric
optimization budget is imposed for this iteration.

## Alternatives

### Direct source ownership in Presentation

The ViewModel could own a mock or hardware source directly. This reduces the
number of types but couples presentation state to acquisition mechanism,
buffering, and target hardware. It is attractive only for disposable demos,
not for the cross-target reference application.

### Asynchronous sequences across every boundary

Sources and repositories could expose `AsyncSequence` values consumed by
Presentation tasks. This naturally models suspension and multiple producers,
but adds task lifetime, continuation buffering, cancellation, actor handoff,
and runtime availability concerns to a deliberately low-frequency,
single-consumer graph. It may become preferable if measured acquisition rates
or target APIs require backpressure or parallel processing.

### Periodic sample buffers

The repository could store a value for every sample interval. That model is
simple for fixed-rate acquisition and some drawing pipelines, but spends memory
on unchanged digital levels and makes the MVP depend on a sampling frequency.
It may be preferable for future analog or high-frequency applications but is
not required for this analyzer.

### Target-specific presentation forks

Each platform could implement its own analyzer screen. This allows aggressive
target optimization but defeats the reference application's purpose and can
hide missing GiftUI abstractions behind superficially similar applications.

### Runtime-sized channel and control collections

The presentation could use dynamic collection views for channels and window
buttons. This is more extensible but introduces client-surface and static
composition requirements that the fixed MVP does not need.

### One undivided application module

All behavior could live in an executable target. This simplifies packaging but
allows platform and UI dependencies to leak into signal semantics and prevents
independent conformance testing of application boundaries.

## Rejected Approaches

- Direct source ownership in Presentation was rejected because it couples the
  portable presentation to acquisition, buffering, and target hardware.
- Asynchronous sequences across every boundary were rejected for the MVP
  because they introduce task lifetime, buffering, cancellation, and runtime
  dependencies that the low-frequency single-consumer graph does not need.
- Periodic sample buffers were rejected because they spend bounded embedded
  memory on unchanged digital values and make behavior depend on a sampling
  frequency.
- Target-specific presentation forks were rejected because they defeat the
  reference application's portability purpose.
- Runtime-sized channel and control collections were rejected because the
  fixed MVP does not justify their client-surface or static-composition cost.
- One undivided application module was rejected because it permits UI and
  platform dependencies to leak into domain behavior and weakens independent
  conformance testing.

## Compatibility

The RFC preserves the observable behavior and dependency direction of the
macOS investigation. Moving the presentation from SwiftUI to GiftUI is an
intentional implementation migration; exact visual styling and SwiftUI source
compatibility are not promised.

Target hosts may use different concrete source, storage, executor, and runtime
types. They must preserve domain values, action semantics, ordering, retention,
visible-range calculation, disabled controls, and user-visible error behavior.

The architecture does not define ABI stability or persistence formats. Capture
values are in-memory application contracts, and no export compatibility is
required for MVP.

## Testing Strategy

- Domain tests verify models, visible-range arithmetic where owned, action
  delegation, observation attachment/detachment, and synchronous ordering.
- Data tests verify initial delivery, chronological accumulation, duration,
  retention, clear, start/stop/restart, startup failure, deterministic mock
  patterns, and prevention of stale events after cancellation.
- Presentation tests verify state replacement, intent routing, observation
  lifetime, error mapping, window selection, and disabled-state derivation.
- GiftUI conformance tests separately verify every required client operation
  on dynamic and static runtimes and applicable backends.
- Integration tests run the complete analyzer with a deterministic source and
  compare semantic state plus rendered grid/trace evidence.
- macOS dynamic and static execution must precede Raspberry Pi/Linux execution
  and nRF52840 static execution, following the MVP validation progression.
- Raspberry Pi display/input and nRF52840 display claims require connected
  hardware evidence; host or simulator runs are insufficient.
- Resource tests measure retained-transition capacity, overflow behavior,
  baseline preservation, sustained 80-transition-per-second ingestion,
  four-frame-per-second rendering, source-to-frame latency, stack high-water
  mark where available, RAM, and binary size under documented workloads.

## Risks

- The separately governed observation and Canvas features may expose static or
  embedded constraints that require this RFC or its downstream contract to be
  revisited.
- A synchronous callback chain can block acquisition if repository or
  presentation work grows; measurements may require batching or a different
  source adapter while preserving serialized delivery.
- A 2,404-entry transition buffer plus drawing and runtime state may still be a
  material fraction of embedded RAM even though aggressive optimization is not
  an MVP requirement.
- Value snapshots may hide copying costs on constrained targets.
- Target-specific composition can accidentally expand beyond legitimate host,
  input, display, clock, and source responsibilities.
- Framework work may incorrectly treat the analyzer's bounded needs as a
  general-purpose UI or graphics contract.
- An implementation copied directly from the investigation could turn legacy
  choices into de facto authority before review.

## Open Questions

No architectural questions remain open for RFC approval. Review resolved the
original questions as follows:

1. Inputs are limited to 10 Hz per channel, or 80 transition events per second
   aggregate. Static capture capacity is at least 2,404 entries; overflow
   evicts the oldest entries while retaining per-channel baseline levels.
2. Static embedded execution does not rely on `MainActor`, Observation,
   `Task`, or desktop clock/timer facilities. It preserves the same serialized
   behavior through static mechanisms.
3. Observable reference-state invalidation remains an MVP requirement but will
   begin a separate feature lifecycle with its own Proposal.
4. Canvas/path/stroke drawing remains an MVP requirement and is governed by
   accepted PROPOSAL-006, approved RFC-009, and accepted ADR-028 through
   ADR-031. Its exact public contract still requires an approved drawing
   Specification.
5. The display uses a 250-millisecond refresh interval. MVP validation records
   RAM, stack, binary size, and latency and proves that the application fits;
   this iteration imposes no stronger optimization budget.
6. Visible-range calculation remains in Presentation.
7. Public and core APIs represent intervals with `Duration`; target backends
   provide monotonic time acquisition and timer scheduling capabilities.

The Observation and Canvas lifecycle artifacts are downstream dependencies,
not unresolved decisions owned by this RFC. Their accepted architecture may
govern the Signal Analyzer Specification, but their exact public contracts
must be approved in downstream Specifications before implementation.

Post-approval status: the observable-reference-state lifecycle produced
accepted ADR-024 through ADR-027. ADR-027 superseded ADR-002 and returned
SPEC-001 to review. The Canvas lifecycle produced approved RFC-009 and accepted
ADR-028 through ADR-031; its missing gate is an approved drawing Specification.

## Decision Summary

The approved direction is extracted into separate accepted ADRs recording:

1. the analyzer's inward dependency structure and target-host composition
   boundary;
2. serialized synchronous sink delivery for acquisition values and state
   (historically extracted as ADR-002, later superseded by ADR-027);
3. transition-based digital capture with bounded repository-owned history;
4. a substantially shared fixed presentation with target-specific hosting and
   source adapters outside it.

ADR-001, ADR-003, and ADR-004 remain accepted. ADR-002 is superseded by
accepted ADR-027, which preserves synchronous application delivery while
placing observable ViewModel mutation behind bounded fact admission into
GiftUI's distinct mutation domain.

## References

- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [RFC-008: Observable Reference State Architecture](rfc-008-observable-reference-state-architecture.md)
- [ADR-002: Serialized Synchronous Acquisition Delivery](../adrs/adr-002-serialized-synchronous-acquisition-delivery.md)
- [ADR-027: Bounded Presentation-Fact Admission](../adrs/adr-027-bounded-presentation-fact-admission.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
- External investigation source: `GIFTUI_SIGNAL_ANALYZER_SPEC.md` in the
  SignalAnalyzer playground repository.
- External investigation source: `GIFTUI_VIEW_FEATURE_PRIORITIES.md` in the
  SignalAnalyzer playground repository.
- External implementation evidence: the SignalAnalyzer playground package,
  its four application targets, and their tests.
