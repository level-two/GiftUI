// Draft target form after context injection. The authoring signature has only
// bounds/context. Adding `read` here is an explicit experimental contract delta.
protocol Canvas: View, _GiftUISemanticPrimitivePayload where Body == Never {
    func draw(in bounds: Rect, context: inout GraphicsContext,
              read: borrowing FrameRead) throws(DrawingError)
}
extension Canvas {
    var body: Never { fatalError("Canvas body is never evaluated") }
    func _giftUITraverse<V: _GiftUISemanticTraversalVisitor>(_ visitor: inout V) {
        visitor.visitPrimitive(self)
    }
}
