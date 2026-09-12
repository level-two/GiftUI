public struct Canvas: View, _GiftUISemanticPrimitivePayload {
    public typealias Body = Never

    #if GIFTUI_DYNAMIC_PROFILE
        private let draw:
            (
                inout GraphicsContext,
                Size
            ) throws(DrawingError) -> Void
    #endif

    public init(
        _ draw:
            @escaping (
                inout GraphicsContext,
                Size
            ) throws(DrawingError) -> Void
    ) {
        #if GIFTUI_DYNAMIC_PROFILE
            self.draw = draw
        #else
            _ = draw
        #endif
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
