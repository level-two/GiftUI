public struct TupleView<Content>: View, PrimitiveView {
    public let value: Content

    public init(_ value: Content) {
        self.value = value
    }
}
