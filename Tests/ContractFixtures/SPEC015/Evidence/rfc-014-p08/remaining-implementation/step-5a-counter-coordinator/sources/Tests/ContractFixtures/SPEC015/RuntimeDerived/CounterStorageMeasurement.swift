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
protocol CounterCandidateBacking: InteractionCandidateRecordStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CounterCommittedBacking: InteractionCommittedRecordStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CounterHitBacking: InteractionHitRegionStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
extension StaticTwoInteractionCandidateStorage: CounterCandidateBacking {
    var retainedIdentitySlots: Int { 2 }
    var retainedPayloadBytes: Int { 0 } // Records are already inside Self's inline layout.
}
extension StaticTwoInteractionCommittedStorage: CounterCommittedBacking {
    var retainedIdentitySlots: Int { 2 }
    var retainedPayloadBytes: Int { 0 }
}
extension StaticTwoInteractionHitStorage: CounterHitBacking {
    var retainedIdentitySlots: Int { 2 }
    var retainedPayloadBytes: Int { 0 }
}
#if !hasFeature(Embedded)
extension DynamicInteractionCandidateStorage: CounterCandidateBacking {
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
extension DynamicInteractionCommittedStorage: CounterCommittedBacking {
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
extension DynamicInteractionHitStorage: CounterHitBacking {
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
#endif
func counterMeasureInteraction<C: CounterCandidateBacking, R: CounterCommittedBacking, H: CounterHitBacking>(_ storage: borrowing InteractionOwnedKeyState<C, R, H>) -> CounterInteractionMeasurement where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    storage.withBacking { candidate, candidateHits, prepared, committed, committedHits in
        // Each record owns one complete identity. Candidate includes the prepared
        // committed bank. Key bytes are subtracted from those records, never added twice.
        let candidateKeys = UInt64(candidate.retainedIdentitySlots + candidateHits.retainedIdentitySlots + prepared.retainedIdentitySlots) * UInt64(MemoryLayout<SemanticCompleteIdentity>.size)
        let committedKeys = UInt64(committed.retainedIdentitySlots + committedHits.retainedIdentitySlots) * UInt64(MemoryLayout<SemanticCompleteIdentity>.size)
        let candidateRaw = UInt64(MemoryLayout<C>.size + MemoryLayout<H>.size + MemoryLayout<R>.size + candidate.retainedPayloadBytes + candidateHits.retainedPayloadBytes + prepared.retainedPayloadBytes)
        let committedRaw = UInt64(MemoryLayout<R>.size + MemoryLayout<H>.size + committed.retainedPayloadBytes + committedHits.retainedPayloadBytes)
        precondition(candidateKeys <= candidateRaw && committedKeys <= committedRaw)
        return .init(candidateRecords: min(candidate.capacity, prepared.capacity), candidateHits: candidateHits.capacity,
            committedRecords: committed.capacity, committedHits: committedHits.capacity,
            candidateIdentityBytes: candidateKeys, committedIdentityBytes: committedKeys,
            candidateBytes: candidateRaw - candidateKeys, committedBytes: committedRaw - committedKeys)
    }
}

// Only the escapable, owned workspaces leave the enclosing scoped opportunity.
// Model/root/semantic/Canvas scopes are destroyed before this transfer returns.
struct CounterReturnedWorkspaces<G: CounterGeometry, C: CounterCandidateBacking, R: CounterCommittedBacking, H: CounterHitBacking> where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    var geometry: G
    var interaction: InteractionOwnedKeyState<C, R, H>
    var checks: Int
    init(geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>, checks: Int) {
        self.geometry = consume geometry
        self.interaction = consume interaction
        self.checks = checks
    }
}
