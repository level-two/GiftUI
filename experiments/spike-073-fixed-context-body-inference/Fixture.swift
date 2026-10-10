// Disposable SPIKE-073 language fixture; no production GiftUI module is imported.
enum AccessFailure: UInt8, Error, Equatable { case invalidPhase, invalidKey }
struct Entry { var value: UInt32 }
struct ModelKey { let index: Int }

struct FrameRead: ~Escapable {
    private let entries: Span<Entry>
    @_lifetime(copy entries)
    init(entries: Span<Entry>) { self.entries = entries }
    func scalar(_ key: ModelKey) throws(AccessFailure) -> UInt32 {
        guard key.index >= 0, key.index < entries.count else { throw .invalidKey }
        return entries[key.index].value
    }
}

struct Owner: ~Copyable {
    // Fixture precondition: caller retains exclusive initialized backing for Owner's lifetime.
    private let entries: UnsafeMutableBufferPointer<Entry>
    private var deriving = false
    init(_ entries: UnsafeMutableBufferPointer<Entry>) { self.entries = entries }
    mutating func begin() throws(AccessFailure) {
        guard !deriving else { throw .invalidPhase }
        deriving = true
    }
    mutating func finish() { deriving = false }
    mutating func write(_ value: UInt32, key: ModelKey) throws(AccessFailure) {
        guard !deriving else { throw .invalidPhase }
        guard key.index >= 0, key.index < entries.count else { throw .invalidKey }
        entries[key.index].value = value
    }
    @_lifetime(borrow self)
    borrowing func read() throws(AccessFailure) -> FrameRead {
        guard deriving else { throw .invalidPhase }
        return FrameRead(entries: Span(_unsafeElements: entries))
    }
}

protocol View {
    associatedtype Body: View
    func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> Body
    func metric() -> UInt32
}
extension View { func metric() -> UInt32 { 0 } }
protocol Leaf: View where Body == Never {}
extension Leaf {
    func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> Never {
        fatalError("leaf evaluation is forbidden")
    }
}
extension Never: View {
    func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> Never { switch self {} }
    func metric() -> UInt32 { switch self {} }
}
struct Label: Leaf {
    let value: UInt32
    func metric() -> UInt32 { value }
}
struct Pair<A: View, B: View>: Leaf {
    let a: A
    let b: B
    func metric() -> UInt32 { a.metric() + b.metric() }
}
enum Choice<A: View, B: View>: Leaf {
    case first(A), second(B)
    func metric() -> UInt32 {
        switch self { case .first(let a): a.metric(); case .second(let b): b.metric() }
    }
}
@resultBuilder enum Builder {
    static func buildBlock<A: View>(_ a: A) -> A { a }
    static func buildBlock<A: View, B: View>(_ a: A, _ b: B) -> Pair<A, B> { Pair(a: a, b: b) }
    static func buildEither<A: View, B: View>(first: A) -> Choice<A, B> { .first(first) }
    static func buildEither<A: View, B: View>(second: B) -> Choice<A, B> { .second(second) }
}
@Builder func badge(_ value: UInt32) -> some View {
    Label(value: value)
    Label(value: 3)
}
struct Root: View {
    let key: ModelKey
    @Builder func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> some View {
        if try read.scalar(key) > 0 {
            Label(value: try read.scalar(key))
            badge(2)
        } else {
            Label(value: 0)
        }
    }
}
struct Nested: View {
    let key: ModelKey
    @Builder func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> some View {
        Label(value: try read.scalar(key))
        badge(4)
    }
}
// Scalar output stands in for owned geometry. This does not implement GraphicsContext.
protocol Canvas: Leaf { func draw(read: borrowing FrameRead) throws(AccessFailure) -> UInt32 }
struct Meter: Canvas {
    let key: ModelKey
    let factor: UInt32
    func draw(read: borrowing FrameRead) throws(AccessFailure) -> UInt32 {
        try read.scalar(key) * factor
    }
}
func evaluate<V: View>(_ view: V, owner: borrowing Owner) throws(AccessFailure) -> V.Body {
    let read = try owner.read()
    return try view.evaluate(read: read)
}
func draw<C: Canvas>(_ canvas: C, owner: borrowing Owner) throws(AccessFailure) -> UInt32 {
    let read = try owner.read()
    return try canvas.draw(read: read)
}
struct Checks {
    var total: Int32 = 0
    var failures: Int32 = 0
    mutating func expect(_ condition: Bool) { total += 1; if !condition { failures += 1 } }
}
func runChecks() -> Checks {
    withUnsafeTemporaryAllocation(of: Entry.self, capacity: 2) { entries in
        entries.initialize(repeating: Entry(value: 0))
        defer { entries.deinitialize() }
        var owner = Owner(entries)
        var checks = Checks()
        let rootKey = ModelKey(index: 0)
        let childKey = ModelKey(index: 1)
        do throws(AccessFailure) {
            do throws(AccessFailure) { _ = try owner.read(); checks.expect(false) }
            catch { checks.expect(error == .invalidPhase) }
            try owner.write(7, key: rootKey)
            try owner.write(19, key: childKey)
            try owner.begin()
            let root = try evaluate(Root(key: rootKey), owner: owner)
            checks.expect(root.metric() == 12)
            let nested = try evaluate(Nested(key: childKey), owner: owner)
            checks.expect(nested.metric() == 26)
            // No read borrow remains, but the runtime phase must still reject mutation.
            do throws(AccessFailure) { try owner.write(99, key: rootKey); checks.expect(false) }
            catch { checks.expect(error == .invalidPhase) }
            do throws(AccessFailure) { try owner.begin(); checks.expect(false) }
            catch { checks.expect(error == .invalidPhase) }
            let first = Meter(key: rootKey, factor: 2)
            let second = Meter(key: childKey, factor: 3)
            let geometryA = try draw(first, owner: owner)
            let geometryB = try draw(second, owner: owner)
            checks.expect(geometryA == 14)
            checks.expect(geometryB == 57)
            do throws(AccessFailure) { _ = try evaluate(Root(key: ModelKey(index: 2)), owner: owner); checks.expect(false) }
            catch { checks.expect(error == .invalidKey) }
            do throws(AccessFailure) { _ = try draw(Meter(key: ModelKey(index: -1), factor: 1), owner: owner); checks.expect(false) }
            catch { checks.expect(error == .invalidKey) }
            owner.finish()
            try owner.write(0, key: rootKey)
            try owner.write(23, key: childKey)
            checks.expect(root.metric() == 12) // Previously owned output remains unchanged.
            checks.expect(geometryA == 14)
            checks.expect(geometryB == 57)
            try owner.begin()
            let later = try evaluate(Root(key: rootKey), owner: owner)
            checks.expect(later.metric() == 0) // Different builder branch, same associated Body.
            let laterNested = try evaluate(Nested(key: childKey), owner: owner)
            checks.expect(laterNested.metric() == 30)
            let laterGeometry = try draw(second, owner: owner)
            checks.expect(laterGeometry == 69)
            owner.finish()
        } catch { checks.expect(false) }
        return checks
    }
}
@_cdecl("spike073_run") public func spike073Run() -> Int32 {
    let result = runChecks()
    return result.failures == 0 && result.total == 15 ? 0 : 1
}
#if NEG_OVERLAP
func invalidMutation(_ owner: inout Owner) throws(AccessFailure) -> UInt32 {
    let read = try owner.read()
    owner.finish()
    return try read.scalar(ModelKey(index: 0))
}
#endif
#if NEG_ESCAPE
struct InvalidEscapingStorage { let read: FrameRead }
#endif
