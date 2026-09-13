---
spec: SPEC-014
feature: giftui-mvp-architecture
title: Implementation Design — Widened-Integer Stroke Raster
status: current
authors:
  - codex
created: 2026-09-13
updated: 2026-09-13
implementation_plan: ../implementation-plans/spec-014-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Widened-Integer Stroke Raster

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note fixes the internal calculation model for SPEC-014 `T4.4` and the
stroke portions of `T4.5`, `T4.6`, `T5.4`, `T6.3`, and `T6.4`. It explains how
Raster Core consumes one borrowed `StraightLineStrokeView`, tests binary
pixel-center coverage without floating point, and emits backend-owned encoded
pixels before the borrow ends.

It does not change SPEC-012 stroke meaning, add a retained operation, select a
surface or tile implementation, or make generated masks authoritative. The
independent golden vectors and oracle remain owned by SPEC-012 `T8.1` and
`T8.2`; those evidence tasks are currently pending.

## Governing Contract

- [SPEC-014 Backend Requirements and Encoding](../specs/spec-014-backend-integration.md#backend-requirements)
- [SPEC-014 BI-009 and BI-014](../specs/spec-014-backend-integration.md#acceptance-criteria)
- [SPEC-012 canonical stroke coverage](../specs/spec-012-canvas-path-stroke-drawing.md#backend-requirements)
- [ADR-009 checked integer geometry](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-010 synchronous one-shot handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-030 normalized straight-line stroke](../adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md)
- [SPEC-014 plan `T4.4`](../implementation-plans/spec-014-implementation-plan.md#milestone-4-implement-canonical-encoding-and-shared-raster-semantics)

## Current-Code Context

`GiftUIRenderCore` owns the header, ordered point/subpath accessors, and
nonescaping borrowed operation. `GiftUIRasterCore` already owns canonical
encoding plus checked surface/damage/clip intersection. Surface and display
owners accept only encoded values or horizontal regions and therefore do not
participate in stroke geometry.

SPEC-012's `raster-vectors.yaml` is still an empty fail-closed corpus. The
implementation can be built from the approved equations, but `T4.4` and
BI-009 cannot be closed until the upstream independent vectors and oracle are
frozen.

## Proposed Internal Organization

Raster Core owns a stateless `RasterStrokeCoverage` entry point and small
private widened-coordinate helpers. The entry point takes the borrowed view,
descriptor, damage, and a nonescaping replacement callback. It retains no
point, subpath, callback, address, or encoded output after return.

No intermediate point array, segment array, polygon, display list, or full
surface is allocated. A concrete full-surface or tiled sink supplies the
replacement callback and owns any resulting encoded storage.

## Data and Control Flow

1. Read and validate the exact header and every declared point/subpath before
   the first replacement callback.
2. Require contiguous, ordered, nonempty subpath ranges covering exactly the
   declared point count; duplicate points remain points, never boundaries.
3. Intersect inherited clip, damage, and surface bounds. Canvas bounds are not
   an input. Empty intersection succeeds without pixel callbacks.
4. Visit candidate pixel centers in deterministic row-major order.
5. For each center, scan subpaths and their nonzero segments. Stop at the first
   segment body, endpoint cap, or join region containing the center.
6. Encode the header color once and call replacement at most once for that
   pixel. The call occurs while the stroke borrow is active.
7. Return checked pixel/work counts or the first local failure.

## Algorithms and Data Structures

Coordinates are doubled so an integer pixel `(x, y)` has center
`(2*x + 1, 2*y + 1)`, a path point has coordinate `(2*x, 2*y)`, and the
stroke radius is the integer line width. Conversion and every product use
signed 128-bit arithmetic; this admits the complete Int32 coordinate domain
without wrap.

For a nonzero segment `A -> B`, with `D = B - A` and `V = C - A`, the closed
segment body contains center `C` exactly when:

```text
0 <= dot(V, D) <= dot(D, D)
cross(V, D)^2 <= width^2 * dot(D, D)
```

Round caps and joins use the closed doubled-coordinate disk
`distanceSquared(C, vertex) <= width^2`. Butt caps add no region. Zero-length
segments supply neither body, tangent, cap, nor join; the first and last
nonzero segment determine each open subpath's cap endpoints.

For a turn between adjacent nonzero segments, the implementation classifies
the exterior side from the exact cross-product sign. Round joins use the disk.
Miter joins use the intersection of the two exterior offset half-planes. All
half-plane comparisons are expressed by signed cross products and squared
length products, so no normalized vector or square root is materialized. The
miter-limit decision compares the squared intersection distance with
`100 * width^2`; an over-limit intersection selects the closed bevel wedge as
required by SPEC-012. Collinear same-direction and exact reversal pairs add no
join region. Boundary equality is always inside.

The initial implementation deliberately scans the already bounded clipped
surface region rather than deriving a stroke bounding box. This avoids
overflow-prone expansion at extreme coordinates and uses SPEC-014's existing
operation-by-damaged-pixel work ceiling. It is replaceable by a proven tighter
bound without changing pixels or call order.

## Lifecycle and State

The rasterizer is stateless between calls. All validation completes before
output. Once replacement begins, the caller owns normal SPEC-014 surface and
responsibility behavior; a callback refusal stops at the first refused pixel
and becomes the caller's sticky raster failure. No reset method or retained
stroke state exists.

## Runtime Profiles and Platforms

Dynamic, static, ARMv6, and nRF52840 profiles compile the same algorithm and
produce identical logical masks. Profile-specific sinks differ only in where
the replacement callback stores or submits encoded pixels. Signed 128-bit
operations must be verified under every pinned compiler and accounted as
linked-code/stack cost before conformance.

## Resource and Failure Behavior

The algorithm allocates zero heap bytes. Live state is a fixed set of widened
scalars, counters, and borrowed values. Work is bounded by checked damaged
pixels multiplied by declared points/subpaths; `T4.5` records the exact
high-water counters. Invalid ranges or missing accessors are malformed stream,
checked conversion/product failure is arithmetic overflow, and callback
refusal is rasterization failure. The first result is returned without
fallback, saturation, tolerance, antialiasing, or partial style substitution.

## Test and Diagnostic Seams

- recording stroke views count every header/point/subpath access and poison
  their backing storage immediately after return;
- focused vectors cover segment bodies, degenerate points, caps, joins,
  collinearity, reversal, clipping, negative geometry, painter replacement,
  and admitted extremes;
- the same callback transcript feeds full-surface and tiled comparison;
- source and address audits reject `Double`, `Float`, dynamic collections,
  retained pointers/views, and `GiftUIDrawing` imports;
- SPEC-012's independent oracle, once frozen, is compared byte-for-byte rather
  than regenerated from this implementation.

## Rejected Implementation Alternatives

Floating-point scan conversion is rejected because tolerance and platform
rounding cannot prove boundary inclusion. Materialized segment polygons are
rejected because they add workspace and square-root normalization without an
MVP benefit. Replaying the producer per tile and retaining the stroke for later
tiles are rejected by the one-shot ownership contract.

## Open Implementation Questions

There is no open internal semantic choice. SPEC-012 `T8.1` and `T8.2` remain an
upstream evidence blocker: their empty vector corpus cannot validate every
required mask independently. SPEC-014 must not mark `T4.4`, BI-009, or final
conformance complete until that evidence lands.

## Code and Evidence Links

Production and focused-test links will be added when the implementation lands.
The current upstream placeholder is
[`raster-vectors.yaml`](../../Tests/ContractFixtures/SPEC012/raster-vectors.yaml).
