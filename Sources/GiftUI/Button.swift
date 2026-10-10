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
    public typealias Domain = Label.Domain
    public typealias Body = Never

    package let _giftUIButtonPayload: ButtonSemanticPayload<Action, Label>

    public init(action: Action, @ViewBuilder label: () throws(_GiftUIAccessFailure) -> Label)
        throws(_GiftUIAccessFailure)
    {
        _giftUIButtonPayload = ButtonSemanticPayload(
            label: try label(),
            action: action
        )
    }

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("Button has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitActionPrimitive(
            content: _giftUIButtonPayload.label,
            payload: _giftUIButtonPayload
        )
    }
}
