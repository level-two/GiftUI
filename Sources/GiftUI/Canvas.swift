public struct Canvas<D: _GiftUIReadDomain>: View, _GiftUISemanticPrimitivePayload {
    public typealias Domain = D
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

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure)
        -> Never
    {
        fatalError("Canvas has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(self)
    }

    package func _giftUIInvokeCanvas(
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        #if GIFTUI_DYNAMIC_PROFILE
            try draw(&context, size)
        #else
            _ = size
            throw DrawingError.invariantViolation
        #endif
    }
}
