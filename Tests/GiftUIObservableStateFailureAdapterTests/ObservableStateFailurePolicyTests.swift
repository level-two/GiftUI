import Testing

@testable import GiftUIFailureCore
@testable import GiftUIObservableState
@testable import GiftUIObservableStateFailureAdapterFixture

private let focusedPrecedence: [ObservableStateError] = [
    .reentrancyViolation,
    .invalidPhaseSafetyNotProven,
    .invalidPhaseContained,
    .incompatibleAssociation,
    .duplicateOwner,
    .registrationGenerationExhausted,
    .locationCapacityExhausted,
    .registrationCapacityExhausted,
    .associationStagingCapacityExhausted,
    .replacementStagingCapacityExhausted,
    .staleAttachment,
    .invariantViolation,
]

private func mapped(
    _ error: ObservableStateError,
    _ context: ObservableStateFailureDetectionContext
) -> CorrelatedObservableStateFailure {
    let failure = GiftUIObservableStateFailureAdapter.map(
        error,
        detectedAt: context,
        mandatoryEffectsComplete: true
    )
    #expect(failure != nil)
    return failure!
}

@Test
func individualAndSimultaneousFailuresFollowExactFocusedPrecedence() {
    for (higherIndex, higher) in focusedPrecedence.enumerated() {
        #expect(
            GiftUIObservableStateFailureAdapter.selectFocusedFailure(
                from: .failure(higher)
            ) == higher
        )
        for lower in focusedPrecedence.dropFirst(higherIndex + 1) {
            let simultaneous: ObservableStateVisibleFailures = [
                .failure(lower),
                .failure(higher),
            ]
            #expect(
                GiftUIObservableStateFailureAdapter.selectFocusedFailure(from: simultaneous)
                    == higher
            )
        }
    }
    #expect(GiftUIObservableStateFailureAdapter.selectFocusedFailure(from: []) == nil)
}

@Test
func residualPolicyTableIsExactForEveryConditionContext() {
    let initialContexts: [(ObservableStateError, ObservableStateFailureDetectionContext)] = [
        (.locationCapacityExhausted, .initialOrCandidateBinding),
        (.registrationCapacityExhausted, .initialOrCandidateBinding),
        (.associationStagingCapacityExhausted, .activeCycle),
        (.duplicateOwner, .initialOrCandidateBinding),
        (.incompatibleAssociation, .initialOrCandidateBinding),
        (.staleAttachment, .candidateAttachment),
    ]
    for (error, context) in initialContexts {
        let failure = mapped(error, context)
        #expect(
            GiftUIObservableStateFailureAdapter.residualInput(
                for: failure,
                priorRootExists: false,
                residualPolicyPermitted: true
            )?.allowed == [.quiesceAffectedScope, .invokeFatalHook]
        )
        #expect(
            GiftUIObservableStateFailureAdapter.residualInput(
                for: failure,
                priorRootExists: true,
                residualPolicyPermitted: true
            )?.allowed == [.continueOperation, .quiesceAffectedScope]
        )
    }

    let replacementContexts: [(ObservableStateError, ObservableStateFailureDetectionContext)] = [
        (.registrationCapacityExhausted, .replacement),
        (.replacementStagingCapacityExhausted, .replacement),
        (.duplicateOwner, .replacement),
        (.incompatibleAssociation, .replacement),
        (.staleAttachment, .replacementAttachment),
    ]
    for (error, context) in replacementContexts {
        #expect(
            GiftUIObservableStateFailureAdapter.residualInput(
                for: mapped(error, context),
                priorRootExists: true,
                residualPolicyPermitted: true
            )?.allowed == [.continueOperation, .quiesceAffectedScope]
        )
    }

    #expect(
        GiftUIObservableStateFailureAdapter.residualInput(
            for: mapped(.staleAttachment, .retiredReport),
            priorRootExists: true,
            residualPolicyPermitted: true
        )?.allowed == .continueOperation
    )

    let containedPhase = mapped(.invalidPhaseContained, .activeCycle)
    #expect(
        GiftUIObservableStateFailureAdapter.residualInput(
            for: containedPhase,
            priorRootExists: true,
            residualPolicyPermitted: true
        ) == nil
    )
    let terminalContexts: [(ObservableStateError, ObservableStateFailureDetectionContext)] = [
        (.registrationGenerationExhausted, .runtime),
        (.invalidPhaseSafetyNotProven, .activeCycle),
        (.reentrancyViolation, .activeCycle),
        (.invariantViolation, .runtime),
    ]
    for (error, context) in terminalContexts {
        #expect(
            GiftUIObservableStateFailureAdapter.residualInput(
                for: mapped(error, context),
                priorRootExists: true,
                residualPolicyPermitted: true
            )?.allowed == [.quiesceAffectedScope, .invokeFatalHook]
        )
    }

    for (error, context) in initialContexts + replacementContexts + terminalContexts {
        #expect(
            GiftUIObservableStateFailureAdapter.residualInput(
                for: mapped(error, context),
                priorRootExists: true,
                residualPolicyPermitted: false
            ) == nil
        )
    }
}

@Test
func policyInputsPreserveFailureScopeContainmentAndBoundedAttempt() {
    let rows = [
        mapped(.locationCapacityExhausted, .initialOrCandidateBinding),
        mapped(.registrationCapacityExhausted, .replacement),
        mapped(.associationStagingCapacityExhausted, .activeCycle),
        mapped(.replacementStagingCapacityExhausted, .replacement),
        mapped(.registrationGenerationExhausted, .runtime),
        mapped(.duplicateOwner, .initialOrCandidateBinding),
        mapped(.incompatibleAssociation, .replacement),
        mapped(.staleAttachment, .candidateAttachment),
        mapped(.staleAttachment, .replacementAttachment),
        mapped(.staleAttachment, .retiredReport),
        mapped(.invalidPhaseSafetyNotProven, .activeCycle),
        mapped(.reentrancyViolation, .activeCycle),
        mapped(.invariantViolation, .runtime),
    ]

    for failure in rows {
        let input = GiftUIObservableStateFailureAdapter.residualInput(
            for: failure,
            priorRootExists: true,
            residualPolicyPermitted: true
        )
        #expect(input != nil)
        guard let input else { continue }
        guard case .failure(let fact) = input.outcome else {
            Issue.record("residual policy input reinterpreted a local failure")
            continue
        }
        #expect(fact == failure.fact)
        #expect(input.context == failure.detectionContext)
        #expect(!input.allowed.contains(.requestPacedRetry))
        #expect(input.attemptOrdinal == 0)
        #expect(input.attemptLimit == 1)
    }
}

@Test
func secondaryCleanupFailureNeverReplacesFocusedCondition() {
    var selected = GiftUIObservableStateFailureAdapter.selectFocusedFailure(
        from: [.failure(.duplicateOwner), .failure(.staleAttachment)]
    )
    let cleanupFailure = ObservableStateError.invariantViolation
    if selected == nil {
        selected = cleanupFailure
    }

    #expect(selected == .duplicateOwner)
    let failure = mapped(selected!, .initialOrCandidateBinding)
    #expect(failure.localError == .duplicateOwner)
}
