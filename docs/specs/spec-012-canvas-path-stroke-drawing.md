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
> error-model failures found by SPIKE-008 and completes the semantic, layout,
> render, execution, capacity, raster, and static-lowering contracts identified
> during completeness review. SPIKE-008 now records corrected macOS and
> hardware-free nRF52840 declaration evidence. This Specification remains
> non-authoritative until review and explicit maintainer approval.

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
points and explicit subpath ranges captured at one stroke call. **Drawing
attempt** is the pre-publication work for all Canvas occurrences in one
derivation, including refusal recovery that re-expands the current root.
**Drawing plan** is the finite drawing-attempt-local ordered set of every
Canvas snapshot. **Inherited clip** is the SPEC-008 logical clip; Canvas bounds
add no implicit clip. **Canonical raster coverage** is the backend-independent
set of logical pixel centers covered by a stroke before encoding.

## Public Contract

```swift
public struct Canvas: View {
    public typealias Body = Never
    public init(
        _ draw: @escaping (
            inout GraphicsContext,
            Size
        ) throws(DrawingError) -> Void
    )
    public var body: Never { get }
    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
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
It MAY read values frozen for the enclosing derivation but MUST NOT mutate
GiftUI-observed state, dispatch an action, submit an execution fact, request a
wake, start or reenter a cycle, or query capability/backend identity. A
detectable GiftUI phase violation aborts the attempt as `.invalidPhase`; cycle
reentry aborts it as `.reentrancyViolation`. Side effects outside GiftUI's
observation and action contracts are unsupported and receive no replay or
exactly-once guarantee.

`Canvas.Body` is `Never`. Reading `body` is an invariant violation. `Canvas`
conforms to SPEC-006's `_GiftUISemanticPrimitivePayload` marker and its
traversal override calls `visitor.visitPrimitive(self)` exactly once. The
visitor stages one semantic leaf with the exact SPEC-006 structural identity;
it MUST NOT evaluate `body`, create a child, invoke the draw closure, or expose
the closure through a public or package lookup. Dynamic and static semantic
storage MAY encode the staged callable differently, but both MUST associate it
with that exact identity until the post-layout invocation defined below.

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
statically known Canvas expression during its required source-generation step.
The generator assigns each syntactic expression one nonzero `UInt16` callable
ID, emits one fixed-layout capture record containing exactly the values read by
that closure, and emits one finite `StaticCanvasCallableTable` switch case for
the ID. Repeated runtime occurrences reuse the syntactic ID but own distinct
capture records. The generated capture union's size is the greatest case size,
not the sum of all cases.

Every capture type MUST have statically known size and alignment, require no
heap allocation or reference-counted closure context, and be usable in the
static target image without reflection or existential storage. Capturing an
unsupported value, exceeding `maximumStaticCaptureBytes`, assigning more than
`maximumStaticCallableCases` IDs, or failing to prove complete ID coverage is a
static build error; the generator MUST NOT fall back to retaining the source
closure. At semantic staging the static profile stores only the callable ID
and its inline generated capture record. Invocation dispatches that record
through the generated case and preserves the exact scoped
`inout GraphicsContext`, `Size`, typed `throws(DrawingError)`, order, and
release semantics. The generated capture record is destroyed immediately
after invocation and no later than cycle finalization.

An address-stable observable-model location MAY be captured only through its
approved static storage handle: the record borrows that handle, performs no
retain/release, and the host proves the location outlives the invocation.
Capturing an ordinary heap-owned class reference, existential, weak/unowned
runtime box, or dynamically sized collection is unsupported in the static
profile and fails generation.

`StrokeStyle` construction with nonpositive width creates an invalid style
marker; the next stroke throws `.invalidValue` before snapshotting. The
line-width overload is exactly the style overload using `.butt` and `.miter`.
`Shading.color` preserves the exact SPEC-008 opaque RGB value.

## Module Contract

`GiftUI` owns the public declarations and typed Canvas primitive payload.
`GiftUISemanticCore` stages the borrowed payload under SPEC-006 identity and
exposes it only through the drawing-attempt input view below.

`GiftUIDrawing` owns scoped construction, static callable-table contract,
drawing plan, plan validation, post-layout invocation, combined render
preflight/streaming, and recording fixtures. It imports `GiftUI`,
`GiftUISemanticCore`, `GiftUILayout`, `GiftUIRenderLowering`,
`GiftUIRenderCore`, and `GiftUIExecution`; it MUST NOT import a runtime profile,
failure owner, capability implementation, backend, rasterizer, platform,
driver, OS/RTOS, HAL, or hardware target. Its combined producer reuses the
SPEC-008 traversal and validation implementation; it MUST NOT fork ordinary
fill, glyph, style, clip, damage, or text-resource semantics.

`GiftUIRenderCore` owns `StraightLineStrokeHeader`, `StraightLineStrokeView`,
and `DrawingOperationSink` because backends consume those contracts without
importing `GiftUIDrawing`. Runtime profiles supply concrete semantic, callable,
plan, and production workspace. The runtime coordinator imports the focused
owners and invokes drawing at the phase defined below. The owner adapter maps
local errors to SPEC-003; neither drawing module imports a failure owner.

This Specification is the reviewed downstream extension point anticipated by
SPEC-006's generic primitive payload. It adds the `.canvas` meanings below to
SPEC-007's and SPEC-008's closed package vocabularies without changing any
previous case, raw value, traversal order, or non-Canvas result. Approval of
this Specification is required before those additive cases are authoritative.

## Types / APIs

```swift
package struct DrawingLimits: Equatable, Sendable {
    package let maximumLineWidth: GeometryScalar
    package let maximumCanvasOccurrences: UInt16
    package let maximumLivePathPoints: UInt16
    package let maximumLivePathSubpaths: UInt16
    package let maximumPlanStrokes: UInt16
    package let maximumPlanPoints: UInt16
    package let maximumPlanSubpaths: UInt16
    package let maximumNormalizedStrokeOperations: UInt16
    package init?(maximumLineWidth: GeometryScalar,
                  maximumCanvasOccurrences: UInt16,
                  maximumLivePathPoints: UInt16,
                  maximumLivePathSubpaths: UInt16,
                  maximumPlanStrokes: UInt16,
                  maximumPlanPoints: UInt16,
                  maximumPlanSubpaths: UInt16,
                  maximumNormalizedStrokeOperations: UInt16)
}

package struct StaticCanvasLimits: Equatable, Sendable {
    package let maximumStaticCallableCases: UInt16
    package let maximumStaticCaptureBytes: UInt16
    package init?(maximumStaticCallableCases: UInt16,
                  maximumStaticCaptureBytes: UInt16)
}

package protocol StaticCanvasCallableTable {
    associatedtype CaptureStorage: ~Copyable
    var callableCaseCount: UInt16 { get }
    func captureByteCount(for id: UInt16) -> UInt16?
    mutating func invoke(
        id: UInt16,
        captures: borrowing CaptureStorage,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError)
}

package protocol CanvasInvocationSource {
    associatedtype Identity: Equatable, Sendable
    var canvasOccurrenceCount: UInt16 { get }
    func canvasIdentity(at index: UInt16) -> Identity?
    mutating func invokeCanvas(
        at identity: Identity,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError)
    mutating func releaseCanvas(at identity: Identity)
}

package struct DrawingPlanSummary: Equatable, Sendable {
    package let canvasOccurrenceCount: UInt16
    package let strokeCount: UInt16
    package let pointCount: UInt16
    package let subpathCount: UInt16
    package let normalizedStrokeOperationCount: UInt16
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

package protocol DrawingPlanView {
    associatedtype Identity: Equatable, Sendable
    var summary: DrawingPlanSummary { get }
    func strokeCount(of canvas: Identity) -> UInt16?
    func strokeHeader(of canvas: Identity, at index: UInt16)
        -> StraightLineStrokeHeader?
    func point(of canvas: Identity, stroke: UInt16, at index: UInt16) -> Point?
    func subpath(of canvas: Identity, stroke: UInt16, at index: UInt16)
        -> SubpathRange?
}

package protocol DrawingPlanWorkspace: DrawingPlanView {
    var capacity: DrawingLimits { get }
    var isActive: Bool { get }
    mutating func acquire() -> Bool
    mutating func discard()
    mutating func reset()
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
    case invariantViolation = 8
}

package enum DrawingPlanResult: Equatable, Sendable {
    case success(DrawingPlanSummary)
    case failure(DrawingProductionError)
}

package enum CanvasPlanProducer {
    package static func derive<Source, Layout, Workspace>(
        source: inout Source,
        layout: borrowing Layout,
        executionContext: ExecutionContext,
        limits: DrawingLimits,
        workspace: inout Workspace
    ) -> DrawingPlanResult
    where Source: CanvasInvocationSource,
          Layout: ResolvedRenderLayoutView,
          Workspace: DrawingPlanWorkspace,
          Source.Identity == Layout.Identity,
          Source.Identity == Workspace.Identity
}

package enum CanvasRenderProducer {
    package static func preflight<Semantic, Layout, Metrics, Plan, Workspace>(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        drawingPlan: borrowing Plan,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        configuredSinkCapacity: RenderSinkCapacity,
        workspace: inout Workspace
    ) -> RenderProductionResult
    where Semantic: SemanticRenderView,
          Layout: ResolvedRenderLayoutView,
          Metrics: CanonicalTextMetricsView,
          Plan: DrawingPlanView,
          Workspace: RenderProductionWorkspace,
          Semantic.Identity == Layout.Identity,
          Semantic.Identity == Plan.Identity,
          Semantic.Identity == Workspace.Identity

    package static func produce<
        Semantic, Layout, Metrics, Plan, Workspace, Sink
    >(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        drawingPlan: borrowing Plan,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        expectedHeader: RenderPlanHeader,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> RenderProductionResult
    where Semantic: SemanticRenderView,
          Layout: ResolvedRenderLayoutView,
          Metrics: CanonicalTextMetricsView,
          Plan: DrawingPlanView,
          Workspace: RenderProductionWorkspace,
          Sink: DrawingOperationSink,
          Semantic.Identity == Layout.Identity,
          Semantic.Identity == Plan.Identity,
          Semantic.Identity == Workspace.Identity
}
```

The existing SPEC-007 `SemanticLayoutPrimitive` enum gains exactly one case,
`.canvas`. The existing SPEC-008 `SemanticRenderScope` enum gains exactly one
case, `.canvas`. These are additive package-SPI amendments; every pre-existing
case and behavior remains unchanged. Canvas uses SPEC-006's existing generic
primitive visitor operation and therefore adds no visitor category.

All limits MUST be positive. `DrawingLimits` applies to one complete drawing
attempt across all Canvas occurrences. `maximumCanvasOccurrences`, plan
strokes, plan points, plan subpaths, and normalized stroke operations are
global attempt totals. `maximumLivePathPoints` and
`maximumLivePathSubpaths` apply to the one active `withPath`; nested
`withPath` is rejected as `.reentrancyViolation`, so there is exactly one live
Path per attempt. A successful stroke snapshot consumes plan totals but does
not reset live-Path totals; leaving `withPath` resets the live totals only.
`maximumLineWidth` is the greatest client width admitted by the selected
producer/raster configuration; a positive width above it throws
`.capacityExhausted` before snapshotting.

`maximumNormalizedStrokeOperations` MUST be greater than or equal to
`maximumPlanStrokes`; otherwise `DrawingLimits.init` returns `nil`.
`maximumLineWidth <= 0` also makes that initializer return `nil`.
`StaticCanvasLimits` is valid only when both values are nonzero. The generated
table's case count and greatest capture size MUST not exceed those limits.
Counts and indices are exact `UInt16` values; a count equal to its limit
succeeds. `SubpathRange` requires `pointCount > 0` and checked
representability of its exclusive end. Production host values are downstream
configuration; this contract's fixtures inject artificial limits.

`DrawingPlanWorkspace.acquire()` returns `false` without mutation when already
active. After successful acquisition, plan accessors are unavailable until
`derive` succeeds. The summary counts every invoked Canvas including one that
submits no stroke, and `normalizedStrokeOperationCount` MUST equal
`strokeCount`. On success, `strokeCount(of:)` returns zero for an admitted
Canvas with no stroke and `nil` for a non-Canvas identity. Every Canvas
identity and stroke index below its reported count and every point/subpath
index below its header count MUST resolve; an index at or above a reported
count returns `nil`. Missing in-range data, duplicate Canvas identity,
summary/count disagreement, or access after discard/reset is
`.invariantViolation`. Stored points are already translated surface
coordinates; `surfaceOrigin` is retained as coordinate-space metadata and
MUST NOT be reapplied. `discard` invalidates all staged records without
publishing them; `reset` releases storage and returns the workspace to idle.

The SPEC-008 operation count includes each straight-line stroke as exactly one
operation. `DrawingOperationSink` extends, rather than replaces, SPEC-008's
ordered stream protocol. A borrowed stroke view is valid only during the call.
`CanvasRenderProducer` is the sole production entry point for a configuration
that admits Canvas. It performs SPEC-008's complete ordinary traversal and
adds `.canvas` handling in the same traversal; it calls `begin` and `finish`
exactly once for the combined stream. A non-Canvas configuration MAY continue
using SPEC-008's `RenderProducer`, and both entry points MUST produce identical
ordinary-operation transcripts when `drawingPlan.summary` contains zero
Canvas occurrences.

`preflight` performs the complete immutable combined traversal without a sink.
It acquires and resets the caller-owned render workspace within the call and
retains no borrow. On success it returns `.success` with the exact header that
`produce` must later receive as `expectedHeader`. `produce` repeats the same
traversal inside offer; any difference from that header or from the plan
summary is `.invariantViolation` before `begin`. A preflight capacity shortfall
returns SPEC-008 `.capacityExhausted`; no partial header is exposed.

## Behavior

### Invocation and path construction

Canvas adds `.canvas` to SPEC-007's `SemanticLayoutPrimitive` and `.canvas` to
SPEC-008's `SemanticRenderScope`. It is a semantic and layout leaf with zero
children. On each axis its ideal dimension is the present proposal or zero
when that axis is absent; the ordinary SPEC-007 cap and frame-modifier rules
then determine its resolved bounds. Canvas adds no clip, hit region, child,
text scalar, glyph, or ordinary paint operation. Its render scope maps to its
own exact layout identity.

After state freeze and complete layout, while SPEC-009 remains in `.deriving`
and before semantic publication, `CanvasPlanProducer.derive` visits Canvas
occurrences in resolved painter order. It verifies that
`executionContext.phase == .deriving`, that the context names the active cycle
with `cycle != nil`, that `semanticRevision` names the latest complete
publication or is `nil` before the first publication, and that
`candidateFrame == nil`. It then verifies that
`source.canvasOccurrenceCount` equals both the semantic Canvas count and the
number of matching resolved layout identities. Each in-range identity must
resolve exactly once. It invokes each closure at most once with a fresh scoped
context and the exact `Size` from that Canvas's resolved bounds. A closure is
not called during semantic expansion, measurement, `.publishing`, backend
offer, capability resolution, or recursive retry.

After each normal or throwing invocation, the producer calls
`releaseCanvas(at:)` exactly once and makes any later invocation of that staged
callable invalid. After the last occurrence, no closure or capture record may
remain in the semantic result that is eligible for publication. A refusal
recovery later re-expands the current root and repeats layout and drawing in a
new `.deriving` attempt; it does not retain or replay the refused closure or
plan and does not publish a new semantic revision when the rederived semantics
are unchanged.

Each `withPath` supplies the body with the same active context on which
`withPath` was invoked and a new Path with no current point and no subpath.
`move(to:)` starts a new open subpath and makes the point current. Consecutive
moves before any `addLine` replace the current one-point subpath atomically and
do not increase live point or subpath counts; only the latest point is
snapshotted. A move after a subpath has at least two points reserves one new
point and one new subpath boundary before changing state.
`addLine(to:)` without a current point throws `.invalidPathState` and changes
nothing. Zero-length segments are preserved; a one-point or empty subpath
contributes no raster segment but remains an explicit boundary for
deterministic snapshots.

Every successful mutating call is atomic. Capacity exhaustion appends no point
or boundary and preserves the prior path. Calling `withPath` while another
`withPath` is active on the same context throws `.reentrancyViolation` before
acquiring or resetting storage. `withPath` resets and releases all live
construction storage on normal or throwing exit.

### Stroke snapshot and plan

`stroke` validates style and path state, then reserves one record and all point
and subpath storage before copying or uniquely transferring anything. A path
with no nonzero segment is valid and records one canonical no-op stroke so
operation order remains explicit. On success the immutable snapshot contains
the complete ordered geometry and boundaries. Later Path mutation cannot alter
it. Each call appends one plan record in painter order.

If the closure throws `DrawingError`, or GiftUI detects any local failure, the
entire drawing attempt is invalid. The producer releases the active callable,
calls `workspace.discard()` exactly once after acquisition, resets the
workspace, and exposes no plan. No stroke from any Canvas in that attempt
reaches an operation sink. The public source surface admits no other thrown
error type.

### Coordinate resolution and lowering

For each snapshot, drawing checked-adds the Canvas resolved surface origin to
every local point. Overflow aborts the whole plan. It carries the Canvas origin
and translated logical point values consistently; consumers MUST NOT translate
twice. The normalized header carries the inherited SPEC-008 clip. Canvas
bounds do not intersect or replace that clip.

Each snapshot lowers to one `straightLineStroke` call at the Canvas scope's
position in the complete SPEC-008 painter stream. Points and subpath boundaries
remain ordered and exact. Duplicate points never imply a boundary. Split
operations are nonconforming if cap, join, endpoint, or order meaning changes.

Before semantic publication, `CanvasRenderProducer.preflight` validates the
complete plan, translated geometry, attempt limits, the checked sum of ordinary
SPEC-008 and stroke operations, and the immutable host-configured sink-capacity
lower bound. It does not inspect or borrow an endpoint sink. Only a successful
plan and exact preflight header permit publication and candidate allocation.

Inside the later single `SynchronousFrameEndpoint.offer`,
`CanvasRenderProducer` repeats the immutable ordinary/drawing traversal,
constructs one combined `RenderPlanHeader`, requires equality with the
pre-publication `expectedHeader`, compares the actual sink capacity with the
already-proven counts before `begin`, and streams one painter-ordered sequence.
An actual capacity smaller than the startup-validated lower bound is
`.invariantViolation`, not ordinary exhaustion. After `begin`, a `false`
straight-line-stroke call is also `.invariantViolation` and triggers exactly
one SPEC-008 `discard`. During a successful call the sink consumes every
borrow synchronously and may retain only backend-owned derived
pixels/spans/tiles/transfer data after acceptance.

The canonical recording transcript adds the following event at the Canvas
position between SPEC-008's existing events:

```text
stroke(rgb, width, cap, join, origin, clip,
       points[0..<pointCount], subpaths[0..<subpathCount])
```

The combined header's `operationCount` equals fill operations plus positioned-
glyph groups plus straight-line strokes. A canonical no-op stroke remains one
operation and one transcript event.

### Startup gates

RFC-002 B2 structural validation receives a host-owned workload declaration
containing maximum Canvas occurrences, greatest simultaneously live Path
points/subpaths, greatest line width, total submitted strokes, total
snapshotted points/subpaths, ordinary SPEC-008 operations, and total normalized
operations. It checked-
compares each value to `DrawingLimits`, verifies the selected workspace reports
at least those limits, verifies `ordinaryOperations + submittedStrokes` fits
both `RenderLimits.maximumOperations` and the configured sink-capacity lower
bound, and, for static profiles, validates callable-case and capture-byte
limits. Any missing, overflowing, zero, or insufficient fact rejects startup.

The first-party workload declaration MUST be derived from the approved
SPEC-001 Signal Analyzer configuration before that application may claim
drawing conformance. SPEC-001's current candidate 816-segment maximum and
SPIKE-004's conservative 820-segment fixture remain independent feasibility
evidence until SPEC-001 approval; artificial contract fixtures use smaller
limits to exercise every equality and first-excess boundary.

Separately SPEC-004 must resolve `rasterPresentation` with straight-line-stroke
operation coverage, extent, clip, encoding, derived payload, in-flight storage,
one-shot lifetime, and host policy. Both gates pass before the first cycle.
Drawing capacities MUST NOT be added to SPEC-004's closed fields, and
capability success MUST NOT repair a failed B2 comparison.

## State / Lifecycle

```text
SPEC-009 deriving
  -> laid out -> invoking -> plan complete -> preflighted
  -> semantic publication -> candidate allocation -> offered once -> reset
                 \-> failure -> plan discarded -> semantic dirty -> reset
```

The closure is released immediately after its invocation and always before
semantic publication. The plan is released after accepted or refused offer and
no later than cycle finalization. A pre-publication drawing failure follows
SPEC-009's pre-publication rule: it preserves already-applied mutation effects,
publishes no semantic revision or candidate, marks semantics dirty, and
requests one coalesced `.semanticDirty` wake. Refusal after successful
publication retains only SPEC-009 presentation intent; later paced recovery
re-expands, lays out, and invokes a new closure once in a new derivation.

## Capability Requirements

No new public capability exists. Missing semantic stroke support fails
SPEC-004 resolution; insufficient producer construction capacity fails B2.
Portable clients do not branch, omit strokes, or inspect target identity.

## Backend Requirements

Every MVP backend must consume the complete canonical header, ordered points,
and subpaths synchronously and reproduce width, caps, joins, color, order, and
clip. Unsupported native round behavior is not a fallback permission. Concrete
scan-conversion, tiling, and derived-storage algorithms belong to backend
integration, but their observable coverage and encoding are fixed here.

Logical pixels are unit squares with integer upper-left coordinates. Coverage
is binary and is sampled at each pixel center `(x + 1/2, y + 1/2)`; boundary
points are inside. Implementations MAY use doubled integer/rational arithmetic
instead of fractions and MUST produce the same set of covered centers without
antialiasing or alpha.

For positive width `w`, the canonical stroke region is defined as follows:

- each nonzero segment contributes the closed perpendicular-distance region
  within `w / 2` whose projection lies between its endpoints;
- `.butt` adds nothing beyond an open subpath's first and last nonzero segment;
  `.round` unions a closed radius-`w / 2` disk at those endpoints;
- `.round` joins union the same disk at each vertex between adjacent nonzero
  segments;
- `.miter` joins use the exterior intersection of the two offset segment
  edges, with a fixed miter limit of ten times `w / 2`; an intersection beyond
  that limit uses the closed bevel triangle between the two exterior offset
  corners. “Exterior” is the side of the vertex not already covered by both
  adjacent segment bodies. Failure to represent the bounded calculation is an
  invariant/configuration failure, never a bevel fallback;
- same-direction collinear segments and exact parallel reversals add no join
  region beyond their segment bodies. Zero-length segments do not supply a
  tangent or join. A subpath containing no nonzero segment covers nothing for
  either cap.

A pixel is emitted only when its center is in that region and in the inherited
half-open clip `[minX, maxX) x [minY, maxY)`. Canvas bounds never participate.
Opaque painter order is exact replacement: each later covered operation
overwrites the prior pixel. Raster intermediates MUST use sufficient widened
integer or exact-rational range for every startup-admitted extent and width;
runtime wrap, saturation, or floating-point tolerance is nonconforming.

Encoding is exact. RGBA8888 stores `(red, green, blue, 255)`. RGB565 uses
checked integer round-to-nearest conversion
`r5 = (red * 31 + 127) / 255`, `g6 = (green * 63 + 127) / 255`, and
`b5 = (blue * 31 + 127) / 255`, then stores
`(r5 << 11) | (g6 << 5) | b5` most-significant byte first. Shared golden masks
and encoded-byte vectors therefore have zero pixel and zero channel tolerance.

The normative vector corpus MUST include horizontal, vertical, diagonal,
single-point, repeated-point, zero-length, acute/obtuse/right-angle,
same-direction, reversal, miter-limit fallback, odd/even width, butt/round cap,
miter/round join, negative/outside-Canvas, every clip edge, empty clip,
overlap/painter-order, and RGB boundary values `0`, `1`, `127`, `128`, `254`,
and `255`. Full-surface and tiled backends MUST produce identical masks and
encoded bytes for that corpus.

## Error Handling

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `invalidValue`, `invalidPathState` during drawing derivation | `.invalidValue` | `.rendering` | `.activeCycle` | `.contained` |
| checked geometry `arithmeticOverflow` | `.arithmeticOverflow` | `.foundation` | `.operation` | `.contained` |
| `capacityExhausted`, `operationCapacityExhausted` during drawing derivation | `.capacityExhausted` | `.rendering` | `.activeCycle` | `.contained` |
| `invalidScope` | `.invalidPhase` | `.rendering` | `.activeCycle` | `.safetyNotProven` |
| `invalidPhase` | `.invalidPhase` | `.rendering` | `.activeCycle` | `.safetyNotProven` |
| `reentrancyViolation` | `.reentrancyViolation` | `.rendering` | `.activeCycle` | `.safetyNotProven` |
| idle combined-sink `sinkRefused` during offer | `.nonRetryableRefusal` | `.rendering` | `.candidateFrame` | `.contained` |
| drawing or combined-stream `invariantViolation` | `.invariantViolation` | `.rendering` | `.runtime` | `.safetyNotProven` |

Detection precedence is normative. Startup validates limit construction,
static callable coverage, B2 workload sufficiency, then SPEC-004 capability.
Within one drawing attempt the producer checks, in order: active-workspace
reentry; `.deriving` phase and source scope; Canvas occurrence count and exact
identity coverage; invocation in painter order; nested-Path reentry; each Path
mutation's state and live capacity; each stroke's style and path state; plan
stroke, point, and subpath reservations; translated geometry; normalized-
stroke count; combined SPEC-008 operation count; configured sink-capacity
lower bound; and immutable-plan consistency. It returns the first visible
failure and performs no later check that could invoke client code.

All pre-publication failures discard the incomplete plan, preserve applied
mutation effects, mark semantics dirty, and request one coalesced later
derivation. They never silently wrap, truncate, drop a stroke, substitute a
style, trap for ordinary exhaustion, or publish partial output. An idle sink
refusal and any offer-time contract violation occur after publication and
follow SPEC-009 refusal/invariant handling; they do not dirty or roll back the
published semantic revision.

## Performance Requirements

Construction, snapshot, validation, and lowering are linear in admitted
points, subpaths, and strokes. The independent fixture supports at least 820
segments as feasibility evidence, but production capacity is derived later
from approved SPEC-001 and host configuration. Evidence reports closure,
construction, snapshot, lowering, operation, raster, point/stroke bytes, peak
simultaneous workspace, stack, heap, flash, and linked-size deltas separately.

The static drawing producer MUST allocate zero heap bytes and introduce no
reflection, `Any`, task, thread, exception, Objective-C runtime, or hidden
complete-frame pixel buffer. Generated capture storage, live Path storage,
sealed plan storage, combined render workspace, backend raster workspace, and
post-acceptance derived storage MUST be measured separately; reporting only
their sum is insufficient.

On every supported compiler, `DrawingLimits` MUST occupy no more than 20 bytes,
`StaticCanvasLimits` exactly 4 bytes, `SubpathRange` exactly 4 bytes,
`DrawingPlanSummary` exactly 10 bytes, `StraightLineStrokeHeader` no more than
40 bytes, `DrawingProductionError` exactly 1 byte, and `DrawingPlanResult` no
more than 12 bytes. None may contain a reference, existential, closure,
dynamically growing collection, or pointer whose lifetime contributes to its
meaning. The static capture union and plan workspace are explicitly excluded
from these value ceilings and instead MUST equal or remain below their
host-validated configured byte bounds.

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
subpaths, zero-length geometry, snapshot isolation, both overloads, and round
and default styles.

Semantic/layout fixtures record the exact `visitPrimitive` event, identity,
zero-child leaf, present-proposal/absent-axis measurement, frame expansion,
resolved bounds, inherited clip, and absence of hit/text/ordinary-paint output.
Cycle fixtures cover pre-publication invocation, release-before-publication,
whole-attempt discard, throwing-exit cleanup, dirty recovery, refusal
re-expansion without a new semantic revision, and cross-profile equality.

Combined render fixtures cover exact header totals; fill/glyph/stroke painter
order; no-op strokes; local-to-surface overflow; outside-Canvas geometry;
inherited clips; actual-sink capacity disagreement; begin, finish, and discard
call counts; and borrowed-address nonretention. Raster fixtures exercise the
complete normative coverage/encoding corpus with zero mask and byte tolerance
on the RGBA8888 framebuffer and RGB565/tiled reference consumers.

Boundary fixtures exercise every `DrawingLimits`, `StaticCanvasLimits`,
SPEC-008 combined-operation, configured sink, invalid-state, invalid-phase,
scope, reentrancy, and invariant edge in normative detection order. Static
fixtures inspect generated callable IDs, distinct repeated-occurrence capture
records, greatest-case union size, unsupported-capture rejection, complete
switch coverage, cleanup, allocation count, symbols, value sizes, stack, RAM,
flash, and linked-size deltas.

## Acceptance Criteria

- [ ] **DR-001:** Exact public declarations and the typed-throws
  `withPath { context, path in ... }` stroke-mutate-stroke source form compile
  for all MVP profiles; illegal outer-context access, Path copy, and Path
  escape examples fail compilation.
- [ ] **DR-002:** Canvas emits exactly one typed primitive event, has
  `Body == Never`, preserves exact structural/layout/render identity, resolves
  present proposal axes and zero absent axes, and emits no child, hit, text,
  glyph, or ordinary paint event.
- [ ] **DR-003:** Each occurrence is called once in pre-publication
  `.deriving`, after complete layout, with exact size and the frozen revision;
  its callable is released before publication, and refusal recovery obtains a
  new callable only by re-expanding the root.
- [ ] **DR-004:** Snapshot fixtures prove later Path mutation cannot alter an
  earlier stroke and all explicit subpaths are preserved.
- [ ] **DR-005:** The combined recording sink receives one begin/finish pair,
  exact total header counts, and exact fill/glyph/stroke style, point, boundary,
  origin, clip, no-op, and painter-order transcripts across profiles.
- [ ] **DR-006:** RGBA8888 framebuffer and tiled RGB565 fixtures match every
  normative coverage and encoding vector with zero differing pixels or bytes.
- [ ] **DR-007:** Every validation/capacity edge fails in the specified order,
  produces the exact SPEC-003 mapping, and applies the correct pre-publication
  dirty or post-publication refusal/invariant disposition.
- [ ] **DR-008:** Startup fixtures independently fail and pass the complete B2
  workload/plan/combined-operation/static-capture proof and SPEC-004 semantic
  capability gate; no drawing capacity appears in the capability snapshot.
- [ ] **DR-009:** The sink retains no borrowed address after return; accepted,
  refused, and failed attempts retain no plan or closure beyond their specified
  lifetime.
- [ ] **DR-010:** Static generation assigns complete nonzero callable IDs,
  stores distinct bounded inline captures for repeated occurrences, rejects
  unsupported or over-limit captures at build time, and never falls back to a
  retained escaping closure.
- [ ] **DR-011:** Static fixtures exercise concrete typed `DrawingError`
  throwing and cleanup, allocate zero heap bytes, and exclude `any Error`,
  allocator, reflection, task, thread, exception-runtime, and Objective-C
  symbols.
- [ ] **DR-012:** All normative value sizes meet their ceilings and resource
  evidence separately reports captures, live Path, plan, render, raster,
  derived storage, stack, RAM, flash, and timing.
- [ ] **DR-013:** Import-graph tests preserve the stated module ownership,
  keep backends independent of `GiftUIDrawing`, and prove portable Canvas code
  contains no runtime-profile, capability, backend, platform, or target check.

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

SPIKE-008's first run found that the original captured-outer-context source
form overlapped the modifying `withPath` access and that untyped throws required
unsupported `any Error` storage in Embedded Swift. This revision responds by
passing the active context into the `withPath` body and using typed
`throws(DrawingError)` throughout the public surface.

The tracked rerun compiles the corrected declarations and generated bounded
callable on macOS and in the hardware-free nRF52840 Embedded Swift image. It
exercises stroke-mutate-stroke reuse of one scoped Path, concrete typed throws,
and normal/throwing cleanup on macOS. Captured outer-context access, borrowed-
Path consumption, and Path escape fail compilation on both compilers.

The executable nRF52840 image retains ARMv7E-M hard-float attributes, zero
configured heaps, and no candidate-introduced `any Error`, reflection,
Objective-C, task, thread, exception-runtime, or allocator symbols. Relative
to the configuration-equivalent baseline it adds 400 linked flash bytes and 0
linked RAM bytes (26,180 and 6,016 bytes total respectively). Those values are
bounded fixture evidence, not production capacity or cost measurements. No
board was flashed or operated.

## Open Issues

No unresolved contract or architectural issue remains in this draft.
SPIKE-008 records corrected macOS and hardware-free nRF52840 evidence for the
declaration, ownership, typed-throws, ABI, heap, and linked-symbol portions of
DR-001 and DR-011. Full cross-profile conformance remains an implementation-
stage obligation under the Testing Requirements and Acceptance Criteria.

## Deferred and Follow-up Work

- [SPIKE-008](../spikes/spike-008-spec-012-exact-canvas-declarations.md)
  records both the negative evidence that caused this source-contract
  correction and the successful corrected-fixture rerun. It remains evidence
  only and does not define this contract or authorize implementation.

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
