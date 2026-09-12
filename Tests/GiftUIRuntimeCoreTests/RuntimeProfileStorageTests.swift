import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore
import Testing

@testable import GiftUIRuntimeCore

private final class StorageProbe {
    var attemptResetCount = 0
    var allResetCount = 0
    var invalidateAuditAfterAttemptReset = false
    var auditIsInvalid = false
}

private struct FixtureProfileStorage: ~Copyable, RuntimeProfileStorage {
    typealias StructuralIdentity = UInt16

    static let profile = RuntimeProfileKind.dynamic

    let limits: RuntimeProfileLimits
    let retainedAudit: RuntimeStorageAudit
    let probe: StorageProbe

    borrowing func audit() -> RuntimeProfileValidationResult {
        probe.auditIsInvalid ? .invalid(.insufficientStorage) : .valid(retainedAudit)
    }

    mutating func resetAttemptStorage() {
        probe.attemptResetCount += 1
        if probe.invalidateAuditAfterAttemptReset {
            probe.auditIsInvalid = true
        }
    }

    mutating func resetAllStorage() {
        probe.allResetCount += 1
    }
}

private func storageLimits() -> RuntimeProfileLimits {
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
        staticCanvas: nil,
        profile: .dynamic
    )!
}

private func storageAudit(limits: RuntimeProfileLimits) -> RuntimeStorageAudit {
    let byteCounts = RuntimeStorageByteCounts(
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
    guard
        case .valid(let audit) = RuntimeStorageAudit.checked(
            profile: .dynamic,
            limits: limits,
            byteCounts: byteCounts
        )
    else {
        fatalError("fixture audit must be valid")
    }
    return audit
}

private func fixtureStorage(
    probe: StorageProbe
) -> FixtureProfileStorage {
    let limits = storageLimits()
    return FixtureProfileStorage(
        limits: limits, retainedAudit: storageAudit(limits: limits), probe: probe)
}

@Test
func validatedStorageRetainsExactProfileLimitsAuditAndStructuralIdentity() {
    let probe = StorageProbe()
    let expectedLimits = storageLimits()
    let expectedAudit = storageAudit(limits: expectedLimits)
    guard
        let owner = ValidatedRuntimeProfileStorage(
            storage: FixtureProfileStorage(
                limits: expectedLimits,
                retainedAudit: expectedAudit,
                probe: probe
            ),
            structuralIdentity: 47
        )
    else {
        Issue.record("expected successful storage validation")
        return
    }

    #expect(owner.profile == .dynamic)
    #expect(owner.limits == expectedLimits)
    #expect(owner.structuralIdentity == 47)
    #expect(owner.audit() == .valid(expectedAudit))
    #expect(owner.storageUseState == .beforeUse)
}

@Test
func invalidAuditRejectsConstruction() {
    let probe = StorageProbe()
    probe.auditIsInvalid = true
    let owner = ValidatedRuntimeProfileStorage(
        storage: fixtureStorage(probe: probe),
        structuralIdentity: 1
    )

    if case .some = consume owner {
        Issue.record("expected invalid audit to reject construction")
    }
}

@Test
func attemptResetNeverPerformsAllStorageReset() {
    let probe = StorageProbe()
    guard
        var owner = ValidatedRuntimeProfileStorage(
            storage: fixtureStorage(probe: probe),
            structuralIdentity: 1
        )
    else {
        Issue.record("expected successful storage validation")
        return
    }
    let didBeginUse = owner.beginUse()
    #expect(didBeginUse)

    let resetResult = owner.resetAttemptStorage()
    #expect(resetResult == owner.audit())
    #expect(probe.attemptResetCount == 1)
    #expect(probe.allResetCount == 0)
    #expect(owner.storageUseState == .inUse)
}

@Test
func allStorageResetIsLegalOnlyBeforeUseOrAfterQuiescenceAndTeardown() {
    let probe = StorageProbe()
    guard
        var owner = ValidatedRuntimeProfileStorage(
            storage: fixtureStorage(probe: probe),
            structuralIdentity: 1
        )
    else {
        Issue.record("expected successful storage validation")
        return
    }

    let beforeUseReset = owner.resetAllStorage()
    #expect(beforeUseReset == owner.audit())
    #expect(probe.allResetCount == 1)
    let didBeginUse = owner.beginUse()
    #expect(didBeginUse)
    let illegalReset = owner.resetAllStorage()
    #expect(illegalReset == .invalid(.invariantViolation))
    #expect(probe.allResetCount == 1)

    owner.finishQuiescenceAndTeardown()
    let afterTeardownReset = owner.resetAllStorage()
    #expect(afterTeardownReset == owner.audit())
    #expect(probe.allResetCount == 2)
    let didRestart = owner.beginUse()
    #expect(!didRestart)
}

@Test
func capacityMutationAfterValidationIsContainedAsInvariantViolation() {
    let probe = StorageProbe()
    probe.invalidateAuditAfterAttemptReset = true
    guard
        var owner = ValidatedRuntimeProfileStorage(
            storage: fixtureStorage(probe: probe),
            structuralIdentity: 1
        )
    else {
        Issue.record("expected successful storage validation")
        return
    }

    let resetResult = owner.resetAttemptStorage()
    #expect(resetResult == .invalid(.invariantViolation))
    #expect(owner.audit().isValid)
}

private extension RuntimeProfileValidationResult {
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
}
