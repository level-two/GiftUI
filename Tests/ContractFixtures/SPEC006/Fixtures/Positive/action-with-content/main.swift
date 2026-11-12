import GiftUI

private enum FixtureAction: UInt16, GiftUIAction {
    case minimum = 0
    case ordinary = 17
    case maximum = 65_535
}

private struct FixtureActionPayload: _GiftUISemanticActionPayload {
    let _giftUIAction: FixtureAction
}

private struct FixtureActionContainer<Content: View>: View {
    typealias Domain = Content.Domain
    typealias Body = Never

    let content: Content
    let payload: FixtureActionPayload

    init(action: FixtureAction, @ViewBuilder content: () -> Content) {
        self.content = content()
        payload = FixtureActionPayload(_giftUIAction: action)
    }

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError("action container bodies are unreachable") }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitActionPrimitive(content: content, payload: payload)
    }
}

private struct FixtureActionLeaf: View, _GiftUISemanticActionPayload {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never
    let _giftUIAction: FixtureAction

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError("action leaf bodies are unreachable") }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitActionPrimitive(self)
    }
}

func buildEmptyActionContainerFixture() -> some View {
    FixtureActionContainer(action: .minimum) {}
}

func buildOneChildActionContainerFixture() -> some View {
    FixtureActionContainer(action: .ordinary) {
        FixtureActionLeaf(_giftUIAction: .ordinary)
    }
}

func buildFiveChildActionContainerFixture() -> some View {
    FixtureActionContainer(action: .maximum) {
        FixtureActionLeaf(_giftUIAction: .minimum)
        FixtureActionLeaf(_giftUIAction: .ordinary)
        FixtureActionLeaf(_giftUIAction: .maximum)
        FixtureActionLeaf(_giftUIAction: .minimum)
        FixtureActionLeaf(_giftUIAction: .maximum)
    }
}
