import GiftUI

struct Leaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

@ViewBuilder
func invalidDynamicArray() -> some View<_GiftUIEmptyReadDomain> {
    for _ in 0..<2 {
        Leaf()
    }
}
