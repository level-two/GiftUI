import GiftUI
import Testing

@testable import GiftUIExecution

@Test
func everyFocusedOwnerFailureSurvivesEveryCleanupFaultCombination() {
    let failures: [RecordingFixtureOwnerFailure] = [
        .stateChange,
        .completion,
        .semantic,
        .layout,
        .immutableRenderInput,
    ]

    for (ordinal, failure) in failures.enumerated() {
        let phase: ExecutionPhase = ordinal < 2 ? .mutating : .deriving
        let context = ExecutionContext(
            cycle: RunCycleID(rawValue: UInt32(ordinal)),
            semanticRevision: SemanticRevision(rawValue: 17),
            candidateFrame: nil,
            phase: phase
        )

        for faultBits in UInt8(0) ... UInt8(0x1F) {
            var selection = RecordingFocusedFailureSelection()
            selection.captureFirstFocusedFailure(failure, context: context)
            let result = selection.completeMandatoryCleanup(
                injecting: RecordingCleanupFaults(rawValue: faultBits),
                summary: focusedFailureSummary(
                    cycle: RunCycleID(rawValue: UInt32(ordinal))
                )
            )

            guard
                case .failure(let retainedContext, .focusedOwner(let retained), let summary) =
                    result
            else {
                Issue.record("focused failure was replaced: \(failure), faults \(faultBits)")
                continue
            }
            #expect(retained == failure)
            #expect(retainedContext == context)
            #expect(summary != nil)
            #expect(selection.observedCleanupFaults.rawValue == faultBits)
            #expect(selection.completedCleanup == .all)
            #expect(selection.summaryProduced)
        }
    }
}

@Test
func laterFocusedFailureNeverReplacesFirstExactValueOrContext() {
    let firstContext = ExecutionContext(
        cycle: RunCycleID(rawValue: 5),
        semanticRevision: SemanticRevision(rawValue: 8),
        candidateFrame: nil,
        phase: .mutating
    )
    let laterContext = ExecutionContext(
        cycle: RunCycleID(rawValue: 5),
        semanticRevision: SemanticRevision(rawValue: 8),
        candidateFrame: CandidateFrameID(rawValue: 2),
        phase: .finalizing
    )
    var selection = RecordingFocusedFailureSelection()
    selection.captureFirstFocusedFailure(.stateChange, context: firstContext)
    selection.captureFirstFocusedFailure(.layout, context: laterContext)

    let result = selection.completeMandatoryCleanup(
        injecting: [.candidateAbort, .diagnosticWrite],
        summary: focusedFailureSummary(cycle: RunCycleID(rawValue: 5))
    )
    guard case .failure(let context, .focusedOwner(let failure), _) = result else {
        Issue.record("first focused failure was not retained")
        return
    }
    #expect(failure == .stateChange)
    #expect(context == firstContext)
    #expect(selection.firstFailure == .stateChange)
    #expect(selection.detectingContext == firstContext)
}

@Test
func cleanupCannotManufactureGenericExecutionOrDiagnosticFailure() {
    var selection = RecordingFocusedFailureSelection()
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 9),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .deriving
    )
    selection.captureFirstFocusedFailure(.semantic, context: context)
    let result = selection.completeMandatoryCleanup(
        injecting: RecordingCleanupFaults(rawValue: 0xFF),
        summary: focusedFailureSummary(cycle: RunCycleID(rawValue: 9))
    )

    #expect(
        result
            == .failure(
                context,
                .focusedOwner(.semantic),
                focusedFailureSummary(cycle: RunCycleID(rawValue: 9))
            )
    )
    #expect(selection.observedCleanupFaults.rawValue == 0x1F)
    #expect(selection.completedCleanup == .all)
}

@Test
func focusedOwnerFailureIsInlineFiniteAndStaticallyBounded() {
    #expect(MemoryLayout<RecordingFixtureOwnerFailure>.size <= 4)
    #expect(MemoryLayout<RecordingFixtureOwnerFailure>.stride <= 4)
    #expect(MemoryLayout<RecordingFixtureOwnerFailure>.alignment <= 4)
    #expect(RecordingFixtureOwnerFailure.stateChange.rawValue == 0x0101_0001)
    #expect(
        RecordingFixtureOwnerFailure.immutableRenderInput.rawValue
            == 0x0505_0005
    )
    #expect(
        MemoryLayout<RunCycleFailure<RecordingFixtureOwnerFailure>>.size <= 8
    )
}

private func focusedFailureSummary(cycle: RunCycleID) -> RunCycleSummary {
    let limits = ExecutionLimits(
        maximumInputEvents: 1,
        maximumStateChangeFacts: 1,
        maximumCompletionFacts: 0,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 1,
        maximumCommittedActions: 1
    )!
    let admission = AdmissionSummary(
        inputEventCount: 0,
        stateChangeFactCount: 0,
        completionFactCount: 0,
        semanticActionCount: 0,
        includesDirtyRederivation: false,
        includesPresentationRecovery: false,
        limits: limits
    )!
    return RunCycleSummary(
        cycle: cycle,
        admission: admission,
        semanticRevision: SemanticRevision(rawValue: 17),
        semanticDisposition: .dirty,
        logicalFrameDisposition: .notProduced,
        committedPresentationRevision: PresentationRevision(rawValue: 3),
        presentationIntentState: .satisfied,
        presentationPending: nil,
        operationalEvents: []
    )!
}
