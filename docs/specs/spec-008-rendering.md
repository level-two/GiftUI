---
id: SPEC-008
feature: giftui-mvp-architecture
title: Normalized Rendering Contract
status: draft
authors:
  - codex
created: 2026-08-25
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-003
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-021
  - ADR-022
  - ADR-023
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-005
  - SPEC-006
  - SPEC-007
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

## Summary

This Specification defines the Wave 3 rendering contract: portable bounded
`Text`, opaque RGB `Color`, `foregroundStyle`, rectangular `background`,
runtime-neutral style resolution, and deterministic lowering of resolved
layout into a normalized ordered stream of rectangle-fill and positioned-glyph
operations.
It also defines clipping, whole-root damage, bounded production, and the
recording sink used to verify rendering without rasterization.

This document is a `draft`. It does not authorize implementation until it has
completed human review and approval.

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
- ADR-005, ADR-006, ADR-008, ADR-021, ADR-022, and ADR-023 are accepted.
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
- **ADR-021** prohibits rendering and backends from measuring, shaping,
  selecting fallback, or changing logical text geometry.
- **ADR-022** requires a streamable positioned-glyph operation with exact
  instance identity, complete glyphs and positions, opaque paint, and clip.
- **ADR-023** requires nominal identities from `GiftUITextResources`, exact
  resource compatibility, synchronous borrowing, and no translated identity.

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

**Clip**: A checked rectangular intersection in logical coordinates. An empty
clip is valid and causes covered draw operations to be omitted.

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

Both `Text` initializers preserve the same admitted scalar sequence. They do
not perform shaping or choose a font. A dynamic-only module MAY add `String`
and interpolation conveniences, but `GiftUI` MUST NOT expose an unbounded
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
package struct RenderLimits: Equatable, Sendable {
    package let maximumOperations: UInt16
    package let maximumPositionedGlyphs: UInt16
    package let maximumClipDepth: UInt16
    package init?(maximumOperations: UInt16,
                  maximumPositionedGlyphs: UInt16,
                  maximumClipDepth: UInt16)
}

package struct RenderPlanHeader: Equatable, Sendable {
    package let surfaceBounds: Rect
    package let damageBounds: Rect
    package let operationCount: UInt16
    package let positionedGlyphCount: UInt16
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
}

package struct PositionedGlyphOperationHeader: Equatable, Sendable {
    package let instance: FontInstanceID
    package let clip: Rect
    package let color: Color
    package let glyphCount: UInt16
}

package enum RenderProductionError: UInt8, Equatable, Sendable {
    case invalidInput = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case missingForeground = 3
    case incompatibleTextResource = 4
    case sinkRefused = 5
    case reentrancyViolation = 6
    case invariantViolation = 7
}

package enum RenderProductionResult: Equatable, Sendable {
    case success(RenderPlanHeader)
    case failure(RenderProductionError)
}

package protocol RenderOperationSink {
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
```

All three limits MUST be nonzero. `maximumOperations` counts each fill and each
complete positioned-glyph group, not each glyph. Glyph groups MUST contain
`1...maximumPositionedGlyphs` entries, all using the one header instance,
paint, and clip. A producer may split adjacent text into multiple groups only
at text-line or text-occurrence boundaries; splitting MUST be identical across
profiles and MUST NOT change painter order.

The `GiftUIRenderLowering` entry point synchronously borrows a complete
semantic result, the corresponding successful SPEC-007 result, the selected
validated text package,
surface bounds, root foreground, immutable limits, and caller-owned workspace
and sink. It returns one `RenderProductionResult` and retains no borrow.

## Behavior

### Style resolution and painter order

The root effective foreground is a required lowering input. A
`foregroundStyle(color)` changes the effective foreground for its complete
modified subtree, including text and later foreground-rendered declarations.
Nested foreground modifiers use the innermost value. Sibling style does not
leak. Color is an ordinary value; no capability or backend may reinterpret it.

For `content.background(color)`, the fill operation uses the exact resolved
bounds of `content`, intersected with all inherited clips, and occurs
immediately before every operation belonging to that content subtree. Nested
backgrounds follow source modifier order: the outermost background is emitted
first, then inner backgrounds, then foreground content. A zero-area or empty-
clip fill emits no operation.

Siblings emit in SPEC-006 source order. `ZStack` therefore paints back-to-front
in child source order. Rendering MUST NOT sort, batch across an intervening
operation, reorder by paint/resource, or omit one opaque operation merely
because a later operation fully covers it.

### Text lowering

Each resolved text occurrence uses exactly the instance, glyph identities,
baselines, bounds, and clip produced by SPEC-007. Rendering applies only the
effective foreground and packages that resolved data into one positioned-
glyph group per non-empty text line. Empty lines emit no glyph operation.

The operation carries no raw string, advance, shaping request, fallback name,
platform font, raster mode, or backend handle. Rendering and its consumers MUST
NOT remeasure, reshape, choose a glyph, add an advance, or alter a baseline.
Every glyph and selected instance MUST belong to the assembly-validated exact
SPEC-005 resource package.

The glyph source is streamed directly to the sink in source scalar order. The
sink and all later consumers may borrow it only during the enclosing
synchronous offer. No complete run array, retained operation, or replay buffer
is required.

### Clip and damage

`surfaceBounds` MUST have origin `(0,0)` and a valid non-negative size. The
root clip is `surfaceBounds`. Each child clip is the checked intersection of
its inherited clip and resolved bounds when the declaration establishes a
rectangular clipping boundary. For Wave 3, the root and finite frame bounds are
clipping boundaries; stacks, padding, foreground, and background do not add a
different shape. Intersection is half-open on maximum edges.

Wave 3 uses deterministic whole-root damage. `damageBounds` is the intersection
of the successful root bounds and surface bounds; on the first frame or when a
later coordinator requires initialization, it is the complete surface bounds.
No operation may address geometry outside its clip, although its unclipped
logical bounds may extend outside the surface. Fine-grained damage is not
required by this contract.

### Atomic production

Before `begin`, `GiftUIRenderLowering` MUST complete validation and prove that
declared limits and sink-reported capacity admit the whole candidate stream.
`begin` is called once, operations are delivered in order, and `finish` is
called once.
Any refusal or failure calls `discard` exactly once and the stream is not a
current render result. A sink that reports insufficient capacity maps to
`.capacityExhausted`; a sink that reports sufficient capacity and later
refuses maps to `.invariantViolation`, not backpressure.

The recording sink transcript is exactly:

```text
begin(surfaceBounds, damageBounds, operationCount, glyphCount)
fill(bounds, clip, rgb)
beginGlyphs(instance, clip, rgb, count)
glyph(id, baseline) ...
endGlyphs
finish
```

Tests compare nominal identities and numeric fields, never pointers, strings,
metatype addresses, hashes, or profile-private storage.

## State / Lifecycle

```text
idle -> validating -> begun -> streaming -> finished -> idle
              \-----------> failed/discarded ------> idle
```

The `GiftUIRenderLowering` workspace and `GiftUIRenderCore` sink are exclusively
borrowed for one attempt. Reentry fails
before `begin`. A successful stream is immutable in meaning for its candidate
cycle. Resource and payload borrows end before the synchronous consumer call
returns. No operation or borrowed pointer may be retained or replayed.

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
precedence is invalid input, arithmetic, capacity, foreground, resource,
explicit early sink refusal, reentrancy, then invariant violation.

The first runtime/owner adapter above `GiftUIRenderLowering` maps errors to
SPEC-003 facts:

| Render error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| invalid input | `invalidValue` | `rendering` | `candidateFrame` | `contained` |
| arithmetic overflow | `arithmeticOverflow` | `rendering` | `candidateFrame` | `contained` |
| capacity exhausted | `capacityExhausted` | `rendering` | `candidateFrame` | `contained` |
| missing foreground/resource | `requiredFacilityUnavailable` | `rendering` | `runtime` | `contained` |
| incompatible resource | `invalidValue` | `rendering` | `candidateFrame` | `contained` |
| sink refused before begin | `nonRetryableRefusal` | `rendering` | `candidateFrame` | `contained` |
| reentrancy violation | `reentrancyViolation` | `rendering` | `activeCycle` | `safetyNotProven` |
| invariant violation | `invariantViolation` | `rendering` | `runtime` | `safetyNotProven` |

No diagnostic path may alter the result, allocate as a requirement, or cause a
second production attempt.

## Performance Requirements

- Production MUST be `O(o + g)`, where `o` is semantic/render occurrences and
  `g` is positioned glyphs; no operation sort is permitted.
- Static production MUST allocate zero heap bytes after assembly and operate
  with caller-owned finite workspace.
- Direct sink emission MUST be conforming; a complete retained display list
  MUST NOT be required in either profile.
- `Color` MUST occupy exactly 3 bytes. `PositionedGlyph` MUST contain no
  reference, existential, closure, string, or collection.
- Signal Analyzer fixtures MUST report operation/glyph high-water, workspace
  bytes, stack high-water, and generated code-size delta under the later host
  evidence configuration.

## Compatibility

The public declarations are MVP source contract but establish no stable ABI.
Dynamic text conveniences must reject or adapt content into `BoundedText`
before portable lowering and must produce identical operations when admitted.
A future retained producer may generate this vocabulary without changing
client, semantic, layout, or backend contracts.

## Testing Requirements

- Compile fixtures for `Color`, all named colors, bounded/static/integer text,
  modifier chaining, custom views, and both profiles; negative fixtures prove
  that `clear` and portable `String` initialization are absent.
- UTF-8 fixtures cover empty, 96-byte, 97-byte, malformed, ASCII, degree sign,
  replacement-scalar, and every `Int32` formatting boundary.
- Golden operation transcripts cover nested foreground/background modifiers,
  siblings, ZStack painter order, empty/zero bounds, partial/off-surface clips,
  complete clips, whole-root damage, and exact RGB values.
- Text transcripts prove exact instance/glyph identity, baseline, clip, paint,
  grouping, resource mismatch rejection, and no raw-string payload.
- Limit tests exercise exactly-at and one-over operation/glyph/clip bounds,
  preflight refusal, late refusal, reentry, and atomic discard.
- Dynamic and static fixtures MUST produce byte-for-byte equal transcripts,
  summaries, and SPEC-003 mappings; static production allocates zero heap bytes.
- Import tests prove `GiftUIRenderCore` depends only on `GiftUI` and
  `GiftUITextResources`; prove `GiftUIRenderLowering` is the only rendering
  contract target that imports both semantic and layout contracts; and reject
  semantic/layout/lowering authority in backends or concrete integrations.

## Acceptance Criteria

- [ ] Required public text/color/style declarations compile using only
  `import GiftUI`; excluded alpha/unbounded surfaces do not compile.
- [ ] Canonical fixtures emit exact fills and positioned glyph groups in the
  specified painter order with complete clip, identity, baseline, and RGB data.
- [ ] No render or backend path remeasures text, changes glyphs/positions, or
  substitutes a resource.
- [ ] Every capacity, invalid input, overflow, missing resource, sink refusal,
  reentrancy, and invariant case maps exactly and publishes no partial stream.
- [ ] Dynamic and static recordings are identical, and static production uses
  no heap allocation after assembly.
- [ ] The Signal Analyzer fixture renders all required labels, values, status,
  errors, opaque foreground colors, and rectangular backgrounds within declared
  limits without a pixel backend.
- [ ] Import-graph tests preserve the
  semantic/layout/`GiftUIRenderLowering`/`GiftUIRenderCore`/backend boundary,
  keep both runtime profiles on the shared lowering implementation, and
  preserve the `GiftUITextResources` identity owner.

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
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [Legacy GiftUI Framework Specification](../GiftUI_Framework_Spec.md)
