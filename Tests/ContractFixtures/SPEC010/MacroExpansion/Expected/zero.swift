struct EmptyHost: View {
    var body: Never { fatalError() }

    mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor) {

    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitStatefulCustomView(self) { declaration in
            declaration.body
        }
    }
}

extension EmptyHost: _GiftUIObservableStateHost {
}
