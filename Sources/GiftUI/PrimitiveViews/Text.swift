public struct Text: View, PrimitiveView {
    package let content: String

    public init(_ content: String) {
        self.content = content
    }
}
