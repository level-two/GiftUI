public protocol GiftUIAction: RawRepresentable, Equatable, Sendable
where RawValue == UInt16 {}

public protocol _GiftUISemanticPrimitivePayload {}

public protocol _GiftUISemanticActionPayload {
    associatedtype Action: GiftUIAction

    var _giftUIAction: Action { get }
}

public protocol _GiftUISemanticModifierPayload {}

public protocol _GiftUIReadDomain { associatedtype Slot }

public enum _GiftUIAccessFailure: UInt8, Error, Equatable {
    case invalidPhase = 0
    case wrongOwner = 1
    case wrongSchema = 2
    case staleModel = 3
    case outOfBounds = 4
}

public struct _GiftUIFrameRead<D: _GiftUIReadDomain>: ~Escapable {
    @usableFromInline package let slots: Span<D.Slot>

    @_lifetime(copy slots)
    @inlinable
    package init(slots: Span<D.Slot>) { self.slots = slots }
}

public struct _GiftUIModelKey<Schema>: Equatable {
    private let ownerInstance: UInt32
    private let allocationGeneration: UInt32
    private let slot: UInt16

    package init(ownerInstance: UInt32, allocationGeneration: UInt32, slot: UInt16) {
        self.ownerInstance = ownerInstance
        self.allocationGeneration = allocationGeneration
        self.slot = slot
    }

    // Only package-owned generated schemas and host bridges can inspect this value.
    package var _giftUIOwnerInstance: UInt32 { ownerInstance }
    package var _giftUIAllocationGeneration: UInt32 { allocationGeneration }
    package var _giftUISlot: UInt16 { slot }
}

public enum _GiftUIEmptyReadDomain: _GiftUIReadDomain {
    public typealias Slot = UInt8
}

public protocol View<Domain> {
    associatedtype Domain: _GiftUIReadDomain
    associatedtype Body: View
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Body
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain
}

public extension View where Body.Domain == Domain {
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitCustomView(self) {
            (read: borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) in
            try _giftUIEvaluate(read: read)
        }
    }
}

extension Never: View {
    public typealias Domain = _GiftUIEmptyReadDomain
    public typealias Body = Never
    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    { switch self {} }
    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain { switch self {} }
}
public protocol _GiftUISemanticTraversalVisitor: ~Copyable, ~Escapable {
    associatedtype Domain: _GiftUIReadDomain

    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) ->
            Declaration.Body
    ) where Declaration.Domain == Domain, Declaration.Body.Domain == Domain

    mutating func visitStatefulCustomView<
        Declaration: View & _GiftUIObservableStateHost
    >(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) where Declaration.Domain == Domain, Declaration.Body.Domain == Domain

    mutating func visitEmpty()

    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    ) where A.Domain == Domain, B.Domain == Domain

    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    ) where A.Domain == Domain, B.Domain == Domain, C.Domain == Domain

    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    ) where A.Domain == Domain, B.Domain == Domain, C.Domain == Domain, D.Domain == Domain

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    )
    where
        A.Domain == Domain, B.Domain == Domain, C.Domain == Domain, D.Domain == Domain,
        E.Domain == Domain

    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First,
        second: Second.Type
    ) where First.Domain == Domain, Second.Domain == Domain

    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    ) where First.Domain == Domain, Second.Domain == Domain

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type)
    where Content.Domain == Domain

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) where Content.Domain == Domain

    mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(
        _ payload: borrowing Payload
    )

    mutating func visitPrimitive<
        Content: View,
        Payload: _GiftUISemanticPrimitivePayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) where Content.Domain == Domain

    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    )

    mutating func visitActionPrimitive<
        Content: View,
        Payload: _GiftUISemanticActionPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) where Content.Domain == Domain

    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) where Content.Domain == Domain
}

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView<_GiftUIEmptyReadDomain> {
        EmptyView<_GiftUIEmptyReadDomain>()
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<A: View, B: View>(
        _ a: A,
        _ b: B
    ) -> TupleView<A, B> where A.Domain == B.Domain {
        TupleView(a, b)
    }

    public static func buildBlock<A: View, B: View, C: View>(
        _ a: A,
        _ b: B,
        _ c: C
    ) -> TupleView3<A, B, C> where A.Domain == B.Domain, A.Domain == C.Domain {
        TupleView3(a, b, c)
    }

    public static func buildBlock<A: View, B: View, C: View, D: View>(
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> TupleView4<A, B, C, D>
    where A.Domain == B.Domain, A.Domain == C.Domain, A.Domain == D.Domain {
        TupleView4(a, b, c, d)
    }

    public static func buildBlock<A: View, B: View, C: View, D: View, E: View>(
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D,
        _ e: E
    ) -> TupleView5<A, B, C, D, E>
    where
        A.Domain == B.Domain, A.Domain == C.Domain, A.Domain == D.Domain,
        A.Domain == E.Domain
    {
        TupleView5(a, b, c, d, e)
    }

    public static func buildEither<A: View, B: View>(
        first: A
    ) -> ConditionalContent<A, B> where A.Domain == B.Domain {
        ConditionalContent(first: first)
    }

    public static func buildEither<A: View, B: View>(
        second: B
    ) -> ConditionalContent<A, B> where A.Domain == B.Domain {
        ConditionalContent(second: second)
    }

    public static func buildOptional<Content: View>(
        _ content: Content?
    ) -> OptionalContent<Content> {
        OptionalContent(content)
    }
}

public struct EmptyView<D: _GiftUIReadDomain>: View {
    public typealias Domain = D
    public typealias Body = Never

    package init() {}

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("EmptyView has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitEmpty()
    }
}

public struct TupleView<A: View, B: View>: View where A.Domain == B.Domain {
    public typealias Domain = A.Domain
    public typealias Body = Never

    package let a: A
    package let b: B

    package init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("TupleView has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitFixed(a, b)
    }
}

public struct TupleView3<A: View, B: View, C: View>: View
where A.Domain == B.Domain, A.Domain == C.Domain {
    public typealias Domain = A.Domain
    public typealias Body = Never

    package let a: A
    package let b: B
    package let c: C

    package init(_ a: A, _ b: B, _ c: C) {
        self.a = a
        self.b = b
        self.c = c
    }

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("TupleView3 has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitFixed(a, b, c)
    }
}

public struct TupleView4<A: View, B: View, C: View, D: View>: View
where A.Domain == B.Domain, A.Domain == C.Domain, A.Domain == D.Domain {
    public typealias Domain = A.Domain
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

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("TupleView4 has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitFixed(a, b, c, d)
    }
}

public struct TupleView5<A: View, B: View, C: View, D: View, E: View>: View
where A.Domain == B.Domain, A.Domain == C.Domain, A.Domain == D.Domain, A.Domain == E.Domain {
    public typealias Domain = A.Domain
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

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("TupleView5 has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitFixed(a, b, c, d, e)
    }
}

public struct ConditionalContent<First: View, Second: View>: View
where First.Domain == Second.Domain {
    public typealias Domain = First.Domain
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

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("ConditionalContent has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        switch storage {
        case .first(let content):
            visitor.visitConditionalFirst(content, second: Second.self)
        case .second(let content):
            visitor.visitConditionalSecond(first: First.self, content)
        }
    }
}

public struct OptionalContent<Content: View>: View {
    public typealias Domain = Content.Domain
    public typealias Body = Never

    package let content: Content?

    package init(_ content: Content?) {
        self.content = content
    }

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("OptionalContent has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        if let content {
            visitor.visitOptionalPresent(content)
        } else {
            visitor.visitOptionalAbsent(Content.self)
        }
    }
}
