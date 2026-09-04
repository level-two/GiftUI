public protocol GiftUIAction: RawRepresentable, Equatable, Sendable
where RawValue == UInt16 {}

public protocol _GiftUISemanticTraversalVisitor {
    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: () -> Declaration.Body
    )
}

public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    )
}

extension View {
    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitCustomView(self) { body }
    }
}

extension Never: View {
    public typealias Body = Never

    public var body: Never {
        fatalError("Never cannot produce a GiftUI view body")
    }
}

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
}
