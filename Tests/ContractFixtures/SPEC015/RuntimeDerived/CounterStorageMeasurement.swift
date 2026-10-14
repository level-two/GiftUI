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
    static func elements<T: ~Copyable & ~Escapable>(_ type: T.Type, count: Int) -> Self {
        .init(count: count, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment)
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
    static func owned<T: InteractionOwnedBankMeasurementSource, Record>(_ bank: borrowing T, record: Record.Type, optionalRecords: Bool, retainedBytes: Int? = nil) -> Self {
        let facts = bank.ownedInteractionBankMeasurement
        let total = facts.inlineSize.addingReportingOverflow(facts.retainedPayloadBytes)
        precondition(!total.overflow)
        return .init(bank: facts, recordSize: MemoryLayout<Record>.size,
            recordStride: MemoryLayout<Record>.stride, recordAlignment: MemoryLayout<Record>.alignment,
            optionalRecords: optionalRecords, retainedBytes: retainedBytes ?? total.partialValue)
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
            visit(.elements(SemanticCompleteIdentity.self, count: count, family: keys))
            visit(.init(family: family, kind: .elements, count: count, size: facts.recordSize,
                stride: facts.recordStride, alignment: facts.recordAlignment, chargedBytes: UInt64(records.partialValue) - identityBytes))
            visit(.elements(UInt8.self, count: facts.retainedBytes - records.partialValue, family: family))
        }
        bank(candidate, family: 19, keys: 5); bank(candidateHits, family: 19, keys: 5); bank(prepared, family: 19, keys: 5)
        bank(committed, family: 20, keys: 6); bank(committedHits, family: 20, keys: 6)
        visit(.elements(UInt8.self, count: stateMetadataBytes, family: 19))
    }
}
struct CounterPhysicalGeometryFacts: CounterStorageRegionSource {
    var regions: InlineArray<48, CounterStorageRegion?> = .init(repeating: nil)
    var count = 0
    mutating func append(_ region: CounterStorageRegion) {
        precondition(count < regions.count); regions[count] = region; count += 1
    }
    borrowing func visitStorageRegions(_ visit: (CounterStorageRegion) -> Void) {
        for index in 0..<count { visit(regions[index]!) }
    }
}
