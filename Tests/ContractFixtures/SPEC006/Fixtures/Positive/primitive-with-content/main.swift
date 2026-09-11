import GiftUI

private struct FixturePayload: _GiftUISemanticPrimitivePayload {}

private struct FixtureContainer<Content: View>: View {
    let content: Content

    var body: Never {
        fatalError("primitive container bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(content: content, payload: FixturePayload())
    }
}

private struct FixtureLeaf: View, _GiftUISemanticPrimitivePayload {
    var body: Never {
        fatalError("primitive bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}

func buildPrimitiveContainerFixture() -> some View {
    FixtureContainer(content: FixtureLeaf())
}
