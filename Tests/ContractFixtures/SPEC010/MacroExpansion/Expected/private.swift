private struct PrivateHost: View {
    @State private var model = Model()
    var body: Never { fatalError() }

    fileprivate mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor) {
        visitor.visit(&_model, declarationOrdinal: 0)
    }

    fileprivate func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitStatefulCustomView(self) {
            (declaration: borrowing Self, read: borrowing _GiftUIFrameRead<Domain>)
                throws(_GiftUIAccessFailure) in
            try declaration._giftUIEvaluate(read: read)
        }
    }
}

extension PrivateHost: _GiftUIObservableStateHost {
}
