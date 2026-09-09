import Testing

@testable import GiftUIExecution
@testable import GiftUIFailureCore
@testable import GiftUIFailureDiagnostics
@testable import GiftUIFailureExecution
@testable import GiftUIRenderCore

private let diagnosticContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 34),
    semanticRevision: SemanticRevision(rawValue: 55),
    candidateFrame: CandidateFrameID(rawValue: 89),
    phase: .finalizing
)

@Test
func diagnosticConfigurationsPreserveCompleteExecutionSnapshot() {
    let baseline = correctnessSnapshot()
    let configurations: [(String, GiftUIDiagnosticSinkResult?)] = [
        ("omitted", nil),
        ("selected", .accepted),
        ("saturated", .saturated),
        ("dropped", .dropped),
        ("failing", .failed),
    ]

    for (name, result) in configurations {
        let attackSurface = DiagnosticAttackSurface(authoritativeState: baseline.authoritativeState)
        attackSurface.enterDiagnostics()
        var projector = GiftUIDiagnosticProjector(
            selection: selection(enabled: result != nil),
            sink: ExecutionDiagnosticSink(result: result ?? .accepted, attackSurface: attackSurface)
        )
        let construction = ConstructionCounter()

        projector.projectExecutionFailure(construction: construction)

        #expect(correctnessSnapshot() == baseline, "configuration: \(name)")
        #expect(attackSurface.authoritativeState == baseline.authoritativeState)
        #expect(attackSurface.semanticMutationCount == 0)
        #expect(attackSurface.actionInvocationCount == 0)
        if let result {
            #expect(construction.value == 1)
            #expect(projector.sink.consumed == 1)
            #expect(projector.counters.count(for: result) == 1)
            #expect(attackSurface.rejectedAttemptCount == 2)
        } else {
            #expect(construction.value == 0)
            #expect(projector.sink.consumed == 0)
            #expect(projector.counters == .init())
            #expect(attackSurface.rejectedAttemptCount == 0)
        }
    }
}

@Test
func diagnosticSinkCannotMutateCoordinatorOrInvokeAction() {
    let baseline = correctnessSnapshot()
    let attackSurface = DiagnosticAttackSurface(authoritativeState: baseline.authoritativeState)
    attackSurface.enterDiagnostics()
    var projector = GiftUIDiagnosticProjector(
        selection: selection(enabled: true),
        sink: ExecutionDiagnosticSink(result: .accepted, attackSurface: attackSurface)
    )

    projector.projectExecutionFailure(construction: ConstructionCounter())

    #expect(attackSurface.authoritativeState == baseline.authoritativeState)
    #expect(attackSurface.semanticMutationCount == 0)
    #expect(attackSurface.actionInvocationCount == 0)
    #expect(attackSurface.rejectedAttemptCount == 2)
    #expect(correctnessSnapshot() == baseline)
}

private func correctnessSnapshot() -> ExecutionCorrectnessSnapshot {
    let admission = ExecutionAdmissionOutcome(result: .queued, context: diagnosticContext)
    let mapping = GiftUIExecutionFailureAdapter.execution(
        .requiredFacilityUnavailable,
        context: diagnosticContext,
        provenAffectedScope: .runtime,
        safeReuseProven: true,
        mechanicalEffectsComplete: true
    )!
    let limits = ExecutionLimits(
        maximumInputEvents: 4,
        maximumStateChangeFacts: 3,
        maximumCompletionFacts: 2,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 2,
        maximumCommittedActions: 4
    )!
    let admissionSummary = AdmissionSummary(
        inputEventCount: 1,
        stateChangeFactCount: 1,
        completionFactCount: 1,
        semanticActionCount: 1,
        includesDirtyRederivation: true,
        includesPresentationRecovery: false,
        limits: limits
    )!
    let summary = RunCycleSummary(
        cycle: RunCycleID(rawValue: 34),
        admission: admissionSummary,
        semanticRevision: SemanticRevision(rawValue: 55),
        semanticDisposition: .dirty,
        logicalFrameDisposition: .notProduced,
        committedPresentationRevision: nil,
        presentationIntentState: .satisfied,
        presentationPending: nil,
        operationalEvents: []
    )!

    return ExecutionCorrectnessSnapshot(
        admission: admission,
        mechanicalEffects: 0b1_1111,
        semanticRevision: SemanticRevision(rawValue: 55),
        candidateFrame: CandidateFrameID(rawValue: 89),
        presentationIdentity: 144,
        offerCount: 1,
        wakeReasons: [.admittedWork, .semanticDirty],
        retryCount: 2,
        mappedFact: mapping.fact,
        summary: summary,
        authoritativeState: 233
    )
}

private func selection(enabled: Bool) -> GiftUIDiagnosticSelection {
    GiftUIDiagnosticSelection(
        kindMask: enabled ? 1 << GiftUIDiagnosticKind.failureOutcome.rawValue : 0,
        originMask: 1 << GiftUIFailureOrigin.execution.rawValue,
        minimumSeverity: .error
    )
}

private struct ExecutionCorrectnessSnapshot: Equatable {
    let admission: ExecutionAdmissionOutcome
    let mechanicalEffects: UInt8
    let semanticRevision: SemanticRevision
    let candidateFrame: CandidateFrameID
    let presentationIdentity: UInt32
    let offerCount: UInt8
    let wakeReasons: ExecutionWakeReasons
    let retryCount: UInt8
    let mappedFact: GiftUIFailureFact
    let summary: RunCycleSummary
    let authoritativeState: UInt32
}

private final class ConstructionCounter {
    var value: UInt8 = 0
}

private final class DiagnosticAttackSurface {
    private(set) var authoritativeState: UInt32
    private(set) var semanticMutationCount: UInt8 = 0
    private(set) var actionInvocationCount: UInt8 = 0
    private(set) var rejectedAttemptCount: UInt8 = 0
    private var diagnosticsActive = false

    init(authoritativeState: UInt32) {
        self.authoritativeState = authoritativeState
    }

    func enterDiagnostics() {
        diagnosticsActive = true
    }

    func attemptSemanticMutation() {
        guard !diagnosticsActive else {
            rejectedAttemptCount += 1
            return
        }
        authoritativeState &+= 1
        semanticMutationCount += 1
    }

    func attemptActionInvocation() {
        guard !diagnosticsActive else {
            rejectedAttemptCount += 1
            return
        }
        actionInvocationCount += 1
    }
}

private struct ExecutionDiagnosticSink: GiftUIDiagnosticSink {
    let result: GiftUIDiagnosticSinkResult
    let attackSurface: DiagnosticAttackSurface
    private(set) var consumed: UInt8 = 0

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        _ = record
        consumed += 1
        attackSurface.attemptSemanticMutation()
        attackSurface.attemptActionInvocation()
        return result
    }
}

extension GiftUIDiagnosticProjector {
    fileprivate mutating func projectExecutionFailure(construction: ConstructionCounter) {
        project(kind: .failureOutcome, origin: .execution, severity: .error) {
            construction.value += 1
            return GiftUIDiagnosticRecord(
                kind: .failureOutcome,
                severity: .error,
                flags: 1,
                origin: .execution,
                affectedScope: .runtime,
                condition: GiftUIConditionID.requiredFacilityUnavailable.rawValue,
                correlation0: diagnosticContext.cycle!.rawValue,
                correlation1: diagnosticContext.semanticRevision!.rawValue,
                observation0: diagnosticContext.candidateFrame!.rawValue
            )
        }
    }
}

extension GiftUIDiagnosticDeliveryCounters {
    fileprivate func count(for result: GiftUIDiagnosticSinkResult) -> UInt32 {
        switch result {
        case .accepted: accepted
        case .dropped: dropped
        case .saturated: saturated
        case .failed: failed
        }
    }
}
