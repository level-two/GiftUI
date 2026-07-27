public struct ButtonAction {
    package enum Storage {
        case identified(ActionID)
        #if !hasFeature(Embedded)
        case callback(() -> Void)
        #endif
    }

    package let storage: Storage

    package init(_ action: ActionID) {
        storage = .identified(action)
    }

    #if !hasFeature(Embedded)
    package init(callback: @escaping () -> Void) {
        storage = .callback(callback)
    }
    #endif
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
        self.action = ButtonAction(action)
        self.label = label()
    }

    #if !hasFeature(Embedded)
    package init(
        dynamicAction action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = ButtonAction(callback: action)
        self.label = label()
    }
    #endif

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitButton(action: action, label: label)
    }
}

public extension Button where Label == Text {
    init(_ title: StaticString, action: ActionID) {
        self.init(action: action) {
            Text(title)
        }
    }
}
