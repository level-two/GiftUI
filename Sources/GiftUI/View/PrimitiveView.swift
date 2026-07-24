package protocol PrimitiveView: View where Body == Never {
    func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode
}

extension PrimitiveView {
    public var body: Never {
        fatalError("Primitive GiftUI views do not have a body")
    }

    public func _makeNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        _makePrimitiveNode(context: &context)
    }
}
