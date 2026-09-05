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
    ) {
        visitor.visitStatefulCustomView(self) { declaration in
            declaration.body
        }
    }
}

extension PrivateHost: _GiftUIObservableStateHost {
}
