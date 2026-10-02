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
    let result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>
    let finalization: UInt16
}

private struct DifferentialPipelineOwner: RuntimeCompletePipelineOwner {
    private(set) var stages: [RuntimeCompletePipelineStage] = []
    private(set) var cleanups: [RuntimeCleanupAction] = []
    private(set) var finalizationCount = UInt16(0)

    mutating func admitAndSeal() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.admissionAndSeal)
    }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<RuntimeOwnerFailure> {
        stages.append(.applyAdmittedWork)
        return .applied(true)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.freezeObservableMutation)
    }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<
        RuntimeOwnerFailure
    > {
        step(.observableCandidateAndSemanticExpansion)
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.layout)
    }

    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.canvasInvocationAndPlan)
    }

    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.combinedRenderPreflight)
    }

    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.interactionCandidate)
    }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<
        RuntimeOwnerFailure
    > {
        stages.append(.semanticAndObservablePublication)
        return .published(
            RuntimePipelinePublication(
                semanticRevision: SemanticRevision(rawValue: 7),
                changed: true
            )
        )
    }

    mutating func allocateCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        step(.candidateAllocation)
    }

    mutating func offerAndProduce() -> RuntimePipelineOfferResult<RuntimeOwnerFailure> {
        stages.append(.offerAndProduction)
        return .accepted(PresentationRevision(rawValue: 9))
    }

    mutating func cleanup(_ action: RuntimeCleanupAction) { cleanups.append(action) }
    mutating func applyDisposition(_: RuntimePipelineDisposition) {}
    mutating func finalizePipeline() { finalizationCount += 1 }

    private mutating func step(_ stage: RuntimeCompletePipelineStage) -> RuntimePipelineStepResult<
        RuntimeOwnerFailure
    > {
        stages.append(stage)
        return .advanced
    }
}

private struct DifferentialStaticRegions: StaticProfileStorageRegions {
    let byteCounts = differentialByteCounts()
    private var regionByte: UInt8 = 0
    private var publishedByte: UInt8 = 0
    private var layoutByte: UInt8 = 0
    private var renderByte: UInt8 = 0
    private var pathByte: UInt8 = 0
    private var planByte: UInt8 = 0
    mutating func withRegion<Result>(
        _: RuntimeStorageFamily,
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &regionByte, body)
    }
    mutating func withSemanticRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &regionByte) { candidate in
            try withUnsafeMutableBytes(of: &publishedByte) { published in
                try body(candidate, published)
            }
        }
    }
    mutating func withLayoutRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &regionByte) { layout in
            try withUnsafeMutableBytes(of: &publishedByte) { render in
                try body(layout, render)
            }
        }
    }
    mutating func withSemanticCandidateAndLayoutRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &regionByte) { semantic in
            try withUnsafeMutableBytes(of: &layoutByte) { layout in
                try withUnsafeMutableBytes(of: &renderByte) { render in
                    try body(semantic, layout, render)
                }
            }
        }
    }
    mutating func withPresentationRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer, UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer, UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        try withUnsafeMutableBytes(of: &regionByte) { semantic in
            try withUnsafeMutableBytes(of: &layoutByte) { layout in
                try withUnsafeMutableBytes(of: &renderByte) { render in
                    try withUnsafeMutableBytes(of: &pathByte) { path in
                        try withUnsafeMutableBytes(of: &planByte) { plan in
                            try body(semantic, layout, render, path, plan)
                        }
                    }
                }
            }
        }
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

private func failureCount(in result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>) -> UInt16 {
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

private enum PartialMutationApplicationFailure: UInt8, Equatable, Sendable {
    case captureRevisionMismatch
    case reservedFailureCapacityExhausted
}

private enum PartialMutationOwnerFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case application(PartialMutationApplicationFailure)
}

private let partialMutationContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 1), semanticRevision: nil,
    candidateFrame: nil, phase: .mutating
)

private struct PartialMutationPipelineOwner: RuntimeCompletePipelineOwner {
    var rejectedAfterEffects: UInt16?
    private(set) var appliedEffects: UInt16 = 0
    private(set) var admittedEffects: UInt16 = 0
    var failureState = RuntimeFocusedFailureState<PartialMutationOwnerFailure>()
    private(set) var lastDisposition: RuntimePipelineDisposition?
    private(set) var stages: [RuntimeCompletePipelineStage] = []
    private(set) var cleanups: [RuntimeCleanupAction] = []
    private(set) var finalizationCount = UInt16(0)

    mutating func admitAndSeal() -> RuntimePipelineStepResult<PartialMutationOwnerFailure> {
        step(.admissionAndSeal)
    }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<PartialMutationOwnerFailure>
    {
        stages.append(.applyAdmittedWork)
        let rejection = rejectedAfterEffects
        let effectCount = rejection ?? 0
        admittedEffects += effectCount
        appliedEffects += effectCount
        rejectedAfterEffects = nil
        if rejection != nil {
            let failure = PartialMutationOwnerFailure.application(.captureRevisionMismatch)
            failureState.captureFirst(failure, context: partialMutationContext)
            return .failure(.focusedOwner(failure), mutationApplied: effectCount > 0)
        }
        return .applied(false)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<
        PartialMutationOwnerFailure
    > {
        step(.freezeObservableMutation)
    }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<
        PartialMutationOwnerFailure
    > {
        step(.observableCandidateAndSemanticExpansion)
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult<PartialMutationOwnerFailure> {
        step(.layout)
    }

    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<
        PartialMutationOwnerFailure
    > {
        step(.canvasInvocationAndPlan)
    }

    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<
        PartialMutationOwnerFailure
    > {
        step(.combinedRenderPreflight)
    }

    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<
        PartialMutationOwnerFailure
    > {
        step(.interactionCandidate)
    }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<
        PartialMutationOwnerFailure
    > {
        stages.append(.semanticAndObservablePublication)
        return .published(
            RuntimePipelinePublication(
                semanticRevision: SemanticRevision(rawValue: 7),
                changed: true
            )
        )
    }

    mutating func allocateCandidate() -> RuntimePipelineStepResult<PartialMutationOwnerFailure> {
        step(.candidateAllocation)
    }

    mutating func offerAndProduce() -> RuntimePipelineOfferResult<PartialMutationOwnerFailure> {
        stages.append(.offerAndProduction)
        return .accepted(PresentationRevision(rawValue: 9))
    }

    mutating func cleanup(_ action: RuntimeCleanupAction) { cleanups.append(action) }
    mutating func applyDisposition(_ value: RuntimePipelineDisposition) { lastDisposition = value }
    mutating func finalizePipeline() { finalizationCount += 1 }

    private mutating func step(_ stage: RuntimeCompletePipelineStage) -> RuntimePipelineStepResult<
        PartialMutationOwnerFailure
    > {
        stages.append(stage)
        return .advanced
    }
}

@Test(arguments: [UInt16(0), 1, 3])
func partialMutationFailurePreservesExactProgressAndNeverReplaysAcrossProfiles(effectCount: UInt16)
{
    var dynamic = DynamicRuntimeProfileBinding(
        structuralIdentity: DynamicStructuralIdentity(rawValue: 1)!,
        limits: differentialLimits(profile: .dynamic), byteCounts: differentialByteCounts()
    )!
    var fixed = StaticRuntimeProfileBinding(
        structuralIdentity: StaticStructuralIdentity(rawValue: 1)!,
        limits: differentialLimits(profile: .static),
        regions: DifferentialStaticRegions(), metadata: DifferentialStaticMetadata()
    )!
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 1), semanticRevision: nil,
        candidateFrame: nil, phase: .admitting)
    let idle = ExecutionContext(
        cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    #expect(dynamic.beginOpportunity(context: active) == nil)
    #expect(fixed.beginOpportunity(context: active) == nil)
    var dynamicOwner = PartialMutationPipelineOwner(rejectedAfterEffects: effectCount)
    var staticOwner = PartialMutationPipelineOwner(rejectedAfterEffects: effectCount)
    let dynamicResult = dynamic.runActivePipeline(owner: &dynamicOwner)
    let staticResult = fixed.runActivePipeline(owner: &staticOwner)
    #expect(dynamicResult == staticResult)
    guard case .failed(let record) = dynamicResult else {
        Issue.record("expected admitted-work rejection")
        return
    }
    #expect(record.stage == .applyAdmittedWork)
    #expect(record.failure == .focusedOwner(.application(.captureRevisionMismatch)))
    #expect(record.disposition.semanticDisposition == (effectCount > 0 ? .dirty : .unchanged))
    #expect(record.disposition.wakeReasons == (effectCount > 0 ? [.semanticDirty] : []))
    #expect(dynamicOwner.stages == [.admissionAndSeal, .applyAdmittedWork])
    #expect(staticOwner.stages == dynamicOwner.stages)
    #expect(dynamicOwner.cleanups.isEmpty && staticOwner.cleanups.isEmpty)
    #expect(dynamicOwner.finalizationCount == 1 && staticOwner.finalizationCount == 1)
    #expect(dynamicOwner.failureState.selectedFailure()?.context == partialMutationContext)
    #expect(dynamicOwner.failureState.selectedFailure()?.failure == record.failure)
    dynamicOwner.failureState.captureFirst(
        .application(.reservedFailureCapacityExhausted),
        context: idle)
    dynamicOwner.failureState.recordCleanupFailure(containment: .safetyNotProven)
    #expect(dynamicOwner.failureState.selectedFailure()?.context == partialMutationContext)
    #expect(dynamicOwner.failureState.selectedFailure()?.failure == record.failure)
    #expect(dynamicOwner.failureState.cleanupContainment == .safetyNotProven)
    #expect(dynamic.finishOpportunity(context: idle) == nil)
    #expect(fixed.finishOpportunity(context: idle) == nil)
    #expect(dynamic.beginOpportunity(context: active) == nil)
    #expect(fixed.beginOpportunity(context: active) == nil)
    let recovery = dynamic.runActivePipeline(owner: &dynamicOwner)
    #expect(recovery == fixed.runActivePipeline(owner: &staticOwner))
    guard case .completed = recovery else {
        Issue.record("expected rederivation")
        return
    }
    #expect(dynamicOwner.appliedEffects == effectCount && staticOwner.appliedEffects == effectCount)
    #expect(
        dynamicOwner.admittedEffects == effectCount && staticOwner.admittedEffects == effectCount)
    #expect(dynamicOwner.finalizationCount == 2 && staticOwner.finalizationCount == 2)
    #expect(dynamic.finishOpportunity(context: idle) == nil)
    #expect(fixed.finishOpportunity(context: idle) == nil)
    dynamic.quiesce()
    fixed.quiesce()
    #expect(dynamic.beginOpportunity(context: active) != nil)
    #expect(fixed.beginOpportunity(context: active) != nil)
    let count = dynamicOwner.stages.count
    #expect(
        dynamic.runActivePipeline(owner: &dynamicOwner)
            == fixed.runActivePipeline(owner: &staticOwner))
    #expect(dynamicOwner.stages.count == count)
}
