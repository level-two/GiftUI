class BaseHost {
    @State var inherited = Model()
}
class DerivedHost: BaseHost, View {
    @State var direct = Model()
    var body: Never { fatalError() }

    func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor) {
        visitor.visit(&_direct, declarationOrdinal: 0)
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitStatefulCustomView(self) {
            (declaration: borrowing Self, read: borrowing _GiftUIFrameRead<Domain>)
                throws(_GiftUIAccessFailure) in
            try declaration._giftUIEvaluate(read: read)
        }
    }
}

extension DerivedHost: _GiftUIObservableStateHost {
}
