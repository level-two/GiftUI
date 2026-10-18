@usableFromInline
package struct DisabledSemanticPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    @usableFromInline
    package let isDisabled: Bool

    package init(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }
}

private struct GiftUIDisabledContent<Content: View>: View {
    typealias Domain = Content.Domain
    typealias Body = Never

    let content: Content
    let payload: DisabledSemanticPayload

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure)
        -> Never
    {
        fatalError("GiftUI disabled scopes have no view body")
    }

    @inlinable

    @inline(__always)

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitModifier(content: content, payload: payload)
    }
}

public extension View {
    func disabled(_ disabled: Bool) -> some View<Domain> {
        GiftUIDisabledContent(
            content: self,
            payload: DisabledSemanticPayload(isDisabled: disabled)
        )
    }
}
