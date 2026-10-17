@usableFromInline
package struct ButtonSemanticPayload<Action: GiftUIAction, Label: View>:
    _GiftUISemanticActionPayload
{
    @usableFromInline
    package let label: Label
    package let action: Action

    @usableFromInline
    package var _giftUIAction: Action {
        action
    }
}

public struct Button<Action: GiftUIAction, Label: View>: View {
    public typealias Domain = Label.Domain
    public typealias Body = Never

    @usableFromInline
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

    @inlinable

    @inline(__always)

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitActionPrimitive(
            content: _giftUIButtonPayload.label,
            payload: _giftUIButtonPayload
        )
    }
}
