// Hand-written compiled contract; no production implementation is replaced.
package enum AccessFailure: UInt8, Error, Equatable {
    case phase, key, bounds, capacity, retained, attachment, busy, generation
}
package protocol ReadDomain { associatedtype Slot }
package enum EmptyDomain: ReadDomain { package typealias Slot = UInt8 }
package struct FrameRead<D: ReadDomain>: ~Escapable {
    package let slots: Span<D.Slot>
    @_lifetime(copy slots)
    package init(_ slots: Span<D.Slot>) { self.slots = slots }
}
package struct ModelKey<Schema>: Equatable {
    package let owner: UInt32
    package let generation: UInt32
    package let slot: UInt16
    package init(owner: UInt32, generation: UInt32, slot: UInt16) {
        self.owner = owner; self.generation = generation; self.slot = slot
    }
}
package protocol View<Domain> {
    associatedtype Domain: ReadDomain
    associatedtype Body: View
    func evaluate(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> Body
    func render(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32
}
extension View where Body.Domain == Domain {
    package func render(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32 {
        let body = try evaluate(read: read)
        return try body.render(read: read)
    }
}
package protocol Leaf: View where Body == Never {}
extension Leaf {
    package func evaluate(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> Never {
        fatalError("Leaf body is not evaluated")
    }
}
extension Never: View {
    package typealias Domain = EmptyDomain
    package func evaluate(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> Never { switch self {} }
    package func render(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32 { switch self {} }
}
package struct Label<D: ReadDomain>: Leaf {
    package typealias Domain = D
    package let value: UInt32
    package init(_ value: UInt32) { self.value = value }
    package func render(read: borrowing FrameRead<D>) throws(AccessFailure) -> UInt32 { value }
}
package struct Pair<A: View, B: View>: Leaf where A.Domain == B.Domain {
    package typealias Domain = A.Domain
    package let a: A
    package let b: B
    package func render(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32 {
        try a.render(read: read) + b.render(read: read)
    }
}
package enum Choice<A: View, B: View>: Leaf where A.Domain == B.Domain {
    package typealias Domain = A.Domain
    case first(A), second(B)
    package func render(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32 {
        switch self {
        case .first(let a): try a.render(read: read)
        case .second(let b): try b.render(read: read)
        }
    }
}
@resultBuilder package enum Builder {
    package static func buildBlock<A: View>(_ a: A) -> A { a }
    package static func buildBlock<A: View, B: View>(_ a: A, _ b: B) -> Pair<A,B>
        where A.Domain == B.Domain { Pair(a: a, b: b) }
    package static func buildEither<A: View, B: View>(first a: A) -> Choice<A,B>
        where A.Domain == B.Domain { .first(a) }
    package static func buildEither<A: View, B: View>(second b: B) -> Choice<A,B>
        where A.Domain == B.Domain { .second(b) }
}
package protocol Canvas: Leaf {
    func draw(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32
}
extension Canvas {
    package func render(read: borrowing FrameRead<Domain>) throws(AccessFailure) -> UInt32 {
        try draw(read: read)
    }
}
