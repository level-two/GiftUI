---
spec: SPEC-012
feature: canvas-drawing
title: Implementation Design — Combined Render Traversal
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-09-12
implementation_plan: ../implementation-plans/spec-012-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Combined Render Traversal

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains how SPEC-012 adds Canvas preflight and streaming at the
Canvas painter position while retaining SPEC-008's one ordinary traversal,
workspace, foreground stack, text validation, clip handling, and sink
transaction. It covers plan validation, added-operation accounting, and the
paired extension state used by T5.1-T5.5.

It does not define drawing-plan construction, rasterization, endpoint offer
ownership, runtime-profile callable storage, startup limits, or cycle recovery.

## Governing Contract

The realization follows SPEC-012's render-extension declarations, combined
render behavior, state/lifecycle rules, resource contract, and DR-005, DR-007,
DR-009, DR-012, and DR-013. It implements plan tasks T5.1-T5.5. ADR-028 fixes
the plan as post-layout and cycle-local; ADR-030 fixes one normalized operation
per stroke; ADR-031 fixes bounded failure integration. SPEC-008 remains the
authority for all ordinary lowering behavior.

## Current-Code Context

`GiftUIRenderLowering` already owns recursive preflight and streaming over
`SemanticRenderView` and `ResolvedRenderLayoutView`. The traversal resolves one
scope's bounds and logical inherited clip, performs its ordinary local work,
then visits its children. `GiftUIDrawing` owns `DrawingPlanView` and must add
stroke meaning without independently walking either authoritative view.

## Proposed Internal Organization

Preflight has one private traversal parameterized by a
`RenderPreflightExtension`. The existing ordinary entry point supplies a
zero-operation visitor. The package extension entry point supplies its caller's
visitor and adds each reported count using the existing checked render-limit
path. Streaming will use the same shape with a `RenderStreamingExtension` and
the existing sink transaction.

`CanvasRenderProducer` constructs focused visitors in `GiftUIDrawing`. A
visitor owns only call-local state: the immutable plan view and checked Canvas,
stroke, point, and subpath totals. It does not own semantic/layout traversal,
foreground state, an operation list, or a sink during preflight.

## Data and Control Flow

For each semantic scope, ordinary lowering resolves and validates identity,
bounds, inherited logical clip, depth, local style/background/text meaning,
and then calls the extension before descending into children. The Canvas
visitor returns zero for non-Canvas scopes and the exact Canvas stroke count
for a Canvas scope. The producer checked-adds that count to its ordinary
operation count.

At a Canvas scope the visitor validates the identity's presence, every stroke
header, exact surface origin and inherited clip, complete point lookup, gap-free
subpath coverage, and nil at each exclusive upper bound. After traversal its
`complete()` operation checks the aggregate against all five drawing-plan
summary fields. During production the producer invokes that completion after
the sole preflight traversal and before `begin`; only then may it expose the
combined header to the sink. The paired streaming visitor completes the same
comparison after streaming traversal and before `finish`.

## Algorithms and Data Structures

All counters are `UInt16` and use `addingReportingOverflow`. Stroke and payload
lookups are forward-only and bounded by their declared counts. Subpaths carry
an `expectedFirstPoint` cursor: each range must start at the cursor, its checked
end must not exceed the stroke point count, and the final cursor must equal the
point count. Empty geometry is valid only when both point and subpath counts
are zero.

The local visitor value is destroyed before `CanvasRenderProducer` returns.
Its copyable generic view does not escape the call; underlying cycle-local plan
storage remains owned by the caller and individual stroke payloads are never
retained.

## Lifecycle and State

The extended preflight rejects an active workspace as reentry, acquires an idle
workspace once, and resets it on every acquired exit. Visitor state is new for
each call. Failed traversal exposes no header. A successful preflight does not
change or retain the plan and does not inspect a sink.

The streaming visitor will be separate call-local state so preflight cannot
make emission decisions persistent. The producer must compare the two totals
and immutable snapshots before accepting completion.

## Runtime Profiles and Platforms

The traversal and visitor protocols contain no profile branch. Dynamic and
static profiles supply different concrete semantic, plan, and workspace views
but execute the same generic code and comparison rules. Backend modules see
only `DrawingOperationSink` and borrowed `StraightLineStrokeView` values.

## Resource and Failure Behavior

Traversal remains affine in semantic scopes plus text glyphs and drawing-plan
records. No retained complete operation list or second identity/foreground
stack is introduced. Render-limit overflow and configured capacity shortfall
are `.capacityExhausted`; malformed immutable plan data or aggregate mismatch
is `.invariantViolation`. All preflight failures occur before `begin` because
preflight has no sink.

## Test and Diagnostic Seams

Render-lowering tests preserve the complete SPEC-008 ordinary corpus through
the zero-operation visitor. Drawing tests use direct immutable views to inject
header, range, upper-bound, identity, summary, capacity, and lifecycle faults.
T5.2-T5.4 add paired visitor totals and exact sink transaction transcripts;
T5.5 audits source reuse, imports, and absence of retained operation storage.

## Rejected Implementation Alternatives

- A Canvas-owned semantic recursion is rejected because it could fork
  SPEC-008 identity, clip, text, and painter-order semantics.
- Collecting ordinary and stroke operations before emission is rejected because
  it adds a forbidden complete-frame operation list and retains payloads.
- Applying the surface intersection to the visitor clip is rejected because
  the plan stores the inherited logical clip and the backend applies the render
  surface independently.
- Sharing mutable preflight visitor state with streaming is rejected because
  production must repeat and compare the immutable traversal.

## Open Implementation Questions

T5.1 has no open implementation question. T5.2 exposed a contract-level
completion gap: the extended producer did not return control between its
preflight traversal and `begin`, while the preflight visitor had no completion
operation. The maintainer explicitly approved SPEC-012's exact completion-result
correction for both traversal phases on 2026-09-12. No implementation question
remains; T5.2-T5.5 may proceed through that contract.

## Code and Evidence Links

- [`RenderPreflight.swift`](../../Sources/GiftUIRenderLowering/RenderPreflight.swift)
- [`RenderExtensions.swift`](../../Sources/GiftUIRenderLowering/RenderExtensions.swift)
- [`CanvasRenderProducer.swift`](../../Sources/GiftUIDrawing/CanvasRenderProducer.swift)
- [Combined preflight evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-preflight.md)
- [Pre-begin summary blocker](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-prebegin-summary-blocker.md)
