---
id: FW-022
feature: giftui-mvp-architecture
title: Contract-Accurate Embedded Target Simulator
status: captured
authors:
  - codex
created: 2026-09-11
updated: 2026-09-11
source:
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-022: Contract-Accurate Embedded Target Simulator

> This item preserves a possible post-MVP development and validation tool. It
> does not commit GiftUI to build a simulator, select an implementation, change
> accepted architecture, expand MVP scope, or authorize implementation.

## Observation / Opportunity

GiftUI's accepted architecture and approved Specifications expose unusually
strong seams for an embedded-target simulator: deterministic semantic, layout,
render, execution, observable-state, interaction, and failure contracts;
explicit dynamic and static runtime profiles; immutable target-host
configuration; bounded storage and work; canonical pixel encodings; normalized
input; recording endpoints; and separately identified backend, display,
transport, clock, and hardware ownership.

A desktop tool similar in developer role to Apple's iOS Simulator could run a
portable GiftUI application through production GiftUI owners while presenting
a simulated constrained display and input device. It could make target limits,
resource lifetimes, performance evidence, frame transactions, and failures
visible during ordinary development instead of leaving those concerns to late
cross-build or hardware validation.

GiftUI previously had a macOS simulator proof of concept. That implementation
and its mixed specification remain available from the immutable `PoC` tag as
historical evidence. They demonstrate feasibility of the desktop viewport and
input experience, but their platform-owned stack is not current authority and
must not be restored as the architecture of a future simulator.

## Why Deferred

An interactive embedded-target simulator is not required by the current MVP
scope. MVP completion requires the substantially shared Signal Analyzer to run
on macOS dynamic, macOS static, Raspberry Pi/Linux with framebuffer and
PiScreen, and nRF52840 with the supported TFT. Builds, host fixtures, emulators,
and simulators cannot substitute for the required connected-target evidence.

The approved contracts that would make the simulator trustworthy are also not
yet fully implemented. In particular, production owners for interaction,
drawing, runtime profiles, backend integration, and host configuration must
exist before a simulator can compose them without duplicating behavior or
reviving obsolete proof-of-concept ownership. SPEC-013 through SPEC-015 have
approved contracts and ready plans, but their downstream production targets
and complete conformance evidence remain pending.

This is a major cross-cutting feature rather than lightweight implementation
work. It could establish new host composition, tooling, instrumentation,
evidence-class, target-binary, peripheral-model, and calibration boundaries.
Those decisions require normal lifecycle review after concrete value and
feasibility are established.

## Potential Value

- Provide a fast interactive development environment for portable GiftUI
  applications using embedded display extents, pixel encodings, input paths,
  storage limits, and frame pacing.
- Exercise production semantic, layout, drawing, render, state, interaction,
  execution, and failure behavior rather than a simulator-specific duplicate.
- Detect capacity exhaustion, forbidden allocation, excessive workspace use,
  rendering changes, deadline risk, and transport pressure earlier.
- Visualize exact cycles, publications, frame offers, retries, tile visits,
  payload submissions, high-water marks, failures, and operational-health
  transitions.
- Support deterministic replay of normalized facts, input, virtual time,
  endpoint responses, and injected faults for debugging and conformance.
- Report precisely which results are contract-exact, target-image-exact,
  conservatively bounded, calibrated, estimated, or hardware-only.
- Create a common place to compare dynamic and static realizations without
  leaking runtime-profile or target selection into portable Presentation.

## Candidate System Shape

The following is a candidate for later Exploration, not an accepted design:

```text
portable GiftUI application
           |
           v
production semantic/layout/runtime pipeline
           |
           v
production normalized rendering and RGB565 tiled raster path
           |
           v
simulated display, input, clock, transport, and fault endpoints
           |
           v
viewport, timeline, resource report, and evidence manifest
```

The simulator would live at or outside the target-host composition boundary.
It would not be imported by `GiftUI`, portable Presentation, semantic core,
layout, rendering core, or reusable runtime owners. Target-specific display,
input, clock, scheduling, transport, and instrumentation would remain outside
portable application source.

A possible macOS shell could provide:

- a pixel-scaled TFT viewport for fixed target extents;
- mouse or trackpad input lowered through the normalized input contract;
- deterministic virtual time and scripted Signal Analyzer acquisition;
- frame, operation, tile, region, payload, and failure timelines;
- resource and high-water dashboards;
- fault injection for backpressure, refusal, capacity exhaustion, short
  transfer, disconnection, stale input, invalid identity, and deadline edges;
- exact capture and replay of simulator inputs and results; and
- immutable device presets, with complete host reconstruction when a preset or
  other immutable configuration changes.

At least two execution levels should be evaluated rather than hidden behind
one undifferentiated claim:

1. A **native contract simulator** could execute host-native builds of the
   production GiftUI owners using the static storage model, target limits,
   canonical RGB565 path, virtual clock, and simulated peripherals. It would
   prioritize interactive speed, determinism, inspection, and exact logical
   behavior.
2. A **target-binary emulator** could execute the actual cross-compiled target
   image under an instruction-set and peripheral model, bridging the emulated
   display, input, transport, and time sources to the desktop shell. It could
   provide stronger evidence for ABI, instruction count, target runtime,
   target-specific stack behavior, and processor-dependent performance.

Connected-hardware calibration and validation would remain a third, separate
evidence class. It could refine simulator timing envelopes but would not turn
simulator output into connected-hardware evidence.

## Fidelity and Claim Boundaries

Precision must be declared independently for each observable dimension. A
single percentage or general claim such as "accurately emulates nRF52840" is
not sufficient.

| Dimension | Candidate fidelity claim |
| --- | --- |
| Semantic expansion, layout, state, actions, lifecycle, and failure ordering | Exact when the production owners execute with identical normalized inputs, resources, configuration, and limits |
| Capacity success and first-excess behavior | Exact when the same bounded stores and limits are used |
| Normalized render operation order and geometry | Exact |
| Canonical opaque RGB565/RGBA8888 pixels, clipping, and stroke coverage | Byte-for-byte exact under the approved resources and backend contract |
| Virtual frame cadence, service-window boundaries, retries, and scripted endpoint timing | Exactly reproducible in simulator time, but not necessarily equal to wall-clock hardware time |
| Static store sizes, configured workspaces, and declared payload/in-flight limits | Exact for the selected implementation and configuration |
| Linked flash, read-only data, writable data, BSS, and linked RAM | Exact only from the actual target ELF produced by the named pinned compiler and flags |
| Heap allocation behavior | Strongly provable through zero allocator calls, configuration, and target-image symbol inspection on static paths |
| Stack | Conservatively bounded when the complete call graph is finite and inspectable; measured high-water remains method- and workload-dependent |
| CPU work | Exact operation counts and potentially exact emulated instruction counts; elapsed device time requires a processor model and calibration |
| SPI or display transfer duration | Modelable within a stated envelope using exact payloads plus a versioned and calibrated transport model |
| Interrupt latency, flash wait states, DMA/bus contention, electrical behavior, real TFT response, temperature effects, and energy | Hardware-dependent and not generally guaranteeable by the native simulator |

The simulator must not use native macOS elapsed time as an absolute prediction
of Cortex-M4F performance. Host timing may be useful for regression detection
when the host, build, fixture, warm-up, and sampling method are pinned. Stronger
target timing claims require the target binary plus an adequate processor and
peripheral model, followed by comparison with separately authorized hardware
measurements. User-facing estimates should be ranges or budgets with explicit
assumptions rather than false precision.

Every run should emit an evidence manifest containing at least:

- repository revision and dirty state;
- compiler, SDK, optimization mode, flags, and target triple;
- portable application/workload identity;
- exact resource-package identity;
- target preset and all effective limits;
- simulator or emulator engine and version;
- timing and peripheral model versions;
- warm-up, repetitions, sampling, and instrumentation method;
- transcript and output digests; and
- a per-result evidence class such as contract-exact, target-image-exact,
  conservative-bound, calibrated-estimate, host-regression, simulator, or
  connected-target.

## Resource Model

The resource view should account for ownership and overlapping lifetimes, not
merely add unrelated type sizes or report one process-wide memory number.
Candidate categories include:

- portable and generated client code;
- linked text and read-only resource data;
- writable data and BSS;
- runtime live, candidate, queue, attempt, committed-routing, recovery, and
  generated-Canvas storage;
- semantic, layout, Path, drawing-plan, render, glyph, and stroke workspaces;
- surface, tile, row/span, region-record, payload, in-flight, display,
  transport, and driver storage;
- observable, interaction, action, fact-admission, host-policy, diagnostic,
  and application storage;
- dynamic allocator payload and allocator bookkeeping, reported separately;
- stack by phase and complete worst-case call chain; and
- generated specialization and callable-table code size.

The tool should expose a lifetime timeline that identifies the actual
simultaneous high-water mark. It should preserve SPEC-013's separation between
profile-owned bytes and text-resource, capability, backend, host, stack, and
application costs so one owner cannot hide cost inside another. Static paths
should fail when a declared store is absent, insufficient, inconsistent, or
overflows; they should not silently resize or fall back to heap storage.

The first nRF52840 simulator preset should reproduce the approved 480 x 320
surface, 480 x 4 RGB565 region, 960-byte row, and 3,840-byte raster, payload,
and in-flight bounds without a complete framebuffer. The Signal Analyzer
fixture should also preserve the approved workload, capacity, and 250 ms
service/frame pacing inputs instead of inventing reduced simulator values.

## Performance Model

Performance reporting should separate deterministic work from predicted
elapsed time:

- semantic nodes, layout scopes, glyphs, ordinary render operations, Canvas
  points/subpaths/strokes, tile visits, regions, payloads, bytes, facts,
  actions, offers, refusals, and retries can be counted exactly;
- virtual-clock scheduling, coalescing, deadline edges, and finite retry
  behavior can be reproduced exactly;
- phase-level host duration can detect regressions but cannot establish MCU
  latency;
- target-binary instruction counts can improve processor-work estimates but do
  not by themselves model memory wait states, interrupts, peripherals, or
  contention;
- transport and scan-out estimates should combine exact submitted bytes and
  regions with a named calibrated model; and
- connected-target measurements remain necessary for on-device latency,
  jitter, stack high-water, display behavior, electrical integration, and
  energy claims.

The simulator should support budget assertions and trend comparison without
introducing a universal cost optimizer or silently selecting a different
backend realization. General cost-aware realization selection remains the
separate opportunity preserved by FW-007.

## Current Non-goals

- Do not add this feature to the MVP milestone or treat it as an MVP exit
  requirement.
- Do not replace Raspberry Pi, PiScreen, nRF52840, TFT, input, transport, or
  other required connected-target validation.
- Do not restore the retired PoC simulator or its platform-owned vertical stack
  as current architecture.
- Do not create simulator-specific semantic expansion, layout, rendering,
  state, action, interaction, failure, or retry behavior.
- Do not expose simulator, emulator, target, backend, capability, resource, or
  runtime-profile selection to portable Presentation.
- Do not weaken static zero-allocation rules or substitute heap-backed storage
  when a configured target limit is exhausted.
- Do not claim cycle accuracy, electrical accuracy, energy accuracy, or exact
  real-device latency without adequate models and connected-hardware
  calibration.
- Do not define a universal peripheral simulator, debugger, profiler, cost
  algebra, or automated realization planner as part of this capture.
- Do not choose AppKit, another desktop UI toolkit, an instruction emulator,
  IPC protocol, process boundary, peripheral model, or instrumentation format
  before Exploration compares their consequences.

## Revisit Triggers

- SPEC-011 through SPEC-015 expose implemented production owner seams adequate
  to compose a simulator without duplicating their behavior.
- Developers begin repeatedly reconstructing ad hoc macOS target-limit,
  viewport, input, virtual-clock, fault, or resource-inspection harnesses.
- A concrete portable application beyond the fixed Signal Analyzer needs rapid
  iteration against an embedded display/input/profile before hardware is
  routinely available.
- Connected nRF52840 measurements exist for representative worst-case Signal
  Analyzer frames and transport paths, enabling a versioned calibration and
  error-envelope study.
- Resource or timing regressions escape host fixtures or cross-build reports
  often enough that an integrated lifetime/performance view would materially
  shorten diagnosis.
- A maintainer explicitly chooses to evaluate an iOS-Simulator-like developer
  experience as a post-MVP product investment.

## Promotion Gate and Suggested Evidence

When a trigger fires, promote this item first to an Exploration unless the
problem, value, users, and investment case are already sufficiently concrete
for a Proposal. The Exploration should answer at least:

1. Which user workflows require an interactive simulator rather than existing
   recording fixtures, cross-build inspection, or connected hardware?
2. Which fidelity dimensions must be exact, bounded, calibrated, estimated,
   or explicitly unsupported?
3. Can the native simulator execute all production owners and embedded limits
   without changing portable semantics or target-host ownership?
4. What additional evidence does a target-binary emulator provide, and does it
   justify its implementation and maintenance cost?
5. Which processor, clock, interrupt, SPI/display, and input effects can be
   calibrated to useful error envelopes?
6. How are resource lifetimes, target ELF sections, stack bounds/high-water,
   operation counts, and performance samples correlated without instrumentation
   changing the measured image unnoticed?
7. Which portions of the retired PoC can be adapted as shell-only evidence,
   and which must remain retired?
8. What is the smallest independently useful slice: viewport and input,
   contract timeline, resource laboratory, target-binary execution, or a
   combination?

If implementation evidence is required, use a bounded Spike with named
questions and stop conditions. A Spike should compare at least one identical
Signal Analyzer workload across native contract simulation, target-binary
emulation when feasible, and connected hardware. It must report limitations
and must not place disposable code in production targets.

A positive Exploration may promote to a Proposal. After human acceptance, the
feature will likely require an independently reviewable RFC because simulator
host ownership, evidence claims, instrumentation effects, target-binary
boundaries, and performance calibration can be approved or rejected without
changing the existing MVP host contracts. Normal RFC, ADR, Specification,
implementation-plan, implementation, and conformance gates still apply.

## Disposition

Captured as post-MVP work under `giftui-mvp-architecture` for navigation
without registering a simulator feature or changing that feature's current
stage. Current MVP scope, accepted architecture, approved Specifications,
implementation tasks, and connected-hardware requirements are unchanged.
Re-evaluate only when one of the stated triggers occurs; this document is not
authority to implement or to claim embedded-hardware equivalence.

## References

- [GiftUI Proof-of-Concept Historical Baseline](../engineering/POC_HISTORICAL_BASELINE.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [SPEC-013: Dynamic and Static Runtime Profile Contract](../specs/spec-013-runtime-profiles.md)
- [SPEC-014: Raster Backend and Display Integration Contract](../specs/spec-014-backend-integration.md)
- [SPEC-015: MVP Target-Host Configuration Contract](../specs/spec-015-host-configuration.md)
- [SPEC-015 Implementation Plan](../implementation-plans/spec-015-implementation-plan.md)
- [SPIKE-002: nRF52840 Capability-Path Resource and Zero-Heap Evidence](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
- [SPIKE-004: Canvas Path Plan Feasibility](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [FW-007: Cost-Aware Capability Realization Planning](fw-007-cost-aware-capability-planning.md)
- Historical `PoC:docs/GiftUI_PoC_A_macOS_Simulator_Spec.md`
