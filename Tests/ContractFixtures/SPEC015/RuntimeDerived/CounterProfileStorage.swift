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

// These are the actual typed owners, not an audited allocation recipe. An
// activation moves owned workspaces into the scoped pipeline and restores them
// only after the consuming coordinator has quiesced and ended all its borrows.
typealias CounterStaticCandidate = StaticTwoInteractionCandidateStorage<SemanticCompleteIdentity>
typealias CounterStaticCommitted = StaticTwoInteractionCommittedStorage<SemanticCompleteIdentity>
typealias CounterStaticHits = StaticTwoInteractionHitStorage<SemanticCompleteIdentity>
typealias CounterStaticKeys = InteractionOwnedKeyState<CounterStaticCandidate, CounterStaticCommitted, CounterStaticHits>
typealias CounterRootLayout = (owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16, captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int, liveBytes: Int, candidateBytes: Int)
let counterSemanticLimits = SemanticRecordLimits(records: 64, paths: 192, depth: 24, fanout: 5, payloads: 128, textScalars: 64, payloadBytes: 4096)!
let counterCanvasLimits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: UInt16(MemoryLayout<CounterValueTable.CaptureStorage>.stride))!
let counterExecutionLimits = ExecutionLimits(maximumInputEvents: 2, maximumStateChangeFacts: 34, maximumCompletionFacts: 1, maximumSemanticActions: 2, maximumActiveInputSources: 1, maximumCommittedActions: 2)!

struct CounterSemanticBacking: ~Copyable {
    var records: InlineArray<128, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<384, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<256, CounterPayload?> = .init(repeating: nil)
    var scalars: InlineArray<128, UInt32> = .init(repeating: 0)
    static var paddingBytes: Int {
        let fields = MemoryLayout<InlineArray<128, SemanticRuntimeRecord>>.size + MemoryLayout<InlineArray<384, SemanticPathEntry>>.size + MemoryLayout<InlineArray<256, CounterPayload?>>.size + MemoryLayout<InlineArray<128, UInt32>>.size
        precondition(MemoryLayout<Self>.size >= fields)
        return MemoryLayout<Self>.size - fields
    }
}

struct CounterStaticWorkspaceBacking {
    var scopes: InlineArray<1024, UInt8> = .init(repeating: 0)
    var text: InlineArray<1056, UInt8> = .init(repeating: 0)
    var path: InlineArray<20, UInt8> = .init(repeating: 0)
    var plan: InlineArray<112, UInt8> = .init(repeating: 0)
    var measurement: CounterGeometryMeasurement {
        .init(layout: counterLayoutLimits, render: counterRenderLimits, renderWorkspace: counterRenderCapacity, drawing: counterDrawingLimits,
            layoutBytes: UInt64(scopes.count + text.count + MemoryLayout<StaticCounterGeometry>.size - MemoryLayout<QualifiedRender>.size - MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.size),
            renderBytes: UInt64(MemoryLayout<QualifiedRender>.size), pathBytes: UInt64(path.count),
            planBytes: UInt64(plan.count + MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.size))
    }
    mutating func withGeometry(_ body: (consuming StaticCounterGeometry) -> Int) -> Int {
        withUnsafeMutableBytes(of: &scopes) { s in
            withUnsafeMutableBytes(of: &text) { t in
                withUnsafeMutableBytes(of: &path) { p in
                    withUnsafeMutableBytes(of: &plan) { d in
                        body(StaticCounterGeometry(scopes: s, text: t, path: p, plan: d))
                    }
                }
            }
        }
    }
}

struct CounterCanvasAudit: RuntimeStaticCanvasAuditMetadata {
    let table = CounterValueTable()
    var callableCaseCount: UInt16 { table.callableCaseCount }
    var declaredEntryCount: UInt16 { table.callableCaseCount }
    var maximumDeclaredID: UInt16 { table.callableCaseCount }
    func coverageMultiplicity(for id: UInt16) -> UInt8 { table.captureByteCount(for: id) == nil ? 0 : 1 }
    func captureByteCount(for id: UInt16) -> UInt16? { table.captureByteCount(for: id) }
}



func counterSemanticConfiguration(_ limits: RuntimeProfileLimits) -> SemanticRecordLimits {
    SemanticRecordLimits(records: limits.maximumSemanticStructuralOccurrences, paths: limits.records.maximumPathEntries, depth: limits.records.maximumPathDepth, fanout: limits.records.maximumPathChildFanout, payloads: counterSemanticLimits.payloads, textScalars: counterSemanticLimits.textScalars, payloadBytes: limits.records.maximumPayloadBytesPerBank)!
}

// A report is a value, never RuntimeProfileStorage. Each typed physical region
// contributes to exactly one family, with complete identities partitioned out
// of Interaction records by counterMeasureInteraction.
struct CounterSemanticMeasurement {
    let limits: SemanticRecordLimits
    let records: CounterExtent
    let paths: CounterExtent
    let payloads: CounterExtent
    let scalars: CounterExtent
    let controlBytes: Int
}

func counterValidateBacking<G, C, R, H, GR: CounterStorageRegionSource>(profile: RuntimeProfileKind, limits: RuntimeProfileLimits,
    root: CounterRootLayout, rootMetadataRegion: CounterStorageRegion, semantic: CounterSemanticMeasurement, geometry: CounterGeometryMeasurement,
    interaction: borrowing InteractionOwnedKeyState<C, R, H>, geometryType: G.Type,
    canvasCount: Int, canvasCapacity: UInt16, canvasControlBytes: Int,
    factoryRegion: CounterStorageRegion,
    factoryDescriptorRegion: CounterStorageRegion? = nil,
    geometryRegions: borrowing GR,
    report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult
where G: CounterGeometry, C: CounterCandidateBacking, R: CounterCommittedBacking, H: CounterHitBacking,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    // The concrete scoped render adapter exports exactly the configured view;
    // inaccessible physical headroom remains measured in the backing regions.
    guard counterRenderWorkspaceCovers(geometry.renderWorkspace, limits.renderWorkspace) else { return .invalid(.insufficientStorage) }
    let keys = counterMeasureInteraction(interaction)
    let keyLimits = interaction.identityCapacities
    let semanticLimits = semantic.limits
    guard let recordBytes = semantic.records.bytes, let pathBytes = semantic.paths.bytes,
        let payloadBytes = semantic.payloads.bytes, let scalarBytes = semantic.scalars.bytes,
        let canvasBytes = CounterExtent.elements(CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?.self, count: canvasCount).bytes else { return .invalid(.arithmeticOverflow) }
    let interactionStores = MemoryLayout<C>.size + MemoryLayout<R>.size * 2 + MemoryLayout<H>.size * 2
    let interactionMetadata = MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - interactionStores
    let pending = MemoryLayout<InlineArray<2, NormalizedPointerEvent?>>.size + MemoryLayout<InlineArray<34, UInt8>>.size + MemoryLayout<UInt16>.size + MemoryLayout<UInt16?>.size
    let sealed = MemoryLayout<CounterAdmissionBacking>.size - pending
    let result = MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.size
    typealias Admission = CounterAdmission
    typealias Owner = CounterPipelineOwner<G, C, R, H>
    typealias Coordinator = StaticRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>
    var concreteCoordinatorBytes = MemoryLayout<Coordinator>.size
    #if !hasFeature(Embedded)
    if profile == .dynamic {
        concreteCoordinatorBytes = MemoryLayout<DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>>.size
    }
    #endif
    // Endpoint/sink metadata belongs to the backend owner, not profile storage.
    // Physical backend arrays in CounterControl remain fully charged below.
    let coordinator = concreteCoordinatorBytes - MemoryLayout<G>.size
        - MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<CounterEndpoint>.size
        + MemoryLayout<CounterControl>.size - Admission.pointerStateStorageBytes
        - MemoryLayout<CounterAdmissionBacking>.size - MemoryLayout<CounterPointerState>.size - result
        + Int(factoryRegion.chargedBytes) + Int(factoryDescriptorRegion?.chargedBytes ?? 0)
    // Bank zero occupies exactly the configured whole-element prefix. Bank one
    // owns the second configured slice plus any retained allocator tail; never
    // divide a typed element when Array capacity rounds to an odd count.
    let firstRecords = CounterExtent.elements(SemanticRuntimeRecord.self, count: Int(semanticLimits.records)).bytes!
    let firstPaths = CounterExtent.elements(SemanticPathEntry.self, count: Int(semanticLimits.paths)).bytes!
    let firstPayloads = CounterExtent.elements(CounterPayload?.self, count: Int(semanticLimits.payloads)).bytes!
    let firstScalars = CounterExtent.elements(UInt32.self, count: Int(semanticLimits.textScalars)).bytes!
    guard semantic.records.count >= Int(semanticLimits.records) * 2,
        semantic.paths.count >= Int(semanticLimits.paths) * 2,
        semantic.payloads.count >= Int(semanticLimits.payloads) * 2,
        semantic.scalars.count >= Int(semanticLimits.textScalars) * 2 else { return .invalid(.insufficientStorage) }
    let candidatePayload = firstPayloads + firstScalars
    let publishedPayload = payloadBytes - firstPayloads + scalarBytes - firstScalars
    let firstMatch = UInt64(semanticLimits.paths) * UInt64(MemoryLayout<UInt16>.size)
    let allMatch = UInt64(semantic.paths.count) * UInt64(MemoryLayout<UInt16>.size)
    let matchControl = 4 * MemoryLayout<UInt32>.size
    guard firstPaths >= firstMatch, pathBytes >= allMatch,
        semantic.controlBytes >= matchControl, coordinator >= 0,
        interactionMetadata >= 0 else { return .invalid(.invariantViolation) }
    let values: InlineArray<26, UInt64> = [firstPaths - firstMatch, pathBytes - firstPaths - (allMatch - firstMatch), candidatePayload, publishedPayload,
        allMatch + UInt64(matchControl), keys.candidateIdentityBytes, keys.committedIdentityBytes,
        UInt64(root.metadataBytes), UInt64(root.modelBytes), UInt64(root.pinBytes),
        firstRecords + UInt64(semantic.controlBytes - matchControl), recordBytes - firstRecords,
        geometry.layoutBytes, geometry.renderBytes, canvasBytes + UInt64(canvasControlBytes), geometry.pathBytes, geometry.planBytes,
        UInt64(root.liveBytes), UInt64(root.candidateBytes), keys.candidateBytes + UInt64(interactionMetadata), keys.committedBytes,
        UInt64(pending), UInt64(sealed), UInt64(Admission.pointerStateStorageBytes + MemoryLayout<CounterPointerState>.size), UInt64(coordinator), UInt64(result)]
    for index in 0..<values.count where UInt32(exactly: values[index]) == nil { return .invalid(.arithmeticOverflow) }
    var reported: InlineArray<26, UInt64> = .init(repeating: 0)
    var reportOverflow = false
    func record(_ region: CounterStorageRegion) {
        precondition((0..<26).contains(region.family))
        let sum = reported[region.family].addingReportingOverflow(region.chargedBytes)
        reportOverflow = reportOverflow || sum.overflow
        reported[region.family] = sum.partialValue
        report(region)
    }
    record(.elements(SemanticPathEntry.self, count: Int(semanticLimits.paths), family: 0, chargedBytes: values[0]))
    record(.elements(SemanticPathEntry.self, count: semantic.paths.count - Int(semanticLimits.paths), family: 1, chargedBytes: values[1]))
    record(.elements(CounterPayload?.self, count: Int(semanticLimits.payloads), family: 2))
    record(.elements(UInt32.self, count: Int(semanticLimits.textScalars), family: 2))
    record(.elements(CounterPayload?.self, count: semantic.payloads.count - Int(semanticLimits.payloads), family: 3))
    record(.elements(UInt32.self, count: semantic.scalars.count - Int(semanticLimits.textScalars), family: 3))
    // Repeated embedded fields, not a contiguous allocation or another bank.
    record(.elements(UInt16.self, count: semantic.paths.count, family: 4))
    record(.elements(UInt32.self, count: 4, family: 4))
    record(rootMetadataRegion)
    record(.elements(CounterOwnedModel?.self, count: Int(root.models), family: 8))
    record(.elements(Bool.self, count: Int(root.pins), family: 9))
    record(.elements(SemanticRuntimeRecord.self, count: Int(semanticLimits.records), family: 10))
    if profile == .static {
        record(.inline(CounterSemanticBacking.self, family: 10, chargedBytes: CounterSemanticBacking.paddingBytes, kind: .metadataPadding))
        record(.inline(StaticSemanticRecordStorage.self, family: 10, chargedBytes: MemoryLayout<StaticSemanticRecordStorage>.size - matchControl, kind: .partition))
    }
    #if !hasFeature(Embedded)
    if profile == .dynamic {
        record(.inline(UInt16.self, family: 7))
        record(.elements(Bool.self, count: 2, family: 7))
        record(.inline(DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>.self, family: 7))
        record(.inline(InlineArray<2, SemanticRecordBankMetadata>.self, family: 10, chargedBytes: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.size - matchControl, kind: .partition))
        record(.inline([SemanticRuntimeRecord].self, family: 10))
        record(.inline([SemanticPathEntry].self, family: 10))
        record(.inline([CounterPayload?].self, family: 10))
        record(.inline([UInt32].self, family: 10))
        record(.inline(SemanticRecordLimits.self, family: 10))
        record(.inline(SemanticRecordOwnerIdentity.self, family: 10))
        record(.inline(Bool.self, family: 10))
    }
    #endif
    record(.elements(SemanticRuntimeRecord.self, count: semantic.records.count - Int(semanticLimits.records), family: 11))
    geometryRegions.visitStorageRegions(record)
    record(.elements(CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?.self, count: canvasCount, family: 14))
    if profile == .static { record(.inline(StaticCanvasValueStorage.self, family: 14)) }
    #if !hasFeature(Embedded)
    if profile == .dynamic { record(.inline(DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>.self, family: 14)) }
    #endif
    record(.inline(ObservableStateRootStorage<SemanticCompleteIdentity>.self, family: 17, chargedBytes: root.liveBytes, kind: .partition))
    record(.inline(ObservableStateRootStorage<SemanticCompleteIdentity>.self, family: 18, chargedBytes: root.candidateBytes, kind: .partition))
    counterVisitInteraction(interaction, record)
    record(.elements(NormalizedPointerEvent?.self, count: 2, family: 21))
    record(.inline(InlineArray<34, UInt8>.self, family: 21))
    record(.inline(UInt16.self, family: 21))
    record(.inline(UInt16?.self, family: 21))
    record(.inline(CounterAdmissionBacking.self, family: 22, chargedBytes: sealed, kind: .partition))
    record(.inline(Admission.Controller?.self, family: 23, chargedBytes: Admission.pointerStateStorageBytes, kind: .partition))
    record(.inline(CounterPointerState.self, family: 23))
    let coordinatorFields = concreteCoordinatorBytes - MemoryLayout<G>.size - MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<CounterEndpoint>.size
    if profile == .static { record(.inline(Coordinator.self, family: 24, chargedBytes: coordinatorFields, kind: .metadataPadding)) }
    #if !hasFeature(Embedded)
    if profile == .dynamic { record(.inline(DynamicRuntimeExecutionCoordinator<CounterExecutionBinding, Admission, Owner>.self, family: 24, chargedBytes: coordinatorFields, kind: .metadataPadding)) }
    #endif
    // All outer controls, observations, optional controller metadata and padding
    // remain physically live and are charged here exactly once.
    record(.inline(CounterControl.self, family: 24, chargedBytes: MemoryLayout<CounterControl>.size - Admission.pointerStateStorageBytes - MemoryLayout<CounterAdmissionBacking>.size - MemoryLayout<CounterPointerState>.size - result, kind: .metadataPadding))
    record(factoryRegion)
    if let factoryDescriptorRegion { record(factoryDescriptorRegion) }
    record(.inline(RuntimeCompletePipelineResult<RuntimeOwnerFailure>?.self, family: 25))
    guard !reportOverflow else { return .invalid(.arithmeticOverflow) }
    for index in 0..<26 { precondition(reported[index] == values[index], "physical region audit mismatch") }
    let bytes = RuntimeStorageByteCounts(semanticCandidatePathBytes: UInt32(values[0]), semanticPublishedPathBytes: UInt32(values[1]), semanticCandidatePayloadBytes: UInt32(values[2]), semanticPublishedPayloadBytes: UInt32(values[3]), identityMatchWorkspaceBytes: UInt32(values[4]), interactionCandidateIdentityBytes: UInt32(values[5]), interactionCommittedIdentityBytes: UInt32(values[6]), modelMetadataBytes: UInt32(values[7]), modelOwnerBytes: UInt32(values[8]), framePinBytes: UInt32(values[9]), semanticCandidateBytes: UInt32(values[10]), semanticPublishedBytes: UInt32(values[11]), layoutCandidateBytes: UInt32(values[12]), renderWorkspaceBytes: UInt32(values[13]), canvasCallableBytes: UInt32(values[14]), pathWorkspaceBytes: UInt32(values[15]), drawingPlanBytes: UInt32(values[16]), observableLiveBytes: UInt32(values[17]), observableCandidateBytes: UInt32(values[18]), interactionCandidateBytes: UInt32(values[19]), interactionCommittedBytes: UInt32(values[20]), admissionQueueBytes: UInt32(values[21]), sealedBatchBytes: UInt32(values[22]), pointerStateBytes: UInt32(values[23]), coordinatorStateBytes: UInt32(values[24]), failureStateBytes: UInt32(values[25]))
    let records = RuntimeRecordLimits(maximumPathEntries: semanticLimits.paths, maximumPathDepth: semanticLimits.depth, maximumPathChildFanout: semanticLimits.fanout, maximumPayloadBytesPerBank: semanticLimits.payloadBytes, maximumIdentityComponentsPerKey: keyLimits.perKey, maximumInteractionIdentityComponents: keyLimits.perBank)
    let inputs = RuntimeProfileLimitInputs(records: limits.records, models: limits.models, semantic: limits.semantic, maximumSemanticStructuralOccurrences: limits.maximumSemanticStructuralOccurrences, layout: limits.layout, render: limits.render, renderWorkspace: limits.renderWorkspace, renderSink: limits.renderSink, maximumOrdinaryRenderOperations: limits.maximumOrdinaryRenderOperations, execution: limits.execution, observableState: limits.observableState, interaction: limits.interaction, drawing: limits.drawing, staticCanvas: limits.staticCanvas, profile: profile)
    let rootCapacity = ObservableStateRootStorage<SemanticCompleteIdentity>.storageCapacities
    let capacities = RuntimeStorageCapacities(candidateRecords: records, publishedRecords: records,
        models: .init(maximumModelSlots: root.models, maximumOwningTickets: root.claims, maximumFramePins: root.pins, maximumModelCaptureBanks: root.captures),
        semanticCandidate: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticPublished: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticCandidateStructuralOccurrences: semanticLimits.records, semanticPublishedStructuralOccurrences: semanticLimits.records,
        layoutCandidate: geometry.layout, render: geometry.render, renderWorkspace: limits.renderWorkspace,
        canvasCallableOccurrences: canvasCapacity, staticCanvasCaptureBytes: UInt16(MemoryLayout<CounterValueTable.CaptureStorage>.stride),
        pathPoints: geometry.drawing.maximumLivePathPoints, pathSubpaths: geometry.drawing.maximumLivePathSubpaths,
        drawingPlanStrokes: geometry.drawing.maximumPlanStrokes, drawingPlanPoints: geometry.drawing.maximumPlanPoints, drawingPlanSubpaths: geometry.drawing.maximumPlanSubpaths, normalizedStrokeOperations: geometry.drawing.maximumNormalizedStrokeOperations,
        observableLiveLocations: rootCapacity.locations, observableLiveRegistrations: rootCapacity.registrations, observableCandidateAssociations: rootCapacity.associations,
        interactionCandidateActions: keys.candidateRecords, interactionCandidateHitRegions: keys.candidateHits, interactionCommittedActions: keys.committedRecords, interactionCommittedHitRegions: keys.committedHits,
        admissionQueue: counterExecutionLimits, sealedBatch: counterExecutionLimits, pointerStates: 1,
        coordinatorStatePresent: concreteCoordinatorBytes > 0, failureStatePresent: result > 0, byteCounts: bytes)
    if profile == .static { return RuntimeProfileValidator.validateStatic(inputs: inputs, capacities: capacities, metadata: CounterCanvasAudit()) }
    return RuntimeProfileValidator.validateDynamic(inputs: inputs, capacities: capacities)
}

#if !hasFeature(Embedded)
typealias CounterDynamicCandidate = DynamicInteractionCandidateStorage<SemanticCompleteIdentity>
typealias CounterDynamicCommitted = DynamicInteractionCommittedStorage<SemanticCompleteIdentity>
typealias CounterDynamicHits = DynamicInteractionHitStorage<SemanticCompleteIdentity>
typealias CounterDynamicKeys = InteractionOwnedKeyState<CounterDynamicCandidate, CounterDynamicCommitted, CounterDynamicHits>
struct DynamicCounterProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .dynamic }
    let limits: RuntimeProfileLimits
    var root: DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>
    var semantic: DynamicSemanticRecordStorage<CounterPayload>
    var canvas = DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>(capacity: 1)
    var geometry: DynamicCounterGeometry? = DynamicCounterGeometry()
    var interaction: CounterDynamicKeys?
    var control = CounterControl()
    var used = false
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity, limits: RuntimeProfileLimits = counterActualLimits(.dynamic)) {
        self.limits = limits
        root = DynamicObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!
        semantic = DynamicSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
        interaction = CounterDynamicKeys(state: InteractionState(candidateRecords: CounterDynamicCandidate(capacity: 2), candidateHitRegions: CounterDynamicHits(capacity: 2), candidateCommittedRecords: CounterDynamicCommitted(capacity: 2), committedRecords: CounterDynamicCommitted(capacity: 2), committedHitRegions: CounterDynamicHits(capacity: 2)), maximumComponentsPerKey: 24, maximumComponents: 48)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let geometry, let interaction else { return .invalid(.missingStorage) }
        let extent = semantic.retainedExtents
        return counterValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(ObservableModelOwnership.self, family: 7, chargedBytes: root.storageLayout.metadataBytes - MemoryLayout<UInt16>.size - 2 * MemoryLayout<Bool>.size - MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.size, kind: .partition),
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: extent.records), paths: .elements(SemanticPathEntry.self, count: extent.paths), payloads: .elements(CounterPayload?.self, count: extent.payloads), scalars: .elements(UInt32.self, count: extent.scalars), controlBytes: extent.controlBytes),
            geometry: geometry.storageMeasurement(), interaction: interaction, geometryType: DynamicCounterGeometry.self,
            canvasCount: canvas.retainedElementCapacity, canvasCapacity: canvas.capacity,
            canvasControlBytes: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size,
            factoryRegion: .inline(Self.self, family: 24, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size - MemoryLayout<DynamicCounterGeometry>.size - MemoryLayout<CounterDynamicKeys>.size - MemoryLayout<CounterControl>.size, kind: .metadataPadding),
            geometryRegions: geometry, report: report)
    }
    mutating func resetAttemptStorage() {
        precondition(geometry != nil && interaction != nil)
        geometry!.reset()
        interaction!.resolveCandidate(.discard)
        control.admission.finishAttempt()
    }
    mutating func resetAllStorage() {
        precondition(!used || control.unavailable)
        resetAttemptStorage()
        interaction!.resetAllStorage()
        control.admission.resetAll()
    }

    mutating func run() -> Int {
        guard !used, case .valid(let audited) = audit() else { return 0 }
        used = true
        precondition(interaction!.configureIdentityLimits(perKey: limits.records.maximumIdentityComponentsPerKey, perBank: limits.records.maximumInteractionIdentityComponents))
        var movedGeometry = geometry.take()
        var movedInteraction = interaction.take()
        var returned: CounterReturnedWorkspaces<DynamicCounterGeometry, CounterDynamicCandidate, CounterDynamicCommitted, CounterDynamicHits>?
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits)) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            try canvas.withLifetime(table: CounterValueTable(), limits: limits.staticCanvas ?? counterCanvasLimits, configuredCapacity: limits.drawing.maximumCanvasOccurrences) { values in
                                returned = exerciseCounterCoordinator(models: models, root: root, semantic: semantic, values: values, dynamic: true, geometry: movedGeometry.take()!, interaction: movedInteraction.take()!, audit: audited, control: &control)
                            }
                        } catch { preconditionFailure("factory Canvas") }
                    }
                } catch { preconditionFailure("factory semantic") }
            }
        } catch { preconditionFailure("factory model") }
        let workspaces = returned.take()!
        let checks = workspaces.checks
        geometry = workspaces.geometry; interaction = workspaces.interaction
        precondition(audit() == .valid(audited))
        resetAllStorage()
        precondition(audit() == .valid(audited))
        return checks + 6
    }
}
#endif

struct StaticCounterProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .static }
    let limits: RuntimeProfileLimits
    var root: StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>
    var semantic: StaticSemanticRecordStorage
    var semanticBacking = CounterSemanticBacking()
    var canvas = StaticCanvasValueStorage()
    var canvasBacking: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?> = .init(repeating: nil)
    var workspace = CounterStaticWorkspaceBacking()
    var interaction: CounterStaticKeys?
    var control = CounterControl()
    var used = false
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity, limits: RuntimeProfileLimits = counterActualLimits(.static)) {
        self.limits = limits
        root = StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!
        semantic = StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
        interaction = CounterStaticKeys(state: InteractionState(candidateRecords: CounterStaticCandidate(capacity: 2)!, candidateHitRegions: CounterStaticHits(capacity: 2)!, candidateCommittedRecords: CounterStaticCommitted(capacity: 2)!, committedRecords: CounterStaticCommitted(capacity: 2)!, committedHitRegions: CounterStaticHits(capacity: 2)!), maximumComponentsPerKey: 24, maximumComponents: 48)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CounterStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let interaction else { return .invalid(.missingStorage) }
        return counterValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, family: 7, chargedBytes: root.storageLayout.metadataBytes, kind: .metadataPadding),
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: semanticBacking.records.count), paths: .elements(SemanticPathEntry.self, count: semanticBacking.paths.count), payloads: .elements(CounterPayload?.self, count: semanticBacking.payloads.count), scalars: .elements(UInt32.self, count: semanticBacking.scalars.count), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size + CounterSemanticBacking.paddingBytes),
            geometry: workspace.measurement, interaction: interaction, geometryType: StaticCounterGeometry.self,
            canvasCount: canvasBacking.count, canvasCapacity: UInt16(canvasBacking.count),
            canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size,
            factoryRegion: .inline(Self.self, family: 24, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>.size - MemoryLayout<StaticSemanticRecordStorage>.size - MemoryLayout<CounterSemanticBacking>.size - MemoryLayout<StaticCanvasValueStorage>.size - MemoryLayout<InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>>.size - MemoryLayout<CounterStaticWorkspaceBacking>.size - MemoryLayout<CounterStaticKeys>.size - MemoryLayout<CounterControl>.size, kind: .metadataPadding),
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

    mutating func run() -> Int {
        guard !used, case .valid(let audited) = audit() else { return 0 }
        used = true
        precondition(interaction!.configureIdentityLimits(perKey: limits.records.maximumIdentityComponentsPerKey, perBank: limits.records.maximumInteractionIdentityComponents))
        var movedInteraction = interaction.take()
        var checks = 0
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var records = semanticBacking.records.mutableSpan
                    var paths = semanticBacking.paths.mutableSpan
                    var payloads = semanticBacking.payloads.mutableSpan
                    var scalars = semanticBacking.scalars.mutableSpan
                    try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            var entries = canvasBacking.mutableSpan
                            try canvas.withLifetime(entries: &entries, table: CounterValueTable(), capacity: limits.drawing.maximumCanvasOccurrences, limits: limits.staticCanvas ?? counterCanvasLimits) { values in
                                checks = workspace.withGeometry { geometry in
                                    let measured = geometry.storageMeasurement()
                                    var returned = exerciseCounterCoordinator(models: models, root: root, semantic: semantic, values: values, dynamic: false, geometry: geometry, interaction: movedInteraction.take()!, audit: audited, control: &control)
                                    precondition(returned.geometry.storageMeasurement() == measured)
                                    // The returned raw descriptors are consumed here, while all
                                    // four physical arrays are still borrowed and immovable.
                                    returned.geometry.reset()
                                    movedInteraction = returned.interaction
                                    return returned.checks + 1
                                }
                            }
                        } catch { preconditionFailure("factory Canvas") }
                    }
                } catch { preconditionFailure("factory semantic") }
            }
        } catch { preconditionFailure("factory model") }
        interaction = movedInteraction.take()
        precondition(audit() == .valid(audited))
        resetAllStorage()
        precondition(audit() == .valid(audited))
        return checks + 6
    }
}

