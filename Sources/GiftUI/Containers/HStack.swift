public struct HStack<Content: View>: View, PrimitiveView {
    package let spacing: Int
    package let content: Content

    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        precondition(spacing >= 0, "Stack spacing must not be negative")
        self.spacing = spacing
        self.content = content()
    }

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        let contentNode = context.makeChild(content, index: 0)
        return ViewNode(
            kind: .hStack(spacing: spacing),
            children: contentNode.unwrappedGroupChildren
        )
    }
}
