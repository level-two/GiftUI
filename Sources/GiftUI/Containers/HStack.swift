public struct HStack<Content: View>: View, PrimitiveView {
    package let spacing: Int
    package let content: Content

    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        precondition(spacing >= 0, "Stack spacing must not be negative")
        self.spacing = spacing
        self.content = content()
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitHStack(spacing: spacing, content: content)
    }
}
