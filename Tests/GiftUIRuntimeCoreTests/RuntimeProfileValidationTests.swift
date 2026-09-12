import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUISemanticCore
import Testing

private let capacityFamilies = [
    "semantic-candidate",
    "semantic-published",
    "layout-candidate",
    "render",
    "render-workspace",
    "canvas-callable",
    "path-points",
    "path-subpaths",
    "plan-strokes",
    "plan-points",
    "plan-subpaths",
    "normalized-strokes",
    "observable-locations",
    "observable-registrations",
    "observable-associations",
    "interaction-candidate-actions",
    "interaction-candidate-hits",
    "interaction-committed-actions",
    "interaction-committed-hits",
    "admission-queue",
    "sealed-batch",
    "pointer-states",
    "coordinator-state",
    "failure-state",
    "byte-counts",
]

private func validationInputs(
    profile: RuntimeProfileKind = .dynamic,
    invalidFocusedLimits: Bool = false,
    incompatibleLimits: Bool = false
) -> RuntimeProfileLimitInputs {
    RuntimeProfileLimitInputs(
        semantic: invalidFocusedLimits
            ? nil
            : SemanticExpansionLimits(
                maximumDepth: 2,
                maximumSemanticNodes: 2,
                maximumBodyEvaluations: 2,
                maximumModifierApplications: 2,
                maximumActionOccurrences: incompatibleLimits ? 2 : 1
            ),
        layout: LayoutLimits(
            maximumScopes: 2,
            maximumDepth: 2,
            maximumTextScalars: 2,
            maximumTextLines: 2,
            maximumPositionedGlyphs: 2
        ),
        render: RenderLimits(
            maximumOperations: 2,
            maximumPositionedGlyphs: 2,
            maximumClipDepth: 2
        ),
        renderWorkspace: RenderWorkspaceCapacity(
            maximumSemanticScopes: 2,
            maximumLayoutScopes: 2,
            maximumTraversalDepth: 2,
            maximumTextLines: 2
        ),
        renderSink: RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 2),
        maximumOrdinaryRenderOperations: 1,
        execution: ExecutionLimits(
            maximumInputEvents: 2,
            maximumStateChangeFacts: 2,
            maximumCompletionFacts: 2,
            maximumSemanticActions: 2,
            maximumActiveInputSources: 2,
            maximumCommittedActions: 2
        ),
        observableState: ObservableStateLimits(
            maximumLocations: 1,
            maximumRegistrations: 1,
            maximumStagedAssociations: 1
        ),
        interaction: InteractionLimits(maximumActions: 1, maximumHitRegions: 1),
        drawing: DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 1,
            maximumLivePathPoints: 1,
            maximumLivePathSubpaths: 1,
            maximumPlanStrokes: 1,
            maximumPlanPoints: 1,
            maximumPlanSubpaths: 1,
            maximumNormalizedStrokeOperations: 1
        ),
        staticCanvas: profile == .static
            ? StaticCanvasLimits(maximumStaticCallableCases: 2, maximumStaticCaptureBytes: 4)
            : nil,
        profile: profile
    )
}

private func validationByteCounts(overflow: Bool = false) -> RuntimeStorageByteCounts {
    RuntimeStorageByteCounts(
        semanticCandidateBytes: overflow ? .max : 1,
        semanticPublishedBytes: 1,
        layoutCandidateBytes: 1,
        renderWorkspaceBytes: 1,
        canvasCallableBytes: 1,
        pathWorkspaceBytes: 1,
        drawingPlanBytes: 1,
        observableLiveBytes: 1,
        observableCandidateBytes: 1,
        interactionCandidateBytes: 1,
        interactionCommittedBytes: 1,
        admissionQueueBytes: 1,
        sealedBatchBytes: 1,
        pointerStateBytes: 1,
        coordinatorStateBytes: 1,
        failureStateBytes: 1
    )
}

private func validationCapacities(
    profile: RuntimeProfileKind = .dynamic,
    missing: String? = nil,
    insufficient: String? = nil,
    renderWorkspaceHeadroom: Bool = false,
    overflow: Bool = false
) -> RuntimeStorageCapacities {
    let semantic = SemanticExpansionLimits(
        maximumDepth: 2,
        maximumSemanticNodes: 2,
        maximumBodyEvaluations: 2,
        maximumModifierApplications: 2,
        maximumActionOccurrences: 1
    )!
    let layout = LayoutLimits(
        maximumScopes: 2,
        maximumDepth: 2,
        maximumTextScalars: 2,
        maximumTextLines: 2,
        maximumPositionedGlyphs: 2
    )!
    let render = RenderLimits(
        maximumOperations: 2,
        maximumPositionedGlyphs: 2,
        maximumClipDepth: 2
    )!
    let execution = ExecutionLimits(
        maximumInputEvents: 2,
        maximumStateChangeFacts: 2,
        maximumCompletionFacts: 2,
        maximumSemanticActions: 2,
        maximumActiveInputSources: 2,
        maximumCommittedActions: 2
    )!
    let tooSmallSemantic = SemanticExpansionLimits(
        maximumDepth: 1,
        maximumSemanticNodes: 1,
        maximumBodyEvaluations: 1,
        maximumModifierApplications: 1,
        maximumActionOccurrences: 0
    )!
    let tooSmallLayout = LayoutLimits(
        maximumScopes: 1,
        maximumDepth: 1,
        maximumTextScalars: 1,
        maximumTextLines: 1,
        maximumPositionedGlyphs: 1
    )!
    let tooSmallRender = RenderLimits(
        maximumOperations: 1,
        maximumPositionedGlyphs: 1,
        maximumClipDepth: 1
    )!
    let tooSmallExecution = ExecutionLimits(
        maximumInputEvents: 1,
        maximumStateChangeFacts: 1,
        maximumCompletionFacts: 1,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 1,
        maximumCommittedActions: 1
    )!

    func optional<T>(_ family: String, _ value: T, _ small: T) -> T? {
        if missing == family { return nil }
        return insufficient == family ? small : value
    }

    let workspaceMaximum: UInt16 =
        if insufficient == "render-workspace" {
            1
        } else if renderWorkspaceHeadroom {
            3
        } else {
            2
        }
    let workspace = RenderWorkspaceCapacity(
        maximumSemanticScopes: workspaceMaximum,
        maximumLayoutScopes: 2,
        maximumTraversalDepth: 2,
        maximumTextLines: 2
    )!
    return RuntimeStorageCapacities(
        semanticCandidate: optional("semantic-candidate", semantic, tooSmallSemantic),
        semanticPublished: optional("semantic-published", semantic, tooSmallSemantic),
        layoutCandidate: optional("layout-candidate", layout, tooSmallLayout),
        render: optional("render", render, tooSmallRender),
        renderWorkspace: missing == "render-workspace" ? nil : workspace,
        canvasCallableOccurrences: optional("canvas-callable", 1, 0),
        staticCanvasCaptureBytes: profile == .static ? 4 : nil,
        pathPoints: optional("path-points", 1, 0),
        pathSubpaths: optional("path-subpaths", 1, 0),
        drawingPlanStrokes: optional("plan-strokes", 1, 0),
        drawingPlanPoints: optional("plan-points", 1, 0),
        drawingPlanSubpaths: optional("plan-subpaths", 1, 0),
        normalizedStrokeOperations: optional("normalized-strokes", 1, 0),
        observableLiveLocations: optional("observable-locations", 1, 0),
        observableLiveRegistrations: optional("observable-registrations", 1, 0),
        observableCandidateAssociations: optional("observable-associations", 1, 0),
        interactionCandidateActions: optional("interaction-candidate-actions", 1, 0),
        interactionCandidateHitRegions: optional("interaction-candidate-hits", 1, 0),
        interactionCommittedActions: optional("interaction-committed-actions", 1, 0),
        interactionCommittedHitRegions: optional("interaction-committed-hits", 1, 0),
        admissionQueue: optional("admission-queue", execution, tooSmallExecution),
        sealedBatch: optional("sealed-batch", execution, tooSmallExecution),
        pointerStates: optional("pointer-states", 2, 1),
        coordinatorStatePresent: missing != "coordinator-state",
        failureStatePresent: missing != "failure-state",
        byteCounts: missing == "byte-counts" ? nil : validationByteCounts(overflow: overflow)
    )
}

private struct ValidStaticMetadata: RuntimeStaticCanvasAuditMetadata {
    let callableCaseCount: UInt16 = 2
    let declaredEntryCount: UInt16 = 2
    let maximumDeclaredID: UInt16 = 2

    func coverageMultiplicity(for id: UInt16) -> UInt8 { id <= 2 ? 1 : 0 }
    func captureByteCount(for id: UInt16) -> UInt16? { id <= 2 ? id + 1 : nil }
}

private final class PoisonStaticMetadata: RuntimeStaticCanvasAuditMetadata {
    var callCount = 0
    let callableCaseCount: UInt16
    let declaredEntryCount: UInt16
    let maximumDeclaredID: UInt16

    init(
        callableCaseCount: UInt16 = 0, declaredEntryCount: UInt16 = 0, maximumDeclaredID: UInt16 = 0
    ) {
        self.callableCaseCount = callableCaseCount
        self.declaredEntryCount = declaredEntryCount
        self.maximumDeclaredID = maximumDeclaredID
    }

    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        callCount += 1
        return 0
    }

    func captureByteCount(for id: UInt16) -> UInt16? {
        callCount += 1
        return nil
    }
}

@Test
func validDynamicAndStaticStorageProduceExactAudits() {
    let dynamic = RuntimeProfileValidator.validateDynamic(
        inputs: validationInputs(),
        capacities: validationCapacities()
    )
    let staticProfile = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static),
        capacities: validationCapacities(profile: .static),
        metadata: ValidStaticMetadata()
    )

    guard case .valid(let dynamicAudit) = dynamic,
        case .valid(let staticAudit) = staticProfile
    else {
        Issue.record("expected valid profile audits")
        return
    }
    #expect(dynamicAudit.profile == .dynamic)
    #expect(dynamicAudit.totalProfileBytes == 16)
    #expect(staticAudit.profile == .static)
    #expect(staticAudit.totalProfileBytes == 16)
}

@Test(arguments: capacityFamilies)
func everyMissingDynamicStorageFamilyFailsBeforeSufficiency(family: String) {
    let result = RuntimeProfileValidator.validateDynamic(
        inputs: validationInputs(),
        capacities: validationCapacities(
            missing: family,
            insufficient: "canvas-callable",
            overflow: true
        )
    )

    #expect(result == .invalid(.missingStorage))
}

@Test(
    arguments: capacityFamilies.filter {
        !["coordinator-state", "failure-state", "byte-counts"].contains($0)
    })
func everySizedDynamicStorageFamilyRejectsItsFirstShortfall(family: String) {
    let result = RuntimeProfileValidator.validateDynamic(
        inputs: validationInputs(),
        capacities: validationCapacities(insufficient: family)
    )

    #expect(result == .invalid(.insufficientStorage))
}

@Test
func renderWorkspaceRejectsUnconfiguredPhysicalHeadroom() {
    let result = RuntimeProfileValidator.validateDynamic(
        inputs: validationInputs(),
        capacities: validationCapacities(renderWorkspaceHeadroom: true)
    )

    #expect(result == .invalid(.insufficientStorage))
}

@Test
func sixValidationStepsStopAtTheFirstFailure() {
    let metadata = PoisonStaticMetadata()

    let invalidLimits = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static, invalidFocusedLimits: true),
        capacities: validationCapacities(
            profile: .static,
            missing: "semantic-candidate",
            insufficient: "canvas-callable",
            overflow: true
        ),
        metadata: metadata
    )
    #expect(invalidLimits == .invalid(.invalidLimits))
    #expect(metadata.callCount == 0)

    let incompatible = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static, incompatibleLimits: true),
        capacities: validationCapacities(
            profile: .static,
            missing: "semantic-candidate",
            insufficient: "canvas-callable",
            overflow: true
        ),
        metadata: metadata
    )
    #expect(incompatible == .invalid(.incompatibleLimits))
    #expect(metadata.callCount == 0)

    let missing = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static),
        capacities: validationCapacities(
            profile: .static,
            missing: "semantic-candidate",
            insufficient: "canvas-callable",
            overflow: true
        ),
        metadata: metadata
    )
    #expect(missing == .invalid(.missingStorage))
    #expect(metadata.callCount == 0)

    let insufficient = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static),
        capacities: validationCapacities(
            profile: .static,
            insufficient: "canvas-callable",
            overflow: true
        ),
        metadata: metadata
    )
    #expect(insufficient == .invalid(.insufficientStorage))
    #expect(metadata.callCount == 0)

    let arithmetic = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static),
        capacities: validationCapacities(profile: .static, overflow: true),
        metadata: metadata
    )
    #expect(arithmetic == .invalid(.arithmeticOverflow))
    #expect(metadata.callCount == 0)

    let table = RuntimeProfileValidator.validateStatic(
        inputs: validationInputs(profile: .static),
        capacities: validationCapacities(profile: .static),
        metadata: metadata
    )
    #expect(table == .invalid(.staticCanvasTableInvalid))
    #expect(metadata.callCount == 0)
}

@Test
func staticCaptureStorageIsRequiredAndMustCoverItsConfiguredLimit() {
    let missing = RuntimeStorageCapacities(
        semanticCandidate: validationCapacities(profile: .static).semanticCandidate,
        semanticPublished: validationCapacities(profile: .static).semanticPublished,
        layoutCandidate: validationCapacities(profile: .static).layoutCandidate,
        render: validationCapacities(profile: .static).render,
        renderWorkspace: validationCapacities(profile: .static).renderWorkspace,
        canvasCallableOccurrences: 1,
        staticCanvasCaptureBytes: nil,
        pathPoints: 1,
        pathSubpaths: 1,
        drawingPlanStrokes: 1,
        drawingPlanPoints: 1,
        drawingPlanSubpaths: 1,
        normalizedStrokeOperations: 1,
        observableLiveLocations: 1,
        observableLiveRegistrations: 1,
        observableCandidateAssociations: 1,
        interactionCandidateActions: 1,
        interactionCandidateHitRegions: 1,
        interactionCommittedActions: 1,
        interactionCommittedHitRegions: 1,
        admissionQueue: validationCapacities(profile: .static).admissionQueue,
        sealedBatch: validationCapacities(profile: .static).sealedBatch,
        pointerStates: 2,
        coordinatorStatePresent: true,
        failureStatePresent: true,
        byteCounts: validationByteCounts()
    )
    #expect(
        RuntimeProfileValidator.validateStatic(
            inputs: validationInputs(profile: .static),
            capacities: missing,
            metadata: ValidStaticMetadata()
        ) == .invalid(.missingStorage)
    )

    let short = RuntimeStorageCapacities(
        semanticCandidate: missing.semanticCandidate,
        semanticPublished: missing.semanticPublished,
        layoutCandidate: missing.layoutCandidate,
        render: missing.render,
        renderWorkspace: missing.renderWorkspace,
        canvasCallableOccurrences: 1,
        staticCanvasCaptureBytes: 3,
        pathPoints: 1,
        pathSubpaths: 1,
        drawingPlanStrokes: 1,
        drawingPlanPoints: 1,
        drawingPlanSubpaths: 1,
        normalizedStrokeOperations: 1,
        observableLiveLocations: 1,
        observableLiveRegistrations: 1,
        observableCandidateAssociations: 1,
        interactionCandidateActions: 1,
        interactionCandidateHitRegions: 1,
        interactionCommittedActions: 1,
        interactionCommittedHitRegions: 1,
        admissionQueue: missing.admissionQueue,
        sealedBatch: missing.sealedBatch,
        pointerStates: 2,
        coordinatorStatePresent: true,
        failureStatePresent: true,
        byteCounts: validationByteCounts()
    )
    #expect(
        RuntimeProfileValidator.validateStatic(
            inputs: validationInputs(profile: .static),
            capacities: short,
            metadata: ValidStaticMetadata()
        ) == .invalid(.insufficientStorage)
    )
}
