import GiftUI
import GiftUILayout
import GiftUISemanticCore
import Testing

private final class RenderViewLifetimeToken: @unchecked Sendable {}

private struct LifetimeSemanticRenderView: SemanticRenderView {
    let token: RenderViewLifetimeToken
    let rootIdentity: UInt16 = 1
    let semanticScopeCount: UInt16 = 1

    func scope(at identity: UInt16) -> SemanticRenderScope? {
        identity == rootIdentity ? .structural : nil
    }

    func layoutIdentity(for identity: UInt16) -> UInt16? {
        identity == rootIdentity ? rootIdentity : nil
    }

    func childCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }
}

private struct LifetimeResolvedRenderLayoutView: ResolvedRenderLayoutView {
    let token: RenderViewLifetimeToken
    let rootIdentity: UInt16 = 1
    let layoutScopeCount: UInt16 = 1
    let rootBounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 1, height: 1)!
    )!

    func bounds(of identity: UInt16) -> Rect? {
        identity == rootIdentity ? rootBounds : nil
    }

    func clip(of identity: UInt16) -> Rect? {
        identity == rootIdentity ? rootBounds : nil
    }

    func textLineCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func textLine(
        of identity: UInt16,
        at index: UInt16
    ) -> ResolvedRenderTextLine? { nil }

    func glyph(of identity: UInt16, at index: UInt16) -> ResolvedRenderGlyph? {
        nil
    }
}

private func consumeRenderViews<Semantic, Layout>(
    semantic: borrowing Semantic,
    layout: borrowing Layout
) -> UInt16
where
    Semantic: SemanticRenderView,
    Layout: ResolvedRenderLayoutView,
    Semantic.Identity == Layout.Identity
{
    let semanticRoot = semantic.rootIdentity
    let layoutRoot = layout.rootIdentity
    return semantic.layoutIdentity(for: semanticRoot) == layoutRoot
        ? semantic.semanticScopeCount &+ layout.layoutScopeCount
        : 0
}

@Test
func renderViewBorrowRetainsNeitherAuthoritativeResult() {
    weak var semanticToken: RenderViewLifetimeToken?
    weak var layoutToken: RenderViewLifetimeToken?

    do {
        let semanticSource = RenderViewLifetimeToken()
        let layoutSource = RenderViewLifetimeToken()
        semanticToken = semanticSource
        layoutToken = layoutSource

        let semantic = LifetimeSemanticRenderView(token: semanticSource)
        let layout = LifetimeResolvedRenderLayoutView(token: layoutSource)
        #expect(consumeRenderViews(semantic: semantic, layout: layout) == 2)
        #expect(semanticToken != nil)
        #expect(layoutToken != nil)
    }

    #expect(semanticToken == nil)
    #expect(layoutToken == nil)
}
