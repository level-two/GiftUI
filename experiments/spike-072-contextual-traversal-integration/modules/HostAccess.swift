import GiftUI
import GiftUISemanticCore
struct Entry {
    var location: UInt64 = 0
    var ordinal: UInt16 = 0
    var current: UInt32 = 0
    var frozen: UInt32 = 0
}
struct Reads: FrozenAccess, ~Escapable {
    let entries: Span<Entry>
    let epoch: UInt32
    let count: Int
    let poison: UInt16
    @_lifetime(copy entries)
    init(entries: Span<Entry>, count: Int, epoch: UInt32, poison: UInt16) {
        self.entries=entries; self.count=count; self.epoch=epoch; self.poison=poison
    }
    func scalar(_ key: ModelKey, field: UInt16) throws(AccessFailure) -> UInt32 {
        guard key.epoch == epoch else { throw .staleFrame }
        guard Int(key.index) < count else { throw .staleKey }
        // Poison is an independent read-observation oracle: skipped reads cannot fail.
        guard field != poison, field < 2 else { throw .invalidField }
        return field == 0 ? entries[Int(key.index)].frozen : 7
    }
}
struct Session: EvaluationSession, ~Copyable {
    // Explicit fixture precondition: initialized exclusive caller storage outlives Session.
    private var entries: UnsafeMutableBufferPointer<Entry>
    private(set) var count: Int = 0
    private(set) var epoch: UInt32 = 1
    private(set) var frozen = true
    var poison: UInt16 = UInt16.max
    private(set) var binds: UInt32 = 0
    init(_ entries: UnsafeMutableBufferPointer<Entry>) { self.entries=entries }
    mutating func bind(location: UInt64, ordinal: UInt16, seed: UInt32) throws(AccessFailure) -> ModelKey {
        guard frozen else { throw .invalidPhase }
        binds += 1
        for i in 0..<count {
            if entries[i].location == location && entries[i].ordinal == ordinal {
                return ModelKey(index: UInt16(i),epoch: epoch)
            }
        }
        guard count < entries.count else { throw .capacity }
        entries[count] = Entry(location: location,ordinal: ordinal,current: seed,frozen: seed)
        let result=ModelKey(index: UInt16(count),epoch: epoch)
        count += 1
        return result
    }
    @_lifetime(borrow self)
    borrowing func read() -> Reads {
        Reads(entries: Span(_unsafeElements: entries),count: count,epoch: epoch,poison: poison)
    }
    borrowing func evaluate<D: View>(_ declaration: borrowing D) throws(AccessFailure) -> D.Body {
        let scoped=read()
        return try declaration._evaluate(read: scoped)
    }
    mutating func write(_ value: UInt32) throws(AccessFailure) {
        guard !frozen else { throw .invalidPhase }
        guard count > 0 else { throw .staleKey }
        entries[0].current=value
    }
    mutating func finish() { frozen=false }
}
struct Binding: SemanticStatefulBinding {
    typealias Identity = UInt64
    typealias Failure = AccessFailure
    mutating func bind<D: View & _GiftUIObservableStateHost, S: EvaluationSession & ~Copyable>(
        _ declaration: borrowing D, structuralIdentity: UInt64, session: inout S,
        body: (borrowing D, inout S) -> Void
    ) -> SemanticStateBindingOutcome<AccessFailure> {
        var owned = copy declaration
        do { try owned._bind(location: structuralIdentity, session: &session) }
        catch { return .failure(error) }
        body(owned, &session)
        return .bound
    }
}

