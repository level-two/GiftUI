---
id: SPEC-008
feature: giftui-mvp-architecture
title: Normalized Rendering Contract
status: approved
authors:
  - codex
created: 2026-08-25
updated: 2026-08-29
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-003
  - RFC-010
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-021
  - ADR-022
  - ADR-023
  - ADR-032
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-005
  - SPEC-006
  - SPEC-007
  - SPEC-009
  - SPEC-013
  - SPEC-014
  - SPEC-011
  - SPEC-012
related_future_work:
  - FW-001
  - FW-003
  - FW-004
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-008: Normalized Rendering Contract

> **Approval status:** Approved by explicit maintainer authorization. The
> governing Proposal and RFCs, accepted architectural decisions, and approved
> Foundation, Failure, Text Resource, Declarative, and Layout contracts are
> authoritative prerequisites.

## Summary

This Specification defines the Wave 3 rendering contract: portable bounded
`Text`, opaque RGB `Color`, `foregroundStyle`, rectangular `background`,
runtime-neutral style resolution, and deterministic lowering of resolved
layout into a normalized ordered stream of rectangle-fill and positioned-glyph
operations.
It also defines clipping, whole-root damage, bounded production, and the
recording sink used to verify rendering without rasterization.

This document is `approved` and authorizes implementation under this contract.

## Scope

The contract covers macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic,
and nRF52840/Zephyr static configurations. It owns:

- the MVP public text, opaque RGB color, foreground, and background surface;
- inherited foreground and ordered background semantics;
- shared runtime-neutral semantic-and-layout-to-render lowering;
- normalized fill and positioned-glyph operation payloads and traversal;
- checked clip and damage behavior, finite limits, atomic failure, and profile
  equivalence; and
- a recording operation sink that is independent of pixels and hardware.

## Goals

- Carry complete resolved rendering meaning across a backend-neutral boundary.
- Preserve exact text identity, glyph choice, position, paint, and clipping.
- Permit direct bounded static emission without a mandatory display list.
- Make ordering, capacities, and all failures deterministic and testable.
- Keep backend-facing operation transport independent of semantic and layout
  contracts while sharing one lowering implementation across runtime profiles.

## Non-goals

- Define rasterization, pixel encoding, surfaces, backend reservation/handoff,
  presentation, platform APIs, or hardware drivers.
- Define run-cycle coordination, frame publication, or backend handoff.
- Define layout, hit testing, `Button`, `disabled`, actions, state, runtime-cycle
  publication, Canvas, Path, stroke production, gradients, alpha, images,
  shadows, transforms, arbitrary clipping shapes, or blending.
- Require a retained render tree or operation replay.
- Expose font-resource identities or render SPI to portable Presentation.

## Dependencies

### Lifecycle prerequisites

- PROPOSAL-003 is accepted; RFC-002 and RFC-003 are approved.
- ADR-005, ADR-006, ADR-008, ADR-009, ADR-010, ADR-021, ADR-022, ADR-023,
  and ADR-032 are accepted.
- MVP Scope requires text, opaque RGB color, foreground style, rectangular
  backgrounds, and shared presentation across all four configurations.

### Contract prerequisites

- [SPEC-002](spec-002-portable-foundation.md) owns geometry and checked
  arithmetic.
- [SPEC-003](spec-003-failure-outcomes-and-containment.md) owns cross-layer
  outcomes and failure facts.
- [SPEC-005](spec-005-text-resources.md) owns exact font/glyph identities,
  validated resource views, and synchronous resource borrowing.
- [SPEC-006](spec-006-declarative-view-semantics.md) owns semantic expansion,
  source modifier order, identity, and typed payload dispatch.
- [SPEC-007](spec-007-layout.md) owns occurrence bounds, canonical glyph
  selection and positioning, line geometry, and inherited logical clipping.

SPEC-007 MUST reach approval before this Specification can be approved.

## Related ADRs

- **ADR-005** requires one normalized ordered operation vocabulary below
  GiftUI-owned semantics/layout and prohibits backend semantic interpretation.
- **ADR-006** requires equal paint meaning, operation order, clipping, failure,
  and publication behavior across runtime profiles.
- **ADR-008** requires a compiler-visible acyclic module graph. Rendering
  production may join semantic and layout contracts in a higher lowering
  module, but the backend-facing render core remains independent of both.
- **ADR-009** requires checked integer geometry and explicit overflow at every
  clip, damage, bounds, and position boundary.
- **ADR-010** requires positioned-glyph operations and their resource borrows
  to be consumable through the later synchronous one-shot frame offer without
  retention or replay. This Specification defines candidate production, not
  frame acceptance or disposition.
- **ADR-021** prohibits rendering and backends from measuring, shaping,
  selecting fallback, or changing logical text geometry.
- **ADR-022** requires a streamable positioned-glyph operation with exact
  instance identity, complete glyphs and positions, opaque paint, and clip.
- **ADR-023** requires nominal identities from `GiftUITextResources`, exact
  resource compatibility, synchronous borrowing, and no translated identity.
- **ADR-032** gives Semantic Core one exact borrowed identity and traversal
  meaning for downstream layout. Render lowering reuses that same identity to
  correlate the completed semantic and layout results without translation.

## Terminology

**Opaque paint**: One exact 24-bit sRGB color represented by three `UInt8`
channels. It has no alpha or blend mode.

**Effective foreground**: The nearest enclosing `foregroundStyle` color, or
the host-supplied root foreground if no modifier supplies one.

**Render operation**: One complete backend-neutral command in painter order.

**Candidate stream**: All operations staged for one resolved layout before a
later execution contract offers them as a candidate frame.

**Render lowering**: The shared runtime-neutral production step that joins one
successful semantic result with its corresponding successful resolved layout,
resolves rendering styles, and emits normalized operations.

**Render core**: The lower backend-facing contract that owns normalized
operation values, their ordered transport, and recording, but receives no
semantic or layout authority.

**Semantic render view**: A read-only borrowed view of one successful semantic
result containing exact identity, canonical children, and only rendering-
relevant payloads.

**Resolved render layout view**: A read-only borrowed view of one successful
SPEC-007 result, keyed by the exact semantic identity and containing all bounds,
logical clips, lines, and positioned glyphs needed by rendering.

**Clip**: A checked rectangular intersection in logical coordinates. An empty
clip is valid and causes covered draw operations to be omitted.

**Damage mode**: The explicit caller choice between ordinary root-intersection
damage and complete-surface initialization damage. Render lowering does not
infer first-frame state.

## Public Contract

Portable Presentation uses only `import GiftUI`.

```swift
public struct Color: Equatable, Hashable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public init(red: UInt8, green: UInt8, blue: UInt8)

    public static let black: Color
    public static let white: Color
    public static let red: Color
    public static let green: Color
    public static let blue: Color
    public static let gray: Color
}

public struct BoundedText: Equatable, Sendable {
    public static let maximumUTF8ByteCount: UInt16
    public var utf8ByteCount: UInt16 { get }
    public init?(_ content: StaticString)
    public init?<Source: Collection>(utf8: Source)
        where Source.Element == UInt8
    public init(_ value: Int32)
    public func withUTF8<Result>(
        _ body: (UnsafeBufferPointer<UInt8>) throws -> Result
    ) rethrows -> Result
}

public struct Text: View {
    public init(_ content: StaticString)
    public init(_ content: BoundedText)
}

public extension View {
    func foregroundStyle(_ color: Color) -> some View
    func background(_ color: Color) -> some View
}
```

`Color.clear` MUST NOT be declared. The six named colors have exact
values: black `(0,0,0)`, white `(255,255,255)`, red `(255,0,0)`, green
`(0,255,0)`, blue `(0,0,255)`, and gray `(128,128,128)`.

`BoundedText.maximumUTF8ByteCount` is exactly `96`. Initializers return `nil`
when content exceeds 96 bytes or is not well-formed UTF-8; they MUST NOT
truncate, repair, normalize, or allocate as a correctness requirement.
`StaticString` containing a trailing C NUL excludes that terminator. Integer
formatting is locale-independent ASCII base ten, includes `-` only when
negative, and succeeds for every `Int32`. `withUTF8` calls its body once with
exactly the admitted bytes; the borrow ends on return.

`Text.init(_ content: StaticString)` performs the same bounded UTF-8 admission
as `BoundedText.init?`, while remaining non-failable for familiar literal
syntax. On success it stores the admitted bounded value. On failure it stores
a closed invalid-declaration marker with no admitted bytes; that marker is not
client-observable, MUST NOT trap, truncate, repair, or allocate, and MUST make
SPEC-007 return `.invalidDeclaration` before text measurement or render
production begins. `Text.init(_ content: BoundedText)` is always admitted.

For admitted input, both `Text` initializers preserve the same scalar sequence.
They do not perform shaping or choose a font. A dynamic-only module MAY add
`String` and interpolation conveniences, but it MUST first construct
`BoundedText`, return `nil` or its own explicit failure when admission fails,
and lower admitted content identically. `GiftUI` MUST NOT expose an unbounded
string initializer as portable API.

Each public declaration/modifier lowers through SPEC-006's one typed traversal
surface. Modifiers append in source-call order and do not replace descendant
structural identity.

## Module Contract

`GiftUI` owns the public declarations and typed semantic payloads.

This module split realizes RFC-002 boundary B5: `GiftUIRenderLowering` is the
layout-and-semantic-lowering producer, and `GiftUIRenderCore` is the consumer
that owns normalized operation meaning and transport.

`GiftUIRenderCore` owns the normalized operation values, operation headers,
ordered `RenderOperationSink` transport, and canonical recording sink. It MUST
depend only on `GiftUI` and `GiftUITextResources`. It MUST NOT import
`GiftUISemanticCore`, `GiftUILayout`, `GiftUIRenderLowering`, a runtime-profile
implementation, execution, failure, capability, backend, raster provider,
concrete resource, platform, driver, OS/RTOS, HAL, or hardware module.

`GiftUIRenderLowering` owns style resolution, semantic-to-resolved-layout
correlation, render validation and preflight, immutable render limits,
caller-owned production workspace, and `RenderProductionResult`. It MUST
depend on `GiftUI`, `GiftUISemanticCore`, `GiftUILayout`,
`GiftUITextResources`, and `GiftUIRenderCore`. It MUST NOT import a
runtime-profile implementation, execution, backend, raster provider,
capability, concrete resource, platform, driver, OS/RTOS, HAL, or hardware
module. It MUST NOT import `GiftUIFailureCore`; the first runtime/owner adapter
that knows both contracts performs the Error Handling mappings.

Dynamic and static runtimes coordinate semantic expansion and layout, then
invoke this one `GiftUIRenderLowering` implementation. They MAY supply
profile-specific semantic-result, resolved-layout, workspace, and sink storage,
but MUST NOT duplicate, replace, or profile-specialize lowering behavior.
`GiftUIRenderLowering` MUST NOT own run-cycle state, frame identity,
publication, backend handoff, or runtime-profile selection.

This dependency is independent of ADR-032's accepted layout-input edge:
`GiftUIRenderLowering` consumes successful semantic and layout results but does
not alter the one-way `GiftUILayout -> GiftUISemanticCore` dependency or either
module's authority.

The rendering-owned edges are:

```text
GiftUISemanticCore --\
GiftUILayout --------> GiftUIRenderLowering ---> GiftUIRenderCore ---> backends
GiftUITextResources -/             |                    |
GiftUI ----------------------------+--------------------+
```

The arrows into `GiftUIRenderLowering` carry complete successful results and
portable paint intent. The edge into `GiftUIRenderCore` carries only normalized
operation meaning and transport; no semantic declaration, container, state,
action/hit map, or layout algorithm crosses it.

Backends and raster providers consume `GiftUIRenderCore` SPI and MUST NOT
depend on `GiftUIRenderLowering`, semantic core, or layout to reinterpret
content. An implementation MUST NOT create a parallel `Color`,
`FontInstanceID`, or `GlyphID` at a lower boundary.

## Types / APIs

`RenderLimits`, `RenderProductionError`, and `RenderProductionResult` are
package SPI owned by `GiftUIRenderLowering`. `RenderPlanHeader`,
`PositionedGlyph`, both operation payloads, and `RenderOperationSink` are
package SPI owned by `GiftUIRenderCore`.

```swift
package enum SemanticRenderScope: Equatable, Sendable {
    case structural
    case clipBoundary
    case text
    case foregroundStyle(Color)
    case background(Color)
}

package protocol SemanticRenderView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var semanticScopeCount: UInt16 { get }
    func scope(at identity: Identity) -> SemanticRenderScope?
    func layoutIdentity(for identity: Identity) -> Identity?
    func childCount(of identity: Identity) -> UInt16?
    func child(of identity: Identity, at index: UInt16) -> Identity?
}

package struct ResolvedRenderTextLine: Equatable, Sendable {
    package let lineIndex: UInt16
    package let bounds: Rect
    package let baseline: Point
    package let clip: Rect
    package let glyphCount: UInt16
}

package struct ResolvedRenderGlyph: Equatable, Sendable {
    package let lineIndex: UInt16
    package let glyphIndex: UInt16
    package let instance: FontInstanceID
    package let glyph: GlyphID
    package let baseline: Point
    package let clip: Rect
}

package protocol ResolvedRenderLayoutView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var layoutScopeCount: UInt16 { get }
    var rootBounds: Rect { get }
    func bounds(of identity: Identity) -> Rect?
    func clip(of identity: Identity) -> Rect?
    func textLineCount(of identity: Identity) -> UInt16?
    func textLine(of identity: Identity, at index: UInt16)
        -> ResolvedRenderTextLine?
    func glyph(of identity: Identity, at index: UInt16)
        -> ResolvedRenderGlyph?
}

package struct RenderLimits: Equatable, Sendable {
    package let maximumOperations: UInt16
    package let maximumPositionedGlyphs: UInt16
    package let maximumClipDepth: UInt16
    package init?(maximumOperations: UInt16,
                  maximumPositionedGlyphs: UInt16,
                  maximumClipDepth: UInt16)
}

package struct RenderSinkCapacity: Equatable, Sendable {
    package let maximumOperations: UInt16
    package let maximumPositionedGlyphs: UInt16
    package init(maximumOperations: UInt16,
                 maximumPositionedGlyphs: UInt16)
}

package enum RenderDamageMode: UInt8, Equatable, Sendable {
    case rootIntersection = 0
    case initializeCompleteSurface = 1
}

package struct RenderPlanHeader: Equatable, Sendable {
    package let surfaceBounds: Rect
    package let damageBounds: Rect
    package let operationCount: UInt16
    package let positionedGlyphCount: UInt16
    package let maximumObservedClipDepth: UInt16
    package init(surfaceBounds: Rect,
                 damageBounds: Rect,
                 operationCount: UInt16,
                 positionedGlyphCount: UInt16,
                 maximumObservedClipDepth: UInt16)
}

package struct PositionedGlyph: Equatable, Sendable {
    package let glyph: GlyphID
    package let baseline: Point
    package init(glyph: GlyphID, baseline: Point)
}

package struct FillRectOperation: Equatable, Sendable {
    package let bounds: Rect
    package let clip: Rect
    package let color: Color
    package init(bounds: Rect, clip: Rect, color: Color)
}

package struct PositionedGlyphOperationHeader: Equatable, Sendable {
    package let instance: FontInstanceID
    package let clip: Rect
    package let color: Color
    package let glyphCount: UInt16
    package init(instance: FontInstanceID,
                 clip: Rect,
                 color: Color,
                 glyphCount: UInt16)
}

package enum RenderProductionError: UInt8, Equatable, Sendable {
    case invalidInput = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case incompatibleTextResource = 3
    case sinkRefused = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

package enum RenderProductionResult: Equatable, Sendable {
    case success(RenderPlanHeader)
    case failure(RenderProductionError)
}

package protocol RenderProductionWorkspace {
    associatedtype Identity: Equatable, Sendable

    var capacity: RenderLimits { get }
    var isActive: Bool { get }
    mutating func acquire() -> Bool
    mutating func reset()
}

package protocol RenderOperationSink {
    var capacity: RenderSinkCapacity { get }
    mutating func begin(_ header: RenderPlanHeader) -> Bool
    mutating func fillRect(_ operation: FillRectOperation) -> Bool
    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool
    mutating func endPositionedGlyphs() -> Bool
    mutating func finish() -> Bool
    mutating func discard()
}

package enum RenderProducer {
    package static func produce<Semantic, Layout, Metrics, Workspace, Sink>(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> RenderProductionResult
    where Semantic: SemanticRenderView,
          Layout: ResolvedRenderLayoutView,
          Metrics: CanonicalTextMetricsView,
          Workspace: RenderProductionWorkspace,
          Sink: RenderOperationSink,
          Semantic.Identity == Layout.Identity,
          Semantic.Identity == Workspace.Identity
}
```

`GiftUISemanticCore` owns `SemanticRenderScope` and `SemanticRenderView`.
`GiftUILayout` owns `ResolvedRenderTextLine`, `ResolvedRenderGlyph`, and
`ResolvedRenderLayoutView`. The remaining declarations are owned as stated
above. These consumer views are package SPI; their concrete storage MAY differ
by profile, but their identity equality, lookup results, and ordering MUST be
identical.

Every identity and index below its declared count MUST resolve. An index at or
above its declared count and a lookup for an identity not reachable from
`rootIdentity` MUST return `nil` and MUST NOT inspect unowned storage.
`layoutIdentity(for:)` returns the exact SPEC-006 identity of the resolved
layout scope that supplies geometry for a semantic scope. A primitive or
layout-modifier scope maps to itself; a transparent or render-only scope maps
to its one flattened layout content scope. This is identity selection from the
corresponding successful SPEC-006/SPEC-007 results, not translation or a new
identity domain. The semantic root's mapping MUST equal `layout.rootIdentity`.
Every returned mapping MUST resolve within `layoutScopeCount`, including
`bounds` and `clip`. The traversal MUST visit exactly `semanticScopeCount`
semantic identities. The number of distinct reachable layout identities MUST
equal `layoutScopeCount`; repeated mappings from render-only or transparent
scopes do not increase that number.

A text scope provides lines in increasing `lineIndex`; its glyph lookup uses
increasing occurrence-wide `glyphIndex`. Line `i` consumes the next
`glyphCount` entries from that occurrence-wide sequence; each entry MUST name
that line and its `glyphIndex` MUST equal the current occurrence-wide cursor.
The sum of line glyph counts defines the occurrence's exact total glyph count.
Missing in-range data, a missing layout mapping in a corresponding successful
pair, duplicate identity, a render modifier with other than one child,
children on a text scope, or disagreement between line and glyph indices is
`.invariantViolation`.

All three render limits MUST be nonzero. The totals are global to one attempt:

- `maximumOperations` counts each emitted fill and each complete non-empty
  positioned-glyph group, not individual glyphs;
- `maximumPositionedGlyphs` counts every glyph across all groups; and
- `maximumClipDepth` counts simultaneously active logical clipping boundaries,
  with the surface/root boundary at depth one and each nested finite frame or
  text-line boundary adding one even when its intersection is unchanged or
  empty.

The producer starts the semantic root at depth one, increments depth when it
enters a `clipBoundary` scope, and counts each text line at one greater than
its text scope's active depth. `clipBoundary` is used exactly for every
SPEC-007 frame scope and for no padding, stack, transparent, style, background,
or text scope. Depth is structural and MUST NOT be inferred from equal or empty
clip rectangles.

A count equal to its limit is valid; reserving the next unit fails before
`begin` as `.capacityExhausted`. Each non-empty text line emits exactly one
glyph group. A group is never split, and its `glyphCount` is the line's exact
count. Empty lines emit no operation but still participate in input
validation.

`RenderProductionWorkspace.capacity` is the maximum limit set the storage can
support. Each supplied limit MUST be less than or equal to the corresponding
workspace capacity. `acquire` is called only after `isActive == false`; failure
then is `.invariantViolation`. `reset` is called exactly once after every
successful acquisition, on both success and failure. The workspace MUST
provide finite storage for active identity, foreground, traversal, preflight,
and clip state without retaining an input or operation after reset.

`RenderSinkCapacity` fields MAY be zero. They report how many complete
operations and positioned glyphs the idle sink can admit in this attempt. The
producer reads this value once after preflight and before `begin`; it MUST NOT
interpret it as backend frame acceptance or downstream raster capacity.

## Behavior

### Style resolution and painter order

The root effective foreground is the exact required `rootForeground` input. A
`foregroundStyle(color)` changes the effective foreground for its complete
modified subtree, including text and later foreground-rendered declarations.
Nested foreground modifiers use the innermost value. Sibling style does not
leak. Color is an ordinary value; no capability or backend may reinterpret it.

For `content.background(color)`, `FillRectOperation.bounds` is the exact
unclipped resolved bounds returned for that scope's `layoutIdentity`, and
`FillRectOperation.clip` is the checked intersection of its resolved logical
clip with `surfaceBounds`. The fill occurs immediately before every operation
belonging to that content subtree. Nested backgrounds follow source modifier
order: the outermost background is emitted first, then inner backgrounds, then
foreground content. Zero-area bounds or an empty final clip emit no operation.
The bounds field is never replaced by the clipped intersection.

Siblings emit in SPEC-006 source order. `ZStack` therefore paints back-to-front
in child source order. Rendering MUST NOT sort, batch across an intervening
operation, reorder by paint/resource, or omit one opaque operation merely
because a later operation fully covers it.

### Text lowering

Each resolved text occurrence uses exactly the instance, glyph identities,
baselines, bounds, and logical clips produced by SPEC-007. Rendering applies
only the effective foreground, intersects each line clip with `surfaceBounds`,
and packages the resolved data into one positioned-glyph group per non-empty
text line. Empty lines emit no glyph operation.

The operation carries no raw string, advance, shaping request, fallback name,
platform font, raster mode, or backend handle. Rendering and its consumers MUST
NOT remeasure, reshape, choose a glyph, add an advance, or alter a baseline.
Every glyph and selected instance MUST resolve through `textMetrics` and name
its exact descriptor resource. A different resource identity, an unknown
instance, or an unknown glyph returns `.incompatibleTextResource` before
`begin`; rendering never substitutes or translates identity.

The glyph source is streamed directly to the sink in occurrence-wide
`glyphIndex` order. The sink and all later consumers may borrow it only during
the enclosing synchronous call. No complete run array, retained operation, or
replay buffer is required.

### Clip and damage

`surfaceBounds` MUST have origin `(0,0)`; another origin is `.invalidInput`.
Its size and exclusive edges are already valid by SPEC-002 construction. The
final root clip is the checked intersection of the resolved root clip and
`surfaceBounds`. Each operation clip is the checked intersection of its exact
resolved logical clip and `surfaceBounds`. Rendering MUST NOT reconstruct
frame ancestry, widen a layout clip, or add a clipping shape. Intersection is
half-open and uses only SPEC-002 checked arithmetic.

For `.rootIntersection`, `damageBounds` is the checked intersection of
`layout.rootBounds` and `surfaceBounds`. For `.initializeCompleteSurface`, it
is exactly `surfaceBounds`, including when root bounds are smaller or empty.
The later coordinator supplies `.initializeCompleteSurface` for a first frame
or when complete-surface initialization is required; render lowering owns no
frame history and never infers that choice. No operation may affect geometry
outside its clip, although its unclipped logical bounds may extend outside the
surface. Fine-grained damage is not required by this contract.

### Atomic production

Production performs two deterministic traversals over the same immutable
borrows. Preflight validates every semantic/layout lookup, resource identity,
checked intersection, operation/glyph count, and observed clip depth and
constructs the exact `RenderPlanHeader`; it emits nothing and retains no
operation list. Streaming repeats canonical traversal and emits the proven
sequence. A changed lookup or numeric field during streaming is
`.invariantViolation`.

Before `begin`, the producer verifies the supplied limits against workspace
capacity and the preflight totals against both limits and the one reported
sink capacity. A shortfall returns `.capacityExhausted`; neither `begin` nor
`discard` is called. With sufficient capacity, `begin(header)` is called once.
If it returns `false`, the result is `.sinkRefused`; the sink remains idle and
`discard` is not called. After `begin` succeeds, operations are delivered in
order and `finish` is called once. Any later `false`, lookup disagreement, or
failure is `.invariantViolation` and calls `discard` exactly once. Successful
`finish` is followed by neither `discard` nor another sink call.

The canonical recording sink stores an indexed sequence of the following
closed value events; this notation defines event order, not a string or byte
serialization:

```text
begin(surfaceBounds, damageBounds, operationCount, glyphCount,
      maximumObservedClipDepth)
fill(bounds, clip, rgb)
beginGlyphs(instance, clip, rgb, count)
glyph(id, baseline) ...
endGlyphs
finish
```

Tests compare nominal identities and numeric fields, never pointers, strings,
metatype addresses, hashes, enum memory bytes, or profile-private storage. A
successful transcript begins with one `begin`, ends with one `finish`, and has
header counts equal to its complete fill/group and glyph events. `discard`
clears the current transcript. A checking sink MAY expose attempted call counts
for failure tests, but attempted events are not a current render result.

## State / Lifecycle

```text
idle -> acquired -> preflighting -> begun -> streaming -> finished -> reset -> idle
                    \-> failed -------------------------------> reset -> idle
                                   \-> discarded -------------> reset -> idle
```

The `GiftUIRenderLowering` workspace and `GiftUIRenderCore` sink are exclusively
borrowed for one attempt. Reentry while `workspace.isActive` returns
`.reentrancyViolation` before inspecting inputs, reading sink capacity,
acquiring storage, calling `begin`, calling `discard`, or resetting the active
attempt. A successful stream is immutable in meaning for its candidate cycle.
All semantic, layout, resource, operation, and payload borrows end before
`produce` returns. No operation or borrowed pointer may be retained or replayed.

## Capability Requirements

The lowering producer does not resolve capabilities. A host must have validated
the required raster-presentation family before the runtime is admitted, but an
effective capability cannot alter operation order, geometry, identity, color,
or failure meaning. Missing required realization is a host/runtime failure,
not a request to emit another operation vocabulary.

## Backend Requirements

A conforming backend-side consumer imports `GiftUIRenderCore`, MUST support
every normalized operation in this contract, consume each once during the
later synchronous frame offer, and
respect exact clips and painter order. It MUST NOT evaluate `View.body`,
interpret stacks/modifiers, perform layout/text shaping, invoke actions, retain
borrowed operations, or substitute resources. Pixel realization and physical
presentation belong to later contracts.

## Error Handling

Failure is deterministic and whole-stream atomic. At one detecting boundary,
precedence is reentrancy, invalid input, arithmetic, capacity, incompatible
resource, explicit begin refusal, then invariant violation. Reentrancy is
always checked first as described under State / Lifecycle. For all other
simultaneously visible conditions, the producer completes checks in the listed
order and stops at the first applicable error.

The first runtime/owner adapter above `GiftUIRenderLowering` maps errors to
SPEC-003 facts:

| Render error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| invalid input | `invalidValue` | `rendering` | `candidateFrame` | `contained` |
| arithmetic overflow | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| capacity exhausted | `capacityExhausted` | `rendering` | `candidateFrame` | `contained` |
| incompatible resource | `invalidValue` | `rendering` | `candidateFrame` | `contained` |
| `begin` refused | `nonRetryableRefusal` | `rendering` | `candidateFrame` | `contained` |
| reentrancy violation | `reentrancyViolation` | `rendering` | `activeCycle` | `safetyNotProven` |
| invariant violation | `invariantViolation` | `rendering` | `runtime` | `safetyNotProven` |

`invalidInput` is limited to a nonzero surface origin or supplied semantic and
layout results whose semantic-root mapping does not equal the layout root.
Failure of an in-range lookup or mutation of an allegedly successful borrowed
result is an invariant violation. Missing or invalid text resources are
rejected during SPEC-005 host validation or SPEC-007 layout and cannot enter
this function; only disagreement between the validated metrics identity and a
resolved glyph operation is `.incompatibleTextResource`.

No diagnostic path may alter the result, allocate as a requirement, or cause a
second production attempt.

## Performance Requirements

- Production MUST be `O(o + g)`, where `o` is semantic/render occurrences and
  `g` is positioned glyphs. Two complete linear traversals are permitted; no
  operation sort or traversal proportional to `o * g` is permitted.
- Static production MUST allocate zero heap bytes after assembly and operate
  with caller-owned finite workspace.
- Direct sink emission MUST be conforming; a complete retained display list
  MUST NOT be required in either profile.
- `Color` MUST occupy exactly 3 bytes; `BoundedText` MUST occupy no more than
  100 bytes and contain its complete admitted payload inline; `RenderLimits`
  MUST occupy exactly 6 bytes; `RenderSinkCapacity` exactly 4 bytes;
  `RenderPlanHeader` no more than 40 bytes; `PositionedGlyph` no more than 12
  bytes; `FillRectOperation` no more than 36 bytes;
  `PositionedGlyphOperationHeader` no more than 60 bytes;
  `RenderProductionError` exactly 1 byte; and `RenderProductionResult` no more
  than 44 bytes on every supported compiler.
- None of those values may contain a reference, existential, closure, string,
  dynamically growing collection, or pointer whose validity contributes to
  value meaning. Borrowing protocols MAY be specialized from concrete static
  types and MUST NOT require existential storage on Embedded Swift.
- Signal Analyzer evidence MUST report declared and observed operation, glyph,
  and clip-depth high-water; workspace capacity and bytes; maximum call-stack
  high-water; allocation count; lowering duration; and incremental linked code,
  read-only data, initialized data, and zero-initialized data. The exact value-
  layout ceilings and zero-allocation rule above are pass/fail requirements.
  Timing, stack, workspace, and linked-section totals are descriptive inputs to
  the later runtime-profile and host-configuration budgets and MUST NOT be
  omitted or represented as passing connected-target evidence.

### Reproducible evidence configuration

The measurement compilers, targets, SDKs, and optimization modes are exactly
those fixed by SPEC-002's current `Reproducible evidence configuration`.
Implementation MUST provide one checked-in driver at
`scripts/contracts/run-spec-008.sh` with these exact invocations:

```text
scripts/contracts/run-spec-008.sh --profile macos-dynamic
scripts/contracts/run-spec-008.sh --profile macos-static
scripts/contracts/run-spec-008.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-008.sh --profile nrf52840-embedded
```

The driver MUST fail on a compiler, target, SDK, optimization, fixture-manifest,
value-layout, allocation, operation result, or transcript mismatch. It records
the complete command line, compiler identity, repository revision, fixture
manifest digest, value layouts, high-water values, timing method and samples,
section deltas, and link maps. ARMv6 and nRF52840 runs are cross-build and
inspection evidence and require no connected board or display.

## Compatibility

The public declarations are MVP source contract but establish no stable ABI.
Dynamic text conveniences must reject or adapt content into `BoundedText`
before portable lowering and must produce identical operations when admitted.
A future retained producer may generate this vocabulary without changing
client, semantic, layout, or backend contracts.

## Testing Requirements

- `Tests/ContractFixtures/SPEC008/fixtures.yaml` MUST be the canonical corpus
  manifest. Each case declares a stable symbolic name; semantic-render events;
  exact identity tokens; resolved bounds, clips, clip depths, lines, glyphs,
  and resource identity; surface bounds; damage mode; root foreground; render,
  workspace, and sink limits; expected result; expected ordered recording
  events; sink call counts; and expected SPEC-003 mapping. The driver rejects
  duplicate names, missing fields, unknown cases, or unreferenced fixture data.
- Compile fixtures cover `Color`, all named colors, bounded/static/integer text,
  modifier chaining, custom views, and both profiles. Negative fixtures prove
  that `clear`, alpha construction, and portable `String` initialization are
  absent.
- UTF-8 fixtures cover empty, 96-byte, 97-byte, malformed, embedded and trailing
  NUL, ASCII, degree sign, replacement scalar, `Int32.min`, `-1`, `0`, `1`, and
  `Int32.max`. They prove `Text(StaticString)` preserves an invalid marker and
  that SPEC-007 rejects it before rendering without trap, repair, or truncation.
- Semantic/layout correlation fixtures cover unequal roots, independent
  semantic and layout counts, declared-count mismatches, missing and duplicate
  identities, transparent/render-only mappings, invalid child arity, every
  out-of-range index, and every prohibited in-range `nil` lookup.
- Golden operation events cover nested foreground/background modifiers,
  siblings, ZStack painter order, empty/zero bounds, partial/off-surface clips,
  empty clips, unchanged nested clip intersections, whole-root damage, explicit
  complete-surface initialization, exact RGB values, and unclipped fill bounds.
- Text events prove exact instance/glyph identity, line and occurrence-wide
  indices, baseline, clip, paint, exactly one group per non-empty line, empty-
  line omission, incompatible-resource rejection, and no raw-string payload.
- Limit tests exercise exactly-at and one-over global operation, glyph, and
  clip-depth bounds; workspace shortfall; sink-capacity shortfall; `begin`
  refusal; refusal by every post-begin method; immutable-input disagreement;
  nested reentry; workspace reset; and exact discard behavior.
- Recording, dynamic, and static fixtures MUST produce equal canonical event
  sequences, headers, results, and SPEC-003 mappings. Equality is field-by-field
  value equality, not profile-private memory or byte serialization. Static
  production allocates zero heap bytes.
- Import tests prove `GiftUIRenderCore` depends only on `GiftUI` and
  `GiftUITextResources`; prove `GiftUIRenderLowering` is the only rendering
  contract target that imports both semantic and layout contracts; and reject
  semantic/layout/lowering authority in backends or concrete integrations.
- `Tests/ContractFixtures/SPEC008/signal-analyzer.yaml` MUST enumerate every
  required analyzer label, bounded value, status and error text, foreground,
  background, and maximum hierarchy variant. It declares the exact fixture
  limits used by all four profile runs and MUST fit without a pixel backend.
- The four commands under Reproducible evidence configuration MUST run the
  complete corpus. Host-only, cross-build, simulator, and connected-hardware
  evidence remain distinct; no connected hardware is required for this
  Specification's approval seam.

## Acceptance Criteria

- [ ] **RD-001:** The exact public text/color/style declarations compile using
  only `import GiftUI`; `clear`, alpha construction, and portable unbounded
  `String` initialization fail their negative compile fixtures.
- [ ] **RD-002:** Every bounded-text boundary and integer fixture has the exact
  admitted bytes; invalid `Text(StaticString)` declarations reach SPEC-007's
  `.invalidDeclaration` without trap, allocation, repair, truncation, layout
  publication, or render invocation.
- [ ] **RD-003:** Every valid canonical case emits the exact header, fills,
  positioned-glyph groups, and event order declared by `fixtures.yaml`, with
  exact unclipped bounds, final clips, identities, indices, baselines, and RGB.
- [ ] **RD-004:** Root-intersection and complete-surface initialization damage
  match their explicit modes for ordinary, smaller-root, empty-root, and
  off-surface cases; render lowering retains no frame-history state.
- [ ] **RD-005:** Every semantic/layout mismatch, checked overflow, workspace or
  sink capacity edge, incompatible resource, begin refusal, post-begin refusal,
  reentry, and invariant case returns the exact local error and SPEC-003 fact,
  follows the specified begin/discard/reset call counts, and publishes no
  partial current transcript.
- [ ] **RD-006:** No render or backend path remeasures text, changes glyphs or
  positions, substitutes or translates a resource identity, retains a borrow,
  or requires a complete glyph-run array or retained display list.
- [ ] **RD-007:** Recording, dynamic, and static fixtures produce equal
  field-by-field event sequences, headers, results, and failure mappings; all
  global limit totals and exactly-at/one-over behavior match the contract.
- [ ] **RD-008:** All value-layout ceilings, the four evidence commands, and the
  static zero-allocation requirement pass; each command records the required
  compiler, fixture digest, high-water, timing, section, and link-map evidence.
- [ ] **RD-009:** The Signal Analyzer manifest covers every required label,
  bounded value, status, error, opaque foreground, rectangular background, and
  maximum hierarchy variant and fits its declared limits in all four profiles
  without a pixel backend.
- [ ] **RD-010:** Import-graph tests preserve the
  semantic/layout/`GiftUIRenderLowering`/`GiftUIRenderCore`/backend boundary,
  keep both runtime profiles on the shared lowering implementation, and
  preserve the `GiftUITextResources` identity owner.
- [ ] **RD-011:** Review finds no rasterization, pixel encoding, frame
  acceptance/disposition, capability resolution, runtime-profile selection,
  platform, driver, hardware, or Canvas/stroke contract in this Specification.

## Implementation Notes

Existing `Color`, `RenderOperation`, display-list, and recording-backend code
is migration evidence only. Conforming reuse must replace host-sized or
unbounded values, raw strings, retained-only storage, and backend-owned text
placement with this contract. Migration MUST place shared style resolution and
operation production in `GiftUIRenderLowering`; it MUST NOT move that work into
`GiftUIRenderCore` or duplicate it in the dynamic and static runtimes.

## Open Issues

None. Stroke operations for Canvas enter through the separately governed
DRAWING contract and its accepted ADRs; they are not silently added here.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md): richer
  text surface.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md):
  advanced resource/raster delivery.
- [FW-004](../future-work/fw-004-retained-render-tree.md): optional retained
  producer. Current MVP scope and this direct-stream contract remain unchanged.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-009](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-021](../adrs/adr-021-canonical-text-geometry.md)
- [ADR-022](../adrs/adr-022-positioned-glyph-render-operation.md)
- [ADR-023](../adrs/adr-023-exact-font-resource-identity.md)
- [ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md)
- [MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [Legacy GiftUI Framework Specification](../engineering/POC_HISTORICAL_BASELINE.md)
