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
    ) {
        visitor.visitStatefulCustomView(self) { declaration in
            declaration.body
        }
    }
}

extension DerivedHost: _GiftUIObservableStateHost {
}
