import GiftUI
import GiftUISemanticCore
import GiftUITextResources

@usableFromInline
package struct LayoutMeasurement: Equatable, Sendable {
    @usableFromInline
    package let idealSize: Size
    @usableFromInline
    package let resolvedSize: Size

    @usableFromInline
    package init(idealSize: Size, resolvedSize: Size) {
        self.idealSize = idealSize
        self.resolvedSize = resolvedSize
    }
}

@usableFromInline
package struct LayoutPlacement: Equatable, Sendable {
    @usableFromInline
    package let bounds: Rect
    @usableFromInline
    package let clip: Rect

    @usableFromInline
    package init(bounds: Rect, clip: Rect) {
        self.bounds = bounds
        self.clip = clip
    }
}

@usableFromInline
package struct LayoutTextLine<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    @usableFromInline
    package let identity: Identity
    @usableFromInline
    package let lineIndex: UInt16
    @usableFromInline
    package let bounds: Rect
    @usableFromInline
    package let baseline: Point
    @usableFromInline
    package let clip: Rect

    @usableFromInline
    package init(
        identity: Identity,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) {
        self.identity = identity
        self.lineIndex = lineIndex
        self.bounds = bounds
        self.baseline = baseline
        self.clip = clip
    }
}

@usableFromInline
package struct LayoutPositionedGlyph<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    @usableFromInline
    package let identity: Identity
    @usableFromInline
    package let lineIndex: UInt16
    @usableFromInline
    package let glyphIndex: UInt16
    @usableFromInline
    package let instance: FontInstanceID
    @usableFromInline
    package let glyph: GlyphID
    @usableFromInline
    package let baseline: Point
    @usableFromInline
    package let clip: Rect

    @usableFromInline
    package init(
        identity: Identity,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) {
        self.identity = identity
        self.lineIndex = lineIndex
        self.glyphIndex = glyphIndex
        self.instance = instance
        self.glyph = glyph
        self.baseline = baseline
        self.clip = clip
    }
}

@usableFromInline
package protocol LayoutWorkspace {
    associatedtype Identity: Equatable, Sendable

    var maximumScopes: UInt16 { get }
    var maximumDepth: UInt16 { get }
    var maximumTextScalars: UInt16 { get }
    var maximumTextLines: UInt16 { get }
    var maximumPositionedGlyphs: UInt16 { get }
    var isLayoutActive: Bool { get }

    mutating func acquireLayout() -> Bool
    mutating func appendScope(
        identity: borrowing Identity,
        measurement: LayoutMeasurement
    ) -> Bool
    var scopeCount: UInt16 { get }
    func scopeIdentity(at index: UInt16) -> Identity?
    func measurement(for identity: borrowing Identity) -> LayoutMeasurement?
    mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing Identity
    ) -> Bool
    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing Identity
    ) -> Bool
    func placement(for identity: borrowing Identity) -> LayoutPlacement?
    var textLineCount: UInt16 { get }
    mutating func appendTextLine(_ line: LayoutTextLine<Identity>) -> Bool
    func textLine(at index: UInt16) -> LayoutTextLine<Identity>?
    mutating func storeTextLine(
        _ line: LayoutTextLine<Identity>,
        at index: UInt16
    ) -> Bool
    var positionedGlyphCount: UInt16 { get }
    mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<Identity>
    ) -> Bool
    func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<Identity>?
    mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<Identity>,
        at index: UInt16
    ) -> Bool
    mutating func pushScope(_ identity: borrowing Identity) -> Bool
    mutating func popScope()
    mutating func resetLayout()
}
