public struct SeveralHost: View {
    @State private var first = Model()
    struct Nested {
        @State var ignored = Model()
    }
    @GiftUI.State var second = Model()
    static var ignoredStatic = Model()
    public var body: Never { fatalError() }

    public mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor) {
        visitor.visit(&_first, declarationOrdinal: 0)
        visitor.visit(&_second, declarationOrdinal: 1)
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitStatefulCustomView(self) { declaration in
            declaration.body
        }
    }
}

extension SeveralHost: _GiftUIObservableStateHost {
}
