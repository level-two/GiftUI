package enum ViewGraph {
    package static func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size,
        stateStorage: (any StateStorage)? = nil
    ) -> ViewNode {
        var context = ViewBuildContext(stateStorage: stateStorage)
        let root = content._makeNode(context: &context)
        let rootSize = root.measure()
        root.place(
            at: Point(
                x: (surfaceSize.width - rootSize.width) / 2,
                y: (surfaceSize.height - rootSize.height) / 2
            )
        )
        return root
    }
}
