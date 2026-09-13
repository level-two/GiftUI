---
spec: SPEC-014
feature: giftui-mvp-architecture
title: Implementation Design — Operation-Major RGB565 Tiling
status: current
authors:
  - codex
created: 2026-09-13
updated: 2026-09-13
implementation_plan: ../implementation-plans/spec-014-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-001
supersedes: null
superseded_by: null
---

# Implementation Design — Operation-Major RGB565 Tiling

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note selects the internal workspace and traversal for SPEC-014 T6.1-T6.6.
It explains how one borrowed operation is completed across bounded full-width
row tiles, converted into owned horizontal runs, and submitted through one
reusable display slot before the operation call returns.

It does not change the normalized operation stream, display grammar,
capability values, region sizes, failure mapping, or platform configuration.

## Governing Contract

- [SPEC-014 Backend Requirements](../specs/spec-014-backend-integration.md#backend-requirements)
- [SPEC-014 Offer, reservation, and consumption](../specs/spec-014-backend-integration.md#offer-reservation-and-consumption)
- [SPEC-014 BI-003, BI-006, BI-007, BI-009, and BI-014](../specs/spec-014-backend-integration.md#acceptance-criteria)
- [ADR-010 synchronous one-shot handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [SPEC-014 plan T6.1-T6.6](../implementation-plans/spec-014-implementation-plan.md#milestone-6-implement-operation-major-bounded-rgb565-tiled-realization)

## Current-Code Context

Raster Core owns exact fill, glyph, and stroke coverage callbacks plus checked
work limits. Display Core owns a reusable reserved payload writer. Backend
Integration owns the only legal join. Full-surface realizations provide the
zero-tolerance comparison oracle but cannot be present on nRF52840.

## Proposed Internal Organization

Raster Core owns a generic `RGB565TileWorkspace` over caller-owned fixed
storage. The storage protocol provides bounded byte and affected-bit access;
production code owns no Array, pointer, or full-frame buffer.

Backend Integration owns an operation-major tile traversal and the sink that
combines that workspace with one display reservation. The traversal never
owns or invokes the producer. A single sink operation call supplies the
borrowed fill/glyph/stroke and synchronously visits all relevant tiles.

## Data and Control Flow

For one operation call:

1. Intersect its resolved clip with frame damage and surface bounds.
2. Walk intersecting row tiles from top to bottom; the last may be partial.
3. Reset the one workspace to poison-free zero bytes and no affected bits.
4. Invoke the shared rasterizer with that tile's damage rectangle.
5. Scan affected bits row-major and form longest contiguous horizontal runs.
6. Copy run bytes into the reserved writer, flushing before the next run would
   exceed byte or region capacity.
7. Submit each finished payload synchronously, clear the reusable slot, and
   continue until this operation has no remaining tile.
8. Return from the borrowed operation call only after all owned submission or
   validation-only drain work completes.

The producer body is invoked once by the endpoint, never by tile traversal.

## Algorithms and Data Structures

The workspace capacity is exactly `bytesPerRow * regionHeight`; affected bits
are separately bounded to `surfaceWidth * regionHeight`. A tile always spans
the complete surface width. Coverage may be restricted by damage and clip, but
storage geometry never changes between operations.

Run formation scans left to right and emits maximal contiguous affected pixels
within one row. Runs never contain stride padding. Payload bytes and region
records are deterministically cleared on writer reuse. A payload flush occurs
before adding a run that would exceed either selected capacity; one run larger
than the slot is a construction invariant because startup already admitted
the full region width.

## Lifecycle and State

The workspace is idle outside an operation tile. `beginTile` clears prior
bytes/bits; `replacePixel` accepts only the active tile and RGB565 encoding;
`finishTile` exposes a synchronous borrow to run formation; reset poisons and
returns idle. Neither operation nor workspace address survives its call.

The sink becomes draining after the first post-transfer failure. It then
continues grammar and resource validation without writer or physical work,
finishes the reserved frame once, and preserves the first local failure.

## Runtime Profiles and Platforms

Raspberry Pi uses 240 x 16 row tiles. nRF52840 uses 480 x 4 row tiles, exactly
3,840 raster bytes. Dynamic/static host tests use smaller identical logical
fixtures. The same Raster Core coverage functions and run ordering compile in
all four profiles.

## Resource and Failure Behavior

All counters use checked integers and are bounded independently: tile visits,
pixels visited, region submissions, payloads, payload bytes, raster bytes,
glyph bytes, stroke workspace, and in-flight bytes. Before transfer, failure
stops and remains cancellable. After transfer, failure disables output but not
validation/borrow consumption. No fallback, replay, heap allocation, or hidden
complete-frame buffer is permitted in the static path.

## Test and Diagnostic Seams

- record tile order, partial final tile, workspace reset, and producer count;
- compare runs and exact bytes with the full-surface oracle under varied slot
  segmentation;
- poison operation/resource/workspace storage immediately after each borrow;
- inspect addresses, symbols, sections, allocation, stack, and exact Pi/nRF
  high-water values;
- inject writer, first/later submit, and frame-end failure around transfer.

## Rejected Implementation Alternatives

Producer-per-tile replay is rejected because it repeats client-derived work
and violates one-shot delivery. Retaining normalized operations for later
tiles is rejected by the borrow contract. A complete RGB565 frame buffer on
nRF52840 is rejected by the selected capability and storage bound. Tile-major
reordering is rejected because later operations must replace earlier ones.

## Open Implementation Questions

None. Run coalescing is deliberately maximal within a row; future measured
transport-specific coalescing would require equivalent output and bounds.

## Code and Evidence Links

T6.1 is implemented by
[`RGB565TileWorkspace.swift`](../../Sources/GiftUIRasterCore/RGB565TileWorkspace.swift)
and
[`OperationMajorTileTraversal.swift`](../../Sources/GiftUIBackendIntegration/OperationMajorTileTraversal.swift),
with focused coverage in
[`OperationMajorTileTraversalTests.swift`](../../Tests/GiftUIBackendIntegrationTests/OperationMajorTileTraversalTests.swift)
and frozen evidence in
[`operation-major-tile-workspace.md`](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/operation-major-tile-workspace.md).
T6.2 adds
[`RGB565TilePayloadEmitter.swift`](../../Sources/GiftUIBackendIntegration/RGB565TilePayloadEmitter.swift),
[`RGB565TilePayloadEmitterTests.swift`](../../Tests/GiftUIBackendIntegrationTests/RGB565TilePayloadEmitterTests.swift),
and
[`tile-run-payloads.md`](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/tile-run-payloads.md).
T6.3's corpus and full-surface comparisons are recorded in
[`tiled-raster-equivalence.md`](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/tiled-raster-equivalence.md).
Later T6.4-T6.6 links will be added with those tasks. Full-surface comparison
evidence is in
[`full-surface-comparison.md`](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-5/full-surface-comparison.md).
