@usableFromInline
package struct DisabledSemanticPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    @usableFromInline
    package let isDisabled: Bool

    @inlinable
    @inline(__always)
    package init(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }
}

@usableFromInline
struct GiftUIDisabledContent<Content: View>: View {
    @usableFromInline
    typealias Domain = Content.Domain
    @usableFromInline
    typealias Body = Never

    @usableFromInline
    let content: Content
    @usableFromInline
    let payload: DisabledSemanticPayload

    @inlinable
    @inline(__always)
    init(content: Content, payload: DisabledSemanticPayload) {
        self.content = content
        self.payload = payload
    }

    @usableFromInline
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
    @inlinable
    @inline(__always)
    func disabled(_ disabled: Bool) -> some View<Domain> {
        GiftUIDisabledContent(
            content: self,
            payload: DisabledSemanticPayload(isDisabled: disabled)
        )
    }
}
