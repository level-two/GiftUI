public struct TupleView<each Content: View>: View, PrimitiveView {
    public let value: (repeat each Content)

    package init(_ value: repeat each Content) {
        self.value = (repeat each value)
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitTuple(repeat each value)
    }
}
