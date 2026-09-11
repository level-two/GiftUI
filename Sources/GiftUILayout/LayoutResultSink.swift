import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package protocol LayoutResultSink {
    associatedtype Identity: Equatable, Sendable

    mutating func begin(summary: LayoutSummary) -> Bool
    mutating func stageScope(
        identity: Identity,
        bounds: Rect,
        clip: Rect
    ) -> Bool
    mutating func stageTextLine(
        identity: Identity,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool
    mutating func stageGlyph(
        identity: Identity,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool
    mutating func publish() -> Bool
    mutating func discard()
}

package protocol LayoutResultSinkState {
    var isLayoutActive: Bool { get }
}
