import GiftUI
import GiftUITextResources

package struct ResolvedRenderTextLine: Equatable, Sendable {
    package let lineIndex: UInt16
    package let bounds: Rect
    package let baseline: Point
    package let clip: Rect
    package let glyphCount: UInt16

    package init(
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect,
        glyphCount: UInt16
    ) {
        self.lineIndex = lineIndex
        self.bounds = bounds
        self.baseline = baseline
        self.clip = clip
        self.glyphCount = glyphCount
    }
}

package struct ResolvedRenderGlyph: Equatable, Sendable {
    package let lineIndex: UInt16
    package let glyphIndex: UInt16
    package let instance: FontInstanceID
    package let glyph: GlyphID
    package let baseline: Point
    package let clip: Rect

    package init(
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) {
        self.lineIndex = lineIndex
        self.glyphIndex = glyphIndex
        self.instance = instance
        self.glyph = glyph
        self.baseline = baseline
        self.clip = clip
    }
}

package protocol ResolvedRenderLayoutView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var layoutScopeCount: UInt16 { get }
    var renderSnapshotVersion: UInt32 { get }
    var rootBounds: Rect { get }
    func layoutIdentity(at ordinal: UInt16) -> Identity?
    func layoutOrdinal(of identity: Identity) -> UInt16?
    func bounds(of identity: Identity) -> Rect?
    func clip(of identity: Identity) -> Rect?
    func textLineCount(of identity: Identity) -> UInt16?
    func textLine(
        of identity: Identity,
        at index: UInt16
    ) -> ResolvedRenderTextLine?
    func glyph(of identity: Identity, at index: UInt16) -> ResolvedRenderGlyph?
}

