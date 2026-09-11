---
spec: SPEC-007
feature: giftui-mvp-architecture
title: Implementation Design — Bounded Layout Attempt
status: current
authors:
  - codex
created: 2026-09-11
updated: 2026-09-11
implementation_plan: ../implementation-plans/spec-007-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Bounded Layout Attempt

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the caller-owned workspace, generic layout entry, two-phase
scope storage, and atomic sink lifecycle used by `GiftUILayout`. It covers the
internal seams needed by plan tasks `T3.2` through `T3.4` and the storage later
consumed by non-text and text layout tasks.

It does not define Semantic Core storage, runtime host capacities, public
declarations, layout algorithms, canonical text rules, render operations, or
failure-fact mapping. Those meanings remain with SPEC-006, SPEC-007, SPEC-005,
SPEC-008, and SPEC-003 respectively.

## Governing Contract

The realization follows SPEC-007's `Module Contract`, `Types / APIs`,
`Behavior`, `State / Lifecycle`, `Error Handling`, and `Performance
Requirements` sections and acceptance criteria `LY-002`, `LY-003`, `LY-004`,
`LY-005`, and `LY-006`.

The relevant accepted decisions are:

- ADR-005 keeps measurement and placement above the render boundary.
- ADR-006 permits profile-private storage while requiring equal meaning.
- ADR-008 fixes the one-package target boundary and dependency direction.
- ADR-009 requires checked integer geometry and deterministic failure.
- ADR-021 makes layout the sole canonical text-geometry authority.
- ADR-023 requires the exact shared font-resource identities.
- ADR-032 requires a synchronous Semantic Core borrow without a second graph.

## Current-Code Context

`GiftUISemanticCore` exposes the package-only `SemanticLayoutView` and closed
layout payload vocabulary. `GiftUITextResources` exposes the validated
`CanonicalTextMetricsView`. `GiftUILayout` already owns the exact limits,
summary, result, and error values, while the fixture owner adapter maps closed
layout errors only after layout returns.

The producer operates over direct recording views and
`SemanticLayoutResultSink`, which exposes its one profile-owned successful
SPEC-006 result storage directly as `SemanticLayoutView`. It does not make
either producer's identity representation part of layout storage.

## Proposed Internal Organization

`LayoutResultSink` is the exact package protocol from SPEC-007. Its associated
identity is constrained to the semantic view's identity at the generic entry.

`LayoutWorkspace` is a package-only collaborator implemented by each fixture
or runtime profile. It reports all five finite capacities while idle, exposes
an active flag and explicit acquire/reset operations, and provides bounded
operations for:

- an identity-indexed scope slot holding measured and placed geometry;
- a depth stack holding exact identities during traversal;
- sequential decoded-scalar, text-line, and positioned-glyph slots.

The protocol passes identities through generic parameters and equality checks;
it never requests a hash, numeric conversion, byte representation, or copied
semantic node. Scope lookup is a bounded linear scan in the recording and
small static fixtures. A later profile may choose another bounded lookup whose
construction and storage remain outside the layout call.

`LayoutAttempt` is a private fixed-width coordinator. It snapshots limits and
the workspace's reported capacities, records which collaborators this attempt
acquired, maintains checked global counters and the first failure, and owns
all cleanup decisions. Measurement and placement helpers receive this
coordinator plus the borrowed views and never publish directly.

## Data and Control Flow

The sole package `layout` entry performs these phases:

1. Check the workspace and sink active states before reading either borrowed
   view, the proposal, or the limits.
2. Snapshot all five workspace capacities and compare them with the immutable
   limits before acquisition.
3. Acquire the workspace and validate semantic shape, declarations, counts,
   and canonical text lookups while measuring bottom-up into scope and text
   slots.
4. Require declared and observed counts to agree, derive the complete summary,
   and ask the idle sink to begin once.
5. Place top-down from the root and stage scopes, lines, and glyphs in the
   contract's canonical depth-first order.
6. Publish once, reset the workspace, and return success. Any post-begin
   refusal discards the sink exactly once before resetting the workspace.

The semantic and metrics arguments remain borrowed for the whole synchronous
call. Workspace slots copy only exact identity values and derived layout/text
values. Reset invalidates every occupied slot before the call returns, so no
identity or borrowed source survives in the workspace.

## Algorithms and Data Structures

### Scope slots

One scope slot is reserved before the first measurement access for that scope.
It contains the opaque identity, primitive or modifier kind needed for the
second phase, ideal and resolved sizes, and final bounds and clip. Modifier
scopes and primitive scopes use the same slot sequence. Transparent semantic
structure never receives a slot. A second reservation for an equal identity
is an invariant violation rather than an overwrite.

Identity-indexed lookup uses equality over occupied slots. Because each scope
is inserted once and measurement/placement helpers retain the slot ordinal on
their bounded traversal stack, ordinary execution does not rescan ancestors.
Fixture lookup probes may still request an identity directly to prove exact
identity preservation.

### Text slots

Decoded scalars, line records, and positioned-glyph records occupy separate
sequential stores governed by their corresponding global limits. Scope slots
hold only start/count ranges into those stores. Reservations happen before the
semantic or metrics lookup that the contract says must not occur one over a
limit. Break scalars occupy scalar slots but no glyph slot.

### Checked counters and depth

All counts and depth use `UInt16.addingReportingOverflow`. A prospective value
is compared with the immutable limit and capacity snapshot before it becomes
current. Equality at the limit succeeds. The traversal stack is the sole
source of observed depth; the first layout scope below the semantic root is
depth one.

## Lifecycle and State

Workspace state is either idle or acquired. Sink state is queried separately
so workspace-active, sink-active, and both-active reentry are distinguishable
before any input inspection. An acquisition failure changes no caller state.

Pre-begin failure clears only workspace slots reserved by this attempt and
resets the workspace. `begin == false` resets the workspace without calling
`discard`. Once begin succeeds, every stage or publish refusal calls
`discard` exactly once and then resets the workspace. Success publishes once
and resets without discard. The first local error is sticky across cleanup.

## Runtime Profiles and Platforms

Recording and macOS dynamic fixtures may allocate bounded backing arrays
during host assembly, before calling layout. Static fixtures use generated or
fixed-capacity value storage. The generic producer, counter widths, reservation
order, identity equality, geometry, staging order, results, and errors remain
identical across macOS dynamic/static, Raspberry Pi ARMv6, and nRF52840.

No workspace implementation may branch on a backend, capability, driver,
platform, OS/RTOS, HAL, or hardware identity. Cross-profile evidence compares
canonical identity relations and output tokens, never private identity bytes
or slot layout.

## Resource and Failure Behavior

The producer allocates no storage and grows no collection. Every store
operation is admitted against both the call limit and the pre-acquisition
capacity snapshot. Workspace rejection within advertised capacity is an
invariant violation. Checked geometry overflow remains
`.arithmeticOverflow`; malformed declarations remain `.invalidDeclaration`.

Traversal and staging are linear in admitted scopes plus text work. The
profile workspace must report byte count and its traversal stack high-water in
the contract fixtures; these observations do not affect semantic control.

## Test and Diagnostic Seams

Focused test workspaces expose attempted operations, capacity snapshots,
occupied-slot counts, depth high-water, acquire/reset counts, and optional
refusals. Test sinks separately expose begin, stage, publish, and discard
events. Poisoned semantic and metrics views count accessor calls so tests can
prove reentry and pre-reservation failures precede prohibited inspection.

Golden tests use symbolic identities and compare equality relations, ordered
events, geometry, counts, and failures. The failure adapter remains a separate
target and receives only the returned `LayoutError`; diagnostics never enter
the layout producer or influence cleanup.

## Rejected Implementation Alternatives

- A layout-owned copied semantic graph is rejected because ADR-032 requires a
  borrowed Semantic Core view and no second complete representation.
- Hashing or numbering semantic identities is rejected because the sink must
  receive the exact identity and profiles may use different representations.
- Publishing during measurement is rejected because the contract requires a
  complete summary before begin and atomic depth-first staging afterward.
- Profile-specific layout algorithms are rejected because ADR-006 permits
  storage variation, not semantic variation.

## Open Implementation Questions

None blocks `T3.2` through `T3.4`. Exact host capacities and concrete static
slot layouts remain profile assembly choices and will be recorded by the
required resource evidence rather than standardized by this note.

## Code and Evidence Links

- [SPEC-007 Implementation Plan](../implementation-plans/spec-007-implementation-plan.md)
- [SPEC-007](../specs/spec-007-layout.md)
- `Sources/GiftUILayout/`
- `Tests/GiftUILayoutTests/`
- `Tests/ContractFixtures/SPEC007/`
