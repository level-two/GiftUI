public struct TupleView<Content>: View, PrimitiveView {
    public let value: Content
    private let makeChildren: (inout ViewBuildContext) -> [ViewNode]

    package init(
        _ value: Content,
        makeChildren: @escaping (inout ViewBuildContext) -> [ViewNode]
    ) {
        self.value = value
        self.makeChildren = makeChildren
    }

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        ViewNode(kind: .group, children: makeChildren(&context))
    }
}
