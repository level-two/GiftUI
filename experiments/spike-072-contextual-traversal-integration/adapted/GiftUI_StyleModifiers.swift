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

private struct GiftUIModifiedContent<Content: View, Payload: _GiftUISemanticModifierPayload>: _GiftUILeaf
{
    typealias Body = Never

    let content: Content
    let payload: Payload

    var body: Never {
        fatalError("GiftUI modifiers have no view body")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitModifier(content: content, payload: payload, session: &session)
    }
}

public extension View {
    func foregroundStyle(_ color: Color) -> some View {
        GiftUIModifiedContent(
            content: self,
            payload: _GiftUIForegroundStylePayload(color: color)
        )
    }

    func background(_ color: Color) -> some View {
        GiftUIModifiedContent(
            content: self,
            payload: _GiftUIBackgroundPayload(color: color)
        )
    }
}
