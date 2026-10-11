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
import P07TargetWorkspace
import CycleSchema
import CycleTable

// Finite assembly measurement seams. Byte arithmetic is checked before conversion
// to the normative UInt32 fields; no element capacity is inferred from a live count.
struct CycleExtent: Equatable {
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
struct CycleInteractionMeasurement: Equatable {
    let candidateRecords: UInt16
    let candidateHits: UInt16
    let committedRecords: UInt16
    let committedHits: UInt16
    let candidateIdentityBytes: UInt64
    let committedIdentityBytes: UInt64
    let candidateBytes: UInt64
    let committedBytes: UInt64
}
protocol CycleCandidateBacking: InteractionCandidateRecordStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CycleCommittedBacking: InteractionCommittedRecordStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CycleHitBacking: InteractionHitRegionStorage {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
extension StaticSixInteractionCandidateStorage: CycleCandidateBacking {
    var retainedIdentitySlots: Int { 6 }
    var retainedPayloadBytes: Int { 0 } // Records are already inside Self's inline layout.
}
extension StaticSixInteractionCommittedStorage: CycleCommittedBacking {
    var retainedIdentitySlots: Int { 6 }
    var retainedPayloadBytes: Int { 0 }
}
extension StaticSixInteractionHitStorage: CycleHitBacking {
    var retainedIdentitySlots: Int { 6 }
    var retainedPayloadBytes: Int { 0 }
}
#if !hasFeature(Embedded)
extension DynamicInteractionCandidateStorage: CycleCandidateBacking {
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
extension DynamicInteractionCommittedStorage: CycleCommittedBacking {
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
extension DynamicInteractionHitStorage: CycleHitBacking {
    var retainedIdentitySlots: Int { retainedElementCapacity }
    var retainedPayloadBytes: Int { reservedPayloadBytes }
}
#endif
func cycleMeasureInteraction<C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking>(_ storage: borrowing InteractionOwnedKeyState<C, R, H>) -> CycleInteractionMeasurement where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
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
struct CycleGeometryMeasurement: Equatable {
    let layout: LayoutLimits
    let render: RenderLimits
    let renderWorkspace: RenderWorkspaceCapacity
    let drawing: DrawingLimits
    let layoutBytes: UInt64
    let renderBytes: UInt64
    let pathBytes: UInt64
    let planBytes: UInt64
}
