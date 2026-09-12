package struct ButtonSemanticPayload<Action: GiftUIAction, Label: View>:
    _GiftUISemanticActionPayload
{
    package let label: Label
    package let action: Action

    package var _giftUIAction: Action {
        action
    }
}

public struct Button<Action: GiftUIAction, Label: View>: View {
    public typealias Body = Never

    package let _giftUIButtonPayload: ButtonSemanticPayload<Action, Label>

    public init(action: Action, @ViewBuilder label: () -> Label) {
        _giftUIButtonPayload = ButtonSemanticPayload(
            label: label(),
            action: action
        )
    }

    public var body: Never {
        fatalError("Button has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitActionPrimitive(
            content: _giftUIButtonPayload.label,
            payload: _giftUIButtonPayload
        )
    }
}
