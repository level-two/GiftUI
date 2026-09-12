import GiftUI
import GiftUIDrawing
import GiftUIDynamicConveniences
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import Testing

@testable import GiftUIRuntimeCore

@Test
func dynamicProfileTargetLoadsWithoutTheStaticProfile() {}

@Test
func dynamicStructuralIdentityRejectsZeroAndPreservesExactToken() {
    #expect(DynamicStructuralIdentity(rawValue: 0) == nil)
    #expect(DynamicStructuralIdentity(rawValue: 27)?.rawValue == 27)
}

@Test
func typedConstructionRetainsIdentityLimitsAndSuccessfulAudit() {
    let limits = dynamicLimits()
    let validation = RuntimeStorageAudit.checked(
        profile: .dynamic,
        limits: limits,
        byteCounts: dynamicByteCounts()
    )
    let identity = DynamicStructuralIdentity(rawValue: 9)!
    let construction = DynamicProfileConstruction(
        structuralIdentity: identity,
        validation: validation
    )

    #expect(construction?.structuralIdentity == identity)
    #expect(construction?.limits == limits)
    #expect(construction?.storageAudit == validation.audit)
}

@Test
func typedConstructionRejectsFailedOrNonDynamicAudit() {
    let identity = DynamicStructuralIdentity(rawValue: 1)!
    #expect(
        DynamicProfileConstruction(
            structuralIdentity: identity,
            validation: .invalid(.insufficientStorage)
        ) == nil
    )

    let staticLimits = dynamicLimits(profile: .static)
    let staticAudit = RuntimeStorageAudit.checked(
        profile: .static,
        limits: staticLimits,
        byteCounts: dynamicByteCounts()
    )
    #expect(
        DynamicProfileConstruction(
            structuralIdentity: identity,
            validation: staticAudit
        ) == nil
    )
}

@Test
func dynamicStorageAccountsEveryIndependentHeapRegion() {
    let identity = DynamicStructuralIdentity(rawValue: 41)!
    let byteCounts = dynamicByteCounts()
    let storage = DynamicProfileStorage(
        structuralIdentity: identity,
        limits: dynamicLimits(),
        byteCounts: byteCounts
    )
    let expectedAudit = RuntimeStorageAudit.checked(
        profile: .dynamic,
        limits: dynamicLimits(),
        byteCounts: byteCounts
    )

    #expect(storage?.structuralIdentity == identity)
    #expect(storage?.audit() == expectedAudit)
    #expect(storage?.audit().audit?.totalProfileBytes == 136)
    #expect(storage?.allocatorReport()?.ownedPayloadBytes == 136)
    #expect(storage?.allocatorReport()?.observedReservedPayloadBytes ?? 0 >= 136)
    #expect(storage?.allocatorReport()?.allocationCount == 16)
}

@Test
func everyDynamicLogicalDimensionAcceptsExactLimitAndRejectsFirstExcess() {
    var storage = DynamicProfileStorage(
        structuralIdentity: DynamicStructuralIdentity(rawValue: 2)!,
        limits: dynamicLimits(),
        byteCounts: dynamicByteCounts()
    )!

    #expect(DynamicStorageFamily.allCases.count == 16)
    #expect(DynamicStorageLimit.allCases.count == 51)
    let beganAttempt = storage.beginAttempt()
    #expect(beganAttempt)
    for limit in DynamicStorageLimit.allCases {
        let capacity = storage.use(for: limit).limit
        #expect(storage.reserve(capacity, for: limit) == .accepted)
        let fullUse = storage.use(for: limit)
        #expect(fullUse.current == capacity)
        #expect(fullUse.highWater == capacity)
        #expect(storage.reserve(1, for: limit) == .limitExceeded)
        #expect(storage.use(for: limit) == fullUse)
    }
}

@Test
func dynamicAttemptIsExclusiveAndResetPreservesCommittedAndPendingState() {
    var storage = makeDynamicStorage()
    let intent = PresentationPendingIntent(
        semanticRevision: SemanticRevision(rawValue: 8),
        retryableRefusalCount: 2
    )

    let beganAttempt = storage.beginAttempt()
    let beganReentrantAttempt = storage.beginAttempt()
    #expect(beganAttempt)
    #expect(!beganReentrantAttempt)
    #expect(storage.reserve(1, for: .interactionCandidateActions) == .accepted)
    #expect(storage.reserve(1, for: .interactionCommittedActions) == .accepted)
    storage.retainPresentationIntent(intent)
    storage.resetAttemptStorage()
    storage.finishAttempt()

    #expect(storage.storageLifetimeState == .idle)
    #expect(storage.use(for: .interactionCandidateActions).current == 0)
    #expect(storage.use(for: .interactionCommittedActions).current == 1)
    #expect(storage.retainedPresentationIntent == intent)
    #expect(storage.releaseCounters.attemptResetCount == 1)
    #expect(storage.releaseCounters.allStorageResetCount == 0)
}

@Test
func activeQuiescenceDefersMandatoryAttemptReleaseThenTearsDownOnce() {
    var storage = makeDynamicStorage()
    let beganAttempt = storage.beginAttempt()
    #expect(beganAttempt)
    #expect(storage.reserve(1, for: .drawingPlanStrokes) == .accepted)
    #expect(storage.reserve(1, for: .interactionCommittedActions) == .accepted)
    storage.retainPresentationIntent(
        PresentationPendingIntent(
            semanticRevision: SemanticRevision(rawValue: 3),
            retryableRefusalCount: 1
        )
    )

    storage.quiesce()
    #expect(storage.storageLifetimeState == .quiescenceRequested)
    #expect(storage.reserve(1, for: .failureState) == .unavailable)
    storage.finishAttempt()
    storage.quiesce()

    #expect(storage.storageLifetimeState == .tornDown)
    #expect(storage.use(for: .drawingPlanStrokes).current == 0)
    #expect(storage.use(for: .interactionCommittedActions).current == 0)
    #expect(storage.retainedPresentationIntent == nil)
    #expect(storage.releaseCounters.attemptResetCount == 1)
    #expect(storage.releaseCounters.allStorageResetCount == 1)
    #expect(storage.releaseCounters.quiescentTeardownCount == 1)
    let beganAfterTeardown = storage.beginAttempt()
    #expect(!beganAfterTeardown)
}

@Test
func allStorageResetIsEffectiveOnlyAtLegalLifetimeBoundaries() {
    var storage = makeDynamicStorage()
    storage.resetAllStorage()
    #expect(storage.releaseCounters.allStorageResetCount == 1)

    #expect(storage.reserve(1, for: .admissionInputEvents) == .accepted)
    storage.resetAllStorage()
    #expect(storage.use(for: .admissionInputEvents).current == 1)
    #expect(storage.releaseCounters.allStorageResetCount == 1)

    storage.quiesce()
    #expect(storage.use(for: .admissionInputEvents).current == 0)
    storage.resetAllStorage()
    #expect(storage.releaseCounters.allStorageResetCount == 3)
}

@Test
func optInDynamicDeinitializationCounterDoesNotDriveCorrectness() {
    let counter = DynamicStorageDeinitializationCounter()
    do {
        var storage = DynamicProfileStorage(
            structuralIdentity: DynamicStructuralIdentity(rawValue: 71)!,
            limits: dynamicLimits(),
            byteCounts: dynamicByteCounts(),
            deinitializationCounter: counter
        )!
        let beganAttempt = storage.beginAttempt()
        #expect(beganAttempt)
        storage.finishAttempt()
        #expect(counter.count == 0)
    }
    #expect(counter.count == 1)
}

@Test
func dynamicCanvasConvenienceIsExactlyThePortableCanvasContract() {
    let convenience = DynamicCanvas { _, _ in }
    let portable: Canvas = convenience
    #expect(type(of: portable) == Canvas.self)
}

@Test
func dynamicCanvasCallableStorageIsBoundedOrderedAndReleasesExactlyOnce() {
    let first = DynamicStructuralIdentity(rawValue: 1)!
    let second = DynamicStructuralIdentity(rawValue: 2)!
    var storage = DynamicCanvasCallableStorage<DynamicStructuralIdentity>(capacity: 2)

    let stagedFirst = storage.stage(identity: first, canvas: Canvas { _, _ in })
    let stagedDuplicate = storage.stage(identity: first, canvas: Canvas { _, _ in })
    let stagedSecond = storage.stage(identity: second, canvas: Canvas { _, _ in })
    let stagedExcess = storage.stage(
        identity: DynamicStructuralIdentity(rawValue: 3)!,
        canvas: Canvas { _, _ in }
    )
    #expect(stagedFirst)
    #expect(!stagedDuplicate)
    #expect(stagedSecond)
    #expect(!stagedExcess)
    #expect(storage.canvasOccurrenceCount == 2)
    #expect(storage.canvasIdentity(at: 0) == first)
    #expect(storage.canvasIdentity(at: 1) == second)
    #expect(storage.canvasIdentity(at: 2) == nil)

    storage.releaseCanvas(at: first)
    storage.releaseCanvas(at: first)
    #expect(storage.releaseCount == 1)
    storage.discard()
    #expect(storage.releaseCount == 2)
    #expect(storage.canvasOccurrenceCount == 0)
}

@Test
func dynamicBindingUsesCommonLifecycleAndOwnsAttemptCleanup() {
    let identity = DynamicStructuralIdentity(rawValue: 81)!
    var binding = DynamicRuntimeProfileBinding(
        structuralIdentity: identity,
        limits: dynamicLimits(),
        byteCounts: dynamicByteCounts()
    )!
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 5),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )

    let profile = binding.profile
    let auditProfile = binding.storageAudit?.profile
    #expect(profile == .dynamic)
    #expect(auditProfile == .dynamic)
    #expect(binding.beginOpportunity(context: active) == nil)
    #expect(binding.beginOpportunity(context: active) == .reentrancyViolation)
    #expect(binding.reserve(1, for: .drawingPlanStrokes) == .accepted)
    let staged = binding.stageCanvas(identity: identity, canvas: Canvas { _, _ in })
    let stagedOccurrenceCount = binding.canvasOccurrenceCount
    #expect(staged)
    #expect(stagedOccurrenceCount == 1)

    #expect(binding.finishOpportunity(context: idleExecutionContext()) == nil)
    let finishedContext = binding.executionContext
    let finishedStorageState = binding.storageLifetimeState
    let finishedOccurrenceCount = binding.canvasOccurrenceCount
    let releaseCount = binding.canvasReleaseCount
    let attemptResetCount = binding.releaseCounters.attemptResetCount
    #expect(finishedContext == idleExecutionContext())
    #expect(finishedStorageState == .idle)
    #expect(finishedOccurrenceCount == 0)
    #expect(releaseCount == 1)
    #expect(attemptResetCount == 1)
}

@Test
func dynamicBindingDefersActiveQuiescenceThenTearsDownOnce() {
    var binding = DynamicRuntimeProfileBinding(
        structuralIdentity: DynamicStructuralIdentity(rawValue: 82)!,
        limits: dynamicLimits(),
        byteCounts: dynamicByteCounts()
    )!
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 6),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )

    #expect(binding.beginOpportunity(context: active) == nil)
    binding.quiesce()
    let activeQuiescence = binding.isQuiescent
    let requestedStorageState = binding.storageLifetimeState
    #expect(!activeQuiescence)
    #expect(requestedStorageState == .quiescenceRequested)
    #expect(binding.beginOpportunity(context: active) == .reentrancyViolation)

    #expect(binding.finishOpportunity(context: idleExecutionContext()) == nil)
    let finishedQuiescence = binding.isQuiescent
    let tornDownStorageState = binding.storageLifetimeState
    let firstTeardownCount = binding.releaseCounters.quiescentTeardownCount
    #expect(finishedQuiescence)
    #expect(tornDownStorageState == .tornDown)
    #expect(firstTeardownCount == 1)
    binding.quiesce()
    let secondTeardownCount = binding.releaseCounters.quiescentTeardownCount
    #expect(secondTeardownCount == 1)
    #expect(binding.beginOpportunity(context: active) == .requiredFacilityUnavailable)
}

#if GIFTUI_DYNAMIC_PROFILE
    @Test
    func dynamicCanvasCallableInvokesExactPayloadAndRejectsReleasedOccurrence() throws {
        let identity = DynamicStructuralIdentity(rawValue: 4)!
        var invocationCount = 0
        var observedSize: Size?
        var storage = DynamicCanvasCallableStorage<DynamicStructuralIdentity>(capacity: 1)
        let staged = storage.stage(
            identity: identity,
            canvas: Canvas { _, size in
                invocationCount += 1
                observedSize = size
            }
        )
        #expect(staged)

        let size = Size(width: 7, height: 11)!
        try withDynamicCanvasContext { context in
            try storage.invokeCanvas(
                at: identity,
                context: &context,
                size: size
            )
        }
        storage.releaseCanvas(at: identity)

        #expect(invocationCount == 1)
        #expect(observedSize == size)
        #expect(throws: DrawingError.invariantViolation) {
            try withDynamicCanvasContext { context in
                try storage.invokeCanvas(
                    at: identity,
                    context: &context,
                    size: size
                )
            }
        }
    }

    private struct DynamicCanvasContextStorage {}

    private let dynamicCanvasOperations = _GiftUIDrawingOperations(
        beginPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        endPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        movePath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        addLineToPath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        strokePath: { _, _, _, _, _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue }
    )

    private func withDynamicCanvasContext<Result>(
        _ body: (inout GraphicsContext) throws -> Result
    ) throws -> Result {
        var contextStorage = DynamicCanvasContextStorage()
        return try withUnsafeMutablePointer(to: &contextStorage) { pointer in
            var context = GraphicsContext(
                storage: UnsafeMutableRawPointer(pointer),
                generation: 1,
                operations: dynamicCanvasOperations
            )
            return try body(&context)
        }
    }
#endif

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}

private func dynamicLimits(
    profile: RuntimeProfileKind = .dynamic
) -> RuntimeProfileLimits {
    RuntimeProfileLimits(
        semantic: SemanticExpansionLimits(
            maximumDepth: 1,
            maximumSemanticNodes: 1,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 1,
            maximumActionOccurrences: 1
        )!,
        layout: LayoutLimits(
            maximumScopes: 1,
            maximumDepth: 1,
            maximumTextScalars: 1,
            maximumTextLines: 1,
            maximumPositionedGlyphs: 1
        )!,
        render: RenderLimits(
            maximumOperations: 2,
            maximumPositionedGlyphs: 1,
            maximumClipDepth: 1
        )!,
        renderWorkspace: RenderWorkspaceCapacity(
            maximumSemanticScopes: 1,
            maximumLayoutScopes: 1,
            maximumTraversalDepth: 1,
            maximumTextLines: 1
        )!,
        renderSink: RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 1),
        maximumOrdinaryRenderOperations: 1,
        execution: ExecutionLimits(
            maximumInputEvents: 1,
            maximumStateChangeFacts: 1,
            maximumCompletionFacts: 1,
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

private func dynamicByteCounts() -> RuntimeStorageByteCounts {
    RuntimeStorageByteCounts(
        semanticCandidateBytes: 1,
        semanticPublishedBytes: 2,
        layoutCandidateBytes: 3,
        renderWorkspaceBytes: 4,
        canvasCallableBytes: 5,
        pathWorkspaceBytes: 6,
        drawingPlanBytes: 7,
        observableLiveBytes: 8,
        observableCandidateBytes: 9,
        interactionCandidateBytes: 10,
        interactionCommittedBytes: 11,
        admissionQueueBytes: 12,
        sealedBatchBytes: 13,
        pointerStateBytes: 14,
        coordinatorStateBytes: 15,
        failureStateBytes: 16
    )
}

private func makeDynamicStorage() -> DynamicProfileStorage {
    DynamicProfileStorage(
        structuralIdentity: DynamicStructuralIdentity(rawValue: 17)!,
        limits: dynamicLimits(),
        byteCounts: dynamicByteCounts()
    )!
}

private func idleExecutionContext() -> ExecutionContext {
    ExecutionContext(
        cycle: nil,
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .idle
    )
}
