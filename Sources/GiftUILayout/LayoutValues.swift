import GiftUI
import GiftUISemanticCore
import GiftUITextResources

@usableFromInline
package struct LayoutLimits: Equatable, Sendable {
    @usableFromInline
    package let maximumScopes: UInt16
    @usableFromInline
    package let maximumDepth: UInt16
    @usableFromInline
    package let maximumTextScalars: UInt16
    @usableFromInline
    package let maximumTextLines: UInt16
    @usableFromInline
    package let maximumPositionedGlyphs: UInt16

    package init?(
        maximumScopes: UInt16,
        maximumDepth: UInt16,
        maximumTextScalars: UInt16,
        maximumTextLines: UInt16,
        maximumPositionedGlyphs: UInt16
    ) {
        guard maximumScopes > 0,
            maximumDepth > 0,
            maximumTextScalars > 0,
            maximumTextLines > 0,
            maximumPositionedGlyphs > 0
        else {
            return nil
        }
        self.maximumScopes = maximumScopes
        self.maximumDepth = maximumDepth
        self.maximumTextScalars = maximumTextScalars
        self.maximumTextLines = maximumTextLines
        self.maximumPositionedGlyphs = maximumPositionedGlyphs
    }
}

@usableFromInline
package struct LayoutSummary: Equatable, Sendable {
    @usableFromInline
    package let scopeCount: UInt16
    @usableFromInline
    package let textScalarCount: UInt16
    @usableFromInline
    package let textLineCount: UInt16
    @usableFromInline
    package let positionedGlyphCount: UInt16
    @usableFromInline
    package let maximumObservedDepth: UInt16
    @usableFromInline
    package let rootBounds: Rect

    @usableFromInline
    package init(
        scopeCount: UInt16,
        textScalarCount: UInt16,
        textLineCount: UInt16,
        positionedGlyphCount: UInt16,
        maximumObservedDepth: UInt16,
        rootBounds: Rect
    ) {
        self.scopeCount = scopeCount
        self.textScalarCount = textScalarCount
        self.textLineCount = textLineCount
        self.positionedGlyphCount = positionedGlyphCount
        self.maximumObservedDepth = maximumObservedDepth
        self.rootBounds = rootBounds
    }
}

@usableFromInline
package enum LayoutResult: Equatable, Sendable {
    case success(LayoutSummary)
    case failure(LayoutError)
}
