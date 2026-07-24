public struct OptionalContent<Content: View>: View, PrimitiveView {
    package let content: Content?

    package init(_ content: Content?) {
        self.content = content
    }

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        guard let content else {
            return ViewNode(kind: .group)
        }
        return ViewNode(
            kind: .group,
            children: [context.makeChild(content, index: 0)]
        )
    }
}
