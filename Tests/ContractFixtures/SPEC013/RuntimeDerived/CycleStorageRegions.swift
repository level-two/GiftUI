import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import P07TargetWorkspace
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

// Streamed instrumentation, never another storage owner or retained observer bank.
// A partition's charged bytes are a subset of the named typed owner's extent.
// Residual metadata/padding is labeled explicitly instead of inventing elements.
protocol CycleStorageRegionSource {
    borrowing func visitStorageRegions(_ visit: (CycleStorageRegion) -> Void)
}
struct CycleStorageRegion {
    enum Kind: UInt8 { case elements, inlineValue, partition, metadataPadding }
    let family: Int
    let kind: Kind
    let count: Int
    let size: Int
    let stride: Int
    let alignment: Int
    let chargedBytes: UInt64
    init(family: Int, kind: Kind, count: Int, size: Int, stride: Int, alignment: Int, chargedBytes: UInt64) {
        precondition(count >= 0 && size >= 0 && stride >= size && alignment > 0)
        precondition(CycleExtent(count: count, stride: stride, alignment: alignment).bytes! >= chargedBytes)
        self.family = family; self.kind = kind; self.count = count
        self.size = size; self.stride = stride; self.alignment = alignment; self.chargedBytes = chargedBytes
    }
    static func elements<T: ~Copyable & ~Escapable>(_ type: T.Type, count: Int, family: Int, chargedBytes: UInt64? = nil) -> Self {
        .init(family: family, kind: .elements, count: count, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment,
            chargedBytes: chargedBytes ?? CycleExtent.elements(type, count: count).bytes!)
    }
    static func inline<T: ~Copyable & ~Escapable>(_ type: T.Type, family: Int, chargedBytes: Int? = nil, kind: Kind = .inlineValue) -> Self {
        precondition((chargedBytes ?? MemoryLayout<T>.size) >= 0)
        return .init(family: family, kind: kind, count: 1, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment, chargedBytes: UInt64(chargedBytes ?? MemoryLayout<T>.size))
    }
}


#if !hasFeature(Embedded)
extension DynamicCycleGeometry: CycleStorageRegionSource {
    borrowing func visitStorageRegions(_ visit: (CycleStorageRegion) -> Void) {
        visit(.inline(Self.self, family: 12, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<DynamicRenderWorkspace>.size - MemoryLayout<DynamicDrawingPlanWorkspace>.size, kind: .metadataPadding))
        workspace.visitRetainedPayloadExtents { count, size, stride, alignment in
            visit(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CycleExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        resolved.visitRetainedPayloadExtents { count, size, stride, alignment in
            visit(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CycleExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        visit(.inline(DynamicRenderWorkspace.self, family: 13))
        render.visitRetainedPayloadExtents { count, size, stride, alignment in
            visit(.init(family: 13, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CycleExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        plan.visitRetainedPathExtents { count, size, stride, alignment in
            visit(.init(family: 15, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CycleExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        visit(.inline(DynamicDrawingPlanWorkspace.self, family: 16))
        plan.visitRetainedPlanExtents { count, size, stride, alignment in
            visit(.init(family: 16, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CycleExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
    }
}
#endif

extension CycleStaticWorkspaceBacking: CycleStorageRegionSource {
    borrowing func visitStorageRegions(_ visit: (CycleStorageRegion) -> Void) {
        // These four regions use explicit byte codecs, never typed loads or
        // rebinding. Their supplied and required alignment are both UInt8 (1).
        // Scoped typed descriptor values have their own alignment below.
        visit(.elements(UInt8.self, count: scopes.count, family: 12))
        visit(.elements(UInt8.self, count: text.count, family: 12)) // Layout owns the render overlay.
        visit(.inline(StaticCycleGeometry.self, family: 12, chargedBytes: MemoryLayout<StaticCycleGeometry>.size - MemoryLayout<QualifiedRender>.size - MemoryLayout<StaticRecordDrawingWorkspace<StaticSignalAnalyzerNRFDrawingWorkspace>>.size, kind: .metadataPadding))
        visit(.inline(QualifiedRender.self, family: 13))
        visit(.elements(UInt8.self, count: path.count, family: 15))
        visit(.elements(UInt8.self, count: plan.count, family: 16))
        visit(.inline(StaticRecordDrawingWorkspace<StaticSignalAnalyzerNRFDrawingWorkspace>.self, family: 16))
    }
}

func cycleVisitInteraction<C: CycleCandidateBacking & InteractionOwnedBankMeasurementSource, R: CycleCommittedBacking & InteractionOwnedBankMeasurementSource, H: CycleHitBacking & InteractionOwnedBankMeasurementSource>(_ storage: borrowing InteractionOwnedKeyState<C, R, H>, _ visit: (CycleStorageRegion) -> Void) where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    func store<T, Record>(_ type: T.Type, _ record: Record.Type, slots: Int, payload: Int, family: Int, keys: Int) {
        let identityBytes = UInt64(slots * MemoryLayout<SemanticCompleteIdentity>.size)
        visit(.elements(SemanticCompleteIdentity.self, count: slots, family: keys, chargedBytes: identityBytes))
        if payload == 0 {
            let records = slots * MemoryLayout<Record?>.stride
            visit(.elements(Record?.self, count: slots, family: family, chargedBytes: UInt64(records) - identityBytes))
            visit(.inline(type, family: family, chargedBytes: MemoryLayout<T>.size - records, kind: .metadataPadding))
        } else {
            precondition(payload == slots * MemoryLayout<Record>.stride)
            visit(.elements(record, count: slots, family: family, chargedBytes: UInt64(payload) - identityBytes))
            visit(.inline(type, family: family))
        }
    }
    let facts = storage.ownedStorageMeasurement()
    let candidate = facts.candidate, hits = facts.candidateHits
    let prepared = facts.prepared, committed = facts.committed, committedHits = facts.committedHits
        store(C.self, InteractionCandidateRecord<SemanticCompleteIdentity>.self, slots: candidate.retainedIdentitySlots, payload: candidate.retainedPayloadBytes, family: 19, keys: 5)
        store(H.self, InteractionHitRegion<SemanticCompleteIdentity>.self, slots: hits.retainedIdentitySlots, payload: hits.retainedPayloadBytes, family: 19, keys: 5)
        store(R.self, BoundActionRecord<SemanticCompleteIdentity>.self, slots: prepared.retainedIdentitySlots, payload: prepared.retainedPayloadBytes, family: 19, keys: 5)
        store(R.self, BoundActionRecord<SemanticCompleteIdentity>.self, slots: committed.retainedIdentitySlots, payload: committed.retainedPayloadBytes, family: 20, keys: 6)
        store(H.self, InteractionHitRegion<SemanticCompleteIdentity>.self, slots: committedHits.retainedIdentitySlots, payload: committedHits.retainedPayloadBytes, family: 20, keys: 6)
    visit(.inline(InteractionOwnedKeyState<C, R, H>.self, family: 19, chargedBytes: MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<C>.size - MemoryLayout<R>.size * 2 - MemoryLayout<H>.size * 2, kind: .metadataPadding))
}
