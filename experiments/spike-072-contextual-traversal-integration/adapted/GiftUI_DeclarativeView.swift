public protocol GiftUIAction: RawRepresentable, Equatable, Sendable
where RawValue == UInt16 {}

public protocol _GiftUISemanticPrimitivePayload {}

public protocol _GiftUISemanticActionPayload {
    associatedtype Action: GiftUIAction

    var _giftUIAction: Action { get }
}

public protocol _GiftUISemanticModifierPayload {}

public protocol _GiftUISemanticTraversalVisitor {
    mutating func visitCustomView<Declaration: View, Session: EvaluationSession & ~Copyable>(
        _ declaration: borrowing Declaration
    , session: inout Session)

    mutating func visitStatefulCustomView<
        Declaration: View & _GiftUIObservableStateHost
    , Session: EvaluationSession & ~Copyable>(
        _ declaration: borrowing Declaration
    , session: inout Session)

    mutating func visitEmpty<Session: EvaluationSession & ~Copyable>(session: inout Session)

    mutating func visitFixed<A: View, B: View, Session: EvaluationSession & ~Copyable>(
        _ a: borrowing A,
        _ b: borrowing B
    , session: inout Session)

    mutating func visitFixed<A: View, B: View, C: View, Session: EvaluationSession & ~Copyable>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    , session: inout Session)

    mutating func visitFixed<A: View, B: View, C: View, D: View, Session: EvaluationSession & ~Copyable>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    , session: inout Session)

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View, Session: EvaluationSession & ~Copyable>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    , session: inout Session)

    mutating func visitConditionalFirst<First: View, Second: View, Session: EvaluationSession & ~Copyable>(
        _ content: borrowing First,
        second: Second.Type
    , session: inout Session)

    mutating func visitConditionalSecond<First: View, Second: View, Session: EvaluationSession & ~Copyable>(
        first: First.Type,
        _ content: borrowing Second
    , session: inout Session)

    mutating func visitOptionalAbsent<Content: View, Session: EvaluationSession & ~Copyable>(_ content: Content.Type, session: inout Session)

    mutating func visitOptionalPresent<Content: View, Session: EvaluationSession & ~Copyable>(
        _ content: borrowing Content
    , session: inout Session)

    mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload, Session: EvaluationSession & ~Copyable>(
        _ payload: borrowing Payload
    , session: inout Session)

    mutating func visitPrimitive<
        Content: View,
        Payload: _GiftUISemanticPrimitivePayload
    , Session: EvaluationSession & ~Copyable>(
        content: borrowing Content,
        payload: borrowing Payload
    , session: inout Session)

    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload, Session: EvaluationSession & ~Copyable>(
        _ payload: borrowing Payload
    , session: inout Session)

    mutating func visitActionPrimitive<
        Content: View,
        Payload: _GiftUISemanticActionPayload
    , Session: EvaluationSession & ~Copyable>(
        content: borrowing Content,
        payload: borrowing Payload
    , session: inout Session)

    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    , Session: EvaluationSession & ~Copyable>(
        content: borrowing Content,
        payload: borrowing Payload
    , session: inout Session)
}

public protocol View {
    associatedtype Body: View

    func _evaluate<Reads: FrozenAccess & ~Escapable>(read: borrowing Reads) throws(AccessFailure) -> Body

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session)
}

extension View {
    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitCustomView(self, session: &session)
    }
}

public protocol _GiftUILeaf: View where Body == Never {}

extension _GiftUILeaf {
    public func _evaluate<Reads: FrozenAccess & ~Escapable>(read: borrowing Reads) throws(AccessFailure) -> Never {
        throw .invalidField
    }
}

extension Never: _GiftUILeaf {
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

public struct EmptyView: _GiftUILeaf {
    public typealias Body = Never

    package init() {}

    public var body: Never {
        fatalError("EmptyView has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitEmpty(session: &session)
    }
}

public struct TupleView<A: View, B: View>: _GiftUILeaf {
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

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitFixed(a, b, session: &session)
    }
}

public struct TupleView3<A: View, B: View, C: View>: _GiftUILeaf {
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

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitFixed(a, b, c, session: &session)
    }
}

public struct TupleView4<A: View, B: View, C: View, D: View>: _GiftUILeaf {
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

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitFixed(a, b, c, d, session: &session)
    }
}

public struct TupleView5<A: View, B: View, C: View, D: View, E: View>: _GiftUILeaf {
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

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitFixed(a, b, c, d, e, session: &session)
    }
}

public struct ConditionalContent<First: View, Second: View>: _GiftUILeaf {
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

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        switch storage {
        case .first(let content):
            visitor.visitConditionalFirst(content, second: Second.self, session: &session)
        case .second(let content):
            visitor.visitConditionalSecond(first: First.self, content, session: &session)
        }
    }
}

public struct OptionalContent<Content: View>: _GiftUILeaf {
    public typealias Body = Never

    package let content: Content?

    package init(_ content: Content?) {
        self.content = content
    }

    public var body: Never {
        fatalError("OptionalContent has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        if let content {
            visitor.visitOptionalPresent(content, session: &session)
        } else {
            visitor.visitOptionalAbsent(Content.self, session: &session)
        }
    }
}
