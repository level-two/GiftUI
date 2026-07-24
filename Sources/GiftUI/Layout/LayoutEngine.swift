public enum LayoutEngine {
    public static func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> LayoutNode {
        var context = ViewBuildContext()
        let root = content._makeNode(context: &context)
        let rootSize = root.measure()
        root.place(
            at: Point(
                x: (surfaceSize.width - rootSize.width) / 2,
                y: (surfaceSize.height - rootSize.height) / 2
            )
        )
        return root.layoutNode()
    }
}
