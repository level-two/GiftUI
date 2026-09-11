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

package protocol ResolvedRenderLayoutResultStorage: LayoutResultSink,
    LayoutResultSinkState
{
    associatedtype RenderView: ResolvedRenderLayoutView
    where RenderView.Identity == Identity

    var renderView: RenderView { get }
}

package struct ResolvedRenderLayoutResultSink<Storage>: LayoutResultSink,
    LayoutResultSinkState
where Storage: ResolvedRenderLayoutResultStorage {
    package var storage: Storage

    package init(storage: Storage) {
        self.storage = storage
    }

    package var isLayoutActive: Bool {
        storage.isLayoutActive
    }

    package var renderView: Storage.RenderView {
        storage.renderView
    }

    package mutating func begin(summary: LayoutSummary) -> Bool {
        storage.begin(summary: summary)
    }

    package mutating func stageScope(
        identity: Storage.Identity,
        bounds: Rect,
        clip: Rect
    ) -> Bool {
        storage.stageScope(identity: identity, bounds: bounds, clip: clip)
    }

    package mutating func stageTextLine(
        identity: Storage.Identity,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        storage.stageTextLine(
            identity: identity,
            lineIndex: lineIndex,
            bounds: bounds,
            baseline: baseline,
            clip: clip
        )
    }

    package mutating func stageGlyph(
        identity: Storage.Identity,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        storage.stageGlyph(
            identity: identity,
            lineIndex: lineIndex,
            glyphIndex: glyphIndex,
            instance: instance,
            glyph: glyph,
            baseline: baseline,
            clip: clip
        )
    }

    package mutating func publish() -> Bool {
        storage.publish()
    }

    package mutating func discard() {
        storage.discard()
    }
}
