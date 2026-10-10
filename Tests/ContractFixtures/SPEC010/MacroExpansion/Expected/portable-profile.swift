import GiftUI

public struct PortableProfileModel: _GiftUIObservableReference {
    public init() {}

    public mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    public mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}
public struct PortableProfileHost: View {
    @State private var primary = PortableProfileModel()
    @GiftUI.State private var secondary = PortableProfileModel()

    public init() {}

    public var body: Never { fatalError() }

    public mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor & ~Copyable & ~Escapable
    >(_ visitor: inout Visitor) {
        visitor.visit(&_primary, declarationOrdinal: 0)
        visitor.visit(&_secondary, declarationOrdinal: 1)
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitStatefulCustomView(self) {
            (declaration: borrowing Self, read: borrowing _GiftUIFrameRead<Domain>)
                throws(_GiftUIAccessFailure) in
            try declaration._giftUIEvaluate(read: read)
        }
    }
}

extension PortableProfileHost: _GiftUIObservableStateHost {
}
