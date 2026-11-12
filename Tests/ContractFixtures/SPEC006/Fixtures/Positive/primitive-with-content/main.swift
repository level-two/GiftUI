import GiftUI

private struct FixturePayload: _GiftUISemanticPrimitivePayload {}

private struct FixtureContainer<Content: View>: View {
    typealias Domain = Content.Domain
    typealias Body = Never

    let content: Content

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError("primitive container bodies are unreachable") }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(content: content, payload: FixturePayload())
    }
}

private struct FixtureLeaf: View, _GiftUISemanticPrimitivePayload {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError("primitive bodies are unreachable") }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(self)
    }
}

func buildPrimitiveContainerFixture() -> some View {
    FixtureContainer(content: FixtureLeaf())
}
