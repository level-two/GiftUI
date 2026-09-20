import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUIRuntimeStatic
import GiftUISemanticCore
import Testing

private struct DifferentialInputs: Equatable {
    let root = UInt16(1)
    let resources = UInt16(2)
    let limits = UInt16(3)
    let initialModel = UInt16(4)
    let facts = UInt16(5)
    let pointers = UInt16(6)
    let capabilities = UInt16(7)
    let endpointScript = UInt16(8)
    let policy = UInt16(9)
}

private struct DifferentialTranscript: Equatable {
    let inputs: DifferentialInputs
    let validation: UInt32
    let lifecycle: ExecutionContext
    let admission: UInt16
    let mutation: UInt16
    let semantic: UInt16
    let layout: UInt16
    let drawing: UInt16
    let render: UInt16
    let interaction: UInt16
    let offer: UInt16
    let failure: UInt16
    let cleanup: [RuntimeCleanupAction]
    let result: RuntimeCompletePipelineResult
    let finalization: UInt16
}

private struct DifferentialPipelineOwner: RuntimeCompletePipelineOwner {
    private(set) var stages: [RuntimeCompletePipelineStage] = []
    private(set) var cleanups: [RuntimeCleanupAction] = []
    private(set) var finalizationCount = UInt16(0)

    mutating func admitAndSeal() -> RuntimePipelineStepResult { step(.admissionAndSeal) }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult {
        stages.append(.applyAdmittedWork)
        return .applied(true)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult {
        step(.freezeObservableMutation)
    }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult {
        step(.observableCandidateAndSemanticExpansion)
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult { step(.layout) }

    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult {
        step(.canvasInvocationAndPlan)
    }

    mutating func preflightCombinedRender() -> RuntimePipelineStepResult {
        step(.combinedRenderPreflight)
    }

    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult {
        step(.interactionCandidate)
    }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult {
        stages.append(.semanticAndObservablePublication)
        return .published(
            RuntimePipelinePublication(
                semanticRevision: SemanticRevision(rawValue: 7),
                changed: true
            )
        )
    }

    mutating func allocateCandidate() -> RuntimePipelineStepResult { step(.candidateAllocation) }

    mutating func offerAndProduce() -> RuntimePipelineOfferResult {
        stages.append(.offerAndProduction)
        return .accepted(PresentationRevision(rawValue: 9))
    }

    mutating func cleanup(_ action: RuntimeCleanupAction) { cleanups.append(action) }
    mutating func applyDisposition(_: RuntimePipelineDisposition) {}
    mutating func finalizePipeline() { finalizationCount += 1 }

    private mutating func step(_ stage: RuntimeCompletePipelineStage) -> RuntimePipelineStepResult {
        stages.append(stage)
        return .advanced
    }
}

private struct DifferentialStaticRegions: StaticProfileStorageRegions {
    let byteCounts = differentialByteCounts()
    private var regionByte: UInt8 = 0
    mutating func withRegion<Result>(
        _: RuntimeStorageFamily,
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &regionByte, body)
    }
    mutating func resetAttemptRegions() {}
    mutating func resetAllRegions() {}
}

private struct DifferentialStaticMetadata:
    RuntimeStaticCanvasAuditMetadata, StaticCanvasCallableTable
{
    typealias CaptureStorage = UInt8
    let callableCaseCount = UInt16(1)
    let declaredEntryCount = UInt16(1)
    let maximumDeclaredID = UInt16(1)

    func coverageMultiplicity(for id: UInt16) -> UInt8 { id == 1 ? 1 : 0 }
    func captureByteCount(for id: UInt16) -> UInt16? { id == 1 ? 1 : nil }

    mutating func invoke(
        id _: UInt16,
        captures _: borrowing UInt8,
        context _: inout GraphicsContext,
        size _: Size
    ) throws(DrawingError) {}
}

private struct DifferentialAdmission: ExecutionAdmissionSink {
    private(set) var submittedStateChanges = UInt16(0)
    private(set) var submittedCompletions = UInt16(0)

    mutating func submit(pointer _: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        outcome(.queued)
    }

    mutating func submit(stateChange _: UInt16) -> ExecutionAdmissionOutcome {
        submittedStateChanges += 1
        return outcome(.queued)
    }

    mutating func submit(completion _: UInt8) -> ExecutionAdmissionOutcome {
        submittedCompletions += 1
        return outcome(.queued)
    }

    private func outcome(_ result: ExecutionAdmissionResult) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(
            result: result,
            context: ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
        )
    }
}

private struct DifferentialOpportunity: ExecutionOpportunityRunner {
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        .failure(
            ExecutionContext(
                cycle: RunCycleID(rawValue: 1),
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .deriving
            ),
            .focusedOwner(.drawing(.invalidValue)),
            nil
        )
    }
}

@Test
func dynamicAndStaticBindingsProduceEqualCanonicalTranscripts() {
    let inputs = DifferentialInputs()
    var dynamic = DynamicRuntimeProfileBinding(
        structuralIdentity: DynamicStructuralIdentity(rawValue: 1)!,
        limits: differentialLimits(profile: .dynamic),
        byteCounts: differentialByteCounts()
    )!
    var fixed = StaticRuntimeProfileBinding(
        structuralIdentity: StaticStructuralIdentity(rawValue: 1)!,
        limits: differentialLimits(profile: .static),
        regions: DifferentialStaticRegions(),
        metadata: DifferentialStaticMetadata()
    )!
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )
    let idle = ExecutionContext(
        cycle: nil,
        semanticRevision: SemanticRevision(rawValue: 7),
        candidateFrame: nil,
        phase: .idle
    )
    #expect(dynamic.beginOpportunity(context: active) == nil)
    #expect(fixed.beginOpportunity(context: active) == nil)
    var dynamicOwner = DifferentialPipelineOwner()
    var staticOwner = DifferentialPipelineOwner()
    let dynamicResult = dynamic.runActivePipeline(owner: &dynamicOwner)
    let staticResult = fixed.runActivePipeline(owner: &staticOwner)
    #expect(dynamic.finishOpportunity(context: idle) == nil)
    #expect(fixed.finishOpportunity(context: idle) == nil)

    let dynamicTranscript = DifferentialTranscript(
        inputs: inputs,
        validation: dynamic.storageAudit?.totalProfileBytes ?? 0,
        lifecycle: dynamic.executionContext,
        admission: stageCount(.admissionAndSeal, in: dynamicOwner),
        mutation: stageCount(.applyAdmittedWork, in: dynamicOwner)
            + stageCount(.freezeObservableMutation, in: dynamicOwner),
        semantic: stageCount(.observableCandidateAndSemanticExpansion, in: dynamicOwner)
            + stageCount(.semanticAndObservablePublication, in: dynamicOwner),
        layout: stageCount(.layout, in: dynamicOwner),
        drawing: stageCount(.canvasInvocationAndPlan, in: dynamicOwner),
        render: stageCount(.combinedRenderPreflight, in: dynamicOwner),
        interaction: stageCount(.interactionCandidate, in: dynamicOwner),
        offer: stageCount(.candidateAllocation, in: dynamicOwner)
            + stageCount(.offerAndProduction, in: dynamicOwner),
        failure: failureCount(in: dynamicResult),
        cleanup: dynamicOwner.cleanups,
        result: dynamicResult,
        finalization: dynamicOwner.finalizationCount
    )
    let staticTranscript = DifferentialTranscript(
        inputs: inputs,
        validation: fixed.storageAudit?.totalProfileBytes ?? 0,
        lifecycle: fixed.executionContext,
        admission: stageCount(.admissionAndSeal, in: staticOwner),
        mutation: stageCount(.applyAdmittedWork, in: staticOwner)
            + stageCount(.freezeObservableMutation, in: staticOwner),
        semantic: stageCount(.observableCandidateAndSemanticExpansion, in: staticOwner)
            + stageCount(.semanticAndObservablePublication, in: staticOwner),
        layout: stageCount(.layout, in: staticOwner),
        drawing: stageCount(.canvasInvocationAndPlan, in: staticOwner),
        render: stageCount(.combinedRenderPreflight, in: staticOwner),
        interaction: stageCount(.interactionCandidate, in: staticOwner),
        offer: stageCount(.candidateAllocation, in: staticOwner)
            + stageCount(.offerAndProduction, in: staticOwner),
        failure: failureCount(in: staticResult),
        cleanup: staticOwner.cleanups,
        result: staticResult,
        finalization: staticOwner.finalizationCount
    )

    #expect(dynamicTranscript == staticTranscript)
}

@Test func dynamicAndStaticExecutionCoordinatorsUseTheCommonProtocolSeams() {
    var dynamicBinding = DynamicRuntimeProfileBinding(
        structuralIdentity: DynamicStructuralIdentity(rawValue: 31)!,
        limits: differentialLimits(profile: .dynamic),
        byteCounts: differentialByteCounts()
    )!
    var staticBinding = StaticRuntimeProfileBinding(
        structuralIdentity: StaticStructuralIdentity(rawValue: 31)!,
        limits: differentialLimits(profile: .static),
        regions: DifferentialStaticRegions(),
        metadata: DifferentialStaticMetadata()
    )!

    withUnsafeMutablePointer(to: &dynamicBinding) { dynamicPointer in
        withUnsafeMutablePointer(to: &staticBinding) { staticPointer in
            var dynamic = DynamicRuntimeExecutionCoordinator(
                binding: dynamicPointer,
                admission: DifferentialAdmission(),
                opportunity: DifferentialOpportunity()
            )
            var fixed = StaticRuntimeExecutionCoordinator(
                binding: StaticRuntimeExecutionBindingAdapter(binding: staticPointer),
                admission: DifferentialAdmission(),
                opportunity: DifferentialOpportunity()
            )

            let dynamicState = submitStateChange(UInt16(7), to: &dynamic)
            let staticState = submitStateChange(UInt16(7), to: &fixed)
            let dynamicCompletion = submitCompletion(UInt8(9), to: &dynamic)
            let staticCompletion = submitCompletion(UInt8(9), to: &fixed)
            let dynamicResult = runOpportunity(with: &dynamic)
            let staticResult = runOpportunity(with: &fixed)

            #expect(dynamicState == staticState)
            #expect(dynamicCompletion == staticCompletion)
            #expect(dynamicResult == staticResult)
            #expect(dynamic.admission.submittedStateChanges == 1)
            #expect(fixed.admission.submittedStateChanges == 1)
            #expect(dynamic.admission.submittedCompletions == 1)
            #expect(fixed.admission.submittedCompletions == 1)

            dynamic.quiesce()
            fixed.quiesce()
            #expect(submitStateChange(UInt16(8), to: &dynamic).result == .unavailable)
            #expect(submitStateChange(UInt16(8), to: &fixed).result == .unavailable)
            #expect(runOpportunity(with: &dynamic) == runOpportunity(with: &fixed))
        }
    }
}

private struct InteractionProfileTranscript: Equatable {
    let begin: InteractionError?
    let first: InteractionCandidateAppendResult
    let second: InteractionCandidateAppendResult
    let excess: InteractionCandidateAppendResult
    let firstAssignment: InteractionError?
    let secondAssignment: InteractionError?
    let finish: InteractionError?
    let firstRecord: BoundActionRecord<UInt16>?
    let down: PointerGestureOutcome<UInt16>
}

@Test func dynamicAndStaticInteractionStorageProduceEqualBoundedTranscripts() {
    var dynamic = DynamicInteractionState<UInt16>(
        candidateRecords: DynamicInteractionCandidateStorage(capacity: 2),
        candidateHitRegions: DynamicInteractionHitStorage(capacity: 2),
        candidateCommittedRecords: DynamicInteractionCommittedStorage(capacity: 2),
        committedRecords: DynamicInteractionCommittedStorage(capacity: 2),
        committedHitRegions: DynamicInteractionHitStorage(capacity: 2)
    )
    var fixed = StaticInteractionState<UInt16>(
        candidateRecords: StaticInteractionCandidateStorage(capacity: 2)!,
        candidateHitRegions: StaticInteractionHitStorage(capacity: 2)!,
        candidateCommittedRecords: StaticInteractionCommittedStorage(capacity: 2)!,
        committedRecords: StaticInteractionCommittedStorage(capacity: 2)!,
        committedHitRegions: StaticInteractionHitStorage(capacity: 2)!
    )

    #expect(interactionTranscript(from: &dynamic) == interactionTranscript(from: &fixed))
}

private func interactionTranscript<State>(
    from state: inout State
) -> InteractionProfileTranscript
where
    State: InteractionCandidateBuilder & InteractionCommittedActionView
        & InteractionGestureResolver,
    State.Identity == UInt16
{
    let limits = InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
    let bounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 8, height: 8)!
    )!
    let begin = state.beginCandidate(limits: limits)
    let first = state.append(
        identity: 1,
        isEnabled: true,
        bounds: bounds,
        clip: bounds,
        paintOrder: 0,
        action: BoundedApplicationAction(code: 1),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
    let second = state.append(
        identity: 2,
        isEnabled: true,
        bounds: bounds,
        clip: bounds,
        paintOrder: 1,
        action: BoundedApplicationAction(code: 2),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
    let excess = state.append(
        identity: 3,
        isEnabled: true,
        bounds: bounds,
        clip: bounds,
        paintOrder: 2,
        action: BoundedApplicationAction(code: 3),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
    state.resolveCandidate(.discard)

    _ = state.beginCandidate(limits: limits)
    _ = state.append(
        identity: 1,
        isEnabled: true,
        bounds: bounds,
        clip: bounds,
        paintOrder: 0,
        action: BoundedApplicationAction(code: 1),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
    _ = state.append(
        identity: 2,
        isEnabled: true,
        bounds: bounds,
        clip: bounds,
        paintOrder: 1,
        action: BoundedApplicationAction(code: 2),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
    let firstAssignment = state.assignGeneration(ActionGeneration(rawValue: 1), to: 1)
    let secondAssignment = state.assignGeneration(ActionGeneration(rawValue: 2), to: 2)
    let finish = state.finishCandidate()
    state.resolveCandidate(.commit(PresentationRevision(rawValue: 1)))
    return InteractionProfileTranscript(
        begin: begin,
        first: first,
        second: second,
        excess: excess,
        firstAssignment: firstAssignment,
        secondAssignment: secondAssignment,
        finish: finish,
        firstRecord: state.committedRecord(for: 1),
        down: state.resolveDown(at: Point(x: 2, y: 2))
    )
}

private func submitStateChange<Sink: ExecutionAdmissionSink>(
    _ fact: Sink.StateChangeFact,
    to sink: inout Sink
) -> ExecutionAdmissionOutcome {
    sink.submit(stateChange: fact)
}

private func submitCompletion<Sink: ExecutionAdmissionSink>(
    _ fact: Sink.CompletionFact,
    to sink: inout Sink
) -> ExecutionAdmissionOutcome {
    sink.submit(completion: fact)
}

private func runOpportunity<Runner: ExecutionOpportunityRunner>(
    with runner: inout Runner
) -> RunCycleResult<Runner.OwnerFailure> {
    runner.runOpportunity()
}

private func stageCount(
    _ stage: RuntimeCompletePipelineStage,
    in owner: DifferentialPipelineOwner
) -> UInt16 {
    UInt16(owner.stages.count(where: { $0 == stage }))
}

private func failureCount(in result: RuntimeCompletePipelineResult) -> UInt16 {
    if case .failed = result { return 1 }
    return 0
}

private func differentialLimits(profile: RuntimeProfileKind) -> RuntimeProfileLimits {
    RuntimeProfileLimits(
        semantic: SemanticExpansionLimits(
            maximumDepth: 2,
            maximumSemanticNodes: 2,
            maximumBodyEvaluations: 2,
            maximumModifierApplications: 2,
            maximumActionOccurrences: 1
        )!,
        maximumSemanticStructuralOccurrences: 2,
        layout: LayoutLimits(
            maximumScopes: 2,
            maximumDepth: 2,
            maximumTextScalars: 2,
            maximumTextLines: 2,
            maximumPositionedGlyphs: 2
        )!,
        render: RenderLimits(
            maximumOperations: 2,
            maximumPositionedGlyphs: 2,
            maximumClipDepth: 2
        )!,
        renderWorkspace: RenderWorkspaceCapacity(
            maximumSemanticScopes: 2,
            maximumLayoutScopes: 2,
            maximumTraversalDepth: 2,
            maximumTextLines: 2
        )!,
        renderSink: RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 2),
        maximumOrdinaryRenderOperations: 1,
        execution: ExecutionLimits(
            maximumInputEvents: 2,
            maximumStateChangeFacts: 2,
            maximumCompletionFacts: 2,
            maximumSemanticActions: 1,
            maximumActiveInputSources: 1,
            maximumCommittedActions: 1
        )!,
        observableState: ObservableStateLimits(
            maximumLocations: 1,
            maximumRegistrations: 1,
            maximumStagedAssociations: 1
        )!,
        interaction: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
        drawing: DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 1,
            maximumLivePathPoints: 1,
            maximumLivePathSubpaths: 1,
            maximumPlanStrokes: 1,
            maximumPlanPoints: 1,
            maximumPlanSubpaths: 1,
            maximumNormalizedStrokeOperations: 1
        )!,
        staticCanvas: profile == .static
            ? StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 1)
            : nil,
        profile: profile
    )!
}

private func differentialByteCounts() -> RuntimeStorageByteCounts {
    RuntimeStorageByteCounts(
        semanticCandidateBytes: 1,
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
