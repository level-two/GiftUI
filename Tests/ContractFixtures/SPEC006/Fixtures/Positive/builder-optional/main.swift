import GiftUI

struct Leaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

struct OptionalRoot: View {
    typealias Domain = _GiftUIEmptyReadDomain
    let includesLeaf: Bool

    @ViewBuilder
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> some View<_GiftUIEmptyReadDomain> {
        if includesLeaf {
            Leaf()
        }
    }
}
