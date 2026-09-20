---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — Connected-Target Host Loop
status: current
authors:
  - codex
created: 2026-09-20
updated: 2026-09-20
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
dispatch. It renders 480 x 320 content into one 480 x 4 RGB565 staging slot.
ILI9486 consumes the synchronous borrow before return. No full framebuffer,
heap, reflection, `Any`, or runtime profile selection is permitted.

The semantic/action/drawing transcript is profile-equivalent. Device timing,
physical extents, payload counts, stack high-water, and transport errors remain
separate physical evidence and are not normalized away.

## Resource and Failure Behavior

All workspaces come from generated preset limits. The Pi display target keeps
at most 7,680 payload bytes plus bounded region metadata. The nRF display path
keeps exactly one 3,840-byte tile slot; existing application/profile storage
remains separately accounted. The nRF build must remain within its checked
196,608-byte RAM ceiling with both heaps disabled and must demonstrate at
least the contract-required connected stack margin before conformance.

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

The current implementation blocker is the production render projection. The
semantic store retains 81 structural identities, but the approved workload
admits 62 render scopes and the current child projection does not traverse a
coherent render-only tree. The complete foreground/background screen surface
must be realized before final production counts can be compared to the
approved workload.

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
