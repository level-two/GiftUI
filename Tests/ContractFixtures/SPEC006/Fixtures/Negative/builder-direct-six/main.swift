import GiftUI

struct Leaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

@ViewBuilder
func invalidDirectSix() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}
