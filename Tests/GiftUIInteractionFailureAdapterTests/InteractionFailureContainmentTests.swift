import GiftUIFailureCore
import Testing

@testable import GiftUIInteraction
@testable import GiftUIInteractionFailureAdapterFixture

@Test
func containedCandidateFailuresDiscardAndPreserveCommittedState() {
    let errors: [InteractionError] = [
        .capacityExhausted,
        .invalidIdentity,
        .invalidGeometry,
        .incompatibleActionDomain,
        .invalidActionValue,
        .missingModelTarget,
    ]

    for error in errors {
        var withoutMutation = InteractionFailureEffectState(committedStateToken: 0xC0FFEE)
        let contained = InteractionFailureContainment.apply(
            error,
            mutationAlreadyOccurred: false,
            to: &withoutMutation
        )
        #expect(withoutMutation.committedStateToken == 0xC0FFEE)
        #expect(withoutMutation.candidateDiscardCount == 1)
        #expect(withoutMutation.captureCancellationCount == 0)
        #expect(!withoutMutation.isDirty)
        #expect(withoutMutation.wakeRequestCount == 0)
        #expect(withoutMutation.normalCyclePermitted)
        #expect(!withoutMutation.isQuiesced)
        #expect(contained.allowedDispositions == .continueOperation)
        #expect(contained.mandatoryEffectsComplete)
        #expect(!contained.fatalHookEligible)

        var afterMutation = InteractionFailureEffectState(committedStateToken: 0xC0FFEE)
        _ = InteractionFailureContainment.apply(
            error,
            mutationAlreadyOccurred: true,
            to: &afterMutation
        )
        #expect(afterMutation.committedStateToken == 0xC0FFEE)
        #expect(afterMutation.candidateDiscardCount == 1)
        #expect(afterMutation.isDirty)
        #expect(afterMutation.wakeRequestCount == 1)
    }
}

@Test
func repeatedContainedFailuresCoalesceDirtyWakeWithoutRestoringCandidate() {
    var state = InteractionFailureEffectState(committedStateToken: 29)
    _ = InteractionFailureContainment.apply(
        .invalidGeometry,
        mutationAlreadyOccurred: true,
        to: &state
    )
    _ = InteractionFailureContainment.apply(
        .capacityExhausted,
        mutationAlreadyOccurred: true,
        to: &state
    )

    #expect(state.committedStateToken == 29)
    #expect(state.candidateDiscardCount == 2)
    #expect(state.isDirty)
    #expect(state.wakeRequestCount == 1)
}

@Test
func safetyNotProvenFailuresCancelQuiesceAndExcludeNormalCycles() {
    let errors: [InteractionError] = [
        .invalidPhase,
        .reentrancyViolation,
        .invariantViolation,
    ]

    for error in errors {
        var state = InteractionFailureEffectState(committedStateToken: 31)
        let terminal = InteractionFailureContainment.apply(
            error,
            mutationAlreadyOccurred: true,
            to: &state
        )
        #expect(state.committedStateToken == 31)
        #expect(state.candidateDiscardCount == 1)
        #expect(state.captureCancellationCount == 1)
        #expect(!state.normalCyclePermitted)
        #expect(state.isQuiesced)
        #expect(
            terminal.allowedDispositions
                == [.quiesceAffectedScope, .invokeFatalHook]
        )
        #expect(!terminal.allowedDispositions.contains(.continueOperation))
        #expect(!terminal.allowedDispositions.contains(.requestPacedRetry))
        #expect(terminal.mandatoryEffectsComplete)
        #expect(terminal.fatalHookEligible)
    }
}
