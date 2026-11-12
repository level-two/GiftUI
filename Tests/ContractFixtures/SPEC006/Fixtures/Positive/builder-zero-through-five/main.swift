import GiftUI

struct Leaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

@ViewBuilder
func zero() -> some View<_GiftUIEmptyReadDomain> {}

@ViewBuilder
func one() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
}

@ViewBuilder
func two() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
}

@ViewBuilder
func three() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
    Leaf()
}

@ViewBuilder
func four() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}

@ViewBuilder
func five() -> some View<_GiftUIEmptyReadDomain> {
    Leaf()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}
