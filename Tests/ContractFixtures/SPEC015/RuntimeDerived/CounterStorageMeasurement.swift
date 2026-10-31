import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import P08CounterSchema
import P08CounterTable

// Finite assembly measurement seams. Byte arithmetic is checked before conversion
// to the normative UInt32 fields; no element capacity is inferred from a live count.
struct CounterExtent: Equatable {
    let count: Int
    let stride: Int
    let alignment: Int
    var bytes: UInt64? {
        guard count >= 0, stride >= 0, alignment > 0 else { return nil }
        let product = UInt64(count).multipliedReportingOverflow(by: UInt64(stride))
        return product.overflow ? nil : product.partialValue
    }
    static func elements(count: Int, stride: Int, alignment: Int) -> Self {
        .init(count: count, stride: stride, alignment: alignment)
    }
    static func elements<T: ~Copyable & ~Escapable>(_ type: T.Type, count: Int) -> Self {
        elements(count: count, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment)
    }
}
struct CounterInteractionMeasurement: Equatable {
    let candidateRecords: UInt16
    let candidateHits: UInt16
    let committedRecords: UInt16
    let committedHits: UInt16
    let candidateIdentityBytes: UInt64
    let committedIdentityBytes: UInt64
    let candidateBytes: UInt64
    let committedBytes: UInt64
}
protocol CounterCandidateBacking: ~Copyable, ~Escapable, InteractionCandidateRecordStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CounterCommittedBacking: ~Copyable, ~Escapable, InteractionCommittedRecordStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CounterHitBacking: ~Copyable, ~Escapable, InteractionHitRegionStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
extension StaticTwoInteractionCandidateStorage: CounterCandidateBacking, InteractionOwnedBankMeasurementSource {
    package var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement {
        .init(count: count, capacity: capacity, retainedIdentitySlots: retainedIdentitySlots,
            retainedPayloadBytes: retainedPayloadBytes, inlineSize: MemoryLayout<Self>.size,
            inlineStride: MemoryLayout<Self>.stride, inlineAlignment: MemoryLayout<Self>.alignment)
    }
    var retainedIdentitySlots: Int { 2 }
    var retainedPayloadBytes: Int { 0 } // Records are already inside Self's inline layout.
}
extension StaticTwoInteractionCommittedStorage: CounterCommittedBacking, InteractionOwnedBankMeasurementSource {
    package var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement {
        .init(count: count, capacity: capacity, retainedIdentitySlots: retainedIdentitySlots,
            retainedPayloadBytes: retainedPayloadBytes, inlineSize: MemoryLayout<Self>.size,
            inlineStride: MemoryLayout<Self>.stride, inlineAlignment: MemoryLayout<Self>.alignment)
    }
    var retainedIdentitySlots: Int { 2 }
    var retainedPayloadBytes: Int { 0 }
}
extension StaticTwoInteractionHitStorage: CounterHitBacking, InteractionOwnedBankMeasurementSource {
    package var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement {
        .init(count: count, capacity: capacity, retainedIdentitySlots: retainedIdentitySlots,
            retainedPayloadBytes: retainedPayloadBytes, inlineSize: MemoryLayout<Self>.size,
            inlineStride: MemoryLayout<Self>.stride, inlineAlignment: MemoryLayout<Self>.alignment)
    }
    var retainedIdentitySlots: Int { 2 }
    var retainedPayloadBytes: Int { 0 }
}
#if !hasFeature(Embedded)
extension DynamicInteractionCandidateStorage: CounterCandidateBacking, InteractionOwnedBankMeasurementSource {
    package var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement {
        .init(count: count, capacity: capacity, retainedIdentitySlots: retainedIdentitySlots,
            retainedPayloadBytes: retainedPayloadBytes, inlineSize: MemoryLayout<Self>.size,
            inlineStride: MemoryLayout<Self>.stride, inlineAlignment: MemoryLayout<Self>.alignment)
    }
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
extension DynamicInteractionCommittedStorage: CounterCommittedBacking, InteractionOwnedBankMeasurementSource {
    package var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement {
        .init(count: count, capacity: capacity, retainedIdentitySlots: retainedIdentitySlots,
            retainedPayloadBytes: retainedPayloadBytes, inlineSize: MemoryLayout<Self>.size,
            inlineStride: MemoryLayout<Self>.stride, inlineAlignment: MemoryLayout<Self>.alignment)
    }
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
extension DynamicInteractionHitStorage: CounterHitBacking, InteractionOwnedBankMeasurementSource {
    package var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement {
        .init(count: count, capacity: capacity, retainedIdentitySlots: retainedIdentitySlots,
            retainedPayloadBytes: retainedPayloadBytes, inlineSize: MemoryLayout<Self>.size,
            inlineStride: MemoryLayout<Self>.stride, inlineAlignment: MemoryLayout<Self>.alignment)
    }
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
#endif
func counterMeasureInteraction<C: CounterCandidateBacking & InteractionOwnedBankMeasurementSource & Copyable & Escapable, R: CounterCommittedBacking & InteractionOwnedBankMeasurementSource & Copyable & Escapable, H: CounterHitBacking & InteractionOwnedBankMeasurementSource & Copyable & Escapable>(_ storage: borrowing InteractionOwnedKeyState<C, R, H>) -> CounterInteractionMeasurement where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    let facts = storage.ownedStorageMeasurement()
    let candidate = facts.candidate, candidateHits = facts.candidateHits
    let prepared = facts.prepared, committed = facts.committed, committedHits = facts.committedHits
        // Each record owns one complete identity. Candidate includes the prepared
        // committed bank. Key bytes are subtracted from those records, never added twice.
        let candidateKeys = UInt64(candidate.retainedIdentitySlots + candidateHits.retainedIdentitySlots + prepared.retainedIdentitySlots) * UInt64(MemoryLayout<SemanticCompleteIdentity>.size)
        let committedKeys = UInt64(committed.retainedIdentitySlots + committedHits.retainedIdentitySlots) * UInt64(MemoryLayout<SemanticCompleteIdentity>.size)
        let candidateRaw = UInt64(candidate.inlineSize + candidateHits.inlineSize + prepared.inlineSize + candidate.retainedPayloadBytes + candidateHits.retainedPayloadBytes + prepared.retainedPayloadBytes)
        let committedRaw = UInt64(committed.inlineSize + committedHits.inlineSize + committed.retainedPayloadBytes + committedHits.retainedPayloadBytes)
        precondition(candidateKeys <= candidateRaw && committedKeys <= committedRaw)
        return .init(candidateRecords: min(candidate.capacity, prepared.capacity), candidateHits: candidateHits.capacity,
            committedRecords: committed.capacity, committedHits: committedHits.capacity,
            candidateIdentityBytes: candidateKeys, committedIdentityBytes: committedKeys,
            candidateBytes: candidateRaw - candidateKeys, committedBytes: committedRaw - committedKeys)
}

// Only the escapable, owned workspaces leave the enclosing scoped opportunity.
// Model/root/semantic/Canvas scopes are destroyed before this transfer returns.
struct CounterReturnedWorkspaces<G: CounterGeometry & Copyable & Escapable, C: CounterCandidateBacking & Copyable & Escapable, R: CounterCommittedBacking & Copyable & Escapable, H: CounterHitBacking & Copyable & Escapable> where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    var geometry: G
    var interaction: InteractionOwnedKeyState<C, R, H>
    var checks: Int
    init(geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>, checks: Int) {
        self.geometry = consume geometry
        self.interaction = consume interaction
        self.checks = checks
    }
}

// Facts are independent owned values; they neither lend a bank nor invoke a
// caller with storage. Full retained extents include native Optional/tail bytes.
struct CounterPhysicalBankFacts {
    let bank: InteractionOwnedBankMeasurement
    let recordSize: Int
    let recordStride: Int
    let recordAlignment: Int
    let optionalRecords: Bool
    let retainedBytes: Int
    static func retainedExtent(_ bank: InteractionOwnedBankMeasurement, requested: Int?) -> Int {
        let total = bank.inlineSize.addingReportingOverflow(bank.retainedPayloadBytes)
        precondition(!total.overflow)
        return requested ?? total.partialValue
    }
    static func owned(bank: InteractionOwnedBankMeasurement, optionalRecords: Bool, retainedBytes: Int, recordSize: Int, recordStride: Int, recordAlignment: Int) -> Self {
        .init(bank: bank, recordSize: recordSize, recordStride: recordStride, recordAlignment: recordAlignment, optionalRecords: optionalRecords, retainedBytes: retainedBytes)
    }
    static func owned<T: InteractionOwnedBankMeasurementSource, Record>(_ bank: borrowing T, record: Record.Type, optionalRecords: Bool, retainedBytes: Int? = nil) -> Self {
        let facts = bank.ownedInteractionBankMeasurement
        let retained = retainedExtent(facts, requested: retainedBytes)
        return owned(bank: facts, optionalRecords: optionalRecords, retainedBytes: retained, recordSize: MemoryLayout<Record>.size, recordStride: MemoryLayout<Record>.stride, recordAlignment: MemoryLayout<Record>.alignment)
    }
}
struct CounterPhysicalInteractionFacts: CounterStorageRegionSource {
    let candidate: CounterPhysicalBankFacts
    let candidateHits: CounterPhysicalBankFacts
    let prepared: CounterPhysicalBankFacts
    let committed: CounterPhysicalBankFacts
    let committedHits: CounterPhysicalBankFacts
    let stateMetadataBytes: Int
    var measurement: CounterInteractionMeasurement {
        func keys(_ facts: CounterPhysicalBankFacts) -> UInt64 {
            let bytes = UInt64(facts.bank.retainedIdentitySlots).multipliedReportingOverflow(by: UInt64(MemoryLayout<SemanticCompleteIdentity>.size))
            precondition(!bytes.overflow); return bytes.partialValue
        }
        let candidateKeys = keys(candidate) + keys(candidateHits) + keys(prepared)
        let committedKeys = keys(committed) + keys(committedHits)
        let candidateRaw = UInt64(candidate.retainedBytes) + UInt64(candidateHits.retainedBytes) + UInt64(prepared.retainedBytes)
        let committedRaw = UInt64(committed.retainedBytes) + UInt64(committedHits.retainedBytes)
        precondition(candidateKeys <= candidateRaw && committedKeys <= committedRaw)
        return .init(candidateRecords: min(candidate.bank.capacity, prepared.bank.capacity), candidateHits: candidateHits.bank.capacity,
            committedRecords: committed.bank.capacity, committedHits: committedHits.bank.capacity,
            candidateIdentityBytes: candidateKeys, committedIdentityBytes: committedKeys,
            candidateBytes: candidateRaw - candidateKeys, committedBytes: committedRaw - committedKeys)
    }
    borrowing func visitStorageRegions(_ visit: (CounterStorageRegion) -> Void) {
        func bank(_ facts: CounterPhysicalBankFacts, family: Int, keys: Int) {
            let count = facts.bank.retainedIdentitySlots
            let identityBytes = UInt64(count) * UInt64(MemoryLayout<SemanticCompleteIdentity>.size)
            let records = count.multipliedReportingOverflow(by: facts.recordStride)
            precondition(!records.overflow && UInt64(records.partialValue) >= identityBytes && facts.retainedBytes >= records.partialValue)
            visit(.elements(count: count, family: keys, size: MemoryLayout<SemanticCompleteIdentity>.size, stride: MemoryLayout<SemanticCompleteIdentity>.stride, alignment: MemoryLayout<SemanticCompleteIdentity>.alignment))
            visit(.init(family: family, kind: .elements, count: count, size: facts.recordSize,
                stride: facts.recordStride, alignment: facts.recordAlignment, chargedBytes: UInt64(records.partialValue) - identityBytes))
            visit(.elements(count: facts.retainedBytes - records.partialValue, family: family, size: MemoryLayout<UInt8>.size, stride: MemoryLayout<UInt8>.stride, alignment: MemoryLayout<UInt8>.alignment))
        }
        bank(candidate, family: 19, keys: 5); bank(candidateHits, family: 19, keys: 5); bank(prepared, family: 19, keys: 5)
        bank(committed, family: 20, keys: 6); bank(committedHits, family: 20, keys: 6)
        visit(.elements(count: stateMetadataBytes, family: 19, size: MemoryLayout<UInt8>.size, stride: MemoryLayout<UInt8>.stride, alignment: MemoryLayout<UInt8>.alignment))
    }
}
// Fixed scalar record cells; no generic container construction metadata.
struct CounterPhysicalRegionBuffer {
    private var r00: CounterStorageRegion? = nil
    private var r01: CounterStorageRegion? = nil
    private var r02: CounterStorageRegion? = nil
    private var r03: CounterStorageRegion? = nil
    private var r04: CounterStorageRegion? = nil
    private var r05: CounterStorageRegion? = nil
    private var r06: CounterStorageRegion? = nil
    private var r07: CounterStorageRegion? = nil
    private var r08: CounterStorageRegion? = nil
    private var r09: CounterStorageRegion? = nil
    private var r10: CounterStorageRegion? = nil
    private var r11: CounterStorageRegion? = nil
    private var r12: CounterStorageRegion? = nil
    private var r13: CounterStorageRegion? = nil
    private var r14: CounterStorageRegion? = nil
    private var r15: CounterStorageRegion? = nil
    private var r16: CounterStorageRegion? = nil
    private var r17: CounterStorageRegion? = nil
    private var r18: CounterStorageRegion? = nil
    private var r19: CounterStorageRegion? = nil
    private var r20: CounterStorageRegion? = nil
    private var r21: CounterStorageRegion? = nil
    private var r22: CounterStorageRegion? = nil
    private var r23: CounterStorageRegion? = nil
    private var r24: CounterStorageRegion? = nil
    private var r25: CounterStorageRegion? = nil
    private var r26: CounterStorageRegion? = nil
    private var r27: CounterStorageRegion? = nil
    private var r28: CounterStorageRegion? = nil
    private var r29: CounterStorageRegion? = nil
    private var r30: CounterStorageRegion? = nil
    private var r31: CounterStorageRegion? = nil
    private var r32: CounterStorageRegion? = nil
    private var r33: CounterStorageRegion? = nil
    private var r34: CounterStorageRegion? = nil
    private var r35: CounterStorageRegion? = nil
    private var r36: CounterStorageRegion? = nil
    private var r37: CounterStorageRegion? = nil
    private var r38: CounterStorageRegion? = nil
    private var r39: CounterStorageRegion? = nil
    private var r40: CounterStorageRegion? = nil
    private var r41: CounterStorageRegion? = nil
    private var r42: CounterStorageRegion? = nil
    private var r43: CounterStorageRegion? = nil
    private var r44: CounterStorageRegion? = nil
    private var r45: CounterStorageRegion? = nil
    private var r46: CounterStorageRegion? = nil
    private var r47: CounterStorageRegion? = nil
    var count: Int { 48 }
    subscript(_ index: Int) -> CounterStorageRegion? {
        get {
            switch index {
            case 0: return r00
            case 1: return r01
            case 2: return r02
            case 3: return r03
            case 4: return r04
            case 5: return r05
            case 6: return r06
            case 7: return r07
            case 8: return r08
            case 9: return r09
            case 10: return r10
            case 11: return r11
            case 12: return r12
            case 13: return r13
            case 14: return r14
            case 15: return r15
            case 16: return r16
            case 17: return r17
            case 18: return r18
            case 19: return r19
            case 20: return r20
            case 21: return r21
            case 22: return r22
            case 23: return r23
            case 24: return r24
            case 25: return r25
            case 26: return r26
            case 27: return r27
            case 28: return r28
            case 29: return r29
            case 30: return r30
            case 31: return r31
            case 32: return r32
            case 33: return r33
            case 34: return r34
            case 35: return r35
            case 36: return r36
            case 37: return r37
            case 38: return r38
            case 39: return r39
            case 40: return r40
            case 41: return r41
            case 42: return r42
            case 43: return r43
            case 44: return r44
            case 45: return r45
            case 46: return r46
            case 47: return r47
            default: preconditionFailure("physical region index out of bounds")
            }
        }
        set {
            switch index {
            case 0: r00 = newValue
            case 1: r01 = newValue
            case 2: r02 = newValue
            case 3: r03 = newValue
            case 4: r04 = newValue
            case 5: r05 = newValue
            case 6: r06 = newValue
            case 7: r07 = newValue
            case 8: r08 = newValue
            case 9: r09 = newValue
            case 10: r10 = newValue
            case 11: r11 = newValue
            case 12: r12 = newValue
            case 13: r13 = newValue
            case 14: r14 = newValue
            case 15: r15 = newValue
            case 16: r16 = newValue
            case 17: r17 = newValue
            case 18: r18 = newValue
            case 19: r19 = newValue
            case 20: r20 = newValue
            case 21: r21 = newValue
            case 22: r22 = newValue
            case 23: r23 = newValue
            case 24: r24 = newValue
            case 25: r25 = newValue
            case 26: r26 = newValue
            case 27: r27 = newValue
            case 28: r28 = newValue
            case 29: r29 = newValue
            case 30: r30 = newValue
            case 31: r31 = newValue
            case 32: r32 = newValue
            case 33: r33 = newValue
            case 34: r34 = newValue
            case 35: r35 = newValue
            case 36: r36 = newValue
            case 37: r37 = newValue
            case 38: r38 = newValue
            case 39: r39 = newValue
            case 40: r40 = newValue
            case 41: r41 = newValue
            case 42: r42 = newValue
            case 43: r43 = newValue
            case 44: r44 = newValue
            case 45: r45 = newValue
            case 46: r46 = newValue
            case 47: r47 = newValue
            default: preconditionFailure("physical region index out of bounds")
            }
        }
    }
}

struct CounterPhysicalGeometryFacts: CounterStorageRegionSource {
    var regions = CounterPhysicalRegionBuffer()
    var count = 0
    mutating func append(_ region: CounterStorageRegion) {
        precondition(count < regions.count); regions[count] = region; count += 1
    }
    borrowing func visitStorageRegions(_ visit: (CounterStorageRegion) -> Void) {
        let limit = count
        precondition(limit >= 0)
        var index = 0
        while index < limit {
            visit(regions[index]!)
            index += 1
        }
    }
}

#if GIFTUI_PHYSICAL_FACTS_QUALIFICATION
func p08OriginalPhysicalBankFacts<T: InteractionOwnedBankMeasurementSource, Record>(_ bank: borrowing T, record: Record.Type, optionalRecords: Bool, retainedBytes: Int? = nil) -> CounterPhysicalBankFacts {
    let facts = bank.ownedInteractionBankMeasurement
    let total = facts.inlineSize.addingReportingOverflow(facts.retainedPayloadBytes)
    precondition(!total.overflow)
    return .init(bank: facts, recordSize: MemoryLayout<Record>.size, recordStride: MemoryLayout<Record>.stride, recordAlignment: MemoryLayout<Record>.alignment, optionalRecords: optionalRecords, retainedBytes: retainedBytes ?? total.partialValue)
}
#endif
