public struct _GiftUIForegroundStylePayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    package let color: Color

    package init(color: Color) {
        self.color = color
    }
}

public struct _GiftUIBackgroundPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    package let color: Color

    package init(color: Color) {
        self.color = color
    }
}

@usableFromInline
struct GiftUIModifiedContent<Content: View, Payload: _GiftUISemanticModifierPayload>:
    View
{
    @usableFromInline
    typealias Domain = Content.Domain
    @usableFromInline
    typealias Body = Never

    @usableFromInline
    let content: Content
    @usableFromInline
    let payload: Payload

    @usableFromInline
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure)
        -> Never
    {
        fatalError("GiftUI modifiers have no view body")
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
    func foregroundStyle(_ color: Color) -> some View<Domain> {
        GiftUIModifiedContent(
            content: self,
            payload: _GiftUIForegroundStylePayload(color: color)
        )
    }

    func background(_ color: Color) -> some View<Domain> {
        GiftUIModifiedContent(
            content: self,
            payload: _GiftUIBackgroundPayload(color: color)
        )
    }
}
