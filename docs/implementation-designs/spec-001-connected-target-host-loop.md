---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — Connected-Target Host Loop
status: current
authors:
  - codex
created: 2026-09-20
updated: 2026-09-23
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Connected-Target Host Loop

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specifications.

## Purpose and Boundary

This note explains the missing production join between the existing Signal
Analyzer application owners, the complete GiftUI run-cycle stages, and the
PiScreen or nRF52840 device adapters. It is the implementation direction for
SPEC-001 plan tasks T6.7 and T6.8.

The current target artifacts validate presets and now contain bounded device
adapters, but they do not execute a complete analyzer cycle. The existing
`SignalAnalyzerIntegratedCycleTests` are valuable ordering evidence, but their
owner substitutes layout, Canvas derivation, interaction construction, and
frame production. This note prevents those substitutions from being promoted
as production behavior or connected-target evidence.

This design does not change portable Presentation, runtime-stage ordering,
endpoint contracts, preset bounds, error meaning, or hardware gates.

## Governing Contract

The mechanism realizes SPEC-001 `Target host`, `Observable state and admission
configuration`, `Serialized delivery`, `ViewModel behavior`, `State /
Lifecycle`, and acceptance criteria SA-AC-005, SA-AC-023 through SA-AC-025,
SA-AC-028, SA-AC-039, and SA-AC-045. The implementation tasks are T6.7 and
T6.8, followed by T8.1 through T8.3.

ADR-001 and ADR-004 keep the application graph and portable hierarchy shared.
ADR-011 fixes one serialized cycle and publication boundary. ADR-024 through
ADR-028 fix observable ownership, fact admission, and post-layout Drawing.
ADR-033 fixes bounded action dispatch and final model-generation validation.
SPEC-009, SPEC-011, SPEC-013, SPEC-014, and SPEC-015 own the reusable cycle,
interaction, profile, backend, and host contracts consumed here.

## Current-Code Context

`SignalAnalyzerView`, the Domain/Data/Presentation owners, fact admission, and
six-action dispatch are implemented. Dynamic and Static observable root
adapters, semantic expansion, layout, Canvas planning, render lowering,
interaction storage, RGB565 rasterization, display handoff, activation,
pacing, and teardown also exist as focused production components.

The missing code is an application-specific owner that stores those focused
components together and implements every `RuntimeCompletePipelineOwner` stage
with the real component for that stage. `HardwareFreePresetRunner` must remain
a validation harness. `LinuxPiScreenExercise` and the finite nRF device entry
must remain adapter diagnostics. Neither becomes the application host.

## Proposed Internal Organization

Add one package-internal `SignalAnalyzerTargetHost` module. It may import the
Signal Analyzer application modules and the focused GiftUI modules because it
is application composition, not reusable framework policy. Executables import
this module and add only their platform devices and process loop. The nRF
firmware compiles the same module's Static source set explicitly, as it does
for the existing generated preset source.

The module contains two concrete owners rather than one runtime-selected
profile:

- a Dynamic owner for Raspberry Pi, storing Dynamic profile workspaces and a
  generic synchronous display target; and
- a Static owner for nRF52840, storing generated fixed-capacity regions and a
  generic synchronous display target.

Small package-private helpers may share stage logic where their generic bounds
do not introduce existential storage, runtime profile selection, or allocation
on Static. Each owner conforms to `SignalAnalyzerPresetLiveOwner` and delegates
activation/teardown ordering to the existing host controller.

Platform modules own only device realization:

- Raspberry Pi supplies `LinuxPiScreenFramebuffer`,
  `LinuxPiScreenTouchDevice`, a monotonic clock, and the process wake loop.
- nRF supplies the ILI9486/ADS7846 C shims, Zephyr uptime/sleep, UART
  diagnostics, and the watchdog-aware firmware loop.

## Data and Control Flow

Activation validates and stores the immutable assembly report before any
device or source side effect. It then follows the existing seven activation
steps. The first accepted presentation is produced through the same complete
pipeline later used for ordinary opportunities; input becomes eligible only
after that physical handoff succeeds.

Each opportunity executes the exact stage sequence below:

```text
sealed analyzer facts and normalized input
  -> ViewModel mutation and dirty reporting
  -> observable candidate + semantic expansion of SignalAnalyzerView
  -> layout measure/place
  -> five Canvas invocations and cycle-local Drawing plan
  -> combined render preflight
  -> committed interaction candidate
  -> semantic/observable publication
  -> one-shot candidate allocation
  -> RGB565 tile traversal and synchronous display submission
  -> commit or contract-defined cleanup/disposition
```

PiScreen contact events are converted to normalized pointer events before
admission. nRF PENIRQ/raw samples pass through the accepted calibration and
normalization owner before admission. Hit testing and action capture use only
the committed interaction generation. Dispatch revalidates the current model
target generation immediately before invoking the immutable six-case handler.

Repository callbacks admit facts and request a wake; they never enter the
runtime synchronously. A display refusal or incomplete drain never enables
input or commits a logical presentation. Teardown executes the existing eight
ordered calls and releases device owners last.

## Algorithms and Data Structures

The host owner is an aggregate of focused bounded stores. It does not add a
second state machine. Each `RuntimeCompletePipelineOwner` method translates
one focused component result into the already-defined pipeline result and
records no semantic information beyond that result.

Semantic expansion writes into the selected profile's bounded semantic result
storage. Layout consumes that immutable candidate and writes only its bounded
layout workspace. Canvas callables derive a cycle-local plan after layout.
Combined render preflight must succeed before interaction publication or
endpoint reservation. RGB565 operation-major traversal visits the exact
240 x 16 Pi or 480 x 4 nRF workspace and submits through one synchronous
borrowed payload slot.

The platform input loop keeps one pointer sequence. A contact outside the
logical aspect-fit surface cancels the active sequence. Sequence and
generation checks reject stale events before action dispatch. Counters use
checked arithmetic and saturate only where the governing diagnostic contract
already permits saturation.

## Lifecycle and State

Construction is inert. `valid -> activating -> active` is owned by
`MVPHostActivationController`; activation failure enters `failed` after its
defined partial-progress containment. The runtime opportunity is nonreentrant.
Backpressure or retryable refusal preserves only contract-authorized pending
intent and requests another paced wake.

Teardown first refuses application delivery and input, then stops source and
observation, cancels pointer/platform callbacks, quiesces the runtime,
retires observable routing, releases devices, resets profile storage, and
invalidates report use. No device callback may retain the owner after release.

## Runtime Profiles and Platforms

The Dynamic Pi owner may use bounded retained storage but keeps the generated
1/32/1 admission bounds and exact preset limits. It renders 240 x 240 logical
content into 240 x 16 RGB565 regions and projects them into the validated
480 x 320 framebuffer aspect-fit rectangle.

The Static nRF owner uses only generated inline storage and direct typed
dispatch. It renders 480 x 320 content into one 480 x 4 RGB565 staging slot
and a 240-byte coverage bitmap for touched-pixel run emission.
Its address-stable runtime aggregate retains the common wake/pacing controller
with the generated policy and a caller-supplied monotonic frame origin for the
same lifetime as application and profile storage.
The first paced Static service encloses the application fact/input stage and
always completes its pacing opportunity before returning a stage result; the
full semantic-to-display transaction will extend this serialized service.
The firmware clock seam converts Zephyr's signed 64-bit uptime milliseconds
to checked monotonic microseconds. The finite device entry uses that same
source for its display-transfer measurement until the live loop is linked.
ILI9486 consumes the synchronous borrow before return. No full framebuffer,
heap, reflection, `Any`, or runtime profile selection is permitted.

The display writer and tile store borrow the same 3,840-byte region. Traversal
reads covered pixels in ascending offset order, and the writer packs each
horizontal run toward the front of that region. Its output offset never
overtakes the source offset. Submission consumes each run synchronously before
the writer resets its cursors; reset does not clear unread tile bytes.
The Static endpoint factory constructs both borrowers from one caller-supplied
region, so its firmware call site cannot choose distinct raster and payload
allocations.
The target's transport value holds a noncapturing C function pointer matching
`ili9486_write_rgb565`. It passes one horizontal row and the borrowed bytes
to the C driver before return. A nonzero driver status becomes target transport
refusal; the driver retains detailed fault counters.
A failed synchronous write may have emitted a prefix, so the target retains
presentation responsibility, records one unavailable-health transition, and
drains the reservation even if this was the first payload. It then refuses
later frames until the host reconstructs the target and endpoint.
The paced nRF stage reconciles every accepted offer with target-owned health
before its opportunity ends. A healthy committed offer enables input. A
post-acceptance failure drains first, then the shared health controller marks
fresh construction required and the application owner quiesces its input.
The resulting failure transition remains available for the firmware owner to
route through the approved residual policy.
Once health requires fresh construction, the paced entry rejects later work
before scheduling or beginning another profile attempt. It preserves the
pending wake for the reconstruction owner and performs no display offer.
The Static nRF residual adapter sends only a completed backend-health
transition to the shared host router after those mandatory effects. The
router validates the approved policy table and selects the target's
`quiesceAffectedScope` disposition. Health errors and commit-health mismatch
remain explicit containment results for the firmware composition.

The semantic/action/drawing transcript is profile-equivalent. Device timing,
physical extents, payload counts, stack high-water, and transport errors remain
separate physical evidence and are not normalized away.
The Static preparation entry borrows all five attempt-local regions once and
performs layout, Canvas derivation, and render preflight before lending checked
views to a synchronous handoff callback. No region-backed view escapes that
scope. The generated semantic stage publishes a complete checked revision
before preparation and leaves the candidate region intact for that borrow.
The application owner lends generated inputs from its bound model together
with a noncopyable committer over the disjoint interaction, generation, and
input fields. This keeps model derivation and physical-offer resolution in
one synchronous borrow without duplicating the model.
The production presentation transaction joins semantic publication,
five-region preparation, and physical handoff in that borrow. It returns
distinct unbound-root, semantic, preparation, and handoff outcomes to the
caller, leaving opportunity pacing and recovery with the firmware owner.
The paced application stage now retains its pacing opportunity and profile
attempt through the transaction. Before the first physical frame, fact
application completes with an empty input drain; subsequent opportunities
drain admitted input before presentation. The firmware owner still needs to
join identity allocation, endpoint lifetime, and recovery policy at the
firmware boundary.
The Static nRF identity owner now reserves cycle, semantic, candidate, and
presentation numbers together; semantic revision zero is skipped because the
packed table uses it for unpublished storage. The one-slot endpoint stores
its envelope validator as a value and replaces it only while the raster sink
is idle. This lets consecutive paced opportunities reuse the same raster and
transport owners while rejecting the previous frame identity.

## Resource and Failure Behavior

All workspaces come from generated preset limits. The Pi display target keeps
at most 7,680 payload bytes plus bounded region metadata. The nRF display path
keeps exactly one 3,840-byte tile slot; its separately accounted generated
profile workspace is exactly 36,368 bytes. The firmware build rejects a named
profile, capture, or raster-staging symbol whose linked size differs from the
generated contract; report generation reads those sizes from the inspected ELF
rather than restating configured constants. The nRF build must remain within
its checked 196,608-byte RAM ceiling with both heaps disabled and must
demonstrate at least the contract-required connected stack margin before
conformance.

Every stage maps its focused error through the existing owner adapter. A
device initialization failure occurs before source start. A display failure
after presentation responsibility transfers drains required work and preserves
the original normalized failure. Input transport failure cancels the pointer
sequence and prevents further action eligibility until the host-defined
recovery or fresh construction path succeeds.

## Test and Diagnostic Seams

First add a platform-free host-owner fixture whose display and input adapters
record calls but whose semantic expansion, layout, Drawing, render lowering,
interaction, and raster stages are production implementations. Run the exact
six-control script through both Dynamic and Static owners and compare semantic,
action, Drawing, offer, cleanup, and teardown traces.

Then cross-build the concrete Pi and nRF roots and inspect dependency, ABI,
storage, allocation, framebuffer, and symbol gates. Connected tests record
device identity, artifact digest, initialization, first frame, six controls,
stale-event rejection, sustained pacing, failures, teardown, and resource
high-water. The existing adapter diagnostics remain independently runnable and
must not be counted as application-host success.

## Rejected Implementation Alternatives

- Extending `HardwareFreePresetRunner` into the live owner would mix validation
  evidence with production lifecycle and device side effects.
- Treating the integrated-cycle test owner as production would retain its fake
  layout, Drawing, interaction, and offer stages.
- Putting platform branches in one owner would violate concrete-root ownership
  and make Static resource evidence ambiguous.
- Rendering a precomputed analyzer screenshot would bypass portable semantic,
  layout, Drawing, interaction, and action contracts.
- Restoring the historical thermostat/PiScreen PoC would reintroduce a removed
  architecture and would not execute the approved Signal Analyzer.

## Open Implementation Questions

No architectural choice is open. Exact-tree integration found semantic and
layout capacity mismatches in SPEC-013 / SPEC-015; the maintainer reapproved
schema 3, the independent structural-capacity contract, and the measured
53-scope layout bound on 2026-09-20. Both capacities now pass the real
hierarchy. Concrete private file/type names
may change while the ownership and stage boundaries above remain intact.
Physical nRF shield provenance, continuity/orientation, and power evidence is
a separate execution gate.

The Dynamic semantic store now publishes a coherent render-only projection,
and the complete foreground/background screen surface is realized. The
diagnostic maximum measures 126 retained expansion identities and 98 coherent
render/layout scopes at depth 13. Ordinary render streaming produces 30
operations; the production Dynamic Canvas plan and extension add five strokes
for 35 total operations, 129 positioned glyphs, and clip depth 3. The
maintainer approved these SPEC-008/SPEC-013/SPEC-015 values on 2026-09-20, and
the regenerated exact preset admits the complete production join. Live
host-owner composition is now realized for the Pi lifecycle aggregate,
including the Linux process-loop and graphics-console boundaries. T6.7's
hardware-free implementation is complete; connected execution remains
separately gated by T8.1.

The first host-loop owner is now concrete: one reference-owned Dynamic Pi
pacing state is shared by post-admission repository callbacks, queued input,
and the serialized coordinator it services at the generated frame boundary.
This preserves callback deferral, coalesces all admitted work, and completes
pacing even when the focused coordinator result is a failure. A target-owned
correlation allocator now advances cycles per opportunity and advances
semantic, candidate-frame, and presentation identities only when a changed
candidate reaches publication. The serialized coordinator owns that allocation
call site and passes the reserved tuple directly to presentation. Linux polling
now has a bounded decoded-contact ingress into normalized admission and the
shared pacing owner. The ARMv6 executable's typed input pump maps the real
nonblocking Linux device poll directly into that seam. A production lifecycle
aggregate now delegates exact seven-step activation and eight-step teardown to
the existing host controller, starts acquisition through the committed Start
action, and services deferred source facts at the generated frame boundary.
Its production assembly factory runs the complete checked validator and emits
the immutable report before Linux device construction. The ARMv6 executable's
explicit production mode now uses a monotonic nonblocking loop for touch,
source deadlines, paced opportunities, and signal-triggered controller
teardown. Its platform boundary now acquires Linux graphics-console mode
before framebuffer construction, retains the prior mode, and restores it
after process-loop teardown with fail-closed partial-initialization cleanup.

The first Static nRF input owner now reuses `HostNormalizedInputGate` and an
inline six-entry ring matching the generated preset. It assigns source,
presentation, sequence, and ordinal provenance only after the target-local C
normalizer emits a phase and point; capacity refusal cancels that physical
sequence, and quiescence clears the ring. The host fixture is mechanism
evidence only. The firmware build now whole-module compiles those exact shared
sources with a thin typed C ABI. C forwards phase, logical point, observed
presentation, and physical resynchronization proof; Swift assigns all target
provenance and preserves the normalized rejection vocabulary. The finite entry
constructs and quiesces the owner around device lifetime and installs the first
presentation only after display acceptance. A fixed C pipeline now joins an
injected calibration, the exact normalizer, and this ABI. Transport or bridge
failure resets normalization but cannot assert resynchronization until PENIRQ
is later observed released. Physical calibration still gates activation of
that pipeline in the real polling loop. The fixed ring can now drain only under
`HostApplicationOpportunityGate`, through a total Static handler result; direct
package-level removal is unavailable. The production Static application input
owner keeps the gate, ring, capture, and provenance as fixed value state across
opportunities. During one synchronous drain it creates a scoped interaction
adapter that borrows the generated `StaticInteractionState` and observable root;
no pointer to either movable caller-owned value survives the opportunity. The
interaction state, capture, and observable root share the generated descriptor's
`UInt32` structural identity type, so the application boundary does not truncate
or introduce a parallel identity. The owner installs a physical revision in
admission and dispatch together, and
quiesces both. Dispatch occurs only in the root's mutation phase, and a
mismatched target generation cancels before borrowing the model. The remaining
T6.8 join builds that owner into the firmware's complete generated Static
presentation composition.

The Static nRF composition now also has an inert production assembly validator.
It consumes the generated preset and fixed storage audit, rejects any departure
from the 480 x 320 / 480 x 4 / 3,840-byte projection, resolves the exact
capability contributions, and completes the same nine-stage host validator used
by the Dynamic Pi composition. The resulting immutable report is available
before device or application-owner construction. A noncopyable, caller-owned
Static application storage aggregate now requires that exact report and
constructs the generated root, six-action/six-region interaction state, and
input owner in one inert value. The eventual firmware owner must keep this
value address-stable for the complete bound-model lifetime; activation and
binding remain later joins. For host and future firmware composition, the
aggregate now provides one complete-lifetime scope that lends stable pointers
to its root, interaction, and input fields. The scoped owner binds the initial
model from the host-supplied concrete repository, constructing the exact three
action use cases at that boundary, and retains the direct report route only
inside that scope. The model's use cases keep the repository alive while the
root is bound. On exit the owner quiesces input and publishes structural
absence through the existing Static root lifecycle, detaching the change sink,
removing the model, and releasing the repository before any field pointer
expires.

The generated Static profile workspace is a noncopyable region map over the
firmware's caller-owned retained storage symbol. Its sixteen exact,
nonoverlapping ranges follow registry order and equal the approved 36,368-byte
audit without an allocator or a large stack temporary. Attempt reset clears
only the eight attempt-local families; complete reset clears the entire
caller-owned store. The remaining firmware composition must construct this map
before lending its regions to semantic, layout, Drawing, and render owners.

A report-gated factory now consumes that region map together with a concrete
generated metadata/table value and constructs `StaticRuntimeProfileBinding`
from the preset's exact structural identity and runtime limits. The common
Static runtime therefore owns opportunity begin/finish, attempt reset, and
quiescent teardown without target-local lifecycle duplication. The factory is
generic over generated metadata, but admits it only when its dense callable
case count and greatest declared capture record exactly equal the generated
Signal Analyzer workload's `2 / 32` values. It therefore cannot manufacture,
underfill, or substitute the still-required production Signal Analyzer Canvas
table.

A higher noncopyable runtime aggregate now requires the same immutable assembly
report to construct both the application storage and profile binding. Its one
address-stable scope lends the application owner and common Static binding
together, then quiesces both before either caller-owned field location or the
profile buffer can expire. The aggregate remains generic over the concrete
generated Canvas metadata, so it does not collapse the generation boundary.

The nRF capture region is now split into two 2,404-entry slots of compact
24-byte records, totaling exactly 115,392 bytes. Each record preserves the
portable transition's channel, level, and normalized `Duration` components;
the portable value remains unchanged. The scoped presentation composition
checks alignment and pairwise disjointness of capture, profile, raster, and
coverage regions before lending the capture borrower with its other owners.
This representation is an implementation prerequisite for the Static
repository and snapshot path; the current firmware still links only the
diagnostic input slice.

The target capture history now owns only scalar policy state and mutates the
live compact-record slot in place. It scans the ordered slot for stable
insertion, computes the combined sequence's time and capacity prefix eviction
before writing, and updates baseline levels from that prefix. With no eviction
it shifts records backward; with an evicted prefix it writes forward, so both
paths stay within the 2,404-record slot without a temporary array. Clear
preserves current levels, rebases source time, and advances the same revision
as the portable store. A host differential fixture compares publications,
metadata, and every retained record through sustained capacity pressure.
The snapshot operation copies only initialized live records into the second
slot and returns scalar revision, count, duration, lower-bound, and baseline
metadata. Later live mutations and clear do not change the copied records;
the snapshot borrower must complete synchronous delivery before recopying.
The application adapter and firmware repository join remain to be built.
The scoped presentation composition lends the capture policy and its region
together with the generated application/profile owners, pacing, identity,
endpoint, and health. The policy begins at revision zero within that scope;
its host fixture mutates the live slot before the scope ends.

The compact record and raw region borrower are split from portable
`SignalTransition` conversion. The same primitive source now enters the
firmware's whole-module Embedded Swift build. A C-called Swift layout entry
checks the target's 24-byte size/stride and exact two-slot byte count before
device validation. This proves the encoding layout in the target compiler;
the current firmware still does not run the capture policy or portable model.
The firmware entry now also obtains the actual C storage handoff and lends its
capture pointer and byte count to the shared Swift borrower before device
construction. A refused address, extent, or alignment stops startup.
The exact four-region validator is shared source between the host composition
and Embedded Swift startup. It checks lengths, 8-byte alignment, pairwise
disjointness, and address-addition overflow before owner construction.

The current host-only `StaticObservableModelStorage` keeps `Model?` fields and
the bound `SignalAnalyzerViewModel` is a class. That join has semantic host
fixtures, but it is not the generated, zero-heap typed model location required
by accepted ADR-026 and SPEC-001. The firmware cannot call the full host loop
until this static model realization and its direct observation/use-case route
compile and link with the zero-heap gate. The accepted contract remains intact.

The first target model primitive is one firmware-lifetime typed value location
and a copyable pointer-plus-generation handle. Its six action codes return
bounded intents, while the three window selections mutate the same location
and mark it dirty. Retirement invalidates copies; generation advancement
rejects a stale handle after reactivation. The common source builds on the
host and in Embedded Swift, and firmware startup validates the action map
before entering device validation. This primitive contains neither capture
values nor observation/use-case wiring, so it is not yet the generated
`SignalAnalyzerViewModel` specialization or the production host loop.
The handle accepts action dispatch only inside an explicit model mutation
opportunity. Nested starts, unmatched ends, and action delivery outside the
opportunity reject without changing its window; retirement closes an open
opportunity. This phase guard is shared by the host fixture and target build.

The target metadata factory now fills every generated component that does not
depend on Canvas capture lowering: one observable slot at the preset's exact
root identity, the six-case `SignalAnalyzerAction` specialization, and dense
coverage for callable IDs `1...2`. It accepts a supplied callable table only
after exact assembly selection and independent Static Canvas host validation.
The checked generated table now lowers the two portable Canvas expressions to
dense callable IDs `1...2`. The grid case has an empty capture record. The
trace case has one exact 32-byte record containing the address-stable model
handle, standard channel, and millisecond-exact visible-range bounds. Its
switch invokes the existing grid and trace drawing helpers directly; it does
not retain an escaping Canvas closure or introduce dynamic callable storage.
The generation manifest records all five source occurrences and exact field
offsets, and a contract checker keeps the portable source, manifest, and
generated output synchronized.

The observable-model handle's scoped borrow is typed-throwing. The generated
trace callable can therefore execute the existing `throws(DrawingError)`
waveform helper while borrowing the stable model location, preserving the
original drawing failure without returning or copying captured model state.

The first generated presentation-input stage is also scoped to that model
borrow. It selects the checked normal or diagnostic semantic high-water
summary, reserves every semantic-candidate counter and all five Canvas slots
exactly once in the active Static opportunity, and materializes the grid plus
four trace capture records without retaining the temporary model location.
Concrete generated semantic primitives, layout, Drawing-plan retention, and
render lowering remain the next pipeline join.

The common Static profile binding now synchronously lends one generated region
at a time. Attempt-local regions reject before and after an active opportunity;
retained regions remain available until quiescent teardown. This preserves the
single profile-buffer owner while allowing the focused generated semantic,
layout, Drawing, and render stages to write only their registered ranges.

The aggregate also owns the fixed Static fact-admission storage at a stable
address. Root binding creates the Presentation observation adapter from the
same repository as the model use cases, but does not start it. A distinct
activation call opens the bounded bootstrap producer, starts capture and state
observation, and closes the producer after both current values have terminated
at sequenced admission. The callbacks cannot synchronously mutate the model;
the sealed facts remain for a later serialized mutation opportunity. Scoped
teardown stops observation before quiescing and discarding fact storage, then
quiesces input and removes the root.

That later opportunity is now explicit on the scoped owner. It seals the
active admission batch, enters the Static root's observable mutation phase,
applies each sealed fact in sequence through the bound model, and restores the
idle phase on every return path. Its bounded result distinguishes applied work,
fact rejection, and an unavailable model, while the applied summary carries
the exact `UInt16` fact count and aggregate changed state. An empty later
opportunity is a successful zero-fact application rather than replay.

The scoped owner's input opportunity also owns the action producer lifetime.
It reserves `.action` before delegating to the fixed input drain and releases
that producer on every return path. Consequently a repository callback caused
by Start, Stop, or Clear can only append a bounded fact while the interaction
session owns observable mutation; it cannot reenter the model. Failure to
reserve the producer rejects before the input owner removes any queued event.
Accepted action facts remain active until the next fact opportunity seals and
applies them.

After the first physical presentation, the scoped owner exposes one combined
application opportunity. It seals and applies all previously admitted facts
before opening the action producer and draining input. The result preserves
the separate bounded fact and input summaries and distinguishes fact
application failure from input rejection. Because the seal precedes action
dispatch, callbacks produced by Start, Stop, or Clear cannot join the current
batch and remain ordered for the next application opportunity. Bootstrap fact
application remains an explicit pre-presentation activation step because input
is not eligible until that first presentation is accepted.

The firmware input ABI now has its first address-stable target-owned lifetime:
one fixed global storage value binds the input source once and is mutated in
place by every C bridge call. This removes per-call coordinator copies while
keeping the bridge unavailable before initialization and after quiescence. It
is also the exact storage embedded by the production application input owner,
which delegates its serialized opportunity drain instead of owning a parallel
coordinator. The storage is noncopyable, so neither host composition nor
firmware code can duplicate its sequence, queue, or opportunity state. The
firmware does not yet link the generated root, interaction, rendering, or
endpoint storage, so the complete Static application lifetime remains the next
join.

## Code and Evidence Links

- [`DynamicSemanticHostStorage.swift`](../../Sources/GiftUIRuntimeDynamic/DynamicSemanticHostStorage.swift)
  supplies the first production bounded semantic/layout/render/action source
  for the Raspberry Pi Dynamic host.
- [`SignalAnalyzerIntegratedCycleTests.swift`](../../Tests/GiftUIHostConfigurationTests/SignalAnalyzerIntegratedCycleTests.swift)
  records current ordering evidence and the substitutions that must be removed.
- [`RuntimeCompletePipeline.swift`](../../Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift)
  owns the stage order and cleanup/disposition behavior.
- [`PiScreenDisplayTarget.swift`](../../Sources/GiftUIPlatformRaspberryPi/PiScreenDisplayTarget.swift)
  is the concrete Pi synchronous display target.
- [`DynamicSignalAnalyzerPiEndpoint.swift`](../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiEndpoint.swift)
  constructs the exact Pi raster session and one-shot endpoint around that
  display target.
- [`StaticSignalAnalyzerNRFInputCoordinator.swift`](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInputCoordinator.swift)
  supplies fixed-capacity normalized contact provenance and admission for the
  Static nRF application host.
- [`StaticSignalAnalyzerNRFInputABI.swift`](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInputABI.swift)
  validates C-compatible values and preserves typed admission dispositions at
  the firmware boundary.
- [`StaticSignalAnalyzerNRFInteractionHandler.swift`](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInteractionHandler.swift)
  provides the value session and scoped Static hit-testing/dispatch adapter.
- [`StaticSignalAnalyzerNRFApplicationInputOwner.swift`](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFApplicationInputOwner.swift)
  owns input, capture, presentation replacement, quiescence, and synchronous
  borrows of the generated interaction and observable-root storage.
- [`StaticSignalAnalyzerNRFAssembly.swift`](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFAssembly.swift)
  validates the generated Static preset, storage audit, component graph,
  capability resolution, endpoint projection, application, input, and policy
  contract before construction has side effects.
- [`StaticSignalAnalyzerNRFApplicationStorage.swift`](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFApplicationStorage.swift)
  constructs the inert generated root, interaction, and input storage only
  from that exact validated assembly report.
- [`nrf52840-tft-input-adapter.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md)
  records the current nRF device-adapter boundary and open host-loop gap.
- [`piscreen-platform-adapter.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md)
  records the current Pi device-adapter boundary and open host-loop gap.
- [`dynamic-semantic-host-storage.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-semantic-host-storage.md)
  records the first production-store slice and its atomic capacity tests.
- [`dynamic-observable-semantic-bridge.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-observable-semantic-bridge.md)
  records the production Dynamic state-binding bridge and its exact-type guard.
- [`dynamic-semantic-preset-blocker.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-semantic-preset-blocker.md)
  records the measured exact-tree mismatch and its schema-3 resolution.
- [`dynamic-layout-preset-blocker.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-layout-preset-blocker.md)
  records the production layout join, exact measured maxima, and resolution of
  the former 53-versus-32 capacity blocker.
- [`dynamic-render-workspace.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-render-workspace.md)
  records the bounded Dynamic render-preflight workspace prerequisite.
- [`dynamic-render-projection-blocker.md`](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-render-projection-blocker.md)
  records the measured production semantic-to-render mismatch.
