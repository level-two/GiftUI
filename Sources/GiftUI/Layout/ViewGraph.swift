package enum ViewGraph {
    package static func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size,
        stateStorage: (any StateStorage)? = nil
    ) -> ViewNode {
        var context = ViewBuildContext(stateStorage: stateStorage)
        content._visit(&context)
        guard let root = context.root else {
            preconditionFailure("GiftUI traversal did not produce a root node")
        }
        var layoutContext = LayoutContext()
        let rootSize = root.measure(
            proposal: ProposedSize(
                width: surfaceSize.width,
                height: surfaceSize.height
            ),
            context: &layoutContext
        )
        root.place(
            in: Rect(
                origin: Point(
                    x: LayoutArithmetic.requireSubtract(
                        surfaceSize.width,
                        rootSize.width,
                        operation: "centering root width"
                    ) / 2,
                    y: LayoutArithmetic.requireSubtract(
                        surfaceSize.height,
                        rootSize.height,
                        operation: "centering root height"
                    ) / 2
                ),
                size: rootSize
            ),
            context: &layoutContext
        )
        return root
    }
}
