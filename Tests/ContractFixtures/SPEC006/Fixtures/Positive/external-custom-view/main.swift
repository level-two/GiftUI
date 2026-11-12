import GiftUI

public struct ExternalLeaf: View {
    public typealias Domain = _GiftUIEmptyReadDomain

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("compile-only leaf")
    }
}

public struct ExternalCustomView: View {
    public typealias Domain = _GiftUIEmptyReadDomain
    public typealias Body = ExternalLeaf

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> ExternalLeaf
    {
        ExternalLeaf()
    }
}

public func acceptExternalCustomView(_ view: ExternalCustomView) {
    _ = view
}
