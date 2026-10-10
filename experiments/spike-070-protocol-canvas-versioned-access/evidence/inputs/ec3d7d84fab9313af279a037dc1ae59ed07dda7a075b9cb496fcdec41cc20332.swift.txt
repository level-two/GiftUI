package struct DisabledSemanticPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    package let isDisabled: Bool

    package init(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }
}

private struct GiftUIDisabledContent<Content: View>: View {
    typealias Body = Never

    let content: Content
    let payload: DisabledSemanticPayload

    var body: Never {
        fatalError("GiftUI disabled scopes have no view body")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitModifier(content: content, payload: payload)
    }
}

public extension View {
    func disabled(_ disabled: Bool) -> some View {
        GiftUIDisabledContent(
            content: self,
            payload: DisabledSemanticPayload(isDisabled: disabled)
        )
    }
}
