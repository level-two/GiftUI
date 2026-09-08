import Testing

@testable import GiftUIExecution

private let sealLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 1,
    maximumSemanticActions: 2,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

@Test
func sealSelectsExactOrderedCategoryPrefixes() {
    let selection = ExecutionAdmissionSealer.select(
        pendingInputEvents: 2,
        pendingStateChangeFacts: 2,
        pendingCompletionFacts: 1,
        sameCycleActivationCandidates: 2,
        includesDirtyRederivation: true,
        includesPresentationRecovery: true,
        limits: sealLimits
    )
    #expect(selection != nil)

    var transcript: [String] = []
    for index in 0 ..< selection!.summary.inputEventCount {
        transcript.append("pointer-\(index)")
    }
    for index in 0 ..< selection!.summary.stateChangeFactCount {
        transcript.append("state-\(index)")
    }
    for index in 0 ..< selection!.summary.completionFactCount {
        transcript.append("completion-\(index)")
    }
    for index in 0 ..< selection!.summary.semanticActionCount {
        transcript.append("activation-\(index)")
    }
    if selection!.summary.includesDirtyRederivation {
        transcript.append("dirty")
    }
    if selection!.summary.includesPresentationRecovery {
        transcript.append("presentation-latest")
    }

    #expect(
        transcript == [
            "pointer-0", "pointer-1",
            "state-0", "state-1",
            "completion-0",
            "activation-0", "activation-1",
            "dirty",
            "presentation-latest",
        ]
    )
}

@Test
func overLimitSuffixesRemainDeferredRatherThanFailing() {
    let selection = ExecutionAdmissionSealer.select(
        pendingInputEvents: 4,
        pendingStateChangeFacts: 3,
        pendingCompletionFacts: 2,
        sameCycleActivationCandidates: 1,
        includesDirtyRederivation: false,
        includesPresentationRecovery: false,
        limits: sealLimits
    )

    #expect(selection?.summary.inputEventCount == 2)
    #expect(selection?.summary.stateChangeFactCount == 2)
    #expect(selection?.summary.completionFactCount == 1)
    #expect(selection?.hasDeferredWork == true)
    #expect(4 - selection!.summary.inputEventCount == 2)
    #expect(3 - selection!.summary.stateChangeFactCount == 1)
    #expect(2 - selection!.summary.completionFactCount == 1)
}

@Test
func countEqualToEveryLimitSucceedsWithoutDeferral() {
    let selection = ExecutionAdmissionSealer.select(
        pendingInputEvents: sealLimits.maximumInputEvents,
        pendingStateChangeFacts: sealLimits.maximumStateChangeFacts,
        pendingCompletionFacts: sealLimits.maximumCompletionFacts,
        sameCycleActivationCandidates: sealLimits.maximumSemanticActions,
        includesDirtyRederivation: true,
        includesPresentationRecovery: true,
        limits: sealLimits
    )
    #expect(selection?.hasDeferredWork == false)
    #expect(selection?.summary.semanticActionCount == 2)
}

@Test
func activationMembershipMustComeFromSelectedPointersAndFitItsLimit() {
    #expect(
        ExecutionAdmissionSealer.select(
            pendingInputEvents: 1,
            pendingStateChangeFacts: 0,
            pendingCompletionFacts: 0,
            sameCycleActivationCandidates: 2,
            includesDirtyRederivation: false,
            includesPresentationRecovery: false,
            limits: sealLimits
        ) == nil
    )

    let oneActionLimits = ExecutionLimits(
        maximumInputEvents: 2,
        maximumStateChangeFacts: 1,
        maximumCompletionFacts: 0,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 1,
        maximumCommittedActions: 1
    )!
    #expect(
        ExecutionAdmissionSealer.select(
            pendingInputEvents: 2,
            pendingStateChangeFacts: 0,
            pendingCompletionFacts: 0,
            sameCycleActivationCandidates: 2,
            includesDirtyRederivation: false,
            includesPresentationRecovery: false,
            limits: oneActionLimits
        ) == nil
    )
}

@Test
func emptySealAndSingleIntentMembershipAreExact() {
    let empty = ExecutionAdmissionSealer.select(
        pendingInputEvents: 0,
        pendingStateChangeFacts: 0,
        pendingCompletionFacts: 0,
        sameCycleActivationCandidates: 0,
        includesDirtyRederivation: false,
        includesPresentationRecovery: false,
        limits: sealLimits
    )
    #expect(empty?.summary.inputEventCount == 0)
    #expect(empty?.hasDeferredWork == false)

    let intents = ExecutionAdmissionSealer.select(
        pendingInputEvents: 0,
        pendingStateChangeFacts: 0,
        pendingCompletionFacts: 0,
        sameCycleActivationCandidates: 0,
        includesDirtyRederivation: true,
        includesPresentationRecovery: true,
        limits: sealLimits
    )
    #expect(intents?.summary.includesDirtyRederivation == true)
    #expect(intents?.summary.includesPresentationRecovery == true)
}
