import GiftUI
import GiftUILayout
import GiftUISemanticCore
import GiftUITextResources

package struct StaticSemanticRenderView: SemanticRenderView {
    package let rootIdentity: UInt16 = 1
    package let semanticScopeCount: UInt16 = 1
    package let renderSnapshotVersion: UInt32 = 1

    package func semanticIdentity(at ordinal: UInt16) -> UInt16? {
        ordinal == 0 ? rootIdentity : nil
    }

    package func semanticOrdinal(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func scope(at identity: UInt16) -> SemanticRenderScope? {
        identity == rootIdentity ? .structural : nil
    }

    package func layoutIdentity(for identity: UInt16) -> UInt16? {
        identity == rootIdentity ? rootIdentity : nil
    }

    package func childCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }
}

package struct StaticResolvedRenderLayoutView: ResolvedRenderLayoutView {
    package let rootIdentity: UInt16 = 1
    package let layoutScopeCount: UInt16 = 1
    package let renderSnapshotVersion: UInt32 = 1
    package let rootBounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 8, height: 8)!
    )!

    package func layoutIdentity(at ordinal: UInt16) -> UInt16? {
        ordinal == 0 ? rootIdentity : nil
    }

    package func layoutOrdinal(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func bounds(of identity: UInt16) -> Rect? {
        identity == rootIdentity ? rootBounds : nil
    }

    package func clip(of identity: UInt16) -> Rect? {
        identity == rootIdentity ? rootBounds : nil
    }

    package func textLineCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func textLine(
        of identity: UInt16,
        at index: UInt16
    ) -> ResolvedRenderTextLine? { nil }

    package func glyph(of identity: UInt16, at index: UInt16) -> ResolvedRenderGlyph? {
        nil
    }
}

@inline(never)
package func spec008BorrowedRenderViews<Semantic, Layout>(
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
    var checksum = semantic.semanticScopeCount &+ layout.layoutScopeCount
    checksum &+= UInt16(truncatingIfNeeded: semantic.renderSnapshotVersion)
    checksum &+= UInt16(truncatingIfNeeded: layout.renderSnapshotVersion)
    if semantic.semanticIdentity(at: 0) == semanticRoot {
        checksum &+= 1
    }
    checksum &+= semantic.semanticOrdinal(of: semanticRoot) ?? 0
    if layout.layoutIdentity(at: 0) == layoutRoot {
        checksum &+= 1
    }
    checksum &+= layout.layoutOrdinal(of: layoutRoot) ?? 0
    if semanticRoot == layoutRoot {
        checksum &+= 1
    }
    if semantic.scope(at: semanticRoot) != nil {
        checksum &+= 1
    }
    if semantic.layoutIdentity(for: semanticRoot) == layoutRoot {
        checksum &+= 1
    }
    checksum &+= semantic.childCount(of: semanticRoot) ?? 0
    if layout.bounds(of: layoutRoot) != nil {
        checksum &+= 1
    }
    if layout.clip(of: layoutRoot) != nil {
        checksum &+= 1
    }
    checksum &+= layout.textLineCount(of: layoutRoot) ?? 0
    if layout.textLine(of: layoutRoot, at: 0) != nil {
        checksum &+= 1
    }
    if layout.glyph(of: layoutRoot, at: 0) != nil {
        checksum &+= 1
    }
    return checksum
}

@inline(never)
package func spec008StaticRenderViewEntry() -> UInt16 {
    spec008BorrowedRenderViews(
        semantic: StaticSemanticRenderView(),
        layout: StaticResolvedRenderLayoutView()
    )
}
