package enum ViewGraph {
    package static func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size,
        stateStorage: (any StateStorage)? = nil
    ) -> ViewNode {
        var context = ViewBuildContext(stateStorage: stateStorage)
        let root = content._makeNode(context: &context)
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
                    x: (surfaceSize.width - rootSize.width) / 2,
                    y: (surfaceSize.height - rootSize.height) / 2
                ),
                size: rootSize
            ),
            context: &layoutContext
        )
        return root
    }
}
