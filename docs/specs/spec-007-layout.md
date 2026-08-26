---
id: SPEC-007
feature: giftui-mvp-architecture
title: Proposal-Based Layout Contract
status: approved
authors:
  - codex
created: 2026-08-25
updated: 2026-08-26
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
  - ADR-021
  - ADR-023
  - ADR-032
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-005
  - SPEC-006
  - SPEC-008
  - SPEC-009
  - SPEC-011
  - SPEC-012
related_future_work:
  - FW-001
  - FW-002
  - FW-005
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-007: Proposal-Based Layout Contract

> **Approval status:** Approved by explicit maintainer authorization. The
> governing Proposal and RFCs, accepted architectural decisions, and approved
> Foundation, Failure, Text Resource, and Declarative contracts are
> authoritative prerequisites.

## Summary

This Specification defines the Wave 3 layout contract for the Signal Analyzer:
proposal-based measurement and placement, vertical, horizontal, and overlay
stacks, flexible spacers, explicit spacing and alignment, padding, frame
constraints, canonical text measurement, resolved hit geometry, and bounded
checked layout production. It defines one profile-neutral result and recording
seam; it does not define rendering, input dispatch, or runtime storage.

This document is `approved` and authorizes implementation under this contract.

## Scope

This contract applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840/Zephyr static configurations. It owns:

- Rank 1 client declarations and modifiers required by MVP Scope;
- deterministic measurement and placement from Semantic Core's borrowed
  layout-facing view;
- canonical left-to-right text measurement and positioned glyph production;
- finite layout limits, atomic failure, and a recording-layout seam; and
- logical bounds used later by rendering and hit-map production.

## Goals

- Produce identical logical bounds and positioned text for equivalent input in
  both runtime profiles.
- Cover every Signal Analyzer stack, spacer, padding, frame, alignment, and
  text-layout requirement without a general constraint solver.
- Permit conformance testing without a renderer, backend, runtime, or hardware.
- Make arithmetic, capacity, invalid input, and validated-resource invariant
  failures explicit.

## Non-goals

- Define colors, painting, render operations, clipping/damage lowering, pixels,
  backend SPI, frame handoff, input admission, action activation, or state.
- Define public `Text`; SPEC-008 owns that declaration and its semantic payload.
- Support grids, scrolling, safe areas, priorities, custom `Layout`, baselines,
  fractional geometry, complex-script shaping, bidirectional or vertical text,
  rich text, truncation, hyphenation, or font fallback.
- Require retained layout or render trees. Profile implementations may retain
  derived storage only under later runtime-profile contracts.

## Dependencies

### Lifecycle prerequisites

- PROPOSAL-003 is accepted; RFC-002 and RFC-003 are approved.
- ADR-005, ADR-006, ADR-008, ADR-009, ADR-021, ADR-023, and ADR-032 are
  accepted.
- MVP Scope requires stacks, spacer, spacing, alignment, padding, frame, text,
  and shared logical behavior across all four configurations.

### Contract prerequisites

- [SPEC-002](spec-002-portable-foundation.md) owns `GeometryScalar`, `Point`,
  `Size`, `Rect`, `ProposedSize`, and checked arithmetic.
- [SPEC-003](spec-003-failure-outcomes-and-containment.md) owns cross-layer
  failure facts and outcomes.
- [SPEC-005](spec-005-text-resources.md) owns exact text-resource identities,
  metrics, mappings, validation, and resource lifetime.
- [SPEC-006](spec-006-declarative-view-semantics.md) owns expansion, structural
  identity, modifier order, and the typed traversal seam.

SPEC-008 depends on the completed declarations and layout-result semantics
defined here. Approval of SPEC-008 MUST NOT precede approval of this contract.

## Related ADRs

- **ADR-005** assigns proposal-based layout and semantic-to-layout lowering to
  GiftUI above a backend-neutral render boundary.
- **ADR-006** requires profile-equivalent layout, operation order, identity,
  and deterministic failure meaning.
- **ADR-008** requires the compiler-enforced acyclic target graph, one-package
  topology, and narrow `GiftUI` client import surface that ADR-032 refines.
- **ADR-032** makes `GiftUISemanticCore` the owner of one narrow borrowed
  layout-facing view and requires the direct one-way
  `GiftUILayout -> GiftUISemanticCore` dependency without transferring
  semantic or layout authority.
- **ADR-009** fixes checked integer geometry and excludes a general solver.
- **ADR-021** makes layout the sole text geometry, line-breaking, glyph-choice,
  measurement, and logical-position authority.
- **ADR-023** requires use of the exact validated resource identity and the
  `GiftUITextResources` contracts without parallel identities or fallback.

## Terminology

**Proposal**: A `ProposedSize`; an absent axis is unconstrained, not infinite.

**Ideal size**: The size a scope requests after measuring its content and
applying its own layout semantics, before a present parent proposal caps the
scope's resolved size.

**Layout scope**: One primitive or layout-modifier scope identified by the
exact SPEC-006/ADR-032 identity relation and assigned one resolved `Rect` and
one inherited logical clip. Transparent structural occurrences are traversal
structure, not layout scopes.

**Flexible spacer**: An unmodified `Spacer` that is a direct child of an
`HStack` or `VStack`. It contributes `minLength` on that stack's main axis,
zero on the cross axis, and receives an equal share of any remaining
non-negative main-axis extent.

**Resolved size**: The ideal size capped independently on each axis by a
present parent proposal. A parent proposal may prevent a fixed or minimum
frame request from being fully satisfied; this is clipping, not invalid input.

**Logical clip**: A `Rect` formed only by checked intersection of the root
clip, enclosing frame bounds, resolved text bounds, and text-line bounds as
specified here. It is layout output, not backend pixel clipping or damage
selection.

**Resolved layout**: The complete, immutable-in-meaning set of scope bounds
and clips, text line/glyph positions, and hit geometry staged by one successful
attempt.

## Public Contract

Portable Presentation uses only `import GiftUI`. The following declarations
are Client API and MUST lower through SPEC-006's typed primitive/modifier seam.
They MUST NOT perform layout while their values are initialized or `body` is
evaluated.

```swift
public enum HorizontalAlignment: UInt8, Sendable {
    case leading = 0
    case center = 1
}

public enum VerticalAlignment: UInt8, Sendable {
    case top = 0
    case center = 1
    case bottom = 2
}

public struct Alignment: Equatable, Sendable {
    public let horizontal: HorizontalAlignment
    public let vertical: VerticalAlignment
    public init(
        horizontal: HorizontalAlignment,
        vertical: VerticalAlignment
    )
    public static let center: Alignment
    public static let leading: Alignment
}

public struct EdgeInsets: Equatable, Sendable {
    public let top: GeometryScalar
    public let leading: GeometryScalar
    public let bottom: GeometryScalar
    public let trailing: GeometryScalar
    public init?(top: GeometryScalar, leading: GeometryScalar,
                 bottom: GeometryScalar, trailing: GeometryScalar)
}

public struct EdgeSet: OptionSet, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let top: EdgeSet
    public static let leading: EdgeSet
    public static let bottom: EdgeSet
    public static let trailing: EdgeSet
    public static let horizontal: EdgeSet
    public static let vertical: EdgeSet
    public static let all: EdgeSet
}

public enum FrameLimit: Equatable, Sendable {
    case points(GeometryScalar)
    case infinity
}

public struct VStack<Content: View>: View {
    public init(alignment: HorizontalAlignment = .center,
                spacing: GeometryScalar = 0,
                @ViewBuilder content: () -> Content)
}

public struct HStack<Content: View>: View {
    public init(alignment: VerticalAlignment = .center,
                spacing: GeometryScalar = 0,
                @ViewBuilder content: () -> Content)
}

public struct ZStack<Content: View>: View {
    public init(alignment: Alignment = .center,
                @ViewBuilder content: () -> Content)
}

public struct Spacer: View {
    public init(minLength: GeometryScalar = 0)
}

public extension View {
    func padding(_ length: GeometryScalar) -> some View
    func padding(_ edges: EdgeSet, _ length: GeometryScalar) -> some View
    func padding(_ insets: EdgeInsets) -> some View
    func frame(width: GeometryScalar? = nil,
               height: GeometryScalar? = nil,
               alignment: Alignment = .center) -> some View
    func frame(minWidth: GeometryScalar? = nil,
               maxWidth: FrameLimit? = nil,
               minHeight: GeometryScalar? = nil,
               maxHeight: FrameLimit? = nil,
               alignment: Alignment = .center) -> some View
}
```

`Alignment.center` is exactly `(.center, .center)` and `Alignment.leading` is
exactly `(.leading, .center)`. `EdgeSet.top`, `.leading`, `.bottom`, and
`.trailing` have raw values `1 << 0`, `1 << 1`, `1 << 2`, and `1 << 3`;
`.horizontal` is
`[.leading, .trailing]`, `.vertical` is `[.top, .bottom]`, and `.all` is the
union of all four. An empty set is valid and applies no inset. Raw bits 4...7
are reserved; any padding declaration containing one is invalid.

All lengths, every present optional dimension, finite limit, and inset MUST be
non-negative. `EdgeInsets.init` returns `nil` for an invalid field. Every other
public modifier or container initializer MUST preserve even an invalid
declaration so layout can reject it as `.invalidDeclaration`; it MUST NOT
clamp, take an absolute value, or trap as its sole behavior.
`FrameLimit.points` is invalid when its value is negative. For one axis, a
finite maximum smaller than the minimum is invalid. Fixed `width` or `height`
is both the requested minimum and maximum on that axis. A `nil` field applies
no constraint, and a frame with every dimension `nil` preserves its child's
proposal, resolved size, origin, and clip; its alignment has no observable
effect.

## Module Contract

`GiftUI` owns only the public declarations and typed semantic payloads.
`GiftUILayout` owns measurement, placement, canonical text layout, layout
limits/results, and recording fixtures. Under
[ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md),
`GiftUISemanticCore` owns one package-scoped, read-only layout-facing view over
a complete successful semantic result, and `GiftUILayout` MUST import and
synchronously borrow that view. `GiftUISemanticCore` MUST NOT import
`GiftUILayout`. `GiftUILayout` MUST also depend on `GiftUI` and
`GiftUITextResources` and MUST NOT import render, runtime-profile, backend,
capability, platform, driver, OS/RTOS, HAL, or hardware modules.

The borrowed view MUST expose only exact structural or modifier-scope
identity, semantic occurrence kind, typed layout-relevant payloads, canonical
ordered children, ordered layout modifier scopes and payloads, ordinary
semantic identity for action-bearing occurrences without callable payloads or
committed generations, and borrowed text content associated with its semantic
occurrence. Its concrete storage MAY differ across recording, static, and
dynamic producers, but identity equality, ordering, and payload meaning MUST
be equal. Layout MUST NOT retain any view, node, payload, identity, declaration
value, text source, or action after the layout entry point returns.

`GiftUILayout` MUST NOT import `GiftUIFailureCore`. The first owner adapter that
knows both layout errors and SPEC-003 facts performs the mapping under Error
Handling. `GiftUIRenderCore` is a sibling and MUST NOT be imported by layout.
`GiftUIRenderLowering` may consume successful semantic and layout results as
SPEC-008's shared higher lowering owner, but may not grant rendering authority
to layout or layout authority to rendering. That independent consumer edge
does not alter ADR-032's input edge into `GiftUILayout`.

## Types / APIs

The package SPI below is normative in meaning. Concrete workspace and sink
storage may differ by profile.

`GiftUISemanticCore` MUST own the package-SPI semantic layout-view protocol and
closed payload vocabulary below. A structural scope with no primitive and no
layout modifier is transparent: its children are flattened into its nearest
layout parent in canonical source order. The semantic root and every modifier
scope MUST resolve to exactly one layout child after that flattening; otherwise
layout rejects the declaration. This rule prevents an implicit stack or
overlay from being invented for an uncontained fixed group.

```swift
package enum SemanticLayoutPrimitive: Equatable, Sendable {
    case proxy
    case vStack(alignment: HorizontalAlignment, spacing: GeometryScalar)
    case hStack(alignment: VerticalAlignment, spacing: GeometryScalar)
    case zStack(alignment: Alignment)
    case spacer(minLength: GeometryScalar)
    case text
}

package enum SemanticLayoutModifier: Equatable, Sendable {
    case passthrough
    case padding(edges: EdgeSet, length: GeometryScalar)
    case paddingInsets(EdgeInsets)
    case fixedFrame(width: GeometryScalar?, height: GeometryScalar?,
                    alignment: Alignment)
    case flexibleFrame(minWidth: GeometryScalar?, maxWidth: FrameLimit?,
                       minHeight: GeometryScalar?, maxHeight: FrameLimit?,
                       alignment: Alignment)
}

package protocol SemanticLayoutView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var scopeCount: UInt16 { get }

    func primitive(at identity: Identity) -> SemanticLayoutPrimitive?
    func childCount(of identity: Identity) -> UInt16?
    func child(of identity: Identity, at index: UInt16) -> Identity?

    func modifierCount(of identity: Identity) -> UInt16?
    func modifierScope(of identity: Identity, at index: UInt16) -> Identity?
    func modifier(of identity: Identity, at index: UInt16)
        -> SemanticLayoutModifier?

    func textScalarCount(of identity: Identity) -> UInt16?
    func textScalar(of identity: Identity, at index: UInt16) -> UInt32?
}

package struct LayoutLimits: Equatable, Sendable {
    package let maximumScopes: UInt16
    package let maximumDepth: UInt16
    package let maximumTextScalars: UInt16
    package let maximumTextLines: UInt16
    package let maximumPositionedGlyphs: UInt16
    package init?(maximumScopes: UInt16, maximumDepth: UInt16,
                  maximumTextScalars: UInt16, maximumTextLines: UInt16,
                  maximumPositionedGlyphs: UInt16)
}

package struct LayoutSummary: Equatable, Sendable {
    package let scopeCount: UInt16
    package let textScalarCount: UInt16
    package let textLineCount: UInt16
    package let positionedGlyphCount: UInt16
    package let maximumObservedDepth: UInt16
    package let rootBounds: Rect
}

package enum LayoutError: UInt8, Equatable, Sendable {
    case invalidDeclaration = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case reentrancyViolation = 3
    case invariantViolation = 4
}

package enum LayoutResult: Equatable, Sendable {
    case success(LayoutSummary)
    case failure(LayoutError)
}

package protocol LayoutResultSink {
    associatedtype Identity: Equatable, Sendable
    mutating func begin(summary: LayoutSummary) -> Bool
    mutating func stageScope(identity: Identity,
                             bounds: Rect, clip: Rect) -> Bool
    mutating func stageTextLine(identity: Identity,
                                lineIndex: UInt16, bounds: Rect,
                                baseline: Point, clip: Rect) -> Bool
    mutating func stageGlyph(identity: Identity,
                             lineIndex: UInt16, glyphIndex: UInt16,
                             instance: FontInstanceID, glyph: GlyphID,
                             baseline: Point, clip: Rect) -> Bool
    mutating func publish() -> Bool
    mutating func discard()
}
```

`Identity` MUST be the exact `SemanticLayoutView.Identity`; the sink MUST NOT
translate, hash, or reconstruct it. The sole package layout entry point is
generic over one borrowing `SemanticLayoutView`, one borrowing validated
`CanonicalTextMetricsView`, and one `LayoutResultSink` with the same identity.
It also receives one valid root `ProposedSize`, immutable `LayoutLimits`, and
exclusive `inout` caller-owned workspace and sink, and returns `LayoutResult`.
The concrete workspace representation is profile-private, but it MUST report
all five capacities before acquisition, provide bounded measurement and
placement storage indexed by the exact identity, and support explicit
acquire/reset operations without retaining semantic input.

All five limits MUST be nonzero. `maximumScopes` counts every primitive and
modifier scope staged by layout; transparent structural occurrences do not
count. The traversed total MUST equal `SemanticLayoutView.scopeCount`; a
mismatch is `.invariantViolation`. `maximumDepth` counts simultaneously active
staged scopes with the first layout scope below the semantic root at depth one.
`maximumTextScalars` counts every supplied scalar value, including both scalar
values in CRLF. `maximumTextLines` counts every explicit or wrapped line,
including the one line of empty text. `maximumPositionedGlyphs` counts every
non-line-break scalar after replacement mapping. Each total is global to one
attempt. A count equal to its limit is valid; the next reservation fails before
staging or lookup and returns `.capacityExhausted`.

Semantic access at an index below its declared count MUST succeed. A missing
identity, child, modifier, or scalar inside a declared range is
`.invariantViolation`; an index at or above the count returns `nil` normally.
An invalid Unicode scalar or invalid public payload is
`.invalidDeclaration`. The validated metrics view contains the one MVP
instance at index zero; failure to retrieve that instance, mapping, or metric
after validation is `.invariantViolation`.

`.proxy` is a staged semantic occurrence with exactly one flattened layout
child. It proposes the same size to that child, adopts the child's ideal and
resolved size, places it at the same origin, and adds no clip. It exists for
layout-neutral semantic occurrences, including an action-bearing occurrence
whose identity later interaction must correlate without passing its action.
Any other child count is `.invalidDeclaration`.

`.passthrough` is a staged modifier scope with no measurement, placement, or
clip effect; its bounds and clip equal its single child's. Semantic Core may
emit it only for a modifier whose approved owning Specification explicitly
states that it has no layout effect. An unknown or not-yet-approved modifier
is `.invalidDeclaration`, not an implicit passthrough.

After measurement and complete count validation, the producer calls
`begin(summary:)` once. `false` means the idle sink cannot admit the complete
summary and returns `.capacityExhausted` without calling `discard`. After
`begin` succeeds, every stage call occurs in canonical depth-first order:
outermost modifier scope to innermost modifier scope, then the primitive
scope, then primitive children in source order. A text primitive's line and
glyph events immediately follow its scope event. Any refusal is
`.invariantViolation` and calls `discard` exactly once.
`publish` is called once after all staging; `false` is an invariant failure and
also calls `discard` once. Successful publication is never followed by
`discard`.

## Behavior

### General algorithm

Layout MUST execute synchronously in two logical phases: bottom-up measurement
under proposals, then top-down placement in resolved bounds. A profile may
fuse storage or traversal, but the observable result MUST equal those phases.
Each layout scope is measured once for a given attempt and placed once.
Sibling order is SPEC-006 source order. For `base.a().b()`, modifier `a` is
the inner scope and `b` is the outer scope: measurement applies modifiers in
increasing source-call index and placement enters them in decreasing index.

Every scope first computes its ideal size, then independently caps each axis
to a present proposal using `min(ideal, proposal)`. An absent axis does not cap
the ideal size. A cap changes only the scope's resolved bounds; descendants
retain their already measured sizes and may extend outside those bounds until
an enclosing logical clip applies.

The root receives the supplied proposal and is placed at `Point(x: 0, y: 0)`.
Its resolved bounds establish the initial logical clip. A checked rectangular
intersection uses the greater minimum edge and lesser maximum edge on each
axis; when those edges do not overlap it returns a zero-size rectangle at the
greater minimum edges. All staged bounds and clips are valid SPEC-002 `Rect`
values.

Every addition, subtraction, multiplication, edge, gap total, position, and
constraint computation MUST use SPEC-002 checked arithmetic. Division used to
center or share remainder truncates toward zero. One-unit remainders are
assigned to earlier source-order flexible spacers, making results deterministic.

### Stacks and spacer

- `VStack` proposes its available width and an absent height to non-spacer
  children. Its base width is the maximum child width; its base height is the
  checked sum of non-spacer child heights, every spacer `minLength`, and
  `spacing * max(childCount - 1, 0)`.
- `HStack` applies the transposed rule.
- A stack with no children has zero size. Spacing exists only between adjacent
  children and is never placed before the first or after the last.
- Under an absent main-axis proposal, each flexible spacer receives exactly
  `minLength` and the stack's ideal main extent is its base extent. Under a
  present proposal greater than the base extent, the stack's ideal main extent
  is that proposal and the non-negative remainder is divided among spacers.
  Each receives the quotient; the first `remainder` spacers in source order
  receive one additional unit. Under a present proposal smaller than the base
  extent, every spacer still receives its full `minLength`, children retain
  their measured extents, and the stack's resolved extent is capped to the
  proposal. Overflowing children are not compressed or assigned negative
  sizes.
- A spacer's cross-axis extent is the stack's resolved cross extent. A
  `Spacer` that is not an unmodified direct stack child has ideal size zero on
  both axes; enclosing padding or frame modifiers then apply normally. Layout
  modifiers around a spacer therefore make it an ordinary child rather than a
  flexible slot.
- Placement starts at the stack's low main-axis edge. Each child is followed
  by exactly one spacing gap except the last. The cursor advance is checked.
- Cross-axis `.leading`/`.top` places at the low edge; `.center` centers; and
  `.bottom` places at the high edge. Checked subtraction determines offsets.
- `ZStack` proposes the same proposal to every child, measures to the maximum
  width and height, caps that ideal size by its proposal, and places all
  children in source order inside the resolved bounds. Its `Alignment`
  independently uses the low edge for `.leading`/`.top`, checked centered
  offset for `.center`, and high edge for `.bottom`. `ZStack` itself does not
  add a clip.

### Padding and frame

Padding subtracts applicable checked inset sums from present proposals,
flooring the child proposal at zero, then adds the insets to the child result.
Its ideal size is the checked child size plus those insets and its resolved
size is capped by the original parent proposal. The child origin is translated
by leading/top even when the cap makes the child extend beyond the padding
bounds. Padding does not add a logical clip. Nested padding is applied in
source modifier order.

Frame resolution is independent per axis. A fixed dimension is the requested
lower and upper value. For the flexible overload, an absent minimum is zero;
a finite maximum is an upper bound; `.infinity` is an expansion request but no
finite upper bound.

The child proposal on one axis is resolved as follows:

1. A fixed dimension proposes its exact requested value.
2. Otherwise, a present parent proposal is passed through, capped by a finite
   maximum when one exists. A minimum never raises the child proposal.
3. With an absent parent proposal, a finite maximum is proposed; without one,
   the child proposal remains absent. `.infinity` never invents a proposal.

After measuring the child, a frame clamps the child's ideal size upward to its
minimum and downward to its finite maximum. A fixed dimension instead requests
its exact value. `.infinity` expands that requested size to a present parent
proposal when the proposal is larger. Finally, the present parent proposal
caps the frame's resolved size. Thus a fixed or minimum request may remain
unsatisfied when its parent offers less space; it is not an invalid
declaration. The child is placed within the resolved frame by `alignment`
using checked low-edge, centered, or high-edge offsets. Every frame scope
intersects the inherited logical clip with its resolved bounds before passing
the clip to its child. Ordered frames and padding MUST not be commuted or
merged.

### Canonical text layout

Text is decoded through `SemanticLayoutView` in scalar-index order and uses the
validated resource's sole MVP instance at index zero. U+000A is one explicit
line break, U+000D followed by U+000A is one break consuming both scalar
values, and an isolated U+000D is one break. Every other valid scalar maps
through the exact instance; an unsupported valid scalar uses its exact
replacement glyph. An invalid scalar is `.invalidDeclaration`.

Let `A`, `D`, and `G` be the exact ascent, descent, and line gap. The line-box
height is `A + D`; baseline progression is `A + D + G`. Text begins with one
empty current line. An explicit break finalizes that line and starts another,
so leading, trailing, and consecutive breaks preserve empty lines. Empty text
therefore has exactly one empty line.

MVP wrapping is left-to-right and advance-based. For a present positive width
`W`, layout wraps before a glyph only when the current line already contains a
glyph and `currentAdvance + glyphAdvance > W`. An over-wide first glyph stays
on that line. For `W == 0`, layout wraps before every glyph after the first
glyph of the current line, producing one line per non-break glyph unless an
explicit break already started an empty line. With absent width, only explicit
breaks wrap. Glyph ink bounds do not affect wrapping or line advance.

For zero-based line index `i`, the baseline relative to the text origin is
`Point(x: 0, y: A + i * (A + D + G))`. A glyph baseline x coordinate is the
checked accumulated advance of preceding glyphs on that line. A line's logical
bounds begin at `Point(x: 0, y: baselineY - A)`, have height `A + D`, and have
width equal to its accumulated advance capped by a present width. The text
ideal width is the greatest line width. Its ideal height is
`A + D + (lineCount - 1) * (A + D + G)`. A present height proposal caps only
the resolved text bounds; it never removes lines or glyphs.

Before staging, every relative line bound and baseline is translated by the
resolved text-scope origin through checked addition. `stageTextLine` and
`stageGlyph` therefore receive absolute root-coordinate geometry and the exact
text primitive identity, never a modifier-scope identity.

Every logical line and glyph is staged even when its clip is empty. The text
scope clip is the intersection of its inherited clip and resolved bounds. Each
line clip further intersects that result with the line bounds, and every glyph
on the line uses that exact line clip. `lineIndex` is zero-based;
`glyphIndex` is zero-based across the complete text occurrence in source order
and excludes line-break controls. Text-line events precede their glyph events,
and lines are staged in increasing index. No raster fact may feed back into
these values.

### Hit geometry

Layout publishes exact resolved bounds and logical clips for every primitive
and modifier scope. Later interaction contracts may select actionable scopes,
but their hit bounds MUST be the published bounds or the checked intersection
of those bounds with the published clip. Layout does not associate an action,
enabled state, pointer sequence, or dispatch behavior.

## State / Lifecycle

```text
idle -> workspace-acquired -> validating/measuring -> sink-begun
     -> placing/staging -> published -> workspace-reset -> idle
                          \-> discarded -> workspace-reset -> idle
```

A workspace and sink are exclusively borrowed for one attempt. Reentry with
either active object returns `.reentrancyViolation` before inspecting semantic
input, acquiring storage, calling `begin`, or modifying the active attempt.
That rejected nested call MUST NOT call `discard` or reset either active
object. Failure before sink acquisition resets only workspace state acquired
by this attempt. Failure after `begin` calls `discard` exactly once and then
resets this attempt's workspace. Failure publishes no current layout and
retains no borrowed semantic node, text source, or resource view. Successful
output is immutable in meaning for its owning publication cycle.

## Capability Requirements

Layout consumes no capability to change semantics. Capability absence MUST NOT
select another algorithm, scalar, font, or alignment. Structural availability
and host capacities are validated by later host/runtime contracts.

## Backend Requirements

No backend participates in measurement or placement. Backends MUST NOT
remeasure text, reinterpret stacks, alter positions, or return raster metrics.
The recording sink is sufficient for this Specification's approval seam.

## Error Handling

Errors are deterministic and first-failure atomic. Reentrancy is checked first
at entry. The producer then validates semantic shape and declaration payloads,
checks declared counts against limits and workspace capacity, and performs
measurement and placement in canonical traversal order. Within one arithmetic
or lookup step, the first checked failure is returned. A missing value inside
a Semantic Core or validated text-resource declared range is an invariant
failure, not ordinary invalid input or resource absence.

The owner adapter maps layout errors to SPEC-003 facts as follows:

| Layout error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| invalid declaration | `.invalidValue` | `.layout` | `.candidateFrame` | `.contained` |
| SPEC-002 checked arithmetic overflow | `.arithmeticOverflow` | `.foundation` | `.operation` | `.contained` |
| capacity exhausted | `.capacityExhausted` | `.layout` | `.candidateFrame` | `.contained` |
| reentrancy rejected before acquisition | `.reentrancyViolation` | `.layout` | `.activeCycle` | `.contained` |
| malformed Semantic Core view, post-validation text lookup failure, late sink refusal, or other invariant violation | `.invariantViolation` | `.layout` | `.candidateFrame` | `.safetyNotProven` |

The arithmetic row preserves SPEC-002 and SPEC-005 unchanged: a later
execution adapter MAY correlate that fact with a candidate frame but MUST NOT
replace `.foundation` with `.layout` or widen `.operation`. Invalid
`LayoutLimits` construction returns local `nil`; the first host/runtime owner
that reports it maps it to `.invalidValue`, `.layout`, `.runtime`, and
`.contained` before the first cycle. No failure may produce partial bounds or
positioned glyphs as current output.

## Performance Requirements

- Time MUST be `O(n + g)`, where `n` is admitted layout scopes and `g`
  is admitted text scalars/positioned glyphs; no solver or sibling sort is
  permitted.
- Static conformance MUST perform the attempt with zero heap allocations after
  host assembly and only caller-owned finite workspace.
- The implementation MUST report workspace byte count and maximum call-stack
  high-water for the Signal Analyzer fixture; numeric host budgets belong to
  RUNTIME-PROFILES/HOST-CONFIGURATION.
- Layout limit/result/error values MUST contain no reference, existential,
  string, closure, or unbounded collection.
- `SemanticLayoutPrimitive` MUST occupy no more than 16 bytes and
  `SemanticLayoutModifier` no more than 48 bytes on every contract compiler.
- `LayoutLimits` MUST occupy no more than 10 bytes, `LayoutSummary` no more
  than 28 bytes, `LayoutError` exactly 1 byte, and `LayoutResult` no more than
  32 bytes on every contract compiler.

The implementation MUST provide `scripts/contracts/run-spec-007.sh` with the
following exact commands and the compiler, target, SDK, and optimization
identities fixed by SPEC-002:

```text
scripts/contracts/run-spec-007.sh --profile macos-dynamic
scripts/contracts/run-spec-007.sh --profile macos-static
scripts/contracts/run-spec-007.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-007.sh --profile nrf52840-embedded
```

Each report MUST record the repository revision and dirty state, complete
commands, semantic-view and result value layouts, fixture limits and observed
high-water counts, allocation count, layout workspace bytes, maximum call-stack
high-water, incremental linked code attributable to the Semantic-Core/layout
edge, and evidence that no second complete semantic graph exists. The nRF52840
report MUST inspect the ELF for the required Cortex-M4F hard-float calling
convention. ARMv6 and nRF52840 runs are cross-build/inspection evidence and
make no connected-hardware claim.

## Compatibility

The public declarations are source contract for the MVP but establish no
stable ABI. Dynamic conveniences may adapt into the same bounded semantic
layout view; they MUST produce identical layout when the admitted scalar
sequence fits. Future retained producers and richer layout facilities must not
change this contract's results for the admitted MVP surface.

## Testing Requirements

- Compile fixtures for every public declaration, exact alignment and edge-set
  constant, modifier order, custom view, fixed builder arity, and all four
  profile configurations. Invalid raw edge bits and every negative scalar
  form MUST compile as preserved declarations and fail during layout.
- Semantic-layout-view fixtures cover every primitive and modifier payload,
  transparent structural flattening, rejection of an uncontained multi-child
  root or modifier scope, invalid and in-range indices, exact identity reuse,
  and canonical child/modifier order.
- Table-driven stack tests cover zero through five children, absent and present
  main-axis proposals, direct/wrapped/outside-stack spacers, minimum underflow,
  quotient and source-order remainder distribution, explicit spacing, every
  admitted alignment, oversized children, zero sizes, and exact cursor
  positions.
- Modifier tests prove padding/frame source order, empty and composite edge
  sets, fixed/min/max/infinite behavior on each axis, absent proposals, and the
  exact cases `minWidth: 100` and fixed width `100` under parent width `50`.
- Golden text tests using the SPEC-005 package for ASCII, degree sign,
  replacement glyphs, CR/LF/CRLF, empty content, wrapping, zero-width, clipping,
  first and later baselines, line gaps, trailing/consecutive empty lines,
  height-only clipping, over-wide first glyphs, and checked overflow.
- Bounds tests prove exact primitive and modifier-scope bounds, inherited and
  frame clips, line clips, glyph indices, root origin/bounds, empty
  intersections, and derived hit geometry.
- Limit-edge tests at exactly each bound and one over; sink refusal,
  nested reentrancy, post-validation lookup failure, and arithmetic failures
  must follow the exact acquisition/discard rules and publish atomically.
- The same corpus through recording, dynamic, and static semantic views MUST
  produce equal canonical source-token transcripts, identity relations,
  numeric fields, summaries, and mapped facts. Tests MUST NOT compare
  profile-private raw identity bytes.
- Dependency tests MUST reject layout imports of render/runtime/backend/platform
  modules and backend attempts to import semantic/layout authority. They MUST
  prove the exact one-way `GiftUILayout -> GiftUISemanticCore -> GiftUI` edge
  and reject the reverse edge.
- Borrow and allocation fixtures MUST prove layout retains no semantic view,
  node, payload, identity, text source, or declaration storage; static
  traversal adds no heap allocation or second complete semantic graph.
- The four exact contract-driver commands MUST record every Performance
  Requirement and the nRF52840 hard-float ELF evidence.

## Acceptance Criteria

- [ ] **LY-001:** All public Rank 1 declarations and their exact constants
  compile using only `import GiftUI`; every invalid scalar, frame relation, or
  reserved edge bit is preserved and rejected exactly as specified.
- [ ] **LY-002:** Recording fixtures expose the exact Semantic Core view API,
  primitive/modifier vocabulary, identity relation, flattening rule, child and
  modifier order, text access, and invalid-index behavior without runtime
  storage or a second semantic representation.
- [ ] **LY-003:** Golden stack, spacer, alignment, padding, and frame fixtures
  match every normative proposal, underflow, remainder, placement, clipping,
  and checked-geometry rule, including a 100-point minimum/fixed request under
  a 50-point parent proposal.
- [ ] **LY-004:** Canonical text fixtures produce exact SPEC-005 instance and
  glyph IDs, scalar/glyph/line counts, line bounds, baselines, advances,
  positions, and clips for the complete required corpus.
- [ ] **LY-005:** Every invalid declaration, checked overflow, capacity edge,
  nested reentry, malformed semantic view, post-validation lookup failure, and
  sink refusal returns the exact local error and authoritative SPEC-003 fact,
  follows the acquisition/discard rules, and publishes no partial result.
- [ ] **LY-006:** Recording, dynamic, and static fixtures produce equal
  canonical transcripts, identity relations, summaries, and failure mappings;
  static attempts allocate zero heap bytes and retain no semantic borrow.
- [ ] **LY-007:** Import-graph tests enforce the exact one-way
  `GiftUILayout -> GiftUISemanticCore -> GiftUI` dependency, preserve sibling
  separation from `GiftUIRenderCore`, and reject reverse, runtime, backend, and
  platform imports.
- [ ] **LY-008:** The Signal Analyzer approval fixture succeeds with exact
  limits `maximumScopes: 512`, `maximumDepth: 64`,
  `maximumTextScalars: 4096`, `maximumTextLines: 512`, and
  `maximumPositionedGlyphs: 4096`, and exercises vertical, horizontal,
  overlay, spacer, spacing, all admitted alignments, padding,
  fixed/min/max/infinite frames, and canonical text. These are contract-fixture
  limits, not production host budgets.
- [ ] **LY-009:** The four `run-spec-007.sh` commands reproduce owned-value
  layouts, exact limits/high-water counts, zero-allocation evidence, workspace,
  stack, linked-code and no-second-graph evidence, plus the required nRF52840
  hard-float ELF attributes, without claiming connected hardware.

## Implementation Notes

The existing proof-of-concept layout engine is evidence only. Its recursive
measurement code may be reused after it adopts `Int32`, atomic outcomes,
canonical text metrics, ZStack/spacer/modifiers, and caller-owned bounds.

## Open Issues

No contract or architecture issue remains open. RFC-010 is approved, ADR-032
is accepted, and this review revision fixes the borrowed protocol, closed
payload cases, result shape, algorithms, failure mapping, and approval
evidence.

A request for priority-based compression, baseline alignment, or a new
geometry model is architectural or post-MVP work and must not be decided here.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md): richer
  text and shaping.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md):
  text interaction and accessibility geometry.
- [FW-005](../future-work/fw-005-alternative-geometry-scalars.md): alternative
  scalar models. Current MVP scope remains unchanged.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md)
- [ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [Legacy GiftUI Framework Specification](../GiftUI_Framework_Spec.md)
