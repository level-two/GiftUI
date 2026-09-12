import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import Testing

@Test
func generatedStaticMetadataBindsDenseSlotsActionsAndCanvasCoverage() {
    let metadata = GeneratedRuntimeMetadata(
        observableSlots: GeneratedObservableSlots(),
        action: GeneratedProfileAction.self,
        canvasTable: GeneratedRuntimeCanvasTable(),
        canvasCoverage: GeneratedCanvasCoverage()
    )

    #expect(metadata?.observableSlots.slotCount == 2)
    #expect(metadata?.observableSlots.structuralIdentity(for: 0) == .primary)
    #expect(metadata?.observableSlots.structuralIdentity(for: 1) == .secondary)
    #expect(metadata?.observableSlots.structuralIdentity(for: 2) == nil)
    #expect(
        metadata?.actionSpecialization.decode(BoundedApplicationAction(code: 1)) == .second
    )
    #expect(metadata?.actionSpecialization.decode(BoundedApplicationAction(code: 2)) == nil)
    #expect(metadata?.callableCaseCount == 3)
    #expect(metadata?.declaredEntryCount == 3)
    #expect(metadata?.maximumDeclaredID == 3)
    #expect(metadata?.coverageMultiplicity(for: 0) == 0)
    #expect(metadata?.coverageMultiplicity(for: 1) == 1)
    #expect(metadata?.coverageMultiplicity(for: 2) == 1)
    #expect(metadata?.coverageMultiplicity(for: 3) == 1)
    #expect(metadata?.coverageMultiplicity(for: 4) == 0)
    #expect(metadata?.captureByteCount(for: 1) == 8)
    #expect(metadata?.captureByteCount(for: 2) == 12)
    #expect(metadata?.captureByteCount(for: 3) == 0)
}

@Test
func generatedStaticCanvasSwitchCoversEveryDeclaredID() throws {
    var table = GeneratedRuntimeCanvasTable()
    let captures = GeneratedCanvasCaptureStorage(
        color: .white,
        firstScalar: 1,
        secondScalar: 2
    )
    let size = Size(width: 3, height: 5)!

    for id: UInt16 in 1 ... 3 {
        try withGeneratedCanvasContext { context in
            try table.invoke(id: id, captures: captures, context: &context, size: size)
        }
        #expect(table.lastInvokedID == id)
    }
    #expect(throws: DrawingError.invariantViolation) {
        try withGeneratedCanvasContext { context in
            try table.invoke(id: 0, captures: captures, context: &context, size: size)
        }
    }
}

@Test
func fixedStaticStorageAuditsAllSixteenIndependentInlineRegions() {
    let storage = makeStaticStorage()
    #expect(storage.audit().audit?.totalProfileBytes == 16)
    #expect(storage.structuralIdentity == StaticStructuralIdentity(rawValue: 23))
    #expect(RuntimeStorageFamily.allCases.count == 16)
    #expect(RuntimeStorageLimit.allCases.count == 51)
}

@Test
func fixedStaticLogicalDimensionsAcceptExactLimitAndRejectFirstExcess() {
    var storage = makeStaticStorage()
    let beganAttempt = storage.beginAttempt()
    #expect(beganAttempt)

    for limit in RuntimeStorageLimit.allCases {
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
func fixedStaticAttemptResetPreservesCommittedUntilQuiescentTeardown() {
    var storage = makeStaticStorage()
    let beganAttempt = storage.beginAttempt()
    #expect(beganAttempt)
    #expect(storage.reserve(1, for: .observableCandidateAssociations) == .accepted)
    #expect(storage.reserve(1, for: .interactionCommittedActions) == .accepted)
    storage.resetAttemptStorage()
    storage.finishAttempt()

    #expect(storage.storageLifetimeState == .idle)
    #expect(storage.use(for: .observableCandidateAssociations).current == 0)
    #expect(storage.use(for: .interactionCommittedActions).current == 1)

    storage.quiesce()
    storage.quiesce()
    #expect(storage.storageLifetimeState == .tornDown)
    #expect(storage.use(for: .interactionCommittedActions).current == 0)
    let beganAfterTeardown = storage.beginAttempt()
    #expect(!beganAfterTeardown)
}

private struct GeneratedCanvasContextStorage {}

private let generatedCanvasOperations = _GiftUIDrawingOperations(
    beginPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    endPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    movePath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    addLineToPath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
    strokePath: { _, _, _, _, _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue }
)

private func withGeneratedCanvasContext<Result>(
    _ body: (inout GraphicsContext) throws -> Result
) throws -> Result {
    var contextStorage = GeneratedCanvasContextStorage()
    return try withUnsafeMutablePointer(to: &contextStorage) { pointer in
        var context = GraphicsContext(
            storage: UnsafeMutableRawPointer(pointer),
            generation: 1,
            operations: generatedCanvasOperations
        )
        return try body(&context)
    }
}

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}

private func makeStaticStorage() -> StaticProfileStorage<
    GeneratedStaticRegions,
    GeneratedRuntimeMetadata
> {
    let metadata = GeneratedRuntimeMetadata(
        observableSlots: GeneratedObservableSlots(),
        action: GeneratedProfileAction.self,
        canvasTable: GeneratedRuntimeCanvasTable(),
        canvasCoverage: GeneratedCanvasCoverage()
    )!
    return StaticProfileStorage(
        structuralIdentity: StaticStructuralIdentity(rawValue: 23)!,
        limits: staticLimits(),
        regions: GeneratedStaticRegions(),
        metadata: metadata
    )!
}

private func staticLimits() -> RuntimeProfileLimits {
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
        staticCanvas: StaticCanvasLimits(
            maximumStaticCallableCases: 3,
            maximumStaticCaptureBytes: 12
        )!,
        profile: .static
    )!
}
