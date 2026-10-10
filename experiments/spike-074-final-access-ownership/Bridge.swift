import GiftUI
import SignalAnalyzerDomain
import ApplicationSchema

package struct AnalyzerSlot {
    package var owner: UInt32 = 74
    package var generation: UInt32 = 0
    package var occupied = false
    package var owners: UInt16 = 0
    package var count: UInt16 = 0
    package var acquisition: AcquisitionState = .idle
    // Trusted bridge descriptor; application facades never expose this address.
    package var capture: UnsafeRawBufferPointer
    package init(_ capture: UnsafeRawBufferPointer) { self.capture = capture }
}
package enum AnalyzerDomain: AnalyzerReadDomain {
    package typealias Slot = AnalyzerSlot
    package static func bind(_ key: ModelKey<AnalyzerSchema>, in slots: Span<Slot>) throws(AccessFailure) -> Int {
        let index = Int(key.slot)
        guard index < slots.count, slots[index].occupied,
            key.owner == slots[index].owner, key.generation == slots[index].generation
        else { throw .key }
        return index
    }
    package static func acquisition(at index: Int, in slots: Span<Slot>) -> AcquisitionState { slots[index].acquisition }
    package static func count(at index: Int, in slots: Span<Slot>) -> UInt16 { slots[index].count }
    package static func transition(at position: Int, model: Int, in slots: Span<Slot>) throws(AccessFailure) -> SignalTransition {
        guard position >= 0, position < Int(slots[model].count) else { throw .bounds }
        let record = slots[model].capture.load(fromByteOffset: position * 16, as: StaticSignalAnalyzerNRFCaptureRecord.self)
        return SignalTransition(channelID: SignalChannelID(rawValue: Int(record.channelRawValue)),
            timestamp: Duration(secondsComponent: record.seconds, attosecondsComponent: record.attoseconds),
            level: record.levelRawValue == 0 ? .low : .high)
    }
}
package struct CounterSlot {
    package var value: UInt8
    package init(_ value: UInt8) { self.value = value }
}
package enum CounterDomain: CounterReadDomain {
    package typealias Slot = CounterSlot
    package static func bind(_ key: ModelKey<CounterSchema>, in slots: Span<Slot>) throws(AccessFailure) -> Int {
        guard key.owner == 75, key.generation == 1, Int(key.slot) < slots.count else { throw .key }
        return Int(key.slot)
    }
    package static func value(at index: Int, in slots: Span<Slot>) -> UInt8 { slots[index].value }
}
package enum AttachFault { case none, report, retain, reenter }
package struct Owner: ~Copyable {
    // Preconditions: exclusive initialized slots and aligned raw region outlive Owner;
    // neither backing region is accessible to application code during this borrow.
    private let slots: UnsafeMutableBufferPointer<AnalyzerSlot>
    private var regions: StaticSignalAnalyzerNRFCaptureRegions
    package private(set) var active: Int = 0
    package private(set) var bankOwner: Int = 0
    package private(set) var attachment: UInt32 = 1
    package private(set) var dirty: UInt32 = 0
    private var phase: UInt8 = 0 // 0 mutation, 1 deriving, 2 replacement guard
    private let generationLimit: UInt32
    private var nextModelGeneration: UInt32 = 2
    package init(_ slots: UnsafeMutableBufferPointer<AnalyzerSlot>, bytes: UnsafeMutableRawBufferPointer,
                 generationLimit: UInt32 = .max) {
        precondition(slots.count == 2)
        self.slots = slots
        self.regions = StaticSignalAnalyzerNRFCaptureRegions(storage: bytes)!
        self.generationLimit = generationLimit
        slots[0].occupied = true; slots[0].generation = 1; slots[0].owners = 1
    }
    package borrowing func key(_ index: Int) -> ModelKey<AnalyzerSchema> {
        ModelKey(owner: 74, generation: slots[index].generation, slot: UInt16(index))
    }
    private borrowing func validate(_ key: ModelKey<AnalyzerSchema>) throws(AccessFailure) -> Int {
        let index = Int(key.slot)
        guard index < slots.count, slots[index].occupied,
            key.owner == 74, key.generation == slots[index].generation else { throw .key }
        return index
    }
    private borrowing func mutationAllowed() throws(AccessFailure) {
        guard phase == 0 else { throw phase == 2 ? .busy : .phase }
    }
    package mutating func createEmpty() throws(AccessFailure) -> ModelKey<AnalyzerSchema> {
        try mutationAllowed()
        let index = active == 0 ? 1 : 0
        guard !slots[index].occupied else { throw .capacity }
        guard nextModelGeneration < UInt32.max else { throw .generation }
        slots[index].occupied = true; slots[index].generation = nextModelGeneration
        nextModelGeneration += 1
        slots[index].owners = 1; slots[index].count = 0; slots[index].acquisition = .idle
        return key(index)
    }
    package mutating func retain(_ key: ModelKey<AnalyzerSchema>) throws(AccessFailure) {
        try mutationAllowed(); let index = try validate(key)
        guard slots[index].owners < UInt16.max else { throw .capacity }
        slots[index].owners += 1
    }
    package mutating func releaseExtra(_ key: ModelKey<AnalyzerSchema>) throws(AccessFailure) {
        try mutationAllowed(); let index = try validate(key)
        guard slots[index].owners > 1 else { throw .key }
        slots[index].owners -= 1
    }
    package mutating func populate(_ key: ModelKey<AnalyzerSchema>, count: UInt16) throws(AccessFailure) {
        try mutationAllowed(); let index = try validate(key)
        guard index == bankOwner, count <= 404 else { throw .capacity }
        // All fallible checks precede stores. Generated/domain preflight is represented
        // by this fixed valid record sequence; this is not general snapshot replay.
        for position in 0..<Int(count) {
            let record = StaticSignalAnalyzerNRFCaptureRecord(seconds: Int64(position), attoseconds: 0,
                channelRawValue: UInt32(position % 4 + 1), levelRawValue: UInt32(position % 2))
            precondition(regions.store(record, in: .snapshot, at: position))
        }
        slots[index].count = count; slots[index].acquisition = .running; dirty += 1
    }
    package mutating func replace(_ candidate: ModelKey<AnalyzerSchema>, transferringOld: Bool,
                                  fault: AttachFault = .none) throws(AccessFailure) {
        try mutationAllowed(); let next = try validate(candidate)
        guard next != active else { throw .key }
        guard attachment < generationLimit else { throw .generation }
        guard transferringOld, slots[active].owners == 1 else { throw .retained }
        guard slots[next].count == 0 else { throw .capacity }
        phase = 2
        defer { phase = 0 }
        // The prepared candidate's actual empty seed is visible to attachment.
        precondition(slots[next].acquisition == .idle && slots[next].count == 0)
        switch fault {
        case .none: break
        case .report: throw .attachment
        case .retain:
            try retain(key(active)) // Must fail under the transaction guard.
            throw .attachment
        case .reenter:
            try populate(key(active), count: 0) // Must fail without changing bytes.
            throw .attachment
        }
        let old = active
        // Non-failing fixture commit. Real detach hooks/invariant handling remain a
        // production integration obligation; this fixture has no hidden callback.
        active = next; bankOwner = next; attachment += 1
        slots[old].occupied = false; slots[old].owners = 0
        dirty += 1
    }
    package mutating func begin() throws(AccessFailure) { try mutationAllowed(); phase = 1 }
    package mutating func finish() throws(AccessFailure) {
        guard phase == 1 else { throw .phase }; phase = 0
    }
    @_lifetime(borrow self)
    package borrowing func read() throws(AccessFailure) -> FrameRead<AnalyzerDomain> {
        guard phase == 1 else { throw .phase }
        return FrameRead(Span(_unsafeElements: slots))
    }
    package borrowing func count(_ index: Int) -> UInt16 { slots[index].count }
    package borrowing func owners(_ index: Int) -> UInt16 { slots[index].owners }
    package mutating func seedCanaries() {
        precondition(regions.store(StaticSignalAnalyzerNRFCaptureRecord(seconds: 901, attoseconds: 0,
            channelRawValue: 4, levelRawValue: 1), in: .live, at: 403))
        precondition(regions.store(StaticSignalAnalyzerNRFCaptureRecord(seconds: 902, attoseconds: 0,
            channelRawValue: 3, levelRawValue: 0), in: .admission, at: 403))
    }
    package borrowing func canariesValid() -> Bool {
        regions.load(from: .live, at: 403)?.seconds == 901 &&
            regions.load(from: .admission, at: 403)?.seconds == 902
    }
    package borrowing func modelRecord(_ index: Int) -> Int64 { regions.load(from: .snapshot, at: index)!.seconds }
}
// Inspection functions intentionally return compile-time layout constants on every ABI.
@_cdecl("spike074_slot_stride") public func slotStride() -> Int { MemoryLayout<AnalyzerSlot>.stride }
@_cdecl("spike074_owner_stride") public func ownerStride() -> Int { MemoryLayout<Owner>.stride }
@_cdecl("spike074_key_stride") public func keyStride() -> Int { MemoryLayout<ModelKey<AnalyzerSchema>>.stride }
@_cdecl("spike074_record_stride") public func recordStride() -> Int { MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.stride }
@_cdecl("spike074_counter_stride") public func counterStride() -> Int { MemoryLayout<CounterSlot>.stride }
