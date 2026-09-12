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
    typealias Body = Never

    let content: Content
    let payload: FixtureActionPayload

    init(action: FixtureAction, @ViewBuilder content: () -> Content) {
        self.content = content()
        payload = FixtureActionPayload(_giftUIAction: action)
    }

    var body: Never {
        fatalError("action container bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitActionPrimitive(content: content, payload: payload)
    }
}

private struct FixtureActionLeaf: View, _GiftUISemanticActionPayload {
    let _giftUIAction: FixtureAction

    var body: Never {
        fatalError("action leaf bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
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
