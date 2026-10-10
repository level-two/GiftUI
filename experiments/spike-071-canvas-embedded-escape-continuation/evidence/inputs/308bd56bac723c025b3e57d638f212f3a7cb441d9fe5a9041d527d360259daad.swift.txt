// Disposable owner. Raw backing is supplied initialized, exclusive, disjoint,
// with 404 transitions per bank, and must outlive the owner. Not a host proof.
struct Transition {
    var tick: UInt64
    var level: UInt32
    var channel: UInt32
}
enum AccessFailure: UInt8, Error, Equatable {
    case wrongOwner, staleGeneration, staleFrame, invalidPhase, invalidField
}
struct ModelKey: Equatable {
    let owner: UInt32
    let generation: UInt32
    let epoch: UInt32
}
struct FrameRead: ~Escapable {
    private let transitions: Span<Transition>
    private let value: UInt32
    private let scale: UInt32
    private let owner: UInt32
    private let generation: UInt32
    private let epoch: UInt32
    private let active: Bool

    @_lifetime(copy transitions)
    init(_ transitions: Span<Transition>, value: UInt32, scale: UInt32,
         owner: UInt32, generation: UInt32, epoch: UInt32, active: Bool) {
        self.transitions = transitions
        self.value = value
        self.scale = scale
        self.owner = owner
        self.generation = generation
        self.epoch = epoch
        self.active = active
    }
    func validate(_ key: ModelKey) throws(AccessFailure) {
        guard active else { throw .invalidPhase }
        guard key.owner == owner else { throw .wrongOwner }
        guard key.generation == generation else { throw .staleGeneration }
        guard key.epoch == epoch else { throw .staleFrame }
    }
    func scalar(_ key: ModelKey, field: UInt16) throws(AccessFailure) -> UInt32 {
        try validate(key)
        switch field {
        case 0: return value
        case 1: return scale
        default: throw .invalidField
        }
    }
    func level(_ key: ModelKey, at index: UInt16) throws(AccessFailure) -> UInt32 {
        try validate(key)
        guard Int(index) < transitions.count else { throw .invalidField }
        return transitions[Int(index)].level
    }
    func drawScalar(_ key: ModelKey, field: UInt16) throws(DrawingError) -> UInt32 {
        do { return try scalar(key, field: field) }
        catch { throw .invalidScope }
    }
    func drawLevel(_ key: ModelKey, at index: UInt16) throws(DrawingError) -> UInt32 {
        do { return try level(key, at: index) }
        catch { throw .invalidScope }
    }
}
struct ModelOwner: ~Copyable {
    private let current: UnsafeMutableBufferPointer<Transition>
    private let frozen: UnsafeMutableBufferPointer<Transition>
    private let identity: UInt32
    private var value: UInt32 = CounterModel.initial0
    private var scale: UInt32 = CounterModel.initial1
    private var frozenValue: UInt32 = 0
    private var frozenScale: UInt32 = 0
    private(set) var epoch: UInt32 = 0
    private(set) var revision: UInt32 = 0
    private(set) var frozenRevision: UInt32 = 0
    private(set) var isFrozen = false
    private(set) var dirty = false

    init(current: UnsafeMutableBufferPointer<Transition>,
         frozen: UnsafeMutableBufferPointer<Transition>, identity: UInt32) {
        precondition(current.count == 404 && frozen.count == 404)
        self.current = current
        self.frozen = frozen
        self.identity = identity
    }
    mutating func write(value: UInt32, scale: UInt32) -> AccessFailure? {
        guard !isFrozen else { return .invalidPhase }
        guard revision != UInt32.max else { return .invalidField }
        self.value = value
        self.scale = scale
        revision += 1
        dirty = true
        return nil
    }
    mutating func writeValue(_ value: UInt32) -> AccessFailure? {
        write(value: value, scale: scale)
    }
    mutating func writeTransition(at index: Int, level: UInt32) -> AccessFailure? {
        guard !isFrozen else { return .invalidPhase }
        guard index >= 0 && index < current.count && revision != UInt32.max else {
            return .invalidField
        }
        current[index].level = level
        revision += 1
        dirty = true
        return nil
    }
    mutating func freeze() -> ModelKey? {
        guard !isFrozen && epoch != UInt32.max else { return nil }
        for index in 0..<404 { frozen[index] = current[index] }
        frozenValue = value
        frozenScale = scale
        frozenRevision = revision
        epoch += 1
        isFrozen = true
        return ModelKey(owner: identity, generation: 1, epoch: epoch)
    }
    @_lifetime(borrow self)
    borrowing func read() -> FrameRead {
        FrameRead(Span(_unsafeElements: frozen),
                  value: frozenValue, scale: frozenScale, owner: identity,
                  generation: 1, epoch: epoch, active: isFrozen)
    }
    mutating func finish(published: Bool) {
        isFrozen = false
        if published { dirty = false }
    }
}
