public struct HStack<Content: View>: View, PrimitiveView {
    package let spacing: Int
    package let content: Content

    public init(
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }
}
