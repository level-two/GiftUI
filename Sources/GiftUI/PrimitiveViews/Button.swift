public struct Button<Label: View>: View, PrimitiveView {
    package let action: () -> Void
    package let label: Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
}

public extension Button where Label == Text {
    init(_ title: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(title)
        }
    }
}
