struct EmptyHost: View {
    var body: Never { fatalError() }

    mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor & ~Copyable & ~Escapable
    >(_ visitor: inout Visitor) {

    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitStatefulCustomView(self) {
            (declaration: borrowing Self, read: borrowing _GiftUIFrameRead<Domain>)
                throws(_GiftUIAccessFailure) in
            try declaration._giftUIEvaluate(read: read)
        }
    }
}

extension EmptyHost: _GiftUIObservableStateHost {
}
