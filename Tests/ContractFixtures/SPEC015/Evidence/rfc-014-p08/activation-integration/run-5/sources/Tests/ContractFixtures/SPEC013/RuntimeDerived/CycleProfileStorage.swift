import CycleTable
import CycleSchema
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
import P07TargetWorkspace
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

// These are the actual typed owners, not an audited allocation recipe. An
// activation moves owned workspaces into the scoped pipeline and restores them
// only after the consuming coordinator has quiesced and ended all its borrows.
typealias CycleStaticCandidate = StaticSixInteractionCandidateStorage<SemanticCompleteIdentity>
typealias CycleStaticCommitted = StaticSixInteractionCommittedStorage<SemanticCompleteIdentity>
typealias CycleStaticHits = StaticSixInteractionHitStorage<SemanticCompleteIdentity>
typealias CycleStaticKeys = InteractionOwnedKeyState<CycleStaticCandidate, CycleStaticCommitted, CycleStaticHits>
typealias CycleRootLayout = (owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16, captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int, liveBytes: Int, candidateBytes: Int)
let cycleSemanticLimits = SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: UInt32(98 * MemoryLayout<CyclePayload?>.stride + 224 * 4))!
let cycleCanvasLimits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: UInt16(MemoryLayout<CycleValueTable.CaptureStorage>.stride))!
let cycleExecutionLimits = ExecutionLimits(maximumInputEvents: 2, maximumStateChangeFacts: 1, maximumCompletionFacts: 0, maximumSemanticActions: 1, maximumActiveInputSources: 1, maximumCommittedActions: 6)!

struct CycleSemanticBacking: ~Copyable {
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, CyclePayload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
    static var paddingBytes: Int {
        let fields = MemoryLayout<InlineArray<252, SemanticRuntimeRecord>>.size + MemoryLayout<InlineArray<756, SemanticPathEntry>>.size + MemoryLayout<InlineArray<196, CyclePayload?>>.size + MemoryLayout<InlineArray<448, UInt32>>.size
        precondition(MemoryLayout<Self>.size >= fields)
        return MemoryLayout<Self>.size - fields
    }
}

struct CycleStaticWorkspaceBacking {
    var scopes: InlineArray<3136, UInt8> = .init(repeating: 0)
    var text: InlineArray<4704, UInt8> = .init(repeating: 0)
    var path: InlineArray<3280, UInt8> = .init(repeating: 0)
    var plan: InlineArray<13536, UInt8> = .init(repeating: 0)
    var measurement: CycleGeometryMeasurement {
        .init(layout: cycleLayoutLimits, render: cycleRenderLimits, renderWorkspace: cycleRenderCapacity, drawing: cycleDrawingLimits,
            layoutBytes: UInt64(scopes.count + text.count + MemoryLayout<StaticCycleGeometry>.size - MemoryLayout<QualifiedRender>.size - MemoryLayout<StaticRecordDrawingWorkspace<StaticSignalAnalyzerNRFDrawingWorkspace>>.size),
            renderBytes: UInt64(MemoryLayout<QualifiedRender>.size), pathBytes: UInt64(path.count),
            planBytes: UInt64(plan.count + MemoryLayout<StaticRecordDrawingWorkspace<StaticSignalAnalyzerNRFDrawingWorkspace>>.size))
    }
    mutating func withGeometry(_ body: (consuming StaticCycleGeometry) -> Int) -> Int {
        withUnsafeMutableBytes(of: &scopes) { s in
            withUnsafeMutableBytes(of: &text) { t in
                withUnsafeMutableBytes(of: &path) { p in
                    withUnsafeMutableBytes(of: &plan) { d in
                        body(StaticCycleGeometry(scopes: s, text: t, path: p, plan: d))
                    }
                }
            }
        }
    }
}

struct CycleCanvasAudit: RuntimeStaticCanvasAuditMetadata {
    let table = CycleValueTable()
    var callableCaseCount: UInt16 { table.callableCaseCount }
    var declaredEntryCount: UInt16 { table.callableCaseCount }
    var maximumDeclaredID: UInt16 { table.callableCaseCount }
    func coverageMultiplicity(for id: UInt16) -> UInt8 { table.captureByteCount(for: id) == nil ? 0 : 1 }
    func captureByteCount(for id: UInt16) -> UInt16? { table.captureByteCount(for: id) }
}

func cycleProfileLimits(_ profile: RuntimeProfileKind, paths: UInt16 = 378, structural: UInt16 = 126,
    models: UInt16 = 2, tickets: UInt16 = 4, pins: UInt16 = 2,
    canvas: UInt16 = 5, pathPoints: UInt16 = 202, planPoints: UInt16 = 832,
    actions: UInt16 = 6, inputs: UInt16 = 2, stateFacts: UInt16 = 1) -> RuntimeProfileLimits {
    RuntimeProfileLimits(records: .init(maximumPathEntries: paths, maximumPathDepth: 34, maximumPathChildFanout: 5, maximumPayloadBytesPerBank: cycleSemanticLimits.payloadBytes, maximumIdentityComponentsPerKey: 34, maximumInteractionIdentityComponents: 204),
        models: .init(maximumModelSlots: models, maximumOwningTickets: tickets, maximumFramePins: pins, maximumModelCaptureBanks: 0),
        semantic: .init(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!, maximumSemanticStructuralOccurrences: structural,
        layout: cycleLayoutLimits, render: cycleRenderLimits, renderWorkspace: cycleRenderCapacity,
        renderSink: CycleRenderSink().capacity, maximumOrdinaryRenderOperations: 123, execution: .init(maximumInputEvents: inputs, maximumStateChangeFacts: stateFacts, maximumCompletionFacts: 0, maximumSemanticActions: 1, maximumActiveInputSources: 1, maximumCommittedActions: actions)! ,
        observableState: .init(maximumLocations: 2, maximumRegistrations: 2, maximumStagedAssociations: 2)!, interaction: .init(maximumActions: actions, maximumHitRegions: min(actions, 6))!, drawing: .init(maximumLineWidth: 4, maximumCanvasOccurrences: canvas, maximumLivePathPoints: pathPoints, maximumLivePathSubpaths: 12, maximumPlanStrokes: 5, maximumPlanPoints: planPoints, maximumPlanSubpaths: 16, maximumNormalizedStrokeOperations: 5)!,
        staticCanvas: profile == .static ? cycleCanvasLimits : nil, profile: profile)!
}

func cycleSemanticConfiguration(_ limits: RuntimeProfileLimits) -> SemanticRecordLimits {
    SemanticRecordLimits(records: limits.maximumSemanticStructuralOccurrences, paths: limits.records.maximumPathEntries, depth: limits.records.maximumPathDepth, fanout: limits.records.maximumPathChildFanout, payloads: cycleSemanticLimits.payloads, textScalars: cycleSemanticLimits.textScalars, payloadBytes: limits.records.maximumPayloadBytesPerBank)!
}

// A report is a value, never RuntimeProfileStorage. Each typed physical region
// contributes to exactly one family, with complete identities partitioned out
// of Interaction records by cycleMeasureInteraction.
struct CycleSemanticMeasurement {
    let limits: SemanticRecordLimits
    let records: CycleExtent
    let paths: CycleExtent
    let payloads: CycleExtent
    let scalars: CycleExtent
    let controlBytes: Int
}

func cycleValidateBacking<G, C, R, H, GR: CycleStorageRegionSource>(profile: RuntimeProfileKind, limits: RuntimeProfileLimits,
    root: CycleRootLayout, rootMetadataRegion: CycleStorageRegion, semantic: CycleSemanticMeasurement, geometry: CycleGeometryMeasurement,
    interaction: borrowing InteractionOwnedKeyState<C, R, H>, geometryType: G.Type,
    canvasCount: Int, canvasCapacity: UInt16, canvasControlBytes: Int,
    factoryRegion: CycleStorageRegion,
    geometryRegions: borrowing GR,
    report: (CycleStorageRegion) -> Void) -> RuntimeProfileValidationResult
where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    // The concrete scoped render adapter exports exactly the configured view;
    // inaccessible physical headroom remains measured in the backing regions.
    guard cycleRenderWorkspaceCovers(geometry.renderWorkspace, limits.renderWorkspace) else { return .invalid(.insufficientStorage) }
    let keys = cycleMeasureInteraction(interaction)
    let keyLimits = interaction.identityCapacities
    let semanticLimits = semantic.limits
    guard let recordBytes = semantic.records.bytes, let pathBytes = semantic.paths.bytes,
        let payloadBytes = semantic.payloads.bytes, let scalarBytes = semantic.scalars.bytes,
        let canvasBytes = CycleExtent.elements(CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?.self, count: canvasCount).bytes else { return .invalid(.arithmeticOverflow) }
    let interactionStores = MemoryLayout<C>.size + MemoryLayout<R>.size * 2 + MemoryLayout<H>.size * 2
    let interactionMetadata = MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - interactionStores
    let pending = MemoryLayout<InlineArray<2, NormalizedPointerEvent?>>.size + MemoryLayout<UInt8?>.size
    let sealed = MemoryLayout<CycleAdmissionBacking>.size - pending
    let result = MemoryLayout<RuntimeCompletePipelineResult<RuntimeOwnerFailure>?>.size
    typealias Admission = CycleAdmission
    typealias Owner = CyclePipelineOwner<G, C, R, H>
    typealias Coordinator = StaticRuntimeExecutionCoordinator<CycleExecutionBinding, Admission, Owner>
    var concreteCoordinatorBytes = MemoryLayout<Coordinator>.size
    #if !hasFeature(Embedded)
    if profile == .dynamic {
        concreteCoordinatorBytes = MemoryLayout<DynamicRuntimeExecutionCoordinator<CycleExecutionBinding, Admission, Owner>>.size
    }
    #endif
    // Endpoint and sink belong to the recording adapter, not profile storage.
    let coordinator = concreteCoordinatorBytes - MemoryLayout<G>.size
        - MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<CycleEndpoint>.size
        - Admission.pointerStateStorageBytes
        + MemoryLayout<CycleRuntimeControl>.size - MemoryLayout<CycleAdmissionBacking>.size - MemoryLayout<CyclePointerState>.size - result
        + Int(factoryRegion.chargedBytes)
    // Bank zero occupies exactly the configured whole-element prefix. Bank one
    // owns the second configured slice plus any retained allocator tail; never
    // divide a typed element when Array capacity rounds to an odd count.
    let firstRecords = CycleExtent.elements(SemanticRuntimeRecord.self, count: Int(semanticLimits.records)).bytes!
    let firstPaths = CycleExtent.elements(SemanticPathEntry.self, count: Int(semanticLimits.paths)).bytes!
    let firstPayloads = CycleExtent.elements(CyclePayload?.self, count: Int(semanticLimits.payloads)).bytes!
    let firstScalars = CycleExtent.elements(UInt32.self, count: Int(semanticLimits.textScalars)).bytes!
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
        UInt64(pending), UInt64(sealed), UInt64(Admission.pointerStateStorageBytes + MemoryLayout<CyclePointerState>.size), UInt64(coordinator), UInt64(result)]
    for index in 0..<values.count where UInt32(exactly: values[index]) == nil { return .invalid(.arithmeticOverflow) }
    var reported: InlineArray<26, UInt64> = .init(repeating: 0)
    var reportOverflow = false
    func record(_ region: CycleStorageRegion) {
        precondition((0..<26).contains(region.family))
        let sum = reported[region.family].addingReportingOverflow(region.chargedBytes)
        reportOverflow = reportOverflow || sum.overflow
        reported[region.family] = sum.partialValue
        report(region)
    }
    record(.elements(SemanticPathEntry.self, count: Int(semanticLimits.paths), family: 0, chargedBytes: values[0]))
    record(.elements(SemanticPathEntry.self, count: semantic.paths.count - Int(semanticLimits.paths), family: 1, chargedBytes: values[1]))
    record(.elements(CyclePayload?.self, count: Int(semanticLimits.payloads), family: 2))
    record(.elements(UInt32.self, count: Int(semanticLimits.textScalars), family: 2))
    record(.elements(CyclePayload?.self, count: semantic.payloads.count - Int(semanticLimits.payloads), family: 3))
    record(.elements(UInt32.self, count: semantic.scalars.count - Int(semanticLimits.textScalars), family: 3))
    // Repeated embedded fields, not a contiguous allocation or another bank.
    record(.elements(UInt16.self, count: semantic.paths.count, family: 4))
    record(.elements(UInt32.self, count: 4, family: 4))
    record(rootMetadataRegion)
    record(.elements(CycleOwnedModel?.self, count: Int(root.models), family: 8))
    record(.elements(Bool.self, count: Int(root.pins), family: 9))
    record(.elements(SemanticRuntimeRecord.self, count: Int(semanticLimits.records), family: 10))
    if profile == .static {
        record(.inline(CycleSemanticBacking.self, family: 10, chargedBytes: CycleSemanticBacking.paddingBytes, kind: .metadataPadding))
        record(.inline(StaticSemanticRecordStorage.self, family: 10, chargedBytes: MemoryLayout<StaticSemanticRecordStorage>.size - matchControl, kind: .partition))
    }
    #if !hasFeature(Embedded)
    if profile == .dynamic {
        record(.inline(UInt16.self, family: 7))
        record(.elements(Bool.self, count: 2, family: 7))
        record(.inline(DynamicObservableModelStorage<CycleOwnedModel, CycleModelSchema>.self, family: 7))
        record(.inline(InlineArray<2, SemanticRecordBankMetadata>.self, family: 10, chargedBytes: MemoryLayout<InlineArray<2, SemanticRecordBankMetadata>>.size - matchControl, kind: .partition))
        record(.inline([SemanticRuntimeRecord].self, family: 10))
        record(.inline([SemanticPathEntry].self, family: 10))
        record(.inline([CyclePayload?].self, family: 10))
        record(.inline([UInt32].self, family: 10))
        record(.inline(SemanticRecordLimits.self, family: 10))
        record(.inline(SemanticRecordOwnerIdentity.self, family: 10))
        record(.inline(Bool.self, family: 10))
    }
    #endif
    record(.elements(SemanticRuntimeRecord.self, count: semantic.records.count - Int(semanticLimits.records), family: 11))
    geometryRegions.visitStorageRegions(record)
    record(.elements(CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?.self, count: canvasCount, family: 14))
    if profile == .static { record(.inline(StaticCanvasValueStorage.self, family: 14)) }
    #if !hasFeature(Embedded)
    if profile == .dynamic { record(.inline(DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>.self, family: 14)) }
    #endif
    record(.inline(ObservableStateRootStorage<SemanticCompleteIdentity>.self, family: 17, chargedBytes: root.liveBytes, kind: .partition))
    record(.inline(ObservableStateRootStorage<SemanticCompleteIdentity>.self, family: 18, chargedBytes: root.candidateBytes, kind: .partition))
    cycleVisitInteraction(interaction, record)
    record(.elements(NormalizedPointerEvent?.self, count: 2, family: 21))
    record(.inline(UInt8?.self, family: 21))
    record(.inline(CycleAdmissionBacking.self, family: 22, chargedBytes: sealed, kind: .partition))
    record(.inline(Admission.self, family: 23, chargedBytes: Admission.pointerStateStorageBytes, kind: .partition))
    record(.inline(CyclePointerState.self, family: 23))
    let coordinatorFields = concreteCoordinatorBytes - MemoryLayout<G>.size - MemoryLayout<InteractionOwnedKeyState<C, R, H>>.size - MemoryLayout<CycleEndpoint>.size - Admission.pointerStateStorageBytes
    if profile == .static { record(.inline(Coordinator.self, family: 24, chargedBytes: coordinatorFields, kind: .metadataPadding)) }
    #if !hasFeature(Embedded)
    if profile == .dynamic { record(.inline(DynamicRuntimeExecutionCoordinator<CycleExecutionBinding, Admission, Owner>.self, family: 24, chargedBytes: coordinatorFields, kind: .metadataPadding)) }
    #endif
    record(.inline(CycleRuntimeControl.self, family: 24, chargedBytes: MemoryLayout<CycleRuntimeControl>.size - MemoryLayout<CycleAdmissionBacking>.size - MemoryLayout<CyclePointerState>.size - result, kind: .metadataPadding))
    record(factoryRegion)
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
        canvasCallableOccurrences: canvasCapacity, staticCanvasCaptureBytes: UInt16(MemoryLayout<CycleValueTable.CaptureStorage>.stride),
        pathPoints: geometry.drawing.maximumLivePathPoints, pathSubpaths: geometry.drawing.maximumLivePathSubpaths,
        drawingPlanStrokes: geometry.drawing.maximumPlanStrokes, drawingPlanPoints: geometry.drawing.maximumPlanPoints, drawingPlanSubpaths: geometry.drawing.maximumPlanSubpaths, normalizedStrokeOperations: geometry.drawing.maximumNormalizedStrokeOperations,
        observableLiveLocations: rootCapacity.locations, observableLiveRegistrations: rootCapacity.registrations, observableCandidateAssociations: rootCapacity.associations,
        interactionCandidateActions: keys.candidateRecords, interactionCandidateHitRegions: keys.candidateHits, interactionCommittedActions: keys.committedRecords, interactionCommittedHitRegions: keys.committedHits,
        admissionQueue: cycleExecutionLimits, sealedBatch: cycleExecutionLimits, pointerStates: 1,
        coordinatorStatePresent: concreteCoordinatorBytes > 0, failureStatePresent: result > 0, byteCounts: bytes)
    if profile == .static { return RuntimeProfileValidator.validateStatic(inputs: inputs, capacities: capacities, metadata: CycleCanvasAudit()) }
    return RuntimeProfileValidator.validateDynamic(inputs: inputs, capacities: capacities)
}

#if !hasFeature(Embedded)
typealias CycleDynamicCandidate = DynamicInteractionCandidateStorage<SemanticCompleteIdentity>
typealias CycleDynamicCommitted = DynamicInteractionCommittedStorage<SemanticCompleteIdentity>
typealias CycleDynamicHits = DynamicInteractionHitStorage<SemanticCompleteIdentity>
typealias CycleDynamicKeys = InteractionOwnedKeyState<CycleDynamicCandidate, CycleDynamicCommitted, CycleDynamicHits>
struct DynamicCycleProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .dynamic }
    let limits: RuntimeProfileLimits
    var root: DynamicObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>
    var semantic: DynamicSemanticRecordStorage<CyclePayload>
    var canvas = DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>(capacity: 5)
    var geometry: DynamicCycleGeometry? = DynamicCycleGeometry()
    var interaction: CycleDynamicKeys?
    var control = CycleControl()
    var used = false
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity, limits: RuntimeProfileLimits = cycleProfileLimits(.dynamic)) {
        self.limits = limits
        root = DynamicObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!
        semantic = DynamicSemanticRecordStorage(limits: cycleSemanticLimits, owner: semanticOwner)
        interaction = CycleDynamicKeys(state: InteractionState(candidateRecords: CycleDynamicCandidate(capacity: 6), candidateHitRegions: CycleDynamicHits(capacity: 6), candidateCommittedRecords: CycleDynamicCommitted(capacity: 6), committedRecords: CycleDynamicCommitted(capacity: 6), committedHitRegions: CycleDynamicHits(capacity: 6)), maximumComponentsPerKey: 34, maximumComponents: 204)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CycleStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let geometry, let interaction else { return .invalid(.missingStorage) }
        let extent = semantic.retainedExtents
        return cycleValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(ObservableModelOwnership.self, family: 7, chargedBytes: root.storageLayout.metadataBytes - MemoryLayout<UInt16>.size - 2 * MemoryLayout<Bool>.size - MemoryLayout<DynamicObservableModelStorage<CycleOwnedModel, CycleModelSchema>>.size, kind: .partition),
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: extent.records), paths: .elements(SemanticPathEntry.self, count: extent.paths), payloads: .elements(CyclePayload?.self, count: extent.payloads), scalars: .elements(UInt32.self, count: extent.scalars), controlBytes: extent.controlBytes),
            geometry: geometry.storageMeasurement(), interaction: interaction, geometryType: DynamicCycleGeometry.self,
            canvasCount: canvas.retainedElementCapacity, canvasCapacity: canvas.capacity,
            canvasControlBytes: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>>.size,
            factoryRegion: .inline(Self.self, family: 24, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>>.size - MemoryLayout<DynamicCycleGeometry>.size - MemoryLayout<CycleDynamicKeys>.size - MemoryLayout<CycleControl>.size, kind: .metadataPadding),
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
        var returned: CycleReturnedWorkspaces<DynamicCycleGeometry, CycleDynamicCandidate, CycleDynamicCommitted, CycleDynamicHits>?
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                cycleRejectForeignBinding(models: models, root: root, audit: audited, control: &control)
                do throws(SemanticExpansionError) {
                    try semantic.withLifetime(configuredLimits: cycleSemanticConfiguration(limits)) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            try canvas.withLifetime(table: CycleValueTable(), limits: limits.staticCanvas ?? cycleCanvasLimits, configuredCapacity: limits.drawing.maximumCanvasOccurrences) { values in
                                returned = exercisePipeline(models: models, root: root, semantic: semantic, values: values, dynamic: true, geometry: movedGeometry.take()!, interaction: movedInteraction.take()!, audit: audited, control: &control)
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

struct StaticCycleProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = SemanticCompleteIdentity
    static var profile: RuntimeProfileKind { .static }
    let limits: RuntimeProfileLimits
    var root: StaticObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>
    var semantic: StaticSemanticRecordStorage
    var semanticBacking = CycleSemanticBacking()
    var canvas = StaticCanvasValueStorage()
    var canvasBacking: InlineArray<5, CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?> = .init(repeating: nil)
    var workspace = CycleStaticWorkspaceBacking()
    var interaction: CycleStaticKeys?
    var control = CycleControl()
    var used = false
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity, limits: RuntimeProfileLimits = cycleProfileLimits(.static)) {
        self.limits = limits
        root = StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!
        semantic = StaticSemanticRecordStorage(limits: cycleSemanticLimits, owner: semanticOwner)
        interaction = CycleStaticKeys(state: InteractionState(candidateRecords: CycleStaticCandidate(capacity: 6)!, candidateHitRegions: CycleStaticHits(capacity: 6)!, candidateCommittedRecords: CycleStaticCommitted(capacity: 6)!, committedRecords: CycleStaticCommitted(capacity: 6)!, committedHitRegions: CycleStaticHits(capacity: 6)!), maximumComponentsPerKey: 34, maximumComponents: 204)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult { audit(report: { _ in }) }
    borrowing func audit(report: (CycleStorageRegion) -> Void) -> RuntimeProfileValidationResult {
        guard let interaction else { return .invalid(.missingStorage) }
        return cycleValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout, rootMetadataRegion: .inline(StaticObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>.self, family: 7, chargedBytes: root.storageLayout.metadataBytes, kind: .metadataPadding),
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: semanticBacking.records.count), paths: .elements(SemanticPathEntry.self, count: semanticBacking.paths.count), payloads: .elements(CyclePayload?.self, count: semanticBacking.payloads.count), scalars: .elements(UInt32.self, count: semanticBacking.scalars.count), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size + CycleSemanticBacking.paddingBytes),
            geometry: workspace.measurement, interaction: interaction, geometryType: StaticCycleGeometry.self,
            canvasCount: canvasBacking.count, canvasCapacity: UInt16(canvasBacking.count),
            canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size,
            factoryRegion: .inline(Self.self, family: 24, chargedBytes: MemoryLayout<Self>.size - MemoryLayout<StaticObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>>.size - MemoryLayout<StaticSemanticRecordStorage>.size - MemoryLayout<CycleSemanticBacking>.size - MemoryLayout<StaticCanvasValueStorage>.size - MemoryLayout<InlineArray<5, CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?>>.size - MemoryLayout<CycleStaticWorkspaceBacking>.size - MemoryLayout<CycleStaticKeys>.size - MemoryLayout<CycleControl>.size, kind: .metadataPadding),
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
                cycleRejectForeignBinding(models: models, root: root, audit: audited, control: &control)
                do throws(SemanticExpansionError) {
                    var records = semanticBacking.records.mutableSpan
                    var paths = semanticBacking.paths.mutableSpan
                    var payloads = semanticBacking.payloads.mutableSpan
                    var scalars = semanticBacking.scalars.mutableSpan
                    try semantic.withLifetime(configuredLimits: cycleSemanticConfiguration(limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            var entries = canvasBacking.mutableSpan
                            try canvas.withLifetime(entries: &entries, table: CycleValueTable(), capacity: limits.drawing.maximumCanvasOccurrences, limits: limits.staticCanvas ?? cycleCanvasLimits) { values in
                                checks = workspace.withGeometry { geometry in
                                    let measured = geometry.storageMeasurement()
                                    var returned = exercisePipeline(models: models, root: root, semantic: semantic, values: values, dynamic: false, geometry: geometry, interaction: movedInteraction.take()!, audit: audited, control: &control)
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

func cycleFactoryProbe() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantic = SemanticRecordOwnerNamespace()
    do throws(ObservableStateError) {
        let staticOwner = try models.issue()
        let dynamicOwner = try models.issue()
        let retryStaticOwner = try models.issue(), retryDynamicOwner = try models.issue()
        let idleStaticOwner = try models.issue(), pendingStaticOwner = try models.issue()
        let idleDynamicOwner = try models.issue(), pendingDynamicOwner = try models.issue()
        let activeStaticOwner = try models.issue(), activeDynamicOwner = try models.issue()
        do throws(SemanticExpansionError) {
            var storage = StaticCycleProfileStorage(modelOwner: staticOwner, semanticOwner: try semantic.issue())
            precondition({ if case .valid = storage.audit() { return true }; return false }())
            #if !hasFeature(Embedded)
            cyclePrintAudit(storage.audit(report: { cyclePrintRegion($0, profile: "static") }), profile: "static")
            #endif
            let initial = storage.audit()
            storage.control.admission.pendingState = 1
            storage.resetAttemptStorage()
            precondition(storage.control.admission.pendingState == 1 && storage.audit() == initial)
            storage.resetAllStorage()
            precondition(storage.control.admission.pendingState == nil && storage.audit() == initial)
            var checks = storage.run() + 3
            #if !hasFeature(Embedded)
            var dynamic = DynamicCycleProfileStorage(modelOwner: dynamicOwner, semanticOwner: try semantic.issue())
            precondition({ if case .valid = dynamic.audit() { return true }; return false }())
            cyclePrintAudit(dynamic.audit(report: { cyclePrintRegion($0, profile: "dynamic") }), profile: "dynamic")
            let initialDynamic = dynamic.audit()
            dynamic.control.admission.pendingState = 1
            dynamic.resetAttemptStorage()
            precondition(dynamic.control.admission.pendingState == 1 && dynamic.audit() == initialDynamic)
            dynamic.resetAllStorage()
            precondition(dynamic.control.admission.pendingState == nil && dynamic.audit() == initialDynamic)
            checks += dynamic.run() + 3
            #endif
            var retryStatic = StaticCycleProfileStorage(modelOwner: retryStaticOwner, semanticOwner: try semantic.issue())
            retryStatic.control.terminalRetry = true
            checks += retryStatic.run()
            #if !hasFeature(Embedded)
            var retryDynamic = DynamicCycleProfileStorage(modelOwner: retryDynamicOwner, semanticOwner: try semantic.issue())
            retryDynamic.control.terminalRetry = true
            checks += retryDynamic.run()
            #endif
            for mode: UInt8 in [1, 2, 3] {
                var idleStatic = StaticCycleProfileStorage(modelOwner: mode == 1 ? idleStaticOwner : mode == 2 ? pendingStaticOwner : activeStaticOwner, semanticOwner: try semantic.issue())
                idleStatic.control.idleQuiesceMode = mode
                checks += idleStatic.run()
                #if !hasFeature(Embedded)
                var idleDynamic = DynamicCycleProfileStorage(modelOwner: mode == 1 ? idleDynamicOwner : mode == 2 ? pendingDynamicOwner : activeDynamicOwner, semanticOwner: try semantic.issue())
                idleDynamic.control.idleQuiesceMode = mode
                checks += idleDynamic.run()
                #endif
            }
            return checks
        } catch { preconditionFailure("factory semantic identity") }
    } catch { preconditionFailure("factory model identity") }
}

func cycleRejectForeignBinding(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, audit: RuntimeStorageAudit, control: inout CycleControl) {
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        var foreign = StaticObservableModelStorage<CycleOwnedModel, CycleModelSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        try foreign.withLifetime { (other) throws(ObservableStateError) in
            precondition(!models.sharesOwner(with: other))
            precondition(!root.belongs(to: other))
            withUnsafeMutablePointer(to: &control) { pointer in
                let rejected = CycleExecutionBinding(models: other.borrowedScope(), root: root.borrowedRoot(), control: pointer, audit: audit)
                if case .some = rejected { preconditionFailure("foreign audited construction") }
                precondition(pointer.pointee.stages == 0 && pointer.pointee.streams == 0 && pointer.pointee.applied == 0)
            }
        }
    } catch { preconditionFailure("foreign model construction") }
}

func cycleFactoryCapacityProbe() -> Int {
    var checks = 0
    var models = ObservableModelOwnerNamespace()
    var semantic = SemanticRecordOwnerNamespace()
    for axis in 0..<8 {
        for delta in -1...1 {
            do throws(ObservableStateError) {
                let modelOwner = try models.issue()
                do throws(SemanticExpansionError) {
                    let semanticOwner = try semantic.issue()
                    func limits(_ profile: RuntimeProfileKind) -> RuntimeProfileLimits {
                        cycleProfileLimits(profile, paths: UInt16(378 + (axis == 0 ? delta : 0)), structural: UInt16(126 + (axis == 1 ? delta : 0)),
                            models: UInt16(2 + (axis == 2 ? delta : 0)), tickets: UInt16(4 + (axis == 3 ? delta : 0)), pins: UInt16(2 + (axis == 4 ? delta : 0)),
                            canvas: UInt16(5 + (axis == 5 ? delta : 0)), pathPoints: UInt16(202 + (axis == 6 ? delta : 0)), planPoints: UInt16(832 + (axis == 7 ? delta : 0)))
                    }
                    var storage = StaticCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner, limits: limits(.static))
                    if delta == 1 {
                        precondition(storage.audit() == .invalid(.insufficientStorage))
                        precondition(storage.run() == 0 && !storage.used && storage.control.stages == 0)
                        checks += 2
                    } else {
                        guard case .valid = storage.audit() else { preconditionFailure("Static adequate backing") }; checks += 1
                    }
                    #if !hasFeature(Embedded)
                    var dynamic = DynamicCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner, limits: limits(.dynamic))
                    if delta == 1 {
                        precondition(dynamic.audit() == .invalid(.insufficientStorage))
                        precondition(dynamic.run() == 0 && !dynamic.used && dynamic.control.stages == 0)
                        checks += 2
                    } else {
                        guard case .valid = dynamic.audit() else { preconditionFailure("Dynamic adequate backing") }; checks += 1
                    }
                    #endif
                } catch { preconditionFailure("capacity semantic owner") }
            } catch { preconditionFailure("capacity model owner") }
        }
    }
    do throws(ObservableStateError) {
        let modelOwner = try models.issue()
        do throws(SemanticExpansionError) {
            let semanticOwner = try semantic.issue()
            var wrongProfile = StaticCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner, limits: cycleProfileLimits(.dynamic))
            precondition(wrongProfile.audit() == .invalid(.incompatibleLimits))
            precondition(wrongProfile.run() == 0 && !wrongProfile.used && wrongProfile.control.stages == 0)
            checks += 2
        } catch { preconditionFailure("profile semantic owner") }
    } catch { preconditionFailure("profile model owner") }
    return checks
}

#if !hasFeature(Embedded)
private func cyclePrintAudit(_ result: RuntimeProfileValidationResult, profile: String) {
    guard case .valid(let audit) = result else { preconditionFailure("reported factory audit failed") }
    print("P07-FIELD \(profile) 0 semanticCandidatePathBytes \(audit.semanticCandidatePathBytes)")
    print("P07-FIELD \(profile) 1 semanticPublishedPathBytes \(audit.semanticPublishedPathBytes)")
    print("P07-FIELD \(profile) 2 semanticCandidatePayloadBytes \(audit.semanticCandidatePayloadBytes)")
    print("P07-FIELD \(profile) 3 semanticPublishedPayloadBytes \(audit.semanticPublishedPayloadBytes)")
    print("P07-FIELD \(profile) 4 identityMatchWorkspaceBytes \(audit.identityMatchWorkspaceBytes)")
    print("P07-FIELD \(profile) 5 interactionCandidateIdentityBytes \(audit.interactionCandidateIdentityBytes)")
    print("P07-FIELD \(profile) 6 interactionCommittedIdentityBytes \(audit.interactionCommittedIdentityBytes)")
    print("P07-FIELD \(profile) 7 modelMetadataBytes \(audit.modelMetadataBytes)")
    print("P07-FIELD \(profile) 8 modelOwnerBytes \(audit.modelOwnerBytes)")
    print("P07-FIELD \(profile) 9 framePinBytes \(audit.framePinBytes)")
    print("P07-FIELD \(profile) 10 semanticCandidateBytes \(audit.semanticCandidateBytes)")
    print("P07-FIELD \(profile) 11 semanticPublishedBytes \(audit.semanticPublishedBytes)")
    print("P07-FIELD \(profile) 12 layoutCandidateBytes \(audit.layoutCandidateBytes)")
    print("P07-FIELD \(profile) 13 renderWorkspaceBytes \(audit.renderWorkspaceBytes)")
    print("P07-FIELD \(profile) 14 canvasCallableBytes \(audit.canvasCallableBytes)")
    print("P07-FIELD \(profile) 15 pathWorkspaceBytes \(audit.pathWorkspaceBytes)")
    print("P07-FIELD \(profile) 16 drawingPlanBytes \(audit.drawingPlanBytes)")
    print("P07-FIELD \(profile) 17 observableLiveBytes \(audit.observableLiveBytes)")
    print("P07-FIELD \(profile) 18 observableCandidateBytes \(audit.observableCandidateBytes)")
    print("P07-FIELD \(profile) 19 interactionCandidateBytes \(audit.interactionCandidateBytes)")
    print("P07-FIELD \(profile) 20 interactionCommittedBytes \(audit.interactionCommittedBytes)")
    print("P07-FIELD \(profile) 21 admissionQueueBytes \(audit.admissionQueueBytes)")
    print("P07-FIELD \(profile) 22 sealedBatchBytes \(audit.sealedBatchBytes)")
    print("P07-FIELD \(profile) 23 pointerStateBytes \(audit.pointerStateBytes)")
    print("P07-FIELD \(profile) 24 coordinatorStateBytes \(audit.coordinatorStateBytes)")
    print("P07-FIELD \(profile) 25 failureStateBytes \(audit.failureStateBytes)")
    print("P07-TOTAL \(profile) \(audit.totalProfileBytes)")
}
private func cyclePrintRegion(_ region: CycleStorageRegion, profile: String) {
    print("P07-REGION \(profile) \(region.family) \(region.kind.rawValue) \(region.count) \(region.size) \(region.stride) \(region.alignment) \(region.chargedBytes)")
}
#endif

// Accepted configurations are exercised, not merely audited. Every case keeps
// the physical backing fixed while narrowing one operational budget (and any
// dependent configured bounds required by RuntimeProfileLimits).
func cycleConfiguredLimits(_ profile: RuntimeProfileKind, axis: Int) -> RuntimeProfileLimits {
    let base = cycleProfileLimits(profile, paths: axis == 4 ? 1 : 378,
        models: axis == 17 ? 1 : 2, tickets: axis == 17 ? 1 : 4, pins: axis == 17 ? 1 : 2,
        canvas: axis == 11 || axis == 8 ? 1 : 5,
        pathPoints: axis == 0 ? 1 : (axis == 1 ? 2 : 202), planPoints: axis == 2 ? 1 : (axis == 3 ? 2 : 832), inputs: axis == 19 ? 1 : 2)
    let records = RuntimeRecordLimits(maximumPathEntries: base.records.maximumPathEntries, maximumPathDepth: axis == 5 ? 1 : 34, maximumPathChildFanout: axis == 6 ? 1 : 5, maximumPayloadBytesPerBank: axis == 7 ? 0 : base.records.maximumPayloadBytesPerBank, maximumIdentityComponentsPerKey: 34, maximumInteractionIdentityComponents: axis == 16 ? 1 : 204)
    let semantic = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: axis == 8 ? 1 : 48, maximumBodyEvaluations: axis == 9 ? 1 : 14, maximumModifierApplications: 50, maximumActionOccurrences: axis == 18 ? 1 : 6)!
    let layout = LayoutLimits(maximumScopes: axis == 11 ? 1 : 98, maximumDepth: axis == 10 ? 1 : 19, maximumTextScalars: 224, maximumTextLines: 128, maximumPositionedGlyphs: axis == 12 ? 1 : 224)!
    let workspace = RenderWorkspaceCapacity(maximumSemanticScopes: axis == 13 ? 1 : base.renderWorkspace.maximumSemanticScopes, maximumLayoutScopes: base.renderWorkspace.maximumLayoutScopes, maximumTraversalDepth: axis == 14 ? 1 : base.renderWorkspace.maximumTraversalDepth, maximumTextLines: base.renderWorkspace.maximumTextLines)!
    let drawing = DrawingLimits(maximumLineWidth: axis == 20 ? 5 : base.drawing.maximumLineWidth, maximumCanvasOccurrences: base.drawing.maximumCanvasOccurrences, maximumLivePathPoints: base.drawing.maximumLivePathPoints, maximumLivePathSubpaths: base.drawing.maximumLivePathSubpaths, maximumPlanStrokes: base.drawing.maximumPlanStrokes, maximumPlanPoints: base.drawing.maximumPlanPoints, maximumPlanSubpaths: base.drawing.maximumPlanSubpaths, maximumNormalizedStrokeOperations: base.drawing.maximumNormalizedStrokeOperations)!
    return RuntimeProfileLimits(records: records, models: base.models, semantic: semantic, maximumSemanticStructuralOccurrences: axis == 8 ? 1 : 126, layout: layout, render: base.render, renderWorkspace: workspace, renderSink: base.renderSink, maximumOrdinaryRenderOperations: axis == 15 ? 1 : base.maximumOrdinaryRenderOperations, execution: base.execution, observableState: axis == 17 ? .init(maximumLocations: 1, maximumRegistrations: 1, maximumStagedAssociations: 1)! : base.observableState, interaction: axis == 18 ? .init(maximumActions: 1, maximumHitRegions: 1)! : base.interaction, drawing: drawing, staticCanvas: base.staticCanvas, profile: profile)!
}

func cycleConfiguredLimitProbe() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    var checks = 0
    func expected(_ control: CycleControl, axis: Int) {
        if axis == 1 || axis == 3 || axis >= 17 {
            // Adequate capacities already passed the successful cycle assertions;
            // the final operation now deliberately proves terminal refusal.
            guard case .failed(let terminal)? = control.result else { preconditionFailure("adequate configured limits reach terminal probe") }
            precondition(terminal.failure == .nonRetryableRefusal(.endpoint))
            precondition(terminal.disposition.presentationIntentState == .unavailable)
            precondition(control.unavailable && control.committedRecords == 0)
            precondition(control.applied == 8)
        } else {
            let stage: RuntimeCompletePipelineStage = switch axis {
            case 0, 2: .canvasInvocationAndPlan
            case 4...9: .observableCandidateAndSemanticExpansion
            case 10...12: .layout
            case 13...15: .combinedRenderPreflight
            default: .interactionCandidate
            }
            guard case .failed(let failure)? = control.result else { preconditionFailure("configured excess must fail") }
            let expectedFailure: RunCycleFailure<RuntimeOwnerFailure> = switch axis {
            case 0, 2: .focusedOwner(.drawing(.capacityExhausted))
            case 4...9: .focusedOwner(.semantic(.capacityExhausted))
            case 10...12: .focusedOwner(.layout(.capacityExhausted))
            case 13...15: .renderProduction(.capacityExhausted)
            default: .focusedOwner(.interaction(.capacityExhausted))
            }
            precondition(failure.stage == stage && failure.failure == expectedFailure)
            precondition(control.applied == 0 && control.commits == 0 && control.streams == 0)
            precondition(control.unavailable && !control.frameActive && control.admission.pointerCount == 0)
        }
    }
    for axis in 0..<21 {
        do throws(ObservableStateError) {
            let modelOwner = try models.issue()
            do throws(SemanticExpansionError) {
                let semanticOwner = try semantics.issue()
                let limits = cycleConfiguredLimits(.static, axis: axis)
                var storage = StaticCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner, limits: limits)
                guard case .valid(let before) = storage.audit() else { preconditionFailure("accepted configured Static limit") }
                precondition(before.limits == limits)
                checks += storage.run()
                expected(storage.control, axis: axis)
                precondition(storage.audit() == .valid(before))
                checks += 5
                #if !hasFeature(Embedded)
                let dynamicLimits = cycleConfiguredLimits(.dynamic, axis: axis)
                var dynamic = DynamicCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner, limits: dynamicLimits)
                guard case .valid(let dynamicBefore) = dynamic.audit() else { preconditionFailure("accepted configured Dynamic limit") }
                precondition(dynamicBefore.limits == dynamicLimits)
                checks += dynamic.run()
                expected(dynamic.control, axis: axis)
                precondition(dynamic.audit() == .valid(dynamicBefore))
                checks += 5
                print("P07 configured-limit axis=\(axis) both profiles passed")
                #endif
            } catch { preconditionFailure("configured semantic owner") }
        } catch { preconditionFailure("configured model owner") }
    }
    return checks
}
