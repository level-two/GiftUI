import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore

private struct LimitInputs {
    var semanticNodes: UInt16 = 8
    var semanticStructuralOccurrences: UInt16 = 12
    var semanticActions: UInt16 = 2
    var layoutScopes: UInt16 = 8
    var layoutLines: UInt16 = 4
    var layoutGlyphs: UInt16 = 8
    var renderOperations: UInt16 = 8
    var renderGlyphs: UInt16 = 8
    var workspaceSemanticScopes: UInt16 = 16
    var workspaceLayoutScopes: UInt16 = 8
    var workspaceTraversalDepth: UInt16 = 8
    var workspaceTextLines: UInt16 = 4
    var sinkOperations: UInt16 = 8
    var sinkGlyphs: UInt16 = 8
    var ordinaryOperations: UInt16 = 4
    var executionInputs: UInt16 = 4
    var executionSemanticActions: UInt16 = 2
    var executionCommittedActions: UInt16 = 2
    var interactionActions: UInt16 = 2
    var interactionHitRegions: UInt16 = 2
    var canvasOccurrences: UInt16 = 2
    var normalizedStrokes: UInt16 = 4
}

private func makeLimits(
    _ inputs: LimitInputs = LimitInputs(),
    profile: RuntimeProfileKind = .dynamic,
    includeStaticCanvas: Bool = false,
    records: RuntimeRecordLimits = recordLimits(),
    models: RuntimeModelLimits = modelLimits()
) -> RuntimeProfileLimits? {
    let semantic = SemanticExpansionLimits(
        maximumDepth: 8,
        maximumSemanticNodes: inputs.semanticNodes,
        maximumBodyEvaluations: 8,
        maximumModifierApplications: 8,
        maximumActionOccurrences: inputs.semanticActions
    )!
    let layout = LayoutLimits(
        maximumScopes: inputs.layoutScopes,
        maximumDepth: 8,
        maximumTextScalars: 16,
        maximumTextLines: inputs.layoutLines,
        maximumPositionedGlyphs: inputs.layoutGlyphs
    )!
    let render = RenderLimits(
        maximumOperations: inputs.renderOperations,
        maximumPositionedGlyphs: inputs.renderGlyphs,
        maximumClipDepth: 8
    )!
    let renderWorkspace = RenderWorkspaceCapacity(
        maximumSemanticScopes: inputs.workspaceSemanticScopes,
        maximumLayoutScopes: inputs.workspaceLayoutScopes,
        maximumTraversalDepth: inputs.workspaceTraversalDepth,
        maximumTextLines: inputs.workspaceTextLines
    )!
    let execution = ExecutionLimits(
        maximumInputEvents: inputs.executionInputs,
        maximumStateChangeFacts: 2,
        maximumCompletionFacts: 0,
        maximumSemanticActions: inputs.executionSemanticActions,
        maximumActiveInputSources: 2,
        maximumCommittedActions: inputs.executionCommittedActions
    )!
    let interaction = InteractionLimits(
        maximumActions: inputs.interactionActions,
        maximumHitRegions: inputs.interactionHitRegions
    )!
    let drawing = DrawingLimits(
        maximumLineWidth: 8,
        maximumCanvasOccurrences: inputs.canvasOccurrences,
        maximumLivePathPoints: 8,
        maximumLivePathSubpaths: 4,
        maximumPlanStrokes: 4,
        maximumPlanPoints: 8,
        maximumPlanSubpaths: 4,
        maximumNormalizedStrokeOperations: inputs.normalizedStrokes
    )!

    return RuntimeProfileLimits(
        records: records,
        models: models,
        semantic: semantic,
        maximumSemanticStructuralOccurrences: inputs.semanticStructuralOccurrences,
        layout: layout,
        render: render,
        renderWorkspace: renderWorkspace,
        renderSink: RenderSinkCapacity(
            maximumOperations: inputs.sinkOperations,
            maximumPositionedGlyphs: inputs.sinkGlyphs
        ),
        maximumOrdinaryRenderOperations: inputs.ordinaryOperations,
        execution: execution,
        observableState: ObservableStateLimits(
            maximumLocations: 2,
            maximumRegistrations: 2,
            maximumStagedAssociations: 2
        )!,
        interaction: interaction,
        drawing: drawing,
        staticCanvas: includeStaticCanvas
            ? StaticCanvasLimits(maximumStaticCallableCases: 2, maximumStaticCaptureBytes: 16)!
            : nil,
        profile: profile
    )
}


private func recordLimits(paths: UInt16 = 36, depth: UInt16 = 8, fanout: UInt16 = 5,
                          payload: UInt32 = 128, key: UInt16 = 8, pool: UInt32 = 16) -> RuntimeRecordLimits {
    .init(maximumPathEntries: paths, maximumPathDepth: depth, maximumPathChildFanout: fanout,
          maximumPayloadBytesPerBank: payload, maximumIdentityComponentsPerKey: key,
          maximumInteractionIdentityComponents: pool)
}
private func modelLimits(slots: UInt16 = 2, tickets: UInt16 = 4, pins: UInt16 = 2,
                         captures: UInt16 = 0) -> RuntimeModelLimits {
    .init(maximumModelSlots: slots, maximumOwningTickets: tickets, maximumFramePins: pins,
          maximumModelCaptureBanks: captures)
}
private func bytes(_ excess: Int = -1) -> RuntimeStorageByteCounts {
    .init(
        semanticCandidatePathBytes: excess == 0 ? .max : 1,
        semanticPublishedPathBytes: excess == 1 ? .max : 1,
        semanticCandidatePayloadBytes: excess == 2 ? .max : 1,
        semanticPublishedPayloadBytes: excess == 3 ? .max : 1,
        identityMatchWorkspaceBytes: excess == 4 ? .max : 1,
        interactionCandidateIdentityBytes: excess == 5 ? .max : 1,
        interactionCommittedIdentityBytes: excess == 6 ? .max : 1,
        modelMetadataBytes: excess == 7 ? .max : 1,
        modelOwnerBytes: excess == 8 ? .max : 1,
        framePinBytes: excess == 9 ? .max : 1,
        semanticCandidateBytes: excess == 10 ? .max : 1,
        semanticPublishedBytes: excess == 11 ? .max : 1,
        layoutCandidateBytes: excess == 12 ? .max : 1,
        renderWorkspaceBytes: excess == 13 ? .max : 1,
        canvasCallableBytes: excess == 14 ? .max : 1,
        pathWorkspaceBytes: excess == 15 ? .max : 1,
        drawingPlanBytes: excess == 16 ? .max : 1,
        observableLiveBytes: excess == 17 ? .max : 1,
        observableCandidateBytes: excess == 18 ? .max : 1,
        interactionCandidateBytes: excess == 19 ? .max : 1,
        interactionCommittedBytes: excess == 20 ? .max : 1,
        admissionQueueBytes: excess == 21 ? .max : 1,
        sealedBatchBytes: excess == 22 ? .max : 1,
        pointerStateBytes: excess == 23 ? .max : 1,
        coordinatorStateBytes: excess == 24 ? .max : 1,
        failureStateBytes: excess == 25 ? .max : 1
    )
}

private func capacities(_ limits: RuntimeProfileLimits, candidate: RuntimeRecordLimits?, published: RuntimeRecordLimits?, models: RuntimeModelLimits?) -> RuntimeStorageCapacities {
    let exact = RuntimeStorageCapacities(exact: limits, byteCounts: bytes())
    return RuntimeStorageCapacities(
        candidateRecords: candidate,
        publishedRecords: published,
        models: models,
        semanticCandidate: exact.semanticCandidate,
        semanticPublished: exact.semanticPublished,
        semanticCandidateStructuralOccurrences: exact.semanticCandidateStructuralOccurrences,
        semanticPublishedStructuralOccurrences: exact.semanticPublishedStructuralOccurrences,
        layoutCandidate: exact.layoutCandidate,
        render: exact.render,
        renderWorkspace: exact.renderWorkspace,
        canvasCallableOccurrences: exact.canvasCallableOccurrences,
        staticCanvasCaptureBytes: exact.staticCanvasCaptureBytes,
        pathPoints: exact.pathPoints,
        pathSubpaths: exact.pathSubpaths,
        drawingPlanStrokes: exact.drawingPlanStrokes,
        drawingPlanPoints: exact.drawingPlanPoints,
        drawingPlanSubpaths: exact.drawingPlanSubpaths,
        normalizedStrokeOperations: exact.normalizedStrokeOperations,
        observableLiveLocations: exact.observableLiveLocations,
        observableLiveRegistrations: exact.observableLiveRegistrations,
        observableCandidateAssociations: exact.observableCandidateAssociations,
        interactionCandidateActions: exact.interactionCandidateActions,
        interactionCandidateHitRegions: exact.interactionCandidateHitRegions,
        interactionCommittedActions: exact.interactionCommittedActions,
        interactionCommittedHitRegions: exact.interactionCommittedHitRegions,
        admissionQueue: exact.admissionQueue,
        sealedBatch: exact.sealedBatch,
        pointerStates: exact.pointerStates,
        coordinatorStatePresent: exact.coordinatorStatePresent,
        failureStatePresent: exact.failureStatePresent,
        byteCounts: exact.byteCounts
    )
}
private struct AuditTable: RuntimeStaticCanvasAuditMetadata {
    var callableCaseCount: UInt16 { 1 }
    var declaredEntryCount: UInt16 { 1 }
    var maximumDeclaredID: UInt16 { 1 }
    func coverageMultiplicity(for id: UInt16) -> UInt8 { id == 1 ? 1 : 0 }
    func captureByteCount(for id: UInt16) -> UInt16? { id == 1 ? 0 : nil }
}
private func validate(_ profile: RuntimeProfileKind, _ limits: RuntimeProfileLimits, _ capacities: RuntimeStorageCapacities) -> RuntimeProfileValidationResult {
    let inputs = RuntimeProfileLimitInputs(validated: limits, profile: profile)
    if profile == .dynamic { return RuntimeProfileValidator.validateDynamic(inputs: inputs, capacities: capacities) }
    return RuntimeProfileValidator.validateStatic(inputs: inputs, capacities: capacities, metadata: AuditTable())
}
public func giftuiP07Values() -> Int {
    var checks = 0
    func check(_ value: Bool) { precondition(value); checks += 1 }
    check(makeLimits() != nil)
    check(makeLimits(profile: .static, includeStaticCanvas: true) != nil)
    check(makeLimits(records: recordLimits(paths: 0)) == nil)
    check(makeLimits(records: recordLimits(depth: 0)) == nil)
    check(makeLimits(records: recordLimits(depth: 35, key: 35)) == nil)
    check(makeLimits(records: recordLimits(fanout: 0)) == nil)
    check(makeLimits(records: recordLimits(key: 7)) == nil)
    check(makeLimits(records: recordLimits(pool: 0)) == nil)
    check(makeLimits(models: modelLimits(slots: 0)) == nil)
    check(makeLimits(models: modelLimits(tickets: 0)) == nil)
    check(makeLimits(models: modelLimits(pins: 0)) == nil)
    check(makeLimits(models: modelLimits(captures: 2)) == nil)
    check(makeLimits(models: modelLimits(captures: 1)) != nil)
    for profile in [RuntimeProfileKind.dynamic, .static] {
        let limits = makeLimits(profile: profile, includeStaticCanvas: profile == .static)!
        let result = RuntimeStorageAudit.checked(profile: profile, limits: limits, byteCounts: bytes())
        guard case .valid(let audit) = result else { preconditionFailure() }
        check(validate(profile, limits, capacities(limits, candidate: nil, published: limits.records, models: limits.models)) == .invalid(.missingStorage))
        check(validate(profile, limits, capacities(limits, candidate: limits.records, published: nil, models: limits.models)) == .invalid(.missingStorage))
        check(validate(profile, limits, capacities(limits, candidate: limits.records, published: limits.records, models: nil)) == .invalid(.missingStorage))
        for records in [recordLimits(paths: 35), recordLimits(depth: 7), recordLimits(fanout: 4), recordLimits(payload: 127), recordLimits(key: 7), recordLimits(pool: 15)] {
            check(validate(profile, limits, capacities(limits, candidate: records, published: limits.records, models: limits.models)) == .invalid(.insufficientStorage))
            check(validate(profile, limits, capacities(limits, candidate: limits.records, published: records, models: limits.models)) == .invalid(.insufficientStorage))
        }
        for models in [modelLimits(slots: 1), modelLimits(tickets: 3), modelLimits(pins: 1)] {
            check(validate(profile, limits, capacities(limits, candidate: limits.records, published: limits.records, models: models)) == .invalid(.insufficientStorage))
        }
        for records in [recordLimits(), recordLimits(paths: 37, depth: 9, fanout: 6, payload: 129, key: 9, pool: 17)] {
            if case .valid = validate(profile, limits, capacities(limits, candidate: records, published: records, models: modelLimits(slots: 3, tickets: 5, pins: 3))) { check(true) }
            else { check(false) }
        }
        check(audit.totalProfileBytes == 26)
        check(audit.semanticCandidatePathBytes == 1)
        check(audit.semanticPublishedPathBytes == 1)
        check(audit.semanticCandidatePayloadBytes == 1)
        check(audit.semanticPublishedPayloadBytes == 1)
        check(audit.identityMatchWorkspaceBytes == 1)
        check(audit.interactionCandidateIdentityBytes == 1)
        check(audit.interactionCommittedIdentityBytes == 1)
        check(audit.modelMetadataBytes == 1)
        check(audit.modelOwnerBytes == 1)
        check(audit.framePinBytes == 1)
        check(audit.semanticCandidateBytes == 1)
        check(audit.semanticPublishedBytes == 1)
        check(audit.layoutCandidateBytes == 1)
        check(audit.renderWorkspaceBytes == 1)
        check(audit.canvasCallableBytes == 1)
        check(audit.pathWorkspaceBytes == 1)
        check(audit.drawingPlanBytes == 1)
        check(audit.observableLiveBytes == 1)
        check(audit.observableCandidateBytes == 1)
        check(audit.interactionCandidateBytes == 1)
        check(audit.interactionCommittedBytes == 1)
        check(audit.admissionQueueBytes == 1)
        check(audit.sealedBatchBytes == 1)
        check(audit.pointerStateBytes == 1)
        check(audit.coordinatorStateBytes == 1)
        check(audit.failureStateBytes == 1)
        for i in 0..<26 {
            check(RuntimeStorageAudit.checked(profile: profile, limits: limits, byteCounts: bytes(i)) == .invalid(.arithmeticOverflow))
        }
    }
    return checks
}
