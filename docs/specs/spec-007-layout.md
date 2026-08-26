---
id: SPEC-007
feature: giftui-mvp-architecture
title: Proposal-Based Layout Contract
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
  - RFC-010
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-009
  - ADR-021
  - ADR-023
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-005
  - SPEC-006
  - SPEC-008
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

## Summary

This Specification defines the Wave 3 layout contract for the Signal Analyzer:
proposal-based measurement and placement, vertical, horizontal, and overlay
stacks, flexible spacers, explicit spacing and alignment, padding, frame
constraints, canonical text measurement, resolved hit geometry, and bounded
checked layout production. It defines one profile-neutral result and recording
seam; it does not define rendering, input dispatch, or runtime storage.

This document is a `draft`. It is non-authoritative until human review and
approval complete the Specification gate.

## Scope

This contract applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840/Zephyr static configurations. It owns:

- Rank 1 client declarations and modifiers required by MVP Scope;
- deterministic measurement and placement from a semantic-child adapter;
- canonical left-to-right text measurement and positioned glyph production;
- finite layout limits, atomic failure, and a recording-layout seam; and
- logical bounds used later by rendering and hit-map production.

## Goals

- Produce identical logical bounds and positioned text for equivalent input in
  both runtime profiles.
- Cover every Signal Analyzer stack, spacer, padding, frame, alignment, and
  text-layout requirement without a general constraint solver.
- Permit conformance testing without a renderer, backend, runtime, or hardware.
- Make arithmetic, capacity, invalid input, and resource failures explicit.

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
- ADR-005, ADR-006, ADR-009, ADR-021, and ADR-023 are accepted.
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
- **ADR-009** fixes checked integer geometry and excludes a general solver.
- **ADR-021** makes layout the sole text geometry, line-breaking, glyph-choice,
  measurement, and logical-position authority.
- **ADR-023** requires use of the exact validated resource identity and the
  `GiftUITextResources` contracts without parallel identities or fallback.

## Terminology

**Proposal**: A `ProposedSize`; an absent axis is unconstrained, not infinite.

**Ideal size**: The smallest valid size a node returns for the proposal under
this contract before an enclosing frame expands it.

**Layout occurrence**: One semantic occurrence identified by the exact
SPEC-006 structural identity and assigned one resolved `Rect`.

**Flexible spacer**: A zero-ideal-size child that receives an equal share of
remaining non-negative space only on its enclosing stack's main axis.

**Resolved layout**: The complete, immutable-in-meaning set of occurrence
bounds, text line/glyph positions, and hit bounds staged by one successful
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

All lengths, finite limits, and insets MUST be non-negative. `EdgeInsets.init`
returns `nil` for an invalid field. A public modifier or container initializer
whose non-optional scalar is invalid MUST preserve the declaration but layout
MUST reject it as `.invalidDeclaration`; it MUST NOT clamp, take an absolute
value, or trap as its sole behavior. `FrameLimit.points` is invalid when its
value is negative. For one axis, a finite maximum smaller than the minimum is
invalid. Fixed `width` or `height` is both the minimum and maximum on that axis.

## Module Contract

`GiftUI` owns only the public declarations and typed semantic payloads.
`GiftUILayout` owns measurement, placement, canonical text layout, layout
limits/results, and recording fixtures. [RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md)
evaluates whether it may depend directly on `GiftUISemanticCore` or must retain
RFC-002's layout-owned semantic-child adapter. Until an accepted ADR resolves
that choice, this draft MUST NOT establish either dependency as authoritative
and cannot pass its Specification approval gate. In either direction,
`GiftUILayout` MUST depend on `GiftUI` and `GiftUITextResources` and MUST NOT
import render, runtime-profile, backend, capability, platform, driver,
OS/RTOS, HAL, or hardware modules.

`GiftUILayout` MUST NOT import `GiftUIFailureCore`. The first owner adapter that
knows both layout errors and SPEC-003 facts performs the mapping under Error
Handling. `GiftUIRenderCore` is a sibling and MUST NOT be imported by layout.
`GiftUIRenderLowering` may consume successful semantic and layout results as
SPEC-008's shared higher lowering owner, but may not grant rendering authority
to layout or layout authority to rendering. That consumer edge does not resolve
RFC-010's separate question about the input edge into `GiftUILayout`.

## Types / APIs

The package SPI below is normative in meaning. Concrete workspace and sink
storage may differ by profile.

```swift
package struct LayoutLimits: Equatable, Sendable {
    package let maximumOccurrences: UInt16
    package let maximumDepth: UInt16
    package let maximumTextScalars: UInt16
    package let maximumTextLines: UInt16
    package let maximumPositionedGlyphs: UInt16
    package init?(maximumOccurrences: UInt16, maximumDepth: UInt16,
                  maximumTextScalars: UInt16, maximumTextLines: UInt16,
                  maximumPositionedGlyphs: UInt16)
}

package struct LayoutSummary: Equatable, Sendable {
    package let occurrenceCount: UInt16
    package let textScalarCount: UInt16
    package let textLineCount: UInt16
    package let positionedGlyphCount: UInt16
    package let maximumObservedDepth: UInt16
    package let rootBounds: Rect
}

package enum LayoutError: UInt8, Equatable, Sendable {
    case invalidDeclaration = 0
    case invalidProposal = 1
    case arithmeticOverflow = 2
    case capacityExhausted = 3
    case missingTextResource = 4
    case invalidTextResource = 5
    case reentrancyViolation = 6
    case invariantViolation = 7
}

package enum LayoutResult: Equatable, Sendable {
    case success(LayoutSummary)
    case failure(LayoutError)
}

package protocol LayoutTextSource {
    var scalarCount: UInt16 { get }
    func scalar(at index: UInt16) -> UInt32?
}

package protocol LayoutResultSink {
    associatedtype Identity: Equatable, Sendable
    mutating func begin(limits: LayoutLimits) -> Bool
    mutating func stageOccurrence(identity: Identity, bounds: Rect) -> Bool
    mutating func stageTextLine(identity: Identity,
                                bounds: Rect, baseline: Point) -> Bool
    mutating func stageGlyph(identity: Identity,
                             instance: FontInstanceID, glyph: GlyphID,
                             baseline: Point, clip: Rect) -> Bool
    mutating func publish() -> Bool
    mutating func discard()
}
```

`Identity` is the sink's SPEC-006 semantic identity representation; this
contract does not prescribe its profile-private raw storage. The layout entry
point MUST synchronously borrow the complete successful semantic result, a
validated `CanonicalTextMetricsView`, one root proposal, immutable limits, and
caller-owned workspace/sink. It MUST return `LayoutResult`, publish exactly
once on success, and discard exactly once on any failure.

All five limits MUST be nonzero. A sink MUST report capacity before work. A
reported shortfall is `.capacityExhausted`; refusal after reporting sufficient
capacity is `.invariantViolation`.

## Behavior

### General algorithm

Layout MUST execute synchronously in two logical phases: bottom-up measurement
under proposals, then top-down placement in resolved bounds. A profile may
fuse storage or traversal, but the observable result MUST equal those phases.
Each semantic occurrence is measured once for a given attempt and placed once.
Sibling order is SPEC-006 source order.

The root receives the supplied proposal. Each present proposed dimension is
the root's available extent. The successful root size MUST NOT exceed a present
root proposal. If ideal content is larger, layout constrains the root to the
proposal and clips downstream output to root bounds; it does not create a
negative extent.

Every addition, subtraction, multiplication, edge, gap total, position, and
constraint computation MUST use SPEC-002 checked arithmetic. Division used to
center or share remainder truncates toward zero. One-unit remainders are
assigned to earlier source-order flexible spacers, making results deterministic.

### Stacks and spacer

- `VStack` proposes its available width and an absent height to non-spacer
  children. Its ideal width is the maximum child width; its ideal height is the
  checked sum of child heights plus `spacing * max(childCount - 1, 0)`.
- `HStack` applies the transposed rule.
- A stack with no children has zero size. Spacing exists only between adjacent
  children and is never placed before the first or after the last.
- After fixed children and gaps are measured, remaining main-axis space is
  divided equally among spacers, each receiving at least `minLength`. If the
  available extent cannot satisfy all minimum lengths, spacers receive their
  minimums in source order until the root constraint clips the result; no
  spacer receives a negative size.
- Cross-axis `.leading`/`.top` places at the low edge; `.center` centers; and
  `.bottom` places at the high edge. Checked subtraction determines offsets.
- `ZStack` proposes the same proposal to every child, measures to the maximum
  width and height, and places all children in source order inside that size.

### Padding and frame

Padding subtracts applicable checked inset sums from present proposals,
flooring the child proposal at zero, then adds the insets to the child result.
The child origin is translated by leading/top. Nested padding is applied in
source modifier order.

A frame first derives its child proposal by applying finite fixed/min/max
constraints, then resolves its own size by clamping the child ideal size to
those constraints. `.infinity` expands only to a present parent proposal; under
an absent proposal it behaves as no finite maximum and does not invent a size.
The frame places its child by `alignment`. Ordered frames and padding MUST not
be commuted or merged when that would change measurement or placement.

### Canonical text layout

Text is decoded by its `LayoutTextSource` in scalar-index order. U+000A,
U+000D, and CRLF follow SPEC-005. Every other valid scalar maps through the
selected exact instance; unsupported valid scalars use the exact replacement
glyph. Invalid scalars fail.

MVP text is left-to-right with greedy wrapping. Before placing a glyph whose
checked advance would exceed a present positive width, layout starts a new line
unless it is the first glyph of that line; an over-wide first glyph remains on
that line and is clipped. A zero-width proposal produces one line per non-line-
break glyph. Explicit empty lines are preserved. Text with no scalars has zero
width and one line-box height. Unconstrained width wraps only at explicit line
breaks.

Line width is the checked sum of advances. Line height and baseline progression
come exactly from SPEC-005 line metrics. Measured width is the greatest line
width, constrained by a present width; measured height is the checked line-box
height plus inter-line progression. Each emitted baseline, glyph identity,
position, line bound, and clip MUST be identical in all profiles. No raster
fact may feed back into these values.

### Hit geometry

Layout publishes exact resolved bounds for every occurrence. Later interaction
contracts may select actionable occurrences, but MUST use these bounds or a
checked intersection with the inherited clip. Layout does not associate an
action, enabled state, pointer sequence, or dispatch behavior.

## State / Lifecycle

```text
idle -> begun -> measuring -> placing/staging -> published -> idle
                     \-> failed/discarded ---------> idle
```

A workspace and sink are exclusively borrowed for one attempt. Reentry with
either active object fails before measurement. Failure publishes no current
layout and retains no borrowed semantic node, text source, or resource view.
Successful output is immutable in meaning for its owning publication cycle.

## Capability Requirements

Layout consumes no capability to change semantics. Capability absence MUST NOT
select another algorithm, scalar, font, or alignment. Structural availability
and host capacities are validated by later host/runtime contracts.

## Backend Requirements

No backend participates in measurement or placement. Backends MUST NOT
remeasure text, reinterpret stacks, alter positions, or return raster metrics.
The recording sink is sufficient for this Specification's approval seam.

## Error Handling

Errors are deterministic and first-failure atomic. Precedence is declaration,
proposal, arithmetic, capacity, text-resource absence/invalidity, reentrancy,
then invariant failure when multiple conditions are detected at one boundary.

The owner adapter maps layout errors to SPEC-003 facts as follows:

| Layout error | condition | origin | affected scope | containment |
| --- | --- | --- | --- | --- |
| invalid declaration/proposal | `.invalidValue` | `.layout` | `.candidateFrame` | `.contained` |
| arithmetic overflow | `.arithmeticOverflow` | `.layout` | `.candidateFrame` | `.contained` |
| capacity exhausted | `.capacityExhausted` | `.layout` | `.candidateFrame` | `.contained` |
| missing/invalid text resource | `.requiredFacilityUnavailable` / `.invalidValue` | `.layout` | `.runtime` | `.contained` |
| reentrancy/invariant violation | `.reentrancyViolation` / `.invariantViolation` | `.layout` | `.runtime` | `.safetyNotProven` |

No failure may produce partial bounds or positioned glyphs as current output.

## Performance Requirements

- Time MUST be `O(n + g)`, where `n` is admitted semantic occurrences and `g`
  is admitted text scalars/positioned glyphs; no solver or sibling sort is
  permitted.
- Static conformance MUST perform the attempt with zero heap allocations after
  host assembly and only caller-owned finite workspace.
- The implementation MUST report workspace byte count and maximum call-stack
  high-water for the Signal Analyzer fixture; numeric host budgets belong to
  RUNTIME-PROFILES/HOST-CONFIGURATION.
- Layout limit/result/error values MUST contain no reference, existential,
  string, closure, or unbounded collection.

## Compatibility

The public declarations are source contract for the MVP but establish no
stable ABI. Dynamic conveniences may adapt into the same bounded text source;
they MUST produce identical layout when the admitted scalar sequence fits.
Future retained producers and richer layout facilities must not change this
contract's results for the admitted MVP surface.

## Testing Requirements

- Compile fixtures for every public declaration, modifier order, custom view,
  fixed builder arity, and both runtime profiles.
- Table-driven stack tests for zero through five children, spacers, remainder
  distribution, explicit spacing, every admitted alignment, zero sizes, and
  constrained/unconstrained proposals.
- Modifier tests proving padding/frame source order and fixed/min/max/infinite
  behavior on each axis.
- Golden text tests using the SPEC-005 package for ASCII, degree sign,
  replacement glyphs, CR/LF/CRLF, empty content, wrapping, zero-width, clipping,
  and checked overflow.
- Bounds tests proving exact occurrence, line, glyph, root, and hit geometry.
- Limit-edge tests at exactly each bound and one over; sink refusal,
  reentrancy, invalid resource, and arithmetic failures must discard atomically.
- The same corpus through dynamic and static workspaces MUST produce byte-for-
  byte equal canonical recording transcripts and summaries.
- Dependency tests MUST reject layout imports of render/runtime/backend/platform
  modules and backend attempts to import semantic/layout authority.

## Acceptance Criteria

- [ ] All public Rank 1 declarations compile using only `import GiftUI`.
- [ ] Golden stack, spacer, alignment, padding, and frame fixtures match the
  normative algorithms and checked geometry.
- [ ] Canonical text fixtures produce exact SPEC-005 glyph IDs, line bounds,
  baselines, advances, positions, and clipping.
- [ ] Every invalid input, overflow, capacity edge, resource failure, and
  reentrancy path returns the specified error and publishes no partial result.
- [ ] Dynamic and static fixtures produce identical recording output and
  failure mappings; static attempts allocate zero heap bytes after assembly.
- [ ] Import-graph tests enforce `GiftUILayout` ownership and sibling separation
  from `GiftUIRenderCore`.
- [ ] The Signal Analyzer layout fixture fits declared limits and exercises
  vertical, horizontal, overlay, spacer, spacing, leading/center alignment,
  padding, fixed/min/max/infinite frames, and canonical text.

## Implementation Notes

The existing proof-of-concept layout engine is evidence only. Its recursive
measurement code may be reused after it adopts `Int32`, atomic outcomes,
canonical text metrics, ZStack/spacer/modifiers, and caller-owned bounds.

## Open Issues

- [RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md) must be
  approved and its selected dependency direction extracted into an accepted
  ADR before this Specification can normatively define its semantic-child
  adapter, layout entry point, or final `GiftUILayout` imports.

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
- [MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [Legacy GiftUI Framework Specification](../GiftUI_Framework_Spec.md)
