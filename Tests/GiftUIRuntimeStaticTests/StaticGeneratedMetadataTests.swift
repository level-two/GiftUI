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

@Test func staticCanvasHostValidationIsIndependentAndExact() {
    let metadata = GeneratedRuntimeMetadata(
        observableSlots: GeneratedObservableSlots(),
        action: GeneratedProfileAction.self,
        canvasTable: GeneratedRuntimeCanvasTable(),
        canvasCoverage: GeneratedCanvasCoverage()
    )!
    let exact = StaticCanvasLimits(
        maximumStaticCallableCases: 3,
        maximumStaticCaptureBytes: 12
    )
    #expect(
        StaticCanvasHostValidation.validate(limits: exact, metadata: metadata) == nil
    )
    #expect(
        StaticCanvasHostValidation.validate(limits: nil, metadata: metadata)
            == .invalidLimits
    )
    #expect(
        StaticCanvasHostValidation.validate(
            limits: StaticCanvasLimits(
                maximumStaticCallableCases: 2,
                maximumStaticCaptureBytes: 12
            ),
            metadata: metadata
        ) == .incompleteCallableTable
    )
    #expect(
        StaticCanvasHostValidation.validate(
            limits: StaticCanvasLimits(
                maximumStaticCallableCases: 3,
                maximumStaticCaptureBytes: 11
            ),
            metadata: metadata
        ) == .incompleteCallableTable
    )
}

private final class StaticCanvasHandleModel {
    let value: UInt8

    init(value: UInt8) {
        self.value = value
    }
}

@Test func staticCanvasObservableHandleBorrowsOneAddressStableHostLocation() {
    var location = StaticCanvasHostModelLocation(model: StaticCanvasHandleModel(value: 17))
    var firstAddress: UInt?

    location.withHandle { handle in
        let first = handle.withModel { model in
            firstAddress = UInt(bitPattern: Unmanaged.passUnretained(model).toOpaque())
            return model.value
        }
        let copiedHandle = handle
        let second = copiedHandle.withModel { model in
            #expect(
                UInt(bitPattern: Unmanaged.passUnretained(model).toOpaque()) == firstAddress
            )
            return model.value
        }
        #expect(first == 17)
        #expect(second == 17)
    }
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
func staticCanvasStartupRejectsEveryTableMismatchBeforeInvocation() {
    let invalidMetadata: [FaultedStaticMetadata] = [
        FaultedStaticMetadata(callableCaseCount: 0),
        FaultedStaticMetadata(callableCaseCount: 4, declaredEntryCount: 4, maximumDeclaredID: 4),
        FaultedStaticMetadata(declaredEntryCount: 2),
        FaultedStaticMetadata(maximumDeclaredID: 2),
        FaultedStaticMetadata(fault: .missingCoverage),
        FaultedStaticMetadata(fault: .duplicateCoverage),
        FaultedStaticMetadata(fault: .missingCaptureSize),
        FaultedStaticMetadata(fault: .oversizedCapture),
    ]

    for metadata in invalidMetadata {
        let storage = StaticProfileStorage(
            structuralIdentity: StaticStructuralIdentity(rawValue: 23)!,
            limits: staticLimits(),
            regions: GeneratedStaticRegions(),
            metadata: metadata
        )
        switch consume storage {
        case nil:
            break
        case .some:
            Issue.record("invalid Static Canvas metadata unexpectedly constructed storage")
        }
    }
}

@Test
func staticCanvasStagingRejectsZeroRangeAndSizeBeforeInvocation() {
    let probe = StaticCanvasInvocationProbe()
    let metadata = StaticGeneratedProfileMetadata(
        observableSlots: GeneratedObservableSlots(),
        action: GeneratedProfileAction.self,
        canvasTable: StagingPoisonCanvasTable(probe: probe),
        canvasCoverage: GeneratedCanvasCoverage()
    )!
    let invariant = StaticCanvasStagingValidation.failure(.drawing(.invariantViolation))

    #expect(metadata.validateStagedCallable(id: 0, captureByteCount: 8) == invariant)
    #expect(metadata.validateStagedCallable(id: 4, captureByteCount: 8) == invariant)
    #expect(metadata.validateStagedCallable(id: 1, captureByteCount: 7) == invariant)
    #expect(metadata.validateStagedCallable(id: 1, captureByteCount: 8) == .accepted)
    #expect(probe.invocationCount == 0)
}

@Test
func staticCanvasOccurrenceDestroysInlineCaptureAfterSuccessfulInvocation() throws {
    let lifetime = StaticCaptureLifetime()
    var table = StaticCaptureTable(result: .success, probe: StaticCanvasInvocationProbe())
    var occurrence = makeStaticOccurrence(lifetime: lifetime)

    try withGeneratedCanvasContext { context in
        try occurrence.invoke(
            table: &table,
            context: &context,
            size: Size(width: 7, height: 9)!
        )
    }

    #expect(table.probe.invocationCount == 1)
    #expect(occurrence.state == .released)
    #expect(occurrence.releaseCount == 1)
    #expect(lifetime.destructionCount == 1)
    #expect(throws: DrawingError.invariantViolation) {
        try withGeneratedCanvasContext { context in
            try occurrence.invoke(
                table: &table,
                context: &context,
                size: Size(width: 7, height: 9)!
            )
        }
    }
    #expect(table.probe.invocationCount == 1)
    #expect(lifetime.destructionCount == 1)
}

@Test
func staticCanvasOccurrenceDestroysInlineCaptureAfterTypedThrow() {
    let lifetime = StaticCaptureLifetime()
    var table = StaticCaptureTable(result: .failure, probe: StaticCanvasInvocationProbe())
    var occurrence = makeStaticOccurrence(lifetime: lifetime)

    #expect(throws: DrawingError.invalidValue) {
        try withGeneratedCanvasContext { context in
            try occurrence.invoke(
                table: &table,
                context: &context,
                size: Size(width: 7, height: 9)!
            )
        }
    }
    #expect(table.probe.invocationCount == 1)
    #expect(occurrence.state == .released)
    #expect(occurrence.releaseCount == 1)
    #expect(lifetime.destructionCount == 1)
}

@Test
func staticCanvasOccurrenceDiscardDestroysUninvokedCaptureExactlyOnce() {
    let lifetime = StaticCaptureLifetime()
    var occurrence = makeStaticOccurrence(lifetime: lifetime)

    occurrence.discard()
    occurrence.discard()

    #expect(occurrence.state == .released)
    #expect(occurrence.releaseCount == 1)
    #expect(lifetime.destructionCount == 1)
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

@Test
func staticBindingUsesCommonLifecycleGeneratedTableAndInlineCapture() throws {
    var binding = makeStaticBinding()
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 7),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )

    let profile = binding.profile
    let auditProfile = binding.storageAudit?.profile
    #expect(profile == .static)
    #expect(auditProfile == .static)
    #expect(binding.beginOpportunity(context: active) == nil)
    #expect(binding.beginOpportunity(context: active) == .reentrancyViolation)
    #expect(binding.reserve(1, for: .drawingPlanStrokes) == .accepted)

    guard
        var occurrence = binding.stageCanvas(
            identity: GeneratedProfileIdentity.primary,
            callableID: 1,
            declaredCaptureByteCount: 8,
            capture: GeneratedCanvasCaptureStorage(
                color: .white,
                firstScalar: 1,
                secondScalar: 2
            )
        )
    else {
        Issue.record("valid generated Static Canvas occurrence was rejected")
        return
    }
    try withGeneratedCanvasContext { context in
        try binding.invokeCanvas(
            occurrence: &occurrence,
            context: &context,
            size: Size(width: 3, height: 5)!
        )
    }
    #expect(occurrence.state == .released)
    #expect(occurrence.releaseCount == 1)

    #expect(binding.finishOpportunity(context: idleStaticExecutionContext()) == nil)
    let finishedState = binding.storageLifetimeState
    let finishedContext = binding.executionContext
    #expect(finishedState == .idle)
    #expect(finishedContext == idleStaticExecutionContext())
}

@Test
func staticBindingDefersActiveQuiescenceAndCannotRestart() {
    var binding = makeStaticBinding()
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 8),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )

    #expect(binding.beginOpportunity(context: active) == nil)
    binding.quiesce()
    let activeQuiescence = binding.isQuiescent
    let requestedState = binding.storageLifetimeState
    #expect(!activeQuiescence)
    #expect(requestedState == .quiescenceRequested)

    #expect(binding.finishOpportunity(context: idleStaticExecutionContext()) == nil)
    let finishedQuiescence = binding.isQuiescent
    let tornDownState = binding.storageLifetimeState
    #expect(finishedQuiescence)
    #expect(tornDownState == .tornDown)
    binding.quiesce()
    #expect(binding.beginOpportunity(context: active) == .requiredFacilityUnavailable)
}

private struct GeneratedCanvasContextStorage {}

private final class StaticCanvasInvocationProbe {
    var invocationCount = 0
}

private struct StagingPoisonCanvasTable: StaticCanvasCallableTable {
    let callableCaseCount: UInt16 = 3
    let probe: StaticCanvasInvocationProbe

    func captureByteCount(for id: UInt16) -> UInt16? {
        switch id {
        case 1: 8
        case 2: 12
        case 3: 0
        default: nil
        }
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing GeneratedCanvasCaptureStorage,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        probe.invocationCount += 1
    }
}

private final class StaticCaptureLifetime {
    var destructionCount = 0
}

private final class StaticCaptureToken {
    let lifetime: StaticCaptureLifetime

    init(lifetime: StaticCaptureLifetime) {
        self.lifetime = lifetime
    }

    deinit {
        lifetime.destructionCount += 1
    }
}

private struct StaticInlineCapture {
    let token: StaticCaptureToken
    let scalar: GeometryScalar
}

private enum StaticCaptureTableResult {
    case success
    case failure
}

private struct StaticCaptureTable: StaticCanvasCallableTable {
    let callableCaseCount: UInt16 = 1
    let result: StaticCaptureTableResult
    let probe: StaticCanvasInvocationProbe

    func captureByteCount(for id: UInt16) -> UInt16? {
        id == 1 ? 8 : nil
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing StaticInlineCapture,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        probe.invocationCount += 1
        _ = captures.scalar
        _ = size
        if result == .failure {
            throw .invalidValue
        }
    }
}

private func makeStaticOccurrence(
    lifetime: StaticCaptureLifetime
) -> StaticCanvasOccurrence<GeneratedProfileIdentity, StaticInlineCapture> {
    StaticCanvasOccurrence(
        identity: .primary,
        callableID: 1,
        declaredCaptureByteCount: 8,
        capture: StaticInlineCapture(
            token: StaticCaptureToken(lifetime: lifetime),
            scalar: 17
        ),
        metadata: FaultedStaticMetadata(
            callableCaseCount: 1, declaredEntryCount: 1,
            maximumDeclaredID: 1)
    )!
}

private enum StaticCanvasMetadataFault {
    case none
    case missingCoverage
    case duplicateCoverage
    case missingCaptureSize
    case oversizedCapture
}

private struct FaultedStaticMetadata: RuntimeStaticCanvasAuditMetadata {
    let callableCaseCount: UInt16
    let declaredEntryCount: UInt16
    let maximumDeclaredID: UInt16
    let fault: StaticCanvasMetadataFault

    init(
        callableCaseCount: UInt16 = 3,
        declaredEntryCount: UInt16 = 3,
        maximumDeclaredID: UInt16 = 3,
        fault: StaticCanvasMetadataFault = .none
    ) {
        self.callableCaseCount = callableCaseCount
        self.declaredEntryCount = declaredEntryCount
        self.maximumDeclaredID = maximumDeclaredID
        self.fault = fault
    }

    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        switch fault {
        case .missingCoverage where id == 2: 0
        case .duplicateCoverage where id == 2: 2
        default: id > 0 && id <= callableCaseCount ? 1 : 0
        }
    }

    func captureByteCount(for id: UInt16) -> UInt16? {
        switch fault {
        case .missingCaptureSize where id == 2: nil
        case .oversizedCapture where id == 2: 13
        default: id > 0 && id <= callableCaseCount ? 8 : nil
        }
    }
}

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

private func makeStaticBinding() -> StaticRuntimeProfileBinding<
    GeneratedStaticRegions,
    GeneratedRuntimeMetadata
> {
    let metadata = GeneratedRuntimeMetadata(
        observableSlots: GeneratedObservableSlots(),
        action: GeneratedProfileAction.self,
        canvasTable: GeneratedRuntimeCanvasTable(),
        canvasCoverage: GeneratedCanvasCoverage()
    )!
    return StaticRuntimeProfileBinding(
        structuralIdentity: StaticStructuralIdentity(rawValue: 24)!,
        limits: staticLimits(),
        regions: GeneratedStaticRegions(),
        metadata: metadata
    )!
}

private func idleStaticExecutionContext() -> ExecutionContext {
    ExecutionContext(
        cycle: nil,
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .idle
    )
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
