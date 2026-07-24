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

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        let labelNode = context.makeChild(label, index: 0)
        return ViewNode(kind: .button(action), children: [labelNode])
    }
}

public extension Button where Label == Text {
    init(_ title: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(title)
        }
    }
}
