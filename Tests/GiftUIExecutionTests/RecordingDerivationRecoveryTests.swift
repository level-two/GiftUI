import GiftUI
import Testing

@testable import GiftUIExecution

private struct DerivationWakeRequester: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt16 = 0
    private(set) var reasons: ExecutionWakeReasons = []

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
        self.reasons.formUnion(reasons)
    }
}

@Test
func everyPrepublicationFailureDiscardsAllPartialResults() {
    let points: [RecordingPrepublicationFailurePoint] = [
        .semantic,
        .layout,
        .actionTable,
        .routing,
        .immutableRenderInput,
    ]

    for point in points {
        var recovery = RecordingDerivationRecovery(
            publishedRevision: SemanticRevision(rawValue: 7),
            requester: DerivationWakeRequester()
        )
        #expect(recovery.beginMutationCycle(applying: 1) == nil)
        #expect(recovery.stage(through: point) == nil)
        #expect(recovery.stagedResults == point.partialResults)

        let result = recovery.fail(
            at: point,
            cycle: RunCycleID(rawValue: 4),
            admission: emptyDerivationAdmission(),
            committedPresentationRevision: PresentationRevision(rawValue: 3)
        )
        guard case .failure(let context, .focusedOwner(.injected), let summary) = result else {
            Issue.record("missing focused failure for \(point)")
            continue
        }
        #expect(context.phase == .deriving)
        #expect(context.semanticRevision == SemanticRevision(rawValue: 7))
        #expect(summary?.semanticDisposition == .dirty)
        #expect(summary?.logicalFrameDisposition == .notProduced)
        #expect(summary?.semanticRevision == SemanticRevision(rawValue: 7))
        #expect(recovery.publishedRevision == SemanticRevision(rawValue: 7))
        #expect(recovery.stagedResults.isEmpty)
        #expect(recovery.discardedResults == point.partialResults)
        #expect(recovery.isDirty)
        #expect(recovery.wakeAccumulator.requester.requestCount == 1)
        #expect(recovery.wakeAccumulator.accumulatedReasons == .semanticDirty)
    }
}

@Test
func dirtyFailureRequestsOneLaterWakeAndCannotReenterSynchronously() {
    var recovery = RecordingDerivationRecovery(
        publishedRevision: SemanticRevision(rawValue: 2),
        requester: DerivationWakeRequester()
    )
    #expect(recovery.beginMutationCycle(applying: 2) == nil)
    #expect(recovery.beginMutationCycle(applying: 1) == .reentrancyViolation)
    _ = recovery.fail(
        at: .routing,
        cycle: RunCycleID(rawValue: 8),
        admission: emptyDerivationAdmission(),
        committedPresentationRevision: nil
    )

    #expect(recovery.beginRecovery() == .invalidPhase)
    #expect(recovery.wakeAccumulator.requester.requestCount == 1)
    #expect(recovery.takeRecoveryWakeAtIdle() == .semanticDirty)
    #expect(recovery.beginRecovery() == nil)
    #expect(recovery.beginRecovery() == .reentrancyViolation)
}

@Test
func laterRecoveryRederivesCurrentStateWithoutReplayingAppliedEffects() {
    var recovery = RecordingDerivationRecovery(
        publishedRevision: SemanticRevision(rawValue: 11),
        requester: DerivationWakeRequester()
    )
    #expect(recovery.beginMutationCycle(applying: 2) == nil)
    _ = recovery.fail(
        at: .immutableRenderInput,
        cycle: RunCycleID(rawValue: 12),
        admission: emptyDerivationAdmission(),
        committedPresentationRevision: PresentationRevision(rawValue: 5)
    )
    #expect(recovery.takeRecoveryWakeAtIdle() == .semanticDirty)
    #expect(recovery.beginRecovery() == nil)
    #expect(recovery.appliedEffectCount == 2)
    #expect(
        recovery.completeRecovery(
            publishing: SemanticRevision(rawValue: 12)
        ) == nil
    )

    #expect(recovery.appliedEffectCount == 2)
    #expect(recovery.publishedRevision == SemanticRevision(rawValue: 12))
    #expect(!recovery.isDirty)
    #expect(!recovery.cycleActive)
    #expect(recovery.stagedResults.isEmpty)
    #expect(recovery.discardedResults.isEmpty)
    #expect(recovery.wakeAccumulator.requester.requestCount == 1)
}

@Test
func prepublicationFailureWithoutDirtyWorkPreservesUnchangedDisposition() {
    var recovery = RecordingDerivationRecovery(
        publishedRevision: SemanticRevision(rawValue: 1),
        requester: DerivationWakeRequester()
    )
    #expect(recovery.beginMutationCycle(applying: 0) == nil)
    let result = recovery.fail(
        at: .semantic,
        cycle: RunCycleID(rawValue: 3),
        admission: emptyDerivationAdmission(),
        committedPresentationRevision: nil
    )
    guard case .failure(_, _, let summary) = result else {
        Issue.record("missing clean pre-publication failure")
        return
    }
    #expect(summary?.semanticDisposition == .unchanged)
    #expect(!recovery.isDirty)
    #expect(!recovery.wakeAccumulator.wakeOutstanding)
    #expect(recovery.wakeAccumulator.requester.requestCount == 0)
}

private func emptyDerivationAdmission() -> AdmissionSummary {
    let limits = ExecutionLimits(
        maximumInputEvents: 1,
        maximumStateChangeFacts: 1,
        maximumCompletionFacts: 0,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 1,
        maximumCommittedActions: 1
    )!
    return AdmissionSummary(
        inputEventCount: 0,
        stateChangeFactCount: 0,
        completionFactCount: 0,
        semanticActionCount: 0,
        includesDirtyRederivation: false,
        includesPresentationRecovery: false,
        limits: limits
    )!
}
