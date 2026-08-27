---
id: SPEC-012
feature: canvas-drawing
title: Canvas, Path, and Stroke Drawing Contract
status: draft
authors:
  - codex
created: 2026-08-26
updated: 2026-08-27
proposal:
  - PROPOSAL-006
related_rfcs:
  - RFC-009
related_adrs:
  - ADR-028
  - ADR-029
  - ADR-030
  - ADR-031
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-004
  - SPEC-006
  - SPEC-007
  - SPEC-008
  - SPEC-009
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
  - SPIKE-007
  - SPIKE-008
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-012: Canvas, Path, and Stroke Drawing Contract

> **Draft status:** This revision corrects the source-composition and Embedded
> error-model failures found by SPIKE-008. The corrected declarations still
> require tracked cross-profile evidence and resolution of the remaining Open
> Issues before review. This contract remains non-authoritative until explicit
> maintainer approval.

## Summary

This Specification defines the MVP custom-drawing contract: a laid-out
`Canvas`, synchronous scoped graphics context, uniquely owned transient
straight-line `Path`, immutable stroke snapshots, cycle-local plans, canonical
normalized stroke operations, producer capacity validation, and whole-plan
failure before frame offer.

## Scope

The contract is limited to the Signal Analyzer grid and four digital traces:
opaque RGB strokes, integer geometry, `move(to:)`, `addLine(to:)`, positive
line width, butt/round caps, miter/round joins, inherited clipping, painter
order, and dynamic/static profile equivalence.

## Goals

- Invoke each Canvas closure once after layout with its exact resolved size.
- Make live Path aliasing and escape unavailable in the supported source form.
- Snapshot every stroke and lower complete canonical semantics before backend
  consumption.
- Detect all client/producer failures before the one-shot frame offer.
- Validate structural capacity independently of SPEC-004 capability support.

## Non-goals

Fills, curves, closed paths, images, text in Canvas, transforms, client clips,
alpha, gradients, effects, animation, retained/replayable paths or plans,
asynchronous drawing, floating-point geometry, or backend raster algorithms.

## Dependencies

SPEC-002 owns checked geometry; SPEC-003 outcomes; SPEC-004 the existing
`rasterPresentation` capability; SPEC-006 semantic identity; SPEC-007 Canvas
bounds; SPEC-008 operation order/color/clip transport; and SPEC-009 freeze,
publication, one-shot offer, refusal, and dirty rederivation.

## Related ADRs

- ADR-028 requires post-layout, at-most-once synchronous closure invocation
  and cycle-local plan lifetime.
- ADR-029 requires uniquely owned scoped Path mutation and immutable snapshot
  behavior at stroke submission.
- ADR-030 fixes the complete backend-neutral straight-line stroke meaning,
  local-to-surface translation, inherited clipping, order, and synchronous
  borrowed consumption.
- ADR-031 requires complete pre-offer validation and independent structural
  B2 and semantic capability startup gates.

## Terminology

**Canvas invocation** is one synchronous closure call for one resolved Canvas
occurrence in one derivation attempt. **Path snapshot** is immutable ordered
points and explicit subpath ranges captured at one stroke call. **Drawing plan**
is the finite cycle-local ordered set of snapshots. **Inherited clip** is the
SPEC-008 logical clip; Canvas bounds add no implicit clip.

## Public Contract

```swift
public struct Canvas: View {
    public init(
        _ draw: @escaping (
            inout GraphicsContext,
            Size
        ) throws(DrawingError) -> Void
    )
}

public struct GraphicsContext: ~Copyable {
    public mutating func withPath<Result>(
        _ body: (
            inout GraphicsContext,
            inout Path
        ) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result
    public mutating func stroke(
        _ path: borrowing Path,
        with shading: Shading,
        lineWidth: GeometryScalar
    ) throws(DrawingError)
    public mutating func stroke(
        _ path: borrowing Path,
        with shading: Shading,
        style: StrokeStyle
    ) throws(DrawingError)
}

public struct Path: ~Copyable {
    public mutating func move(to point: Point) throws(DrawingError)
    public mutating func addLine(to point: Point) throws(DrawingError)
}

public struct Shading: Equatable, Sendable {
    public static func color(_ color: Color) -> Shading
}

public struct StrokeStyle: Equatable, Sendable {
    public let lineWidth: GeometryScalar
    public let lineCap: LineCap
    public let lineJoin: LineJoin
    public init(
        lineWidth: GeometryScalar = 1,
        lineCap: LineCap = .butt,
        lineJoin: LineJoin = .miter
    )
}

public enum LineCap: UInt8, Equatable, Sendable {
    case butt = 0
    case round = 1
}

public enum LineJoin: UInt8, Equatable, Sendable {
    case miter = 0
    case round = 1
}

public enum DrawingError: Error, Equatable, Sendable {
    case invalidValue
    case invalidPathState
    case arithmeticOverflow
    case capacityExhausted
    case invalidScope
    case invalidPhase
    case reentrancyViolation
    case invariantViolation
}
```

`GraphicsContext` is supplied only by Canvas. `Path` is supplied only to the
nonescaping `withPath` body and is noncopyable. Neither has a public
initializer. Their borrows MUST NOT escape, cross an asynchronous boundary, or
survive the Canvas invocation. Every closure is synchronous and non-suspending.

`withPath` passes its active `GraphicsContext` and one new `Path` as the
body's two exclusive `inout` parameters. Client source MUST perform stroke
submission through that supplied context parameter; it MUST NOT capture or
access the outer context while `withPath` is active. This shape permits stroke
submission followed by further mutation and another submission of the same
scoped Path without overlapping access to the outer context.

Every public throwing declaration uses typed `throws(DrawingError)`. A Canvas
or `withPath` body therefore cannot introduce an arbitrary `any Error` value.
Portable trailing-closure source MUST state `throws(DrawingError)` explicitly
where the supported compiler does not infer the typed thrown value.

The following is the normative supported composition shape:

```swift
Canvas { (context, size) throws(DrawingError) in
    let shading = Shading.color(Color(red: 255, green: 255, blue: 255))
    try context.withPath { (context, path) throws(DrawingError) in
        try path.move(to: Point(x: 0, y: 0))
        try path.addLine(to: Point(x: size.width, y: size.height))
        try context.stroke(path, with: shading, lineWidth: 2)

        try path.addLine(to: Point(x: size.width, y: 0))
        try context.stroke(path, with: shading, lineWidth: 2)
    }
}
```

The public `Canvas` initializer remains one portable closure-based source
surface. A dynamic profile MAY retain that closure in a bounded profile-owned
wrapper until post-layout invocation. A static profile MUST instead lower each
statically known Canvas body to a generated finite callable with bounded typed
captures before persistent semantic retention; it MUST NOT retain the captured
escaping closure directly. The generated callable MUST preserve the exact
scoped `inout GraphicsContext`, `Size`, typed `throws(DrawingError)`,
ordering, and release semantics specified here without existential storage or
heap allocation.

`StrokeStyle` construction with nonpositive width creates an invalid style
marker; the next stroke throws `.invalidValue` before snapshotting. The
line-width overload is exactly the style overload using `.butt` and `.miter`.
`Shading.color` preserves the exact SPEC-008 opaque RGB value.

## Module Contract

`GiftUI` owns public declarations and typed Canvas semantic payload.
`GiftUIDrawing` owns scoped construction, plan storage contracts, validation,
normalized stroke payload, lowering, and recording fixtures. It imports
`GiftUI`, `GiftUISemanticCore`, `GiftUILayout`, `GiftUIRenderCore`, and
`GiftUIExecution`; it MUST NOT import a runtime profile, failure owner,
capability implementation, backend, rasterizer, platform, driver, OS/RTOS,
HAL, or hardware target.

Runtime profiles supply concrete workspace. Backends consume the added
`GiftUIRenderCore` operation and never import `GiftUIDrawing`. The owner adapter
maps local errors to SPEC-003.

## Types / APIs

```swift
package struct DrawingLimits: Equatable, Sendable {
    package let maximumCanvasOccurrences: UInt16
    package let maximumLivePathPoints: UInt16
    package let maximumLivePathSubpaths: UInt16
    package let maximumPlanStrokes: UInt16
    package let maximumPlanPoints: UInt16
    package let maximumPlanSubpaths: UInt16
    package let maximumNormalizedStrokeOperations: UInt16
    package init?(maximumCanvasOccurrences: UInt16,
                  maximumLivePathPoints: UInt16,
                  maximumLivePathSubpaths: UInt16,
                  maximumPlanStrokes: UInt16,
                  maximumPlanPoints: UInt16,
                  maximumPlanSubpaths: UInt16,
                  maximumNormalizedStrokeOperations: UInt16)
}

package struct SubpathRange: Equatable, Sendable {
    package let firstPoint: UInt16
    package let pointCount: UInt16
    package init?(firstPoint: UInt16, pointCount: UInt16)
}

package struct StraightLineStrokeHeader: Equatable, Sendable {
    package let color: Color
    package let lineWidth: GeometryScalar
    package let lineCap: LineCap
    package let lineJoin: LineJoin
    package let surfaceOrigin: Point
    package let inheritedClip: Rect
    package let pointCount: UInt16
    package let subpathCount: UInt16
}

package protocol StraightLineStrokeView {
    var header: StraightLineStrokeHeader { get }
    func point(at index: UInt16) -> Point?
    func subpath(at index: UInt16) -> SubpathRange?
}

package protocol DrawingOperationSink: RenderOperationSink {
    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool
}

package enum DrawingProductionError: UInt8, Equatable, Sendable {
    case invalidValue = 0
    case invalidPathState = 1
    case arithmeticOverflow = 2
    case capacityExhausted = 3
    case invalidScope = 4
    case invalidPhase = 5
    case reentrancyViolation = 6
    case operationCapacityExhausted = 7
    case sinkRefused = 8
    case invariantViolation = 9
}
```

All limits MUST be nonzero. Counts and indices are exact `UInt16` values; a
count equal to its limit succeeds. `SubpathRange` requires `pointCount > 0` and
checked representability of its exclusive end. Production host values are
downstream configuration; this contract's fixtures inject artificial limits.

The SPEC-008 operation count includes each straight-line stroke as exactly one
operation. `DrawingOperationSink` extends, rather than replaces, SPEC-008's
ordered stream protocol. A borrowed stroke view is valid only during the call.

## Behavior

### Invocation and path construction

Canvas is a semantic leaf with ordinary SPEC-007 measurement and placement.
After state freeze and complete layout, drawing visits Canvas occurrences in
resolved render order and calls each closure at most once with its exact local
`Size`. A closure is not called during semantic expansion, measurement,
backend offer, retry, or capability resolution.

Each `withPath` supplies the body with the same active context on which
`withPath` was invoked and a new Path with no current point and no subpath.
`move(to:)` starts a new open subpath and makes the point current. Consecutive
moves preserve only the latest one-point subpath as a valid explicit subpath.
`addLine(to:)` without a current point throws `.invalidPathState` and changes
nothing. Zero-length segments are preserved; a one-point or empty subpath
contributes no raster segment but remains an explicit boundary for
deterministic snapshots.

Every successful mutating call is atomic. Capacity exhaustion appends no point
or boundary and preserves the prior path. `withPath` resets and releases all
live construction storage on normal or throwing exit.

### Stroke snapshot and plan

`stroke` validates style and path state, then reserves one record and all point
and subpath storage before copying or uniquely transferring anything. A path
with no two-point subpath is valid and records one canonical no-op stroke so
operation order remains explicit. On success the immutable snapshot contains
the complete ordered geometry and boundaries. Later Path mutation cannot alter
it. Each call appends one plan record in painter order.

If the closure throws `DrawingError`, or GiftUI detects any local failure, the
entire Canvas result and whole cycle-local drawing plan are invalid. No stroke
from that plan reaches an operation sink. The public source surface admits no
other thrown error type.

### Coordinate resolution and lowering

For each snapshot, drawing checked-adds the Canvas resolved surface origin to
every local point. Overflow aborts the whole plan. It carries the Canvas origin
and translated logical point values consistently; consumers MUST NOT translate
twice. The normalized header carries the inherited SPEC-008 clip. Canvas
bounds do not intersect or replace that clip.

Each snapshot lowers to one `straightLineStroke` call at the Canvas position
in the complete SPEC-008 painter stream. Points and subpath boundaries remain
ordered and exact. Duplicate points never imply a boundary. Split operations
are nonconforming if cap, join, endpoint, or order meaning changes.

Preflight validates all plan, translated geometry, SPEC-008 total operation,
sink capacity, and borrowed payload bounds before `SynchronousFrameEndpoint`
is called. During offer the sink consumes every borrow synchronously and may
retain only backend-owned derived pixels/spans/tiles/transfer data after
acceptance.

### Startup gates

RFC-002 B2 structural validation proves every `DrawingLimits` value and the
selected producer workspace are sufficient for the configured workload.
Separately SPEC-004 must resolve `rasterPresentation` with straight-line-stroke
operation coverage, extent, clip, encoding, derived payload, in-flight storage,
one-shot lifetime, and host policy. Both gates pass before the first cycle.
Drawing capacities MUST NOT be added to SPEC-004's closed fields.

## State / Lifecycle

```text
laid out -> invoking -> plan complete -> preflighted -> offered once -> reset
                    \-> failure -> whole plan discarded -> dirty rederivation
```

The closure and plan are released no later than cycle finalization. Refusal
retains only SPEC-009 presentation intent; later recovery rederives and invokes
a new closure once in a new attempt.

## Capability Requirements

No new public capability exists. Missing semantic stroke support fails
SPEC-004 resolution; insufficient producer construction capacity fails B2.
Portable clients do not branch, omit strokes, or inspect target identity.

## Backend Requirements

Every MVP backend must consume the complete canonical header, ordered points,
and subpaths synchronously and reproduce width, caps, joins, color, order, and
clip. Unsupported native round behavior is not a fallback permission. Concrete
rasterization, quantization, tiling, and derived storage belong to the later
backend-integration contract.

## Error Handling

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `invalidValue`, `invalidPathState` | `.invalidValue` | `.rendering` | `.candidateFrame` | `.contained` |
| `arithmeticOverflow` | `.arithmeticOverflow` | `.rendering` | `.candidateFrame` | `.contained` |
| `capacityExhausted`, `operationCapacityExhausted` | `.capacityExhausted` | `.rendering` | `.candidateFrame` | `.contained` |
| `invalidScope` | `.invalidPhase` | `.rendering` | `.activeCycle` | `.safetyNotProven` |
| `invalidPhase` | `.invalidPhase` | `.rendering` | `.activeCycle` | `.safetyNotProven` |
| `reentrancyViolation` | `.reentrancyViolation` | `.rendering` | `.activeCycle` | `.safetyNotProven` |
| `sinkRefused` | `.nonRetryableRefusal` | `.rendering` | `.candidateFrame` | `.contained` |
| `invariantViolation` | `.invariantViolation` | `.rendering` | narrowest proven scope | `.safetyNotProven` |

All pre-offer failures discard the incomplete plan, preserve applied mutation
effects, mark semantics dirty, and request one paced rederivation. They never
silently wrap, truncate, drop a stroke, substitute a style, trap for ordinary
exhaustion, or publish partial output.

## Performance Requirements

Construction, snapshot, validation, and lowering are linear in admitted
points, subpaths, and strokes. The independent fixture supports at least 820
segments as feasibility evidence, but production capacity is derived later
from approved SPEC-001 and host configuration. Evidence reports closure,
construction, snapshot, lowering, operation, raster, point/stroke bytes, peak
simultaneous workspace, stack, heap, flash, and linked-size deltas separately.

The static drawing producer MUST allocate zero heap bytes and introduce no
reflection, `Any`, task, thread, exception, Objective-C runtime, or hidden
complete-frame pixel buffer.

## Compatibility

There is no prior approved Canvas API. These declarations are the MVP source
contract, not SwiftUI compatibility. Internal plan packing, workspace layout,
and borrowing implementation are not ABI or persistent formats.

## Testing Requirements

Provide `scripts/contracts/run-spec-012.sh` for macOS dynamic/static and
hardware-free Raspberry Pi ARMv6/nRF52840 compile/link modes. Recording tests
cover closure count/size, the exact typed-throws Canvas and `withPath` source
shape, context/path scope escape rejection, outer-context overlapping-access
rejection, move/line state, stroke-mutate-stroke reuse of one Path, multiple
subpaths, zero-length geometry, snapshot isolation, both overloads, round and
default styles, painter order, local-to-surface overflow, outside-Canvas
geometry, inherited clips, every capacity boundary, whole-plan discard,
throwing-exit cleanup, refusal rederivation, borrowed-address nonretention, and
cross-profile equality.

## Acceptance Criteria

- [ ] **DR-001:** Exact public declarations and the typed-throws
  `withPath { context, path in ... }` stroke-mutate-stroke source form compile
  for all MVP profiles; illegal outer-context access, Path copy, and Path
  escape examples fail compilation.
- [ ] **DR-002:** Each occurrence is called once after layout with exact size
  and observes the same frozen revision as its enclosing derivation.
- [ ] **DR-003:** Snapshot fixtures prove later Path mutation cannot alter an
  earlier stroke and all explicit subpaths are preserved.
- [ ] **DR-004:** Recording sinks receive exact canonical style, point,
  boundary, origin, clip, and painter order transcripts across profiles.
- [ ] **DR-005:** Every validation/capacity edge fails before offer, discards
  the whole plan, and produces the exact SPEC-003 mapping.
- [ ] **DR-006:** Startup fixtures independently fail and pass B2 structural
  capacity and SPEC-004 semantic capability gates.
- [ ] **DR-007:** The sink retains no borrowed address after return and refusal
  retains no plan or closure.
- [ ] **DR-008:** Static fixtures exercise concrete typed `DrawingError`
  throwing and cleanup, allocate zero heap bytes, and exclude `any Error`,
  allocator, reflection, task, thread, exception-runtime, and Objective-C
  symbols.

## Implementation Notes

SPIKE-004's copy-to-plan and unique-range sealing strategies are both viable.
Its C arena is evidence, not the production Swift contract.

SPIKE-007 proves the shared storage premise relevant to Canvas: retaining a
captured escaping Swift closure across a committed-record lifetime preserves an
allocator path even when the enclosing record is noncopyable, while a generated
finite tagged callable with bounded typed captures compiles and links without
that allocator path. The Spike's zero-argument action callable is not evidence
that Canvas's corrected typed-throws, two-`inout` `withPath` signature
compiles.

### SPIKE-008 evidence

SPIKE-008 compiled the exact declaration shapes and a generated bounded
callable's throwing `(inout GraphicsContext, Size)` signature on macOS and in a
hardware-free Embedded Swift declaration image when concrete thrown values
were disabled. Illegal borrowed-Path consumption and Path escape failed
compilation on both compilers as required. The macOS runtime fixture exercised
normal and throwing `withPath` cleanup successfully.

The declaration-only nRF52840 image retained ARMv7E-M hard-float attributes,
zero configured heaps, and no candidate-introduced reflection, Objective-C,
task, thread, or allocator symbols. Whole-module elimination made its linked
flash and RAM equal to the configuration-equivalent baseline (25,780 and 6,016
bytes respectively); those values are declaration evidence, not production
capacity or cost measurements. No board was flashed or operated.

The original experiment did not validate the intended supported source
composition or Embedded throwing behavior. This revision responds to both
negative results by passing the active context into the `withPath` body and
using typed `throws(DrawingError)` throughout the public surface. A follow-up
local declaration fixture compiled and linked those corrected forms on macOS
and the supported hardware-free nRF52840 configuration, including concrete
typed throws and normal/throwing cleanup, without an `any Error` dependency.
That local result motivates this contract correction but does not replace the
tracked cross-profile evidence required by DR-001 and DR-008.

## Open Issues

- The tracked SPIKE-008 fixtures and evidence still describe the superseded
  untyped-throws, captured-outer-context source shape. They must be updated and
  rerun against this corrected exact contract before DR-001 or DR-008 can pass.
- Pixel quantization and raster tolerance vectors are intentionally owned by
  the Wave 6 backend-integration Specification, not this portable contract.

## Deferred and Follow-up Work

- [SPIKE-008](../spikes/spike-008-spec-012-exact-canvas-declarations.md)
  records the negative evidence that caused this source-contract correction.
  Its fixtures must be revised and rerun before review; its original candidate
  does not define the corrected contract.

Richer drawing and retained paths remain outside the accepted MVP scope.

## References

- [PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [ADR-028](../adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md)
- [ADR-029](../adrs/adr-029-scoped-transient-path-snapshot-semantics.md)
- [ADR-030](../adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md)
- [ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md)
- [SPIKE-008](../spikes/spike-008-spec-012-exact-canvas-declarations.md)
