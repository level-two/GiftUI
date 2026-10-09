// Candidate B. Unsafe host activation is explicitly outside compiler proof.
// Raw backing must be initialized, aligned, unique to this owner and live until
// owner destruction. Only this file can construct/access the stored pointers.
struct Transition {
    var tick: UInt64
    var level: UInt32
    var channel: UInt32
}

struct FrozenCapture: ~Escapable {
    private let values: Span<Transition>
    let revision: UInt32

    @lifetime(copy values)
    fileprivate init(values: Span<Transition>, revision: UInt32) {
        self.values = values
        self.revision = revision
    }

    var count: Int { values.count }
    func transition(at index: Int) -> Transition? {
        guard index >= 0, index < values.count else { return nil }
        return values[index]
    }
}

struct CaptureOwner: ~Copyable {
    private let storage: UnsafeMutableBufferPointer<Transition>
    private(set) var revision: UInt32

    init(unsafeStorage: UnsafeMutableBufferPointer<Transition>, revision: UInt32) {
        precondition(unsafeStorage.count == 404)
        storage = unsafeStorage
        self.revision = revision
    }

    @lifetime(borrow self)
    borrowing func view() -> FrozenCapture {
        FrozenCapture(values: Span(_unsafeElements: storage), revision: revision)
    }

    borrowing func withView(_ body: (borrowing FrozenCapture) -> UInt64) -> UInt64 {
        body(view())
    }

    mutating func replaceValues(revision: UInt32, level: UInt32) {
        self.revision = revision
        for index in 0..<404 {
            storage[index] = Transition(tick: UInt64(index), level: level, channel: UInt32(index % 4))
        }
    }
}

@inline(never)
func checksum(_ view: borrowing FrozenCapture) -> UInt64 {
    var sum: UInt64 = UInt64(view.revision)
    for index in 0..<view.count {
        let item = view.transition(at: index)!
        sum &+= item.tick &+ UInt64(item.level) &+ UInt64(item.channel)
    }
    return sum
}

// External caller provides the live storage: object compilation cannot erase
// the indexed reads as a compile-time known array.
@_cdecl("spike069_read")
func readCapture(_ raw: UnsafeMutableRawPointer, _ revision: UInt32) -> UInt64 {
    let elements = raw.assumingMemoryBound(to: Transition.self)
    let owner = CaptureOwner(
        unsafeStorage: UnsafeMutableBufferPointer(start: elements, count: 404),
        revision: revision
    )
    return owner.withView { view in checksum(view) }
}
