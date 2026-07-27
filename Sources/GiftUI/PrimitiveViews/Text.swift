public struct Text: View, PrimitiveView {
    package let content: String

    /// Creates text from storage whose size is known in the application
    /// binary. Bounded and resource-backed representations will replace the
    /// current graph conversion in the static runtime.
    public init(_ content: StaticString) {
        self.content = content.description
    }

    public init(_ content: String) {
        self.content = content
    }

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        ViewNode(kind: .text(content))
    }
}
