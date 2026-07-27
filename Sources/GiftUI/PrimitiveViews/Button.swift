package enum ButtonAction {
    case identified(ActionID)
    case callback(() -> Void)
}

public struct Button<Label: View>: View, PrimitiveView {
    package let action: ButtonAction
    package let label: Label

    /// Creates a portable button whose bounded identifier is dispatched by
    /// the selected runtime.
    public init(
        action: ActionID,
        @ViewBuilder label: () -> Label
    ) {
        self.action = .identified(action)
        self.label = label()
    }

    package init(
        dynamicAction action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = .callback(action)
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
    init(_ title: StaticString, action: ActionID) {
        self.init(action: action) {
            Text(title)
        }
    }
}
