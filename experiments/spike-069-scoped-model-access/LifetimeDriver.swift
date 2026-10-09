// A bounded protocol model, NOT the production observation/traversal owners.
// Three model snapshots permit installed + staged + one application-retained
// old snapshot; separate source/admission slots make five physical slots.
struct SnapshotKey: Equatable {
    let context: UInt32
    let slot: UInt8
    let generation: UInt32
}

private struct SlotControl {
    var generation: UInt32 = 0
    var occupied = false
    var applicationOwned = false
    var pins: UInt16 = 0
}

struct SnapshotPool: ~Copyable {
    private var first: CaptureOwner
    private var second: CaptureOwner
    private var third: CaptureOwner
    private var a = SlotControl()
    private var b = SlotControl()
    private var c = SlotControl()
    private let context: UInt32
    private(set) var installed: SnapshotKey?

    init(unsafeBacking: UnsafeMutablePointer<Transition>, context: UInt32) {
        self.context = context
        first = CaptureOwner(unsafeStorage: .init(start: unsafeBacking, count: 404), revision: 0)
        second = CaptureOwner(unsafeStorage: .init(start: unsafeBacking + 404, count: 404), revision: 0)
        third = CaptureOwner(unsafeStorage: .init(start: unsafeBacking + 808, count: 404), revision: 0)
    }

    private func control(_ slot: UInt8) -> SlotControl {
        switch slot { case 0: return a; case 1: return b; default: return c }
    }

    private mutating func setControl(_ slot: UInt8, _ value: SlotControl) {
        switch slot { case 0: a = value; case 1: b = value; default: c = value }
    }

    private func valid(_ key: SnapshotKey) -> Bool {
        guard key.context == context, key.slot < 3 else { return false }
        let state = control(key.slot)
        return state.occupied && state.generation == key.generation
    }

    mutating func reserve(revision: UInt32, level: UInt32) -> SnapshotKey? {
        for slot: UInt8 in 0..<3 {
            var state = control(slot)
            guard !state.occupied, state.generation != UInt32.max else { continue }
            state.generation += 1
            state.occupied = true
            state.applicationOwned = true
            setControl(slot, state)
            switch slot {
            case 0: first.replaceValues(revision: revision, level: level)
            case 1: second.replaceValues(revision: revision, level: level)
            default: third.replaceValues(revision: revision, level: level)
            }
            return SnapshotKey(context: context, slot: slot, generation: state.generation)
        }
        return nil
    }

    // No foreign callback is made while mutably accessing this aggregate.
    // Attachment success/failure is an explicit input to this protocol model.
    mutating func replace(with key: SnapshotKey, attachmentAccepted: Bool) -> Bool {
        guard valid(key), attachmentAccepted else { return false }
        let previous = installed
        installed = key
        if let previous { reclaimIfUnused(previous) }
        return true
    }

    mutating func releaseApplicationOwner(_ key: SnapshotKey) -> Bool {
        guard valid(key) else { return false }
        var state = control(key.slot)
        guard state.applicationOwned else { return false }
        state.applicationOwned = false
        setControl(key.slot, state)
        reclaimIfUnused(key)
        return true
    }

    private mutating func reclaimIfUnused(_ key: SnapshotKey) {
        guard valid(key) else { return }
        var state = control(key.slot)
        if !state.applicationOwned && state.pins == 0 && installed != key {
            state.occupied = false
            setControl(key.slot, state)
        }
    }

    mutating func pin(_ key: SnapshotKey) -> Bool {
        guard valid(key) else { return false }
        var state = control(key.slot)
        guard state.pins < UInt16.max else { return false }
        state.pins += 1
        setControl(key.slot, state)
        return true
    }

    mutating func unpin(_ key: SnapshotKey) -> Bool {
        guard valid(key) else { return false }
        var state = control(key.slot)
        guard state.pins > 0 else { return false }
        state.pins -= 1
        setControl(key.slot, state)
        reclaimIfUnused(key)
        return true
    }

    borrowing func read(_ key: SnapshotKey) -> UInt64? {
        guard valid(key) else { return nil }
        switch key.slot {
        case 0: return first.withView { checksum($0) }
        case 1: return second.withView { checksum($0) }
        default: return third.withView { checksum($0) }
        }
    }

    // A fresh scoped borrow is constructed only while the live owner is held.
    borrowing func invokePinned(_ key: SnapshotKey) -> UInt64? {
        guard valid(key), control(key.slot).pins > 0 else { return nil }
        return read(key)
    }

    mutating func retireInstalled() {
        let former = installed
        installed = nil
        if let former { reclaimIfUnused(former) }
    }

    var occupiedCount: Int {
        (a.occupied ? 1 : 0) + (b.occupied ? 1 : 0) + (c.occupied ? 1 : 0)
    }
}

// Delayed payload holds an owned key/scalar, never FrozenCapture or a pointer.
// No actual Layout or GiftUI generated callable is implied by this fixture.
struct CanvasWork: ~Copyable {
    private let key: SnapshotKey
    private let multiplier: UInt32
    private var finished = false

    init?(pool: inout SnapshotPool, key: SnapshotKey, multiplier: UInt32) {
        guard pool.pin(key) else { return nil }
        self.key = key
        self.multiplier = multiplier
    }

    mutating func invoke(pool: inout SnapshotPool) -> UInt64? {
        guard !finished, let value = pool.invokePinned(key) else { return nil }
        finished = true
        guard pool.unpin(key) else { return nil }
        return value * UInt64(multiplier)
    }

    mutating func discard(pool: inout SnapshotPool) -> Bool {
        guard !finished else { return false }
        finished = true
        return pool.unpin(key)
    }
}

private func check(_ condition: Bool, _ bit: Int, _ result: inout UInt64) {
    if condition { result |= UInt64(1) << bit }
}

private func mutateCounter(_ value: inout UInt32, report: () -> Void) {
    value += 1
    report()
}

@_cdecl("spike069_lifecycle")
func lifetimeDriver(_ raw: UnsafeMutableRawPointer) -> UInt64 {
    let backing = raw.bindMemory(to: Transition.self, capacity: 5 * 404)
    backing.initialize(repeating: Transition(tick: 0, level: 0, channel: 0), count: 5 * 404)
    defer { backing.deinitialize(count: 5 * 404) }
    var pool = SnapshotPool(unsafeBacking: backing, context: 69)
    var source = CaptureOwner(unsafeStorage: .init(start: backing + 1212, count: 404), revision: 0)
    var admission = CaptureOwner(unsafeStorage: .init(start: backing + 1616, count: 404), revision: 0)
    var results: UInt64 = 0

    guard let old = pool.reserve(revision: 1, level: 2),
          pool.replace(with: old, attachmentAccepted: true) else { return results }
    // Independently derived: sum(0...403) + 404*2 + 101*(0+1+2+3) + revision 1.
    let oldExpected: UInt64 = 82821
    check(MemoryLayout<Transition>.stride == 16 && pool.read(old) == oldExpected, 0, &results)

    guard let candidate = pool.reserve(revision: 2, level: 4) else { return results }
    check(!pool.replace(with: candidate, attachmentAccepted: false)
          && pool.installed == old && pool.read(old) == oldExpected, 1, &results)
    guard pool.releaseApplicationOwner(candidate) else { return results }
    check(pool.read(candidate) == nil && pool.occupiedCount == 1, 2, &results)

    guard var firstWork = CanvasWork(pool: &pool, key: old, multiplier: 1),
          var secondWork = CanvasWork(pool: &pool, key: old, multiplier: 2) else { return results }
    source.replaceValues(revision: 9, level: 8)
    admission.replaceValues(revision: 9, level: 8)
    check(pool.read(old) == oldExpected && source.withView({ checksum($0) }) == 85253
          && admission.withView({ checksum($0) }) == 85253, 3, &results)

    guard let replacement = pool.reserve(revision: 3, level: 6),
          pool.replace(with: replacement, attachmentAccepted: true) else { return results }
    // Model derivation failure as discarding the staged callables. Deliberately
    // do not roll back an already committed replacement.
    check(firstWork.discard(pool: &pool) && pool.installed == replacement, 4, &results)
    check(pool.read(old) == oldExpected && pool.occupiedCount == 2, 5, &results)
    check(secondWork.invoke(pool: &pool) == oldExpected * 2, 6, &results)
    check(secondWork.invoke(pool: &pool) == nil && !firstWork.discard(pool: &pool), 7, &results)

    guard let third = pool.reserve(revision: 4, level: 8) else { return results }
    check(pool.reserve(revision: 5, level: 10) == nil && pool.installed == replacement
          && pool.read(old) == oldExpected, 8, &results)
    guard pool.releaseApplicationOwner(old) else { return results }
    guard let reused = pool.reserve(revision: 6, level: 12) else { return results }
    check(reused.slot == old.slot && reused.generation != old.generation
          && pool.read(old) == nil, 9, &results)

    let foreign = SnapshotKey(context: 70, slot: reused.slot, generation: reused.generation)
    check(pool.read(foreign) == nil && !pool.pin(foreign), 10, &results)
    // No Canvas occurrences for 'third': only application ownership keeps it.
    check(pool.releaseApplicationOwner(third) && pool.read(third) == nil, 11, &results)

    var counter: UInt32 = 0
    var dirty: UInt32 = 0
    var mutationResult: UInt32 = 0
    mutateCounter(&counter) { dirty += 1 }
    mutationResult = counter
    check(counter == 1 && dirty == 1 && mutationResult == 1, 12, &results)

    // A pin alone retains a detached snapshot after application ownership ends.
    guard var retainedWork = CanvasWork(pool: &pool, key: reused, multiplier: 1) else { return results }
    check(pool.releaseApplicationOwner(reused) && pool.read(reused) != nil, 13, &results)
    check(retainedWork.discard(pool: &pool) && pool.read(reused) == nil, 14, &results)
    guard pool.releaseApplicationOwner(replacement) else { return results }
    pool.retireInstalled()
    check(pool.occupiedCount == 0 && pool.read(replacement) == nil, 15, &results)
    return results
}
