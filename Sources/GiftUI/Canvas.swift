public struct Canvas: View, _GiftUISemanticPrimitivePayload {
    public typealias Body = Never

    private let draw:
        (
            inout GraphicsContext,
            Size
        ) throws(DrawingError) -> Void

    public init(
        _ draw:
            @escaping (
                inout GraphicsContext,
                Size
            ) throws(DrawingError) -> Void
    ) {
        self.draw = draw
    }

    public var body: Never {
        fatalError("Canvas has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}
