public struct EmptyView: View, PrimitiveView {
    public init() {}

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitEmpty()
    }
}
