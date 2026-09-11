---
spec: SPEC-012
feature: canvas-drawing
title: Implementation Design — Scoped Path and Plan Storage
status: draft
authors:
  - codex
created: 2026-09-11
updated: 2026-09-11
implementation_plan: ../implementation-plans/spec-012-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
  - SPIKE-008
supersedes: null
superseded_by: null
---

# Implementation Design — Scoped Path and Plan Storage

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note records the internal ownership and lifecycle needed to implement the
noncopyable `GraphicsContext` and `Path` facade over caller-owned bounded
workspace, then seal immutable stroke snapshots into one drawing-attempt-local
plan. The scoped facade, atomic reservation, snapshot isolation, and reset
rules are coupled enough that recovering them independently in T1 and T3 would
risk incompatible implementations.

The note does not define dynamic closure storage, generated static callable
storage, semantic identity representation, run-cycle coordination, render
preflight, backend rasterization, or production capacities. Those remain owned
by SPEC-013, SPEC-009, SPEC-008, SPEC-014, and SPEC-015 as assigned by the
approved contract and plan.

## Governing Contract

This realization follows SPEC-012's `Public Contract`, `Module Contract`,
`Types / APIs`, `Normative Behavior`, `State / Lifecycle`, `Error Handling`,
and `Resource Contract`. It guides plan tasks T1.1-T1.4 and T3.1-T3.6 and
supports DR-001, DR-003, DR-004, DR-007, DR-009, DR-011, and DR-012.

The relevant accepted decisions are:

- ADR-028: Canvas drawing is derived after layout into cycle-local bounded
  storage and completes before semantic publication.
- ADR-029: Path mutation is scoped and transient; every stroke owns an
  immutable whole-path snapshot.
- ADR-030: each accepted stroke becomes one canonical normalized operation.
- ADR-031: drawing failures and startup validation remain bounded and compose
  with the existing execution and capability owners.

## Current-Code Context

`GiftUI` owns public declarations and SPEC-006's generic primitive traversal.
`Canvas` therefore retains its source callable privately and stages itself once
without invoking drawing or exposing a public/package callable lookup.
`GiftUIDrawing` is the focused owner of scoped construction, mutation,
snapshotting, and the plan. Runtime profiles supply the actual workspace and
callable storage; `GiftUIRenderCore` owns only the borrowed sink-facing stroke
view.

SPIKE-004 and SPIKE-008 provide feasibility evidence, not production source or
authority. Their useful observations are limited to fixed-capacity snapshot
accounting and compiler-supported noncopyable, typed-throws source shapes.

## Proposed Internal Organization

The public `GraphicsContext` and `Path` values are opaque, noncopyable scoped
facades. Their private representation carries only an attempt-local storage
reference, a scope generation, and the minimum current state needed to reject
stale use. Concrete arrays, callable storage, and plan storage stay outside
`GiftUI` in caller-owned `GiftUIDrawing` workspace.

The workspace separates three finite regions:

1. live-Path points and explicit subpath starts/ranges;
2. immutable plan point and subpath snapshots;
3. fixed stroke headers referring to their immutable snapshot ranges.

The facade-to-workspace bridge is replaceable and package-internal. The T1.2
candidate stores one workspace pointer, scope generations, and a fixed table
of noncapturing C-compatible functions. The table crosses only primitive
integers and maps one closed status byte back to the exact typed
`DrawingError`; public methods continue to expose only GiftUI values and typed
throws. Four-profile T1.5 and T3 resource checks must still demonstrate that
the representation preserves exclusivity and the static profile's direct-call
and zero-heap constraints. No storage reference, operation table, or callable
meaning becomes public or backend-visible.

## Data and Control Flow

One Canvas invocation acquires a fresh context scope. `withPath` reserves one
live Path scope and passes the active context and new Path as exclusive `inout`
parameters. Path mutation validates scope and state before committing a point
or subpath. Stroke validates style and current Path, preflights all plan
capacities, and only then copies the complete Path snapshot and appends one
header atomically.

After a successful stroke, later Path mutations affect only live storage;
earlier plan snapshots remain unchanged. Leaving `withPath` invalidates the
Path generation and releases its live ranges. Leaving the Canvas invocation
invalidates the context generation. Attempt completion seals the plan for
borrowed traversal; failure discards it. Cycle finalization resets every region
regardless of success, refusal, or failure.

## Algorithms and Data Structures

Live Path storage uses bounded contiguous point storage plus bounded subpath
metadata. A `move` starts an explicit subpath at the appended point. An
`addLine` requires a current point and appends within the current subpath.
Subpath ranges are finalized without inventing implicit connections.

Stroke reservation computes the complete additional point, subpath, stroke,
and normalized-operation demand with checked arithmetic. It validates all
limits before changing any plan cursor. Commit copies points and finalized
subpath ranges, then appends one stroke header. Cursor snapshots permit a
fail-closed rollback if an internal invariant fails during commit; ordinary
capacity failure occurs before copying and leaves every cursor unchanged.

Scope validity is a complete `(attemptGeneration, localGeneration, active)`
comparison rather than an address-only check. Generations never alias within
one workspace lifetime. Exhaustion is an invariant/configuration failure; it
does not silently wrap or revive an old facade.

## Lifecycle and State

The workspace has `idle`, `invoking`, `sealed`, and `discarded` attempt states.
A context is valid only in `invoking` with its exact generation. At most one
Path is active per context. A Path progresses through `empty`, `hasCurrent`,
and `invalidated`; repeated `move` begins another explicit subpath while
retaining earlier subpaths for the next whole-Path snapshot.

Sealing prevents further context or Path mutation and exposes only immutable
plan views. Discard and reset poison prior generations before reclaiming
logical counts so stale facades cannot observe reused storage.

## Runtime Profiles and Platforms

Dynamic and static profiles use the same facade operations, validation order,
snapshot semantics, and normalized plan. A dynamic profile may select a
bounded concrete workspace representation at runtime. A static profile uses
generated/fixed concrete storage and direct callable cases. Neither profile
may heap-allocate through the facade bridge or retain a callable, context,
Path, or plan beyond its specified lifetime.

The public `Canvas` closure storage introduced by T1.1 is only the portable
declaration surface. Profile-specific staging and release are T2.1/T4/T6 work;
this design does not add a package accessor to bypass that contract.

## Resource and Failure Behavior

All point, subpath, stroke, and operation counts are bounded independently.
Live Path and immutable plan capacity are not interchangeable. Snapshot cost
is linear in the submitted Path's points and subpaths and uses only
caller-owned storage. No retained collection, existential, reflection path, or
fallback allocation is permitted.

Validation follows SPEC-012's exact precedence: phase/reentrancy and scope
validity guard mutation, value/path validation precedes snapshotting, checked
arithmetic precedes capacity comparison, and complete capacity validation
precedes commit. Cleanup never replaces the first `DrawingError`.

## Test and Diagnostic Seams

Unit fixtures use small concrete workspaces to exercise equality and
first-excess boundaries, multiple subpaths, zero-length segments,
stroke-mutate-stroke isolation, and normal/throwing invalidation. Poison probes
attempt use after `withPath`, invocation, seal, discard, and reset. Fault
injection at each reservation/commit boundary verifies unchanged cursors and
first-error preservation.

Compile fixtures remain the authority for forbidden construction, copying,
consumption, escaping, asynchronous escape, overlapping outer-context access,
and non-typed throws. Resource reports separately record live Path, plan,
facade, stack, linked RAM/flash, and allocator-symbol evidence.

## Rejected Implementation Alternatives

- Storing points inside the public facade is rejected because workspace and
  capacity ownership belongs to `GiftUIDrawing` and runtime profiles.
- Copyable or retained Path values are rejected because they break scoped
  exclusivity and stale-use invalidation.
- Incremental snapshot append before complete reservation is rejected because
  failure must leave the plan unchanged.
- Reusing live Path ranges as plan storage is rejected because later mutation
  must not alter an earlier stroke.
- A public/package Canvas callable lookup is rejected by the exact primitive
  staging contract.
- Throwing `@convention(thin)` operation references are rejected because the
  pinned host compiler reports nontrivial thin function references as an
  unimplemented feature when the maintained test target forms the table.

## Open Implementation Questions

The primitive-status C-compatible bridge compiles and preserves the scoped
behavior in the pinned host debug build. T1.5 must still prove its emitted
interfaces, SIL, symbols, and Embedded Swift compatibility, and T3 must prove
the concrete workspace binding. Any allocator, existential, reflection,
Objective-C runtime, or forbidden static callable-dispatch artifact is an
upstream contract/architecture blocker, not permission to widen the API or
weaken a profile.

## Code and Evidence Links

- [`Canvas.swift`](../../Sources/GiftUI/Canvas.swift)
- [`DrawingSurface.swift`](../../Sources/GiftUI/DrawingSurface.swift)
- [`DrawingStyles.swift`](../../Sources/GiftUI/DrawingStyles.swift)
- [`GiftUIDrawing.swift`](../../Sources/GiftUIDrawing/GiftUIDrawing.swift)
- [SPEC-012 contract fixtures](../../Tests/ContractFixtures/SPEC012/README.md)
