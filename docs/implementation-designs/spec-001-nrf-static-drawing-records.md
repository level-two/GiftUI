---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — nRF Static Drawing Records
status: current
authors:
  - codex
created: 2026-09-23
updated: 2026-09-23
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — nRF Static Drawing Records

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot amend a Specification.

## Purpose and Boundary

SPEC-001 T6.8 needs the five portable Canvas occurrences to produce the same
grid and four traces in the Static nRF profile. The existing generated callable
table is exact, but no fixed-region path builder or Drawing plan consumes it.
This note selects a bounded representation for those two attempt-local stages.
It does not change Canvas semantics, preset counts, rendering order, or the
physical display contract.

## Governing Contract

[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md) fixes the
five-Canvas analyzer and nRF target; [SPEC-012](../specs/spec-012-canvas-path-stroke-drawing.md)
fixes scoped path construction, snapshot, failure, and plan semantics;
[SPEC-015](../specs/spec-015-host-configuration.md) fixes the generated nRF
workload and exact `3,280 / 13,536` profile byte counts. Accepted ADR-028
through ADR-031 govern post-layout derivation and bounded stroke behavior.
The linked [implementation plan](../implementation-plans/spec-001-implementation-plan.md)
tracks this under T6.8.

## Current-Code Context

The generated semantic candidate and fixed layout result now complete the
common layout pass for the normal and maximal diagnostic trees. The generated
two-case Canvas table invokes the existing portable grid and trace helpers.
`CanvasPlanProducer` expects a `DrawingPlanConstructionWorkspace`; the Dynamic
host has one backed by arrays. `LivePathBuilder` and `StrokeSnapshotProducer`
already own generic construction and validation and should be reused.

## Proposed Internal Organization

Keep both fixed-region stores in `SignalAnalyzerTargetHost`. The profile owner
lends the 3,280-byte path region and 13,536-byte Drawing plan region during one
active opportunity, together with the generated Canvas source and resolved
layout. A scoped workspace implements `DrawingPlanConstructionWorkspace` and
`DrawingPlanMutationStorage`; a smaller live-path store implements
`LivePathStorage`. No profile selection, heap-backed collection, or duplicate
Drawing plan is introduced.

## Data and Control Flow

After layout publication, `CanvasPlanProducer.derive` visits five generated
occurrences in order. Each invocation receives a `GraphicsContext` tied to the
workspace's current generation and Canvas identity. `LivePathBuilder` writes
transient points and subpaths into the path region. On stroke,
`StrokeSnapshotProducer` validates and copies their values into the plan
region, translating by the Canvas origin and retaining the inherited clip.
The transient path resets before the next Canvas. Successful seal exposes one
immutable `DrawingPlanView` for render preflight and streaming; failure
invalidates the context, discards the plan, and does not publish a frame.

## Algorithms and Data Structures

The first production slice uses the exact 3,280-byte path region. At offset
zero, 202 points use eight bytes each for signed 32-bit x/y. Twelve subpaths
follow at offset 1,616, four bytes each for two `UInt16` fields. The remaining
1,616 bytes stay reserved. Counts live in the scoped value, not a second
array. The store rejects a region-size mismatch and preserves the existing
`LivePathBuilder` first-excess behavior. Its host tests cover move replacement,
two subpaths, signed coordinates, exact 202-point capacity, and reset.

The Drawing-plan record codec now fixes a 128-byte header region (including a
104-byte point-occupancy bitmap), five 16-byte Canvas slots at offset 128,
five 64-byte stroke slots at offset 208, 832 eight-byte translated points at
offset 528, and sixteen four-byte subpaths at offset 7,184. The used prefix
ends at 7,248; the rest of the approved 13,536-byte region remains reserved.
Every `StraightLineStrokeHeader` field, Canvas identity, and point/subpath base
ordinal round-trips. The codec rejects duplicate writes even for a zero point,
wrong region size, invalid stroke enums, and corrupt reserved bytes. The plan
owner must still validate cross-record ranges, seal an immutable summary, and
provide a `DrawingPlanView` without allocating filtered collections.

## Lifecycle and State

Construction is inert. `acquire` starts one derivation. Only one Canvas
context and one live path may exist at a time. Context generations reject
stale path or stroke calls. `seal` requires exactly five released Canvas
occurrences and the generated plan counts; `discard` and profile attempt
finish clear the regions and invalidate every borrowed view. The physical
submission step may borrow a sealed view only until the opportunity ends.

## Runtime Profiles and Platforms

The Dynamic Pi workspace remains independent and array-backed. Both profiles
invoke the same portable grid and trace code through the common Drawing
producer and compare normalized operations. The Static path uses only the
generated nRF workload limits and caller-owned regions.

## Resource and Failure Behavior

There is no heap allocation or full framebuffer. All writes check region
length, ordinal, arithmetic, generation, and plan capacity before mutation.
An unrepresentable translated coordinate or an excess point, subpath, stroke,
or Canvas fails through the existing Drawing error mapping. No truncated plan
may be sealed. Firmware linkage later must retain the named profile-store size
and pass ARMv7E-M VFP, zero-heap, RAM/flash, and forbidden-symbol checks.

## Test and Diagnostic Seams

Host tests exercise the live path and plan stores independently, then derive
all five real occurrences against normal and diagnostic generated layout.
Golden stroke/point/subpath comparisons use the Dynamic host oracle.
Embedded compilation and connected display are separate evidence gates.

## Rejected Implementation Alternatives

An array-backed Static workspace would evade the named profile audit and
depend on allocation. Reconstructing strokes while rendering would bypass the
approved post-layout Drawing plan and change failure ordering.

## Open Implementation Questions

Cross-record validation, scoped publication, and five-Canvas derivation remain
to be implemented and checked. No architectural or Specification decision is
open.

## Code and Evidence Links

- [Fixed live-path store](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFLivePathStorage.swift)
- [Live-path host tests](../../Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFLivePathStorageTests.swift)
- [Drawing-plan records](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDrawingPlanRecords.swift)
- [Drawing-plan record tests](../../Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFDrawingPlanRecordsTests.swift)
- [T6.8 evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md)
