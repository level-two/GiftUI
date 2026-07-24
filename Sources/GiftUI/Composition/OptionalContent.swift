public struct OptionalContent<Content: View>: View, PrimitiveView {
    package let content: Content?

    package init(_ content: Content?) {
        self.content = content
    }
}
