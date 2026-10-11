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

func cycleValidateBacking<G, C, R, H>(profile: RuntimeProfileKind, limits: RuntimeProfileLimits,
    root: CycleRootLayout, semantic: CycleSemanticMeasurement, geometry: CycleGeometryMeasurement,
    interaction: borrowing InteractionOwnedKeyState<C, R, H>, geometryType: G.Type,
    canvasCount: Int, canvasCapacity: UInt16, canvasControlBytes: Int,
    factoryMetadataBytes: Int) -> RuntimeProfileValidationResult
where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
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
    typealias Admission = SingleSourceExecutionAdmissionController<CycleQueuedFacts, CycleWake>
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
        + MemoryLayout<CycleRuntimeControl>.size - MemoryLayout<CycleAdmissionBacking>.size - result
        + factoryMetadataBytes
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
    let values: InlineArray<26, UInt64> = [firstPaths, pathBytes - firstPaths, candidatePayload, publishedPayload,
        0, keys.candidateIdentityBytes, keys.committedIdentityBytes,
        UInt64(root.metadataBytes), UInt64(root.modelBytes), UInt64(root.pinBytes),
        firstRecords + UInt64(semantic.controlBytes), recordBytes - firstRecords,
        geometry.layoutBytes, geometry.renderBytes, canvasBytes + UInt64(canvasControlBytes), geometry.pathBytes, geometry.planBytes,
        UInt64(root.liveBytes), UInt64(root.candidateBytes), keys.candidateBytes + UInt64(interactionMetadata), keys.committedBytes,
        UInt64(pending), UInt64(sealed), UInt64(Admission.pointerStateStorageBytes), UInt64(coordinator), UInt64(result)]
    for index in 0..<values.count where UInt32(exactly: values[index]) == nil { return .invalid(.arithmeticOverflow) }
    let bytes = RuntimeStorageByteCounts(semanticCandidatePathBytes: UInt32(values[0]), semanticPublishedPathBytes: UInt32(values[1]), semanticCandidatePayloadBytes: UInt32(values[2]), semanticPublishedPayloadBytes: UInt32(values[3]), identityMatchWorkspaceBytes: UInt32(values[4]), interactionCandidateIdentityBytes: UInt32(values[5]), interactionCommittedIdentityBytes: UInt32(values[6]), modelMetadataBytes: UInt32(values[7]), modelOwnerBytes: UInt32(values[8]), framePinBytes: UInt32(values[9]), semanticCandidateBytes: UInt32(values[10]), semanticPublishedBytes: UInt32(values[11]), layoutCandidateBytes: UInt32(values[12]), renderWorkspaceBytes: UInt32(values[13]), canvasCallableBytes: UInt32(values[14]), pathWorkspaceBytes: UInt32(values[15]), drawingPlanBytes: UInt32(values[16]), observableLiveBytes: UInt32(values[17]), observableCandidateBytes: UInt32(values[18]), interactionCandidateBytes: UInt32(values[19]), interactionCommittedBytes: UInt32(values[20]), admissionQueueBytes: UInt32(values[21]), sealedBatchBytes: UInt32(values[22]), pointerStateBytes: UInt32(values[23]), coordinatorStateBytes: UInt32(values[24]), failureStateBytes: UInt32(values[25]))
    let records = RuntimeRecordLimits(maximumPathEntries: semanticLimits.paths, maximumPathDepth: semanticLimits.depth, maximumPathChildFanout: semanticLimits.fanout, maximumPayloadBytesPerBank: semanticLimits.payloadBytes, maximumIdentityComponentsPerKey: keyLimits.perKey, maximumInteractionIdentityComponents: keyLimits.perBank)
    let inputs = RuntimeProfileLimitInputs(records: limits.records, models: limits.models, semantic: limits.semantic, maximumSemanticStructuralOccurrences: limits.maximumSemanticStructuralOccurrences, layout: limits.layout, render: limits.render, renderWorkspace: limits.renderWorkspace, renderSink: limits.renderSink, maximumOrdinaryRenderOperations: limits.maximumOrdinaryRenderOperations, execution: limits.execution, observableState: limits.observableState, interaction: limits.interaction, drawing: limits.drawing, staticCanvas: limits.staticCanvas, profile: profile)
    let rootCapacity = ObservableStateRootStorage<SemanticCompleteIdentity>.storageCapacities
    let capacities = RuntimeStorageCapacities(candidateRecords: records, publishedRecords: records,
        models: .init(maximumModelSlots: root.models, maximumOwningTickets: root.claims, maximumFramePins: root.pins, maximumModelCaptureBanks: root.captures),
        semanticCandidate: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticPublished: .init(maximumDepth: semanticLimits.depth, maximumSemanticNodes: semanticLimits.records, maximumBodyEvaluations: semanticLimits.records, maximumModifierApplications: semanticLimits.records, maximumActionOccurrences: semanticLimits.records),
        semanticCandidateStructuralOccurrences: semanticLimits.records, semanticPublishedStructuralOccurrences: semanticLimits.records,
        layoutCandidate: geometry.layout, render: geometry.render, renderWorkspace: geometry.renderWorkspace,
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
        root = DynamicObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false)!
        semantic = DynamicSemanticRecordStorage(limits: cycleSemanticLimits, owner: semanticOwner)
        interaction = CycleDynamicKeys(state: InteractionState(candidateRecords: CycleDynamicCandidate(capacity: 6), candidateHitRegions: CycleDynamicHits(capacity: 6), candidateCommittedRecords: CycleDynamicCommitted(capacity: 6), committedRecords: CycleDynamicCommitted(capacity: 6), committedHitRegions: CycleDynamicHits(capacity: 6)), maximumComponentsPerKey: 34, maximumComponents: 204)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult {
        guard let geometry, let interaction else { return .invalid(.missingStorage) }
        let extent = semantic.retainedExtents
        return cycleValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout,
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: extent.records), paths: .elements(SemanticPathEntry.self, count: extent.paths), payloads: .elements(CyclePayload?.self, count: extent.payloads), scalars: .elements(UInt32.self, count: extent.scalars), controlBytes: extent.controlBytes),
            geometry: geometry.storageMeasurement(), interaction: interaction, geometryType: DynamicCycleGeometry.self,
            canvasCount: canvas.retainedElementCapacity, canvasCapacity: canvas.capacity,
            canvasControlBytes: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>>.size,
            factoryMetadataBytes: MemoryLayout<RuntimeProfileLimits>.size + MemoryLayout<Bool>.size)
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
        var movedGeometry = geometry.take()
        var movedInteraction = interaction.take()
        var returned: CycleReturnedWorkspaces<DynamicCycleGeometry, CycleDynamicCandidate, CycleDynamicCommitted, CycleDynamicHits>?
        do throws(ObservableStateError) {
            try root.withLifetime { (models, root) throws(ObservableStateError) in
                cycleRejectForeignBinding(models: models, root: root, audit: audited, control: &control)
                do throws(SemanticExpansionError) {
                    try semantic.withLifetime { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            try canvas.withLifetime(table: CycleValueTable(), limits: cycleCanvasLimits) { values in
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
        root = StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false)!
        semantic = StaticSemanticRecordStorage(limits: cycleSemanticLimits, owner: semanticOwner)
        interaction = CycleStaticKeys(state: InteractionState(candidateRecords: CycleStaticCandidate(capacity: 6)!, candidateHitRegions: CycleStaticHits(capacity: 6)!, candidateCommittedRecords: CycleStaticCommitted(capacity: 6)!, committedRecords: CycleStaticCommitted(capacity: 6)!, committedHitRegions: CycleStaticHits(capacity: 6)!), maximumComponentsPerKey: 34, maximumComponents: 204)!
    }
    borrowing func audit() -> RuntimeProfileValidationResult {
        guard let interaction else { return .invalid(.missingStorage) }
        return cycleValidateBacking(profile: Self.profile, limits: limits, root: root.storageLayout,
            semantic: .init(limits: semantic.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: semanticBacking.records.count), paths: .elements(SemanticPathEntry.self, count: semanticBacking.paths.count), payloads: .elements(CyclePayload?.self, count: semanticBacking.payloads.count), scalars: .elements(UInt32.self, count: semanticBacking.scalars.count), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size),
            geometry: workspace.measurement, interaction: interaction, geometryType: StaticCycleGeometry.self,
            canvasCount: canvasBacking.count, canvasCapacity: UInt16(canvasBacking.count),
            canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size,
            factoryMetadataBytes: MemoryLayout<RuntimeProfileLimits>.size + MemoryLayout<Bool>.size)
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
        var movedInteraction = interaction.take()
        var checks = 0
        do throws(ObservableStateError) {
            try root.withLifetime { (models, root) throws(ObservableStateError) in
                cycleRejectForeignBinding(models: models, root: root, audit: audited, control: &control)
                do throws(SemanticExpansionError) {
                    var records = semanticBacking.records.mutableSpan
                    var paths = semanticBacking.paths.mutableSpan
                    var payloads = semanticBacking.payloads.mutableSpan
                    var scalars = semanticBacking.scalars.mutableSpan
                    try semantic.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            var entries = canvasBacking.mutableSpan
                            try canvas.withLifetime(entries: &entries, table: CycleValueTable(), capacity: 5, limits: cycleCanvasLimits) { values in
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
        do throws(SemanticExpansionError) {
            var storage = StaticCycleProfileStorage(modelOwner: staticOwner, semanticOwner: try semantic.issue())
            precondition({ if case .valid = storage.audit() { return true }; return false }())
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
            let initialDynamic = dynamic.audit()
            dynamic.control.admission.pendingState = 1
            dynamic.resetAttemptStorage()
            precondition(dynamic.control.admission.pendingState == 1 && dynamic.audit() == initialDynamic)
            dynamic.resetAllStorage()
            precondition(dynamic.control.admission.pendingState == nil && dynamic.audit() == initialDynamic)
            checks += dynamic.run() + 3
            #endif
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
