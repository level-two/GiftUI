public protocol GiftUIAction: RawRepresentable, Equatable, Sendable
where RawValue == UInt16 {}

public protocol _GiftUISemanticTraversalVisitor {
    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: () -> Declaration.Body
    )

    mutating func visitEmpty()

    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    )

    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    )

    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    )

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    )

    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First,
        second: Second.Type
    )

    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    )

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type)

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
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
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<A: View, B: View>(
        _ a: A,
        _ b: B
    ) -> TupleView<A, B> {
        TupleView(a, b)
    }

    public static func buildBlock<A: View, B: View, C: View>(
        _ a: A,
        _ b: B,
        _ c: C
    ) -> TupleView3<A, B, C> {
        TupleView3(a, b, c)
    }

    public static func buildBlock<A: View, B: View, C: View, D: View>(
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> TupleView4<A, B, C, D> {
        TupleView4(a, b, c, d)
    }

    public static func buildBlock<A: View, B: View, C: View, D: View, E: View>(
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D,
        _ e: E
    ) -> TupleView5<A, B, C, D, E> {
        TupleView5(a, b, c, d, e)
    }

    public static func buildEither<A: View, B: View>(
        first: A
    ) -> ConditionalContent<A, B> {
        ConditionalContent(first: first)
    }

    public static func buildEither<A: View, B: View>(
        second: B
    ) -> ConditionalContent<A, B> {
        ConditionalContent(second: second)
    }

    public static func buildOptional<Content: View>(
        _ content: Content?
    ) -> OptionalContent<Content> {
        OptionalContent(content)
    }
}

public struct EmptyView: View {
    public typealias Body = Never

    package init() {}

    public var body: Never {
        fatalError("EmptyView has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitEmpty()
    }
}

public struct TupleView<A: View, B: View>: View {
    public typealias Body = Never

    package let a: A
    package let b: B

    package init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }

    public var body: Never {
        fatalError("TupleView has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitFixed(a, b)
    }
}

public struct TupleView3<A: View, B: View, C: View>: View {
    public typealias Body = Never

    package let a: A
    package let b: B
    package let c: C

    package init(_ a: A, _ b: B, _ c: C) {
        self.a = a
        self.b = b
        self.c = c
    }

    public var body: Never {
        fatalError("TupleView3 has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitFixed(a, b, c)
    }
}

public struct TupleView4<A: View, B: View, C: View, D: View>: View {
    public typealias Body = Never

    package let a: A
    package let b: B
    package let c: C
    package let d: D

    package init(_ a: A, _ b: B, _ c: C, _ d: D) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }

    public var body: Never {
        fatalError("TupleView4 has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitFixed(a, b, c, d)
    }
}

public struct TupleView5<A: View, B: View, C: View, D: View, E: View>: View {
    public typealias Body = Never

    package let a: A
    package let b: B
    package let c: C
    package let d: D
    package let e: E

    package init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
    }

    public var body: Never {
        fatalError("TupleView5 has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitFixed(a, b, c, d, e)
    }
}

public struct ConditionalContent<First: View, Second: View>: View {
    public typealias Body = Never

    private enum Storage {
        case first(First)
        case second(Second)
    }

    private let storage: Storage

    package init(first: First) {
        storage = .first(first)
    }

    package init(second: Second) {
        storage = .second(second)
    }

    public var body: Never {
        fatalError("ConditionalContent has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        switch storage {
        case .first(let content):
            visitor.visitConditionalFirst(content, second: Second.self)
        case .second(let content):
            visitor.visitConditionalSecond(first: First.self, content)
        }
    }
}

public struct OptionalContent<Content: View>: View {
    public typealias Body = Never

    package let content: Content?

    package init(_ content: Content?) {
        self.content = content
    }

    public var body: Never {
        fatalError("OptionalContent has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        if let content {
            visitor.visitOptionalPresent(content)
        } else {
            visitor.visitOptionalAbsent(Content.self)
        }
    }
}
