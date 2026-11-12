import GiftUI

struct Leaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

@ViewBuilder
func makeContent() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
}

struct FunctionRoot: View {
    typealias Domain = _GiftUIEmptyReadDomain

    @ViewBuilder
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> some View<_GiftUIEmptyReadDomain> {
        makeContent()
    }
}
