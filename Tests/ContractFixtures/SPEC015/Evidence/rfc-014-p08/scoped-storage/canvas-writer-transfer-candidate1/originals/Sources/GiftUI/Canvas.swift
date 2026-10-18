/// Compiled finite-source Canvas contract. Authored `draw` witnesses are lowered
/// into this fixed-domain requirement; Canvas alone receives the Never leaf default.
public protocol Canvas: View, _GiftUISemanticPrimitivePayload where Body == Never {
    func _giftUIDraw(
        in bounds: Rect, context: inout GraphicsContext,
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(DrawingError)
}

public extension Canvas {
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError("Canvas has no view body") }

    @inlinable

    @inline(__always)

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(self)
    }

    package func _giftUIInvokeCanvas(
        context: inout GraphicsContext, size: Size,
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(DrawingError) {
        guard let bounds = Rect(origin: Point(x: 0, y: 0), size: size) else { throw .invalidValue }
        try _giftUIDraw(
            in: bounds, context: &context, read: read)
    }
}
