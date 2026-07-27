import GiftUI

public final class DynamicRuntime: GiftUIRuntime {
    public typealias Profile = DynamicRuntimeProfile

    public private(set) var isInvalid = true
    package private(set) var invalidationGeneration: UInt = 0
    public lazy var state = DynamicStateStore { [weak self] in
        self?.invalidate()
    }

    public init() {}

    public func invalidate() {
        invalidationGeneration &+= 1
        isInvalid = true
    }

    public func markRendered() {
        isInvalid = false
    }

    package func markRendered(ifUnchangedSince generation: UInt) {
        guard invalidationGeneration == generation else { return }
        markRendered()
    }

    public func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> LayoutNode {
        let generation = invalidationGeneration
        let root = ViewGraph.layout(
            content,
            in: surfaceSize,
            stateStorage: state
        )
        markRendered(ifUnchangedSince: generation)
        return root.layoutNode()
    }

    public func layoutSnapshot<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> DynamicLayoutSnapshot {
        let generation = invalidationGeneration
        let root = makeViewGraph(content, in: surfaceSize)
        let snapshot = DynamicLayoutSnapshot(
            layout: root.layoutNode(),
            identifiedHitRegions: root.makeIdentifiedHitRegions()
        )
        markRendered(ifUnchangedSince: generation)
        return snapshot
    }

    package func makeViewGraph<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> ViewNode {
        ViewGraph.layout(
            content,
            in: surfaceSize,
            stateStorage: state
        )
    }
}
