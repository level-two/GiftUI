import GiftUI

struct FirstLeaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

struct SecondLeaf: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { fatalError() }
}

struct ConditionalRoot: View {
    typealias Domain = _GiftUIEmptyReadDomain
    let useFirst: Bool

    @ViewBuilder
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> some View<_GiftUIEmptyReadDomain> {
        if useFirst {
            FirstLeaf()
        } else {
            SecondLeaf()
        }
    }
}
