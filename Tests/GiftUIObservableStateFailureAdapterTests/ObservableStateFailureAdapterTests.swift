import Testing

@testable import GiftUIFailureCore
@testable import GiftUIObservableState
@testable import GiftUIObservableStateFailureAdapterFixture

@Test
func everyObservableStateFailureContextMapsExactlyAfterEffects() {
    let cases:
        [(
            ObservableStateError,
            ObservableStateFailureDetectionContext,
            GiftUIConditionID,
            GiftUIAffectedScope,
            GiftUIContainment
        )] = [
            (
                .locationCapacityExhausted, .initialOrCandidateBinding, .capacityExhausted,
                .component, .contained
            ),
            (
                .registrationCapacityExhausted, .initialOrCandidateBinding, .capacityExhausted,
                .component, .contained
            ),
            (
                .registrationCapacityExhausted, .replacement, .capacityExhausted, .operation,
                .contained
            ),
            (
                .associationStagingCapacityExhausted, .activeCycle, .capacityExhausted,
                .activeCycle, .contained
            ),
            (
                .replacementStagingCapacityExhausted, .replacement, .capacityExhausted, .operation,
                .contained
            ),
            (
                .registrationGenerationExhausted, .runtime, .invalidIdentity, .runtime,
                .safetyNotProven
            ),
            (.duplicateOwner, .initialOrCandidateBinding, .invalidIdentity, .component, .contained),
            (.duplicateOwner, .replacement, .invalidIdentity, .operation, .contained),
            (
                .incompatibleAssociation, .initialOrCandidateBinding, .invalidIdentity, .component,
                .contained
            ),
            (.incompatibleAssociation, .replacement, .invalidIdentity, .operation, .contained),
            (.staleAttachment, .candidateAttachment, .invalidIdentity, .component, .contained),
            (
                .staleAttachment, .replacementAttachment, .invalidIdentity,
                .operation, .contained
            ),
            (
                .staleAttachment, .retiredReport, .invalidIdentity,
                .operation, .contained
            ),
            (.invalidPhaseContained, .activeCycle, .invalidPhase, .activeCycle, .contained),
            (
                .invalidPhaseSafetyNotProven, .activeCycle, .invalidPhase, .activeCycle,
                .safetyNotProven
            ),
            (
                .reentrancyViolation, .activeCycle, .reentrancyViolation, .activeCycle,
                .safetyNotProven
            ),
            (.invariantViolation, .runtime, .invariantViolation, .runtime, .safetyNotProven),
        ]

    for (error, context, condition, scope, containment) in cases {
        let mapped = GiftUIObservableStateFailureAdapter.map(
            error,
            detectedAt: context,
            mandatoryEffectsComplete: true
        )
        #expect(mapped?.localError == error)
        #expect(mapped?.detectionContext == context)
        #expect(mapped?.fact.condition == condition)
        #expect(mapped?.fact.origin == .observableState)
        #expect(mapped?.fact.affectedScope == scope)
        #expect(mapped?.fact.containment == containment)
    }
}

@Test
func mappingRejectsIncompleteEffectsAndEveryInvalidContextPair() {
    let errors: [ObservableStateError] = [
        .locationCapacityExhausted, .registrationCapacityExhausted,
        .associationStagingCapacityExhausted, .replacementStagingCapacityExhausted,
        .registrationGenerationExhausted, .duplicateOwner, .incompatibleAssociation,
        .staleAttachment, .invalidPhaseContained, .invalidPhaseSafetyNotProven,
        .reentrancyViolation, .invariantViolation,
    ]
    let contexts: [ObservableStateFailureDetectionContext] = [
        .initialOrCandidateBinding, .replacement, .candidateAttachment,
        .replacementAttachment, .retiredReport, .activeCycle, .runtime,
    ]
    let legal = Set([
        "0:0", "1:0", "1:1", "2:5", "3:1", "4:6", "5:0", "5:1",
        "6:0", "6:1", "7:2", "7:3", "7:4", "8:5", "9:5", "10:5", "11:6",
    ])

    for error in errors {
        for context in contexts {
            let key = "\(error.rawValue):\(context.rawValue)"
            let mapped = GiftUIObservableStateFailureAdapter.map(
                error,
                detectedAt: context,
                mandatoryEffectsComplete: true
            )
            #expect((mapped != nil) == legal.contains(key))
            #expect(
                GiftUIObservableStateFailureAdapter.map(
                    error,
                    detectedAt: context,
                    mandatoryEffectsComplete: false
                ) == nil
            )
        }
    }
}
