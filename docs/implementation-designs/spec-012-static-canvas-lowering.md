---
spec: SPEC-012
feature: canvas-drawing
title: Implementation Design — Static Canvas Lowering
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-09-12
implementation_plan: ../implementation-plans/spec-012-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-007
  - SPIKE-008
supersedes: null
superseded_by: null
---

# Implementation Design — Static Canvas Lowering

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note records the source-generation boundary that turns statically known
Canvas expressions into stable nonzero callable IDs, fixed-layout captures,
and complete finite dispatch. It exists because capture packing, repeated
occurrence ownership, dispatch, and destruction span generator and runtime
owners and are not safely reconstructable from one generated switch.

The note does not select production application expressions, capacities,
observable handles, runtime-profile storage, host assembly, or raster behavior.
SPEC-013 owns production generated storage and dispatch integration; SPEC-015
owns production limits and host lifetime proof.

## Governing Contract

The realization follows SPEC-012's `Public Contract`, `Module Contract`,
`Types / APIs`, `Behavior`, `Resource Contract`, and DR-001, DR-010, DR-011,
and DR-012. It guides plan tasks T6.1-T6.5.

ADR-028 fixes callable timing and release, ADR-029 fixes scoped Path ownership,
ADR-030 fixes the normalized stroke meaning reached by dispatch, and ADR-031
requires fail-closed bounds before a cycle begins.

## Current-Code Context

`GiftUI` exposes the single closure-shaped Canvas source API and its narrow
non-returning invocation bridge. `GiftUIDrawing` owns
`StaticCanvasCallableTable` and `StaticCanvasLimits`. T6.1 adds a checked
profile-neutral generator fixture; it does not yet emit or install a production
static Canvas representation. SPEC-013 remains the owner of that profile seam.

## Proposed Internal Organization

Source analysis produces one ordered descriptor. Each expression record has a
stable source key and the exact ordered fields read by its closure. Each
runtime occurrence refers to that expression and owns a distinct capture-record
key plus exact field values.

The lowering step assigns dense IDs `1...N` in descriptor order. It computes
each capture record using checked size/alignment facts, emits one callable case
per expression, and emits occurrence records referencing the assigned ID.
The checked manifest is the review seam between source analysis and Swift
emission. T6.2 consumes it; it is evidence, not normative source authority.

## Data and Control Flow

```text
static source analysis
  -> ordered expression/capture descriptor
  -> checked ID and layout manifest
  -> generated capture records + union + complete switch
  -> profile-owned semantic payload
  -> synchronous Canvas invocation
  -> immediate capture destruction
```

Repeated occurrences share only the expression ID and switch case. They never
share the capture-record key or storage. The closure's `context` and `size`
parameters are invocation inputs, not captures.

## Algorithms and Data Structures

IDs are the one-based position in canonical expression order and therefore
cannot be zero. Source keys and anchors are unique. Record layout preserves
field order, aligns each field offset, and rounds record size to the greatest
field alignment. The capture union uses the maximum record size and alignment,
never the sum. Empty capture records have zero payload bytes and alignment one.

The manifest lists callable cases and switch coverage separately so validation
can reject missing, duplicate, or stray cases before code generation. It also
lists occurrence-to-expression mappings and capture-record identities so reuse
of a record by repeated occurrences is observable.

## Lifecycle and State

The descriptor and manifest are build inputs. A generated occurrence capture
is initialized during static semantic staging, borrowed by exactly one
invocation, and destroyed immediately afterward or during mandatory cycle
finalization. An ID or capture becomes invalid when its owning occurrence is
released; no generated record enters published semantic or frame storage.

## Runtime Profiles and Platforms

Only static profiles consume the generated table and inline records. Dynamic
profiles retain the approved bounded closure wrapper under SPEC-013. Both
reach the same `CanvasInvocationSource` behavior and scoped drawing machinery.
The generator and manifest checker run on the host; emitted Swift must later
compile under both the macOS static and nRF52840 Embedded Swift compilers.

## Resource and Failure Behavior

All counts are checked before conversion to `UInt16`. Capture sizes and aligned
offsets use checked arithmetic. Generation fails before linking for zero or
excess IDs, incomplete coverage, unsupported captures, over-limit records, or
an unlowered closure. There is no closure-retaining fallback. Production limit
comparison and allocator/symbol evidence remain T6.3-T6.5 work.

## Test and Diagnostic Seams

The T6.1 fixture has three expressions and four occurrences. Two occurrences
reuse one callable ID while owning different capture records and values. The
checker reconstructs the full manifest from the descriptor, verifies source
anchors, field layouts, nonzero complete switch coverage, and exact occurrence
ownership. Later tasks add generated Swift compilation, rejection fixtures,
destruction probes, and resource inspection without making diagnostics control
runtime behavior.

## Rejected Implementation Alternatives

- Hash-derived IDs are rejected because collision handling and tool-version
  stability add no value to a finite canonical input order.
- One ID per runtime occurrence is rejected because identity belongs to the
  syntactic expression; occurrence state belongs in distinct capture records.
- Summed capture storage is rejected because the contract requires a tagged
  maximum-sized union.
- A default switch case invoking a retained closure is rejected because
  coverage must be complete and production static images admit no fallback.

## Open Implementation Questions

The exact production source-analysis front end and emitted private type names
remain replaceable SPEC-013 integration details. If that owner cannot preserve
the checked descriptor semantics without changing public Canvas source, the
work returns to Specification review.

## Code and Evidence Links

- [Static Canvas source descriptor](../../Tests/ContractFixtures/SPEC012/static-canvas-input.yaml)
- [Checked static Canvas manifest](../../Tests/ContractFixtures/SPEC012/static-canvas-manifest.yaml)
- [Static Canvas manifest checker](../../scripts/contracts/check-spec-012-static-canvas-manifest.rb)
- [SPEC-012 contract fixtures](../../Tests/ContractFixtures/SPEC012/README.md)
