public struct Text: View, PrimitiveView {
    package let content: String

    public init(_ content: String) {
        self.content = content
    }

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        ViewNode(kind: .text(content))
    }
}
