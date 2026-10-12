import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package struct LayoutMeasurement: Equatable, Sendable {
    package let idealSize: Size
    package let resolvedSize: Size

    package init(idealSize: Size, resolvedSize: Size) {
        self.idealSize = idealSize
        self.resolvedSize = resolvedSize
    }
}

package struct LayoutPlacement: Equatable, Sendable {
    package let bounds: Rect
    package let clip: Rect

    package init(bounds: Rect, clip: Rect) {
        self.bounds = bounds
        self.clip = clip
    }
}

package struct LayoutTextLine<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let lineIndex: UInt16
    package let bounds: Rect
    package let baseline: Point
    package let clip: Rect

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

package struct LayoutPositionedGlyph<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let lineIndex: UInt16
    package let glyphIndex: UInt16
    package let instance: FontInstanceID
    package let glyph: GlyphID
    package let baseline: Point
    package let clip: Rect

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
