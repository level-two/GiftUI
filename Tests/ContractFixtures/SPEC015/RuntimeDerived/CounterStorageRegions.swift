import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

// Streamed instrumentation, never another storage owner or retained observer bank.
// A partition's charged bytes are a subset of the named typed owner's extent.
// Residual metadata/padding is labeled explicitly instead of inventing elements.
protocol CounterStorageRegionSource {
    borrowing func visitStorageRegions(_ visit: (CounterStorageRegion) -> Void)
}
struct CounterStorageRegion {
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
        precondition(CounterExtent(count: count, stride: stride, alignment: alignment).bytes! >= chargedBytes)
        self.family = family; self.kind = kind; self.count = count
        self.size = size; self.stride = stride; self.alignment = alignment; self.chargedBytes = chargedBytes
    }
    static func elements(count: Int, family: Int, chargedBytes: UInt64? = nil, size: Int, stride: Int, alignment: Int) -> Self {
        .init(family: family, kind: .elements, count: count, size: size, stride: stride, alignment: alignment,
            chargedBytes: chargedBytes ?? CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)
    }
    private static func inlineCharge(_ bytes: Int) -> Int {
        precondition(bytes >= 0)
        return bytes
    }
    static func inline(family: Int, chargedBytes: Int? = nil, kind: Kind = .inlineValue, size: Int, stride: Int, alignment: Int) -> Self {
        let charge = inlineCharge(chargedBytes ?? size)
        return .init(family: family, kind: kind, count: 1, size: size, stride: stride, alignment: alignment, chargedBytes: UInt64(charge))
    }
    static func elements<T: ~Copyable & ~Escapable>(_ type: T.Type, count: Int, family: Int, chargedBytes: UInt64? = nil) -> Self {
        elements(count: count, family: family, chargedBytes: chargedBytes, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment)
    }
    static func inline<T: ~Copyable & ~Escapable>(_ type: T.Type, family: Int, chargedBytes: Int? = nil, kind: Kind = .inlineValue) -> Self {
        // Preserve early refusal before any remaining generic layout queries.
        _ = inlineCharge(chargedBytes ?? MemoryLayout<T>.size)
        return inline(family: family, chargedBytes: chargedBytes, kind: kind, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment)
    }
}


#if !hasFeature(Embedded)
extension DynamicCounterGeometry: CounterStorageRegionSource {
    borrowing func visitStorageRegions(_ visit: (CounterStorageRegion) -> Void) {
        visit(.inline(family: 12, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<DynamicRenderWorkspace>.size - MemoryLayout<DynamicDrawingPlanWorkspace>.size, kind: .metadataPadding, size: MemoryLayout<Self>.size, stride: MemoryLayout<Self>.stride, alignment: MemoryLayout<Self>.alignment))
        workspace.visitRetainedPayloadExtents { count, size, stride, alignment in
            visit(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        resolved.visitRetainedPayloadExtents { count, size, stride, alignment in
            visit(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        visit(.inline(family: 13, size: MemoryLayout<DynamicRenderWorkspace>.size, stride: MemoryLayout<DynamicRenderWorkspace>.stride, alignment: MemoryLayout<DynamicRenderWorkspace>.alignment))
        render.visitRetainedPayloadExtents { count, size, stride, alignment in
            visit(.init(family: 13, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        plan.visitRetainedPathExtents { count, size, stride, alignment in
            visit(.init(family: 15, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
        visit(.inline(family: 16, size: MemoryLayout<DynamicDrawingPlanWorkspace>.size, stride: MemoryLayout<DynamicDrawingPlanWorkspace>.stride, alignment: MemoryLayout<DynamicDrawingPlanWorkspace>.alignment))
        plan.visitRetainedPlanExtents { count, size, stride, alignment in
            visit(.init(family: 16, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!))
        }
    }
}
#endif

extension CounterStaticWorkspaceBacking: CounterStorageRegionSource {
    borrowing func visitStorageRegions(_ visit: (CounterStorageRegion) -> Void) {
        // These four regions use explicit byte codecs, never typed loads or
        // rebinding. Their supplied and required alignment are both UInt8 (1).
        // Scoped typed descriptor values have their own alignment below.
        visit(.elements(count: scopes.count, family: 12, size: MemoryLayout<UInt8>.size, stride: MemoryLayout<UInt8>.stride, alignment: MemoryLayout<UInt8>.alignment))
        visit(.elements(count: text.count, family: 12, size: MemoryLayout<UInt8>.size, stride: MemoryLayout<UInt8>.stride, alignment: MemoryLayout<UInt8>.alignment)) // Layout owns the render overlay.
        visit(.inline(family: 12, chargedBytes: MemoryLayout<StaticCounterGeometry>.size - MemoryLayout<QualifiedRender>.size - MemoryLayout<StaticCounterRecordDrawingWorkspace>.size, kind: .metadataPadding, size: MemoryLayout<StaticCounterGeometry>.size, stride: MemoryLayout<StaticCounterGeometry>.stride, alignment: MemoryLayout<StaticCounterGeometry>.alignment))
        visit(.inline(family: 13, size: MemoryLayout<QualifiedRender>.size, stride: MemoryLayout<QualifiedRender>.stride, alignment: MemoryLayout<QualifiedRender>.alignment))
        visit(.elements(count: path.count, family: 15, size: MemoryLayout<UInt8>.size, stride: MemoryLayout<UInt8>.stride, alignment: MemoryLayout<UInt8>.alignment))
        visit(.elements(count: plan.count, family: 16, size: MemoryLayout<UInt8>.size, stride: MemoryLayout<UInt8>.stride, alignment: MemoryLayout<UInt8>.alignment))
        visit(.inline(family: 16, size: MemoryLayout<StaticCounterRecordDrawingWorkspace>.size, stride: MemoryLayout<StaticCounterRecordDrawingWorkspace>.stride, alignment: MemoryLayout<StaticCounterRecordDrawingWorkspace>.alignment))
    }
}

func counterVisitInteraction<C: CounterCandidateBacking & InteractionOwnedBankMeasurementSource, R: CounterCommittedBacking & InteractionOwnedBankMeasurementSource, H: CounterHitBacking & InteractionOwnedBankMeasurementSource>(_ storage: borrowing InteractionOwnedKeyState<C, R, H>, _ visit: (CounterStorageRegion) -> Void) where C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    func store<T, Record>(_ type: T.Type, _ record: Record.Type, slots: Int, payload: Int, family: Int, keys: Int) {
        let identityBytes = UInt64(slots * MemoryLayout<SemanticCompleteIdentity>.size)
        visit(.elements(count: slots, family: keys, chargedBytes: identityBytes, size: MemoryLayout<SemanticCompleteIdentity>.size, stride: MemoryLayout<SemanticCompleteIdentity>.stride, alignment: MemoryLayout<SemanticCompleteIdentity>.alignment))
        if payload == 0 {
            let records = slots * MemoryLayout<Record?>.stride
            visit(.elements(count: slots, family: family, chargedBytes: UInt64(records) - identityBytes, size: MemoryLayout<Record?>.size, stride: MemoryLayout<Record?>.stride, alignment: MemoryLayout<Record?>.alignment))
            visit(.inline(family: family, chargedBytes: MemoryLayout<T>.size - records, kind: .metadataPadding, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment))
        } else {
            precondition(payload == slots * MemoryLayout<Record>.stride)
            visit(.elements(count: slots, family: family, chargedBytes: UInt64(payload) - identityBytes, size: MemoryLayout<Record>.size, stride: MemoryLayout<Record>.stride, alignment: MemoryLayout<Record>.alignment))
            visit(.inline(family: family, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment))
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
    visit(.inline(family: 19, chargedBytes: MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<C>.size - MemoryLayout<R>.size * 2 - MemoryLayout<H>.size * 2, kind: .metadataPadding, size: MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size, stride: MemoryLayout<InteractionOwnedKeyState<C, R, H>>.stride, alignment: MemoryLayout<InteractionOwnedKeyState<C, R, H>>.alignment))
}

#if GIFTUI_PHYSICAL_FACTS_QUALIFICATION
func p08OriginalRegionElements<T: ~Copyable & ~Escapable>(_ type: T.Type, count: Int, family: Int, chargedBytes: UInt64? = nil) -> CounterStorageRegion {
    .init(family: family, kind: .elements, count: count, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment, chargedBytes: chargedBytes ?? CounterExtent.elements(type, count: count).bytes!)
}
func p08OriginalRegionInline<T: ~Copyable & ~Escapable>(_ type: T.Type, family: Int, chargedBytes: Int? = nil, kind: CounterStorageRegion.Kind = .inlineValue) -> CounterStorageRegion {
    precondition((chargedBytes ?? MemoryLayout<T>.size) >= 0)
    return .init(family: family, kind: kind, count: 1, size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment, chargedBytes: UInt64(chargedBytes ?? MemoryLayout<T>.size))
}
#endif
