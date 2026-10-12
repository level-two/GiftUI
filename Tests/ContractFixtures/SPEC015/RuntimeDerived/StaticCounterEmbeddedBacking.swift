import P08CounterTable
import P08CounterSchema
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

// The caller supplies four disjoint, stable slots. Only the selected Embedded
// graph/host use this realization; other callers retain the inline owner.
#if hasFeature(Embedded)
let counterEmbeddedSlotBytes = 30176
let counterEmbeddedSlotCount = 4

typealias CounterSelectedStaticProfileStorage = CounterEmbeddedProfileStorage

struct CounterEmbeddedElements<Element> {
    let start: UnsafeMutablePointer<Element>
    let count: Int
    var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        mutating get { MutableSpan(_unsafeStart: start, count: count) }
    }
}
struct CounterEmbeddedSemanticBacking {
    var records: CounterEmbeddedElements<SemanticRuntimeRecord>
    var paths: CounterEmbeddedElements<SemanticPathEntry>
    var payloads: CounterEmbeddedElements<CounterPayload?>
    var scalars: CounterEmbeddedElements<UInt32>
}

// Typed bindings initialize each physical field separately. In particular no
// full profile or semantic aggregate is ever passed to initialize(to:).
private func counterEmbeddedField<T: ~Copyable>(_ bytes: UnsafeMutableRawBufferPointer,
    _ type: T.Type, offset: Int, stride: Int, alignment: Int, count: Int = 1
) -> UnsafeMutablePointer<T> {
    precondition(MemoryLayout<T>.stride == stride && MemoryLayout<T>.alignment == alignment)
    precondition(offset >= 0 && offset + stride * count <= bytes.count)
    let pointer = bytes.baseAddress!.advanced(by: offset)
    precondition(Int(bitPattern: pointer) % alignment == 0)
    return pointer.bindMemory(to: T.self, capacity: count)
}

struct CounterEmbeddedProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .static }
    private let limitsStorage: UnsafeMutablePointer<RuntimeProfileLimits>
    private let rootStorage: UnsafeMutablePointer<StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>
    private let semanticStorage: UnsafeMutablePointer<StaticSemanticRecordStorage>
    var semanticBacking: CounterEmbeddedSemanticBacking
    private let canvasStorage: UnsafeMutablePointer<StaticCanvasValueStorage>
    var canvasBacking: CounterEmbeddedElements<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>
    private let workspaceStorage: UnsafeMutablePointer<CounterStaticWorkspaceBacking>
    private let interactionStorage: UnsafeMutablePointer<CounterStaticKeys?>
    private let controlStorage: UnsafeMutablePointer<CounterControl>
    private let usedStorage: UnsafeMutablePointer<Bool>
    var limits: RuntimeProfileLimits { limitsStorage.pointee }
    var root: StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity> {
        _read { yield rootStorage.pointee }
        nonmutating _modify { yield &rootStorage.pointee }
    }
    var semantic: StaticSemanticRecordStorage {
        _read { yield semanticStorage.pointee }
        nonmutating _modify { yield &semanticStorage.pointee }
    }
    var canvas: StaticCanvasValueStorage {
        _read { yield canvasStorage.pointee }
        nonmutating _modify { yield &canvasStorage.pointee }
    }
    var workspace: CounterStaticWorkspaceBacking {
        _read { yield workspaceStorage.pointee }
        nonmutating _modify { yield &workspaceStorage.pointee }
    }
    var interaction: CounterStaticKeys? {
        _read { yield interactionStorage.pointee }
        nonmutating _modify { yield &interactionStorage.pointee }
    }
    var control: CounterControl {
        _read { yield controlStorage.pointee }
        nonmutating _modify { yield &controlStorage.pointee }
    }
    var used: Bool {
        _read { yield usedStorage.pointee }
        nonmutating _modify { yield &usedStorage.pointee }
    }
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity,
        backing: UnsafeMutableRawBufferPointer, limits: RuntimeProfileLimits = counterActualLimits(.static)
    ) {
        precondition(backing.count == counterEmbeddedSlotBytes)
        precondition(MemoryLayout<StaticCounterProfileStorage>.stride == counterEmbeddedSlotBytes)
        precondition(Int(bitPattern: backing.baseAddress!) % 8 == 0)
        limitsStorage = counterEmbeddedField(backing, RuntimeProfileLimits.self, offset: 0, stride: 116, alignment: 4)
        rootStorage = counterEmbeddedField(backing, StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, offset: 116, stride: 812, alignment: 4)
        semanticStorage = counterEmbeddedField(backing, StaticSemanticRecordStorage.self, offset: 928, stride: 116, alignment: 4)
        semanticBacking = .init(
            records: .init(start: counterEmbeddedField(backing, SemanticRuntimeRecord.self, offset: 1044, stride: 20, alignment: 2, count: 128), count: 128),
            paths: .init(start: counterEmbeddedField(backing, SemanticPathEntry.self, offset: 3604, stride: 22, alignment: 2, count: 384), count: 384),
            payloads: .init(start: counterEmbeddedField(backing, CounterPayload?.self, offset: 12052, stride: 36, alignment: 4, count: 256), count: 256),
            scalars: .init(start: counterEmbeddedField(backing, UInt32.self, offset: 21268, stride: 4, alignment: 4, count: 128), count: 128))
        canvasStorage = counterEmbeddedField(backing, StaticCanvasValueStorage.self, offset: 21780, stride: 4, alignment: 2)
        canvasBacking = .init(start: counterEmbeddedField(backing, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?.self, offset: 21784, stride: 28, alignment: 4), count: 1)
        workspaceStorage = counterEmbeddedField(backing, CounterStaticWorkspaceBacking.self, offset: 21812, stride: 2212, alignment: 1)
        interactionStorage = counterEmbeddedField(backing, CounterStaticKeys?.self, offset: 24024, stride: 2412, alignment: 4)
        controlStorage = counterEmbeddedField(backing, CounterControl.self, offset: 26440, stride: 3728, alignment: 8)
        usedStorage = counterEmbeddedField(backing, Bool.self, offset: 30168, stride: 1, alignment: 1)
        // Initialize all semantic sentinels through their typed initializers.
        // Zero-filled BSS alone is not a valid initial semantic bank.
        limitsStorage.initialize(to: limits)
        rootStorage.initialize(to: StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!)
        semanticStorage.initialize(to: StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner))
        for index in 0..<128 { semanticBacking.records.start.advanced(by: index).initialize(to: .init()) }
        for index in 0..<384 { semanticBacking.paths.start.advanced(by: index).initialize(to: .init()) }
        for index in 0..<256 { semanticBacking.payloads.start.advanced(by: index).initialize(to: nil) }
        for index in 0..<128 { semanticBacking.scalars.start.advanced(by: index).initialize(to: 0) }
        canvasStorage.initialize(to: StaticCanvasValueStorage())
        canvasBacking.start.initialize(to: nil)
        workspaceStorage.initialize(to: CounterStaticWorkspaceBacking())
        interactionStorage.initialize(to: CounterStaticKeys(state: InteractionState(candidateRecords: CounterStaticCandidate(capacity: 2)!, candidateHitRegions: CounterStaticHits(capacity: 2)!, candidateCommittedRecords: CounterStaticCommitted(capacity: 2)!, committedRecords: CounterStaticCommitted(capacity: 2)!, committedHitRegions: CounterStaticHits(capacity: 2)!), maximumComponentsPerKey: 24, maximumComponents: 48)!)
        controlStorage.initialize(to: CounterControl())
        usedStorage.initialize(to: false)
    }
    deinit {
        // Every host/runtime borrow and teardown ends before this descriptor.
        usedStorage.deinitialize(count: 1)
        controlStorage.deinitialize(count: 1)
        interactionStorage.deinitialize(count: 1)
        workspaceStorage.deinitialize(count: 1)
        canvasBacking.start.deinitialize(count: 1)
        canvasStorage.deinitialize(count: 1)
        semanticBacking.scalars.start.deinitialize(count: 128)
        semanticBacking.payloads.start.deinitialize(count: 256)
        semanticBacking.paths.start.deinitialize(count: 384)
        semanticBacking.records.start.deinitialize(count: 128)
        semanticStorage.deinitialize(count: 1)
        rootStorage.deinitialize(count: 1)
        limitsStorage.deinitialize(count: 1)
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let interaction else { return .invalid(.missingStorage) }
        return counterValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, family: 7, chargedBytes: root.storageLayout.metadataBytes, kind: .metadataPadding),
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: semanticBacking.records.count), paths: .elements(SemanticPathEntry.self, count: semanticBacking.paths.count), payloads: .elements(CounterPayload?.self, count: semanticBacking.payloads.count), scalars: .elements(UInt32.self, count: semanticBacking.scalars.count), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size + CounterSemanticBacking.paddingBytes),
            geometry: workspace.measurement, interaction: interaction, geometryType: StaticCounterGeometry.self,
            canvasCount: canvasBacking.count, canvasCapacity: UInt16(canvasBacking.count),
            canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size,
            factoryRegion: .inline(StaticCounterProfileStorage.self, family: 24, chargedBytes: MemoryLayout<StaticCounterProfileStorage>.stride - MemoryLayout<StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>.size - MemoryLayout<StaticSemanticRecordStorage>.size - MemoryLayout<CounterSemanticBacking>.size - MemoryLayout<StaticCanvasValueStorage>.size - MemoryLayout<InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>>.size - MemoryLayout<CounterStaticWorkspaceBacking>.size - MemoryLayout<CounterStaticKeys>.size - MemoryLayout<CounterControl>.size, kind: .metadataPadding),
            factoryDescriptorRegion: .inline(Self.self, family: 24, kind: .metadataPadding),
            geometryRegions: workspace, report: report)
    }
    mutating func resetAttemptStorage() {
        precondition(interaction != nil)
        _ = workspace.withGeometry { geometry in
            var geometry = consume geometry
            geometry.reset()
            return 0
        }
        interaction!.resolveCandidate(.discard)
        control.admission.finishAttempt()
    }
    mutating func resetAllStorage() {
        precondition(!used || control.unavailable)
        resetAttemptStorage()
        interaction!.resetAllStorage()
        control.admission.resetAll()
    }

}
#else
typealias CounterSelectedStaticProfileStorage = StaticCounterProfileStorage
#endif

func counterSelectedProfileBacking(_ backing: UnsafeMutableRawBufferPointer?, slot: Int) -> UnsafeMutableRawBufferPointer? {
    #if hasFeature(Embedded)
    guard let backing else { preconditionFailure("Embedded counter requires caller backing") }
    precondition((0..<counterEmbeddedSlotCount).contains(slot))
    precondition(backing.count == counterEmbeddedSlotCount * counterEmbeddedSlotBytes)
    return UnsafeMutableRawBufferPointer(rebasing: backing[(slot * counterEmbeddedSlotBytes)..<((slot + 1) * counterEmbeddedSlotBytes)])
    #else
    return nil
    #endif
}
func counterMakeSelectedProfile(modelOwner: ObservableModelOwnerIdentity,
    semanticOwner: SemanticRecordOwnerIdentity, backing: UnsafeMutableRawBufferPointer?
) -> CounterSelectedStaticProfileStorage {
    #if hasFeature(Embedded)
    return .init(modelOwner: modelOwner, semanticOwner: semanticOwner, backing: backing!)
    #else
    return .init(modelOwner: modelOwner, semanticOwner: semanticOwner)
    #endif
}
