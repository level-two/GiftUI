import GiftUI

struct StyledCustomView: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("style public surface fixture is compile-only")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitEmpty()
    }
}

func requireView<Content: View>(_: Content) {}

requireView(StyledCustomView())
requireView(
    Text<_GiftUIEmptyReadDomain>(BoundedText(42))
        .background(Color(red: 1, green: 2, blue: 3))
)
