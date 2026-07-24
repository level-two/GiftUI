import GiftUI

public final class DynamicRuntime {
    public private(set) var isInvalid = true
    public lazy var state = DynamicStateStore { [weak self] in
        self?.invalidate()
    }

    public init() {}

    public func invalidate() {
        isInvalid = true
    }

    public func markRendered() {
        isInvalid = false
    }

    public func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> LayoutNode {
        let root = ViewGraph.layout(
            content,
            in: surfaceSize,
            stateStorage: state
        )
        markRendered()
        return root.layoutNode()
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
