import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
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

package struct StaticRenderMetricsView: CanonicalTextMetricsView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 0,
            realizationCount: 0,
            canonicalManifestByteCount: 0
        )
    }

    package func instance(at index: UInt16) -> FontInstanceDescriptor? { nil }
    package func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }
    package func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }

    private var resource: FontResourceID {
        FontResourceID(
            rawValue: TextResourceDigest(
                word0: 0,
                word1: 0,
                word2: 0,
                word3: 0,
                word4: 0,
                word5: 0,
                word6: 0,
                word7: 8
            )
        )
    }
}

package struct StaticRenderWorkspace: RenderProductionWorkspace {
    package typealias Identity = UInt16
    package let capacity = RenderLimits(
        maximumOperations: 1,
        maximumPositionedGlyphs: 1,
        maximumClipDepth: 1
    )!
    package let structuralCapacity = RenderWorkspaceCapacity(
        maximumSemanticScopes: 1,
        maximumLayoutScopes: 1,
        maximumTraversalDepth: 1,
        maximumTextLines: 1
    )!
    package var isActive = false
    private var semanticVisited = false
    private var layoutVisited = false
    private var foreground = Color.black
    private var foregroundCount: UInt16 = 0

    package init() {}

    package mutating func acquire() -> Bool {
        guard !isActive else { return false }
        isActive = true
        semanticVisited = false
        layoutVisited = false
        foregroundCount = 0
        return true
    }

    package mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        Self.visit(ordinal, active: isActive, slot: &semanticVisited)
    }

    package mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        Self.visit(ordinal, active: isActive, slot: &layoutVisited)
    }

    package var currentForeground: Color? {
        isActive && foregroundCount == 1 ? foreground : nil
    }

    package mutating func pushForeground(_ color: Color) -> Bool {
        guard isActive, foregroundCount == 0 else { return false }
        foreground = color
        foregroundCount = 1
        return true
    }

    package mutating func popForeground() -> Bool {
        guard isActive, foregroundCount == 1 else { return false }
        foregroundCount = 0
        return true
    }

    package mutating func reset() {
        semanticVisited = false
        layoutVisited = false
        foregroundCount = 0
        isActive = false
    }

    private static func visit(
        _ ordinal: UInt16,
        active: Bool,
        slot: inout Bool
    ) -> RenderWorkspaceVisit {
        guard active, ordinal == 0 else { return .invalid }
        guard !slot else { return .repeated }
        slot = true
        return .first
    }
}

package struct StaticRenderSink: RenderOperationSink {
    package let capacity = RenderSinkCapacity(
        maximumOperations: 1,
        maximumPositionedGlyphs: 1
    )
    package init() {}
    package mutating func begin(_ header: RenderPlanHeader) -> Bool {
        header.operationCount == 0
    }
    package mutating func fillRect(_ operation: FillRectOperation) -> Bool { false }
    package mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool { false }
    package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { false }
    package mutating func endPositionedGlyphs() -> Bool { false }
    package mutating func finish() -> Bool { true }
    package mutating func discard() {}
}

@inline(never)
package func spec008StaticRenderProductionEntry() -> UInt16 {
    var workspace = StaticRenderWorkspace()
    var sink = StaticRenderSink()
    let result = RenderProducer.produce(
        semantic: StaticSemanticRenderView(),
        layout: StaticResolvedRenderLayoutView(),
        textMetrics: StaticRenderMetricsView(),
        surfaceBounds: StaticResolvedRenderLayoutView().rootBounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: workspace.capacity,
        workspace: &workspace,
        sink: &sink
    )
    switch result {
    case .success(let header):
        return header.operationCount
    case .failure(let error):
        return UInt16(error.rawValue) + 100
    }
}

@inline(never)
package func spec008StaticRenderWorkspaceSize() -> UInt32 {
    UInt32(MemoryLayout<StaticRenderWorkspace>.size)
}

@inline(never)
package func spec008StaticRenderWorkspaceStride() -> UInt32 {
    UInt32(MemoryLayout<StaticRenderWorkspace>.stride)
}

@inline(never)
package func spec008StaticRenderWorkspaceAlignment() -> UInt32 {
    UInt32(MemoryLayout<StaticRenderWorkspace>.alignment)
}

@inline(never)
package func spec008StaticRenderForegroundSlotBytes() -> UInt32 {
    UInt32(MemoryLayout<Color>.stride)
}

@inline(never)
package func spec008StaticRenderOperationCapacity() -> UInt32 { 1 }

@inline(never)
package func spec008StaticRenderGlyphCapacity() -> UInt32 { 1 }

@inline(never)
package func spec008StaticRenderClipCapacity() -> UInt32 { 1 }

@inline(never)
package func spec008StaticRenderSemanticCapacity() -> UInt32 { 1 }

@inline(never)
package func spec008StaticRenderLayoutCapacity() -> UInt32 { 1 }

@inline(never)
package func spec008StaticRenderTraversalCapacity() -> UInt32 { 1 }

@inline(never)
package func spec008StaticRenderTextLineCapacity() -> UInt32 { 1 }
