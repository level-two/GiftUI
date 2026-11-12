import GiftUI

struct Leaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

@ViewBuilder
func nestedPair() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
}

@ViewBuilder
func nestedSix() -> some View<_GiftUIEmptyReadDomain> {
    nestedPair()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}
