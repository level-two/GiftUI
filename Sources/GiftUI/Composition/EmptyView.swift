public struct EmptyView: View, PrimitiveView {
    public init() {}

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        ViewNode(kind: .group)
    }
}
