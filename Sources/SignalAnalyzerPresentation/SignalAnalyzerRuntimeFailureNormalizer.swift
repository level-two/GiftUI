import GiftUIFailureCore

/// Exact application meaning without requiring a diagnostic projection.
package enum SignalAnalyzerRuntimeFailureNormalizer {
    package static func fact(
        for condition: SignalAnalyzerRuntimeCondition,
        stableStateProven: Bool
    ) -> GiftUIFailureFact {
        let failure: GiftUIFailureFact
        switch condition {
        case .stateLocationCapacityExhausted, .registrationCapacityExhausted:
            failure = fact(.capacityExhausted, .observableState, .component, .contained)
        case .replacementStagingExhausted:
            failure = fact(.capacityExhausted, .observableState, .operation, .contained)
        case .duplicateModelOwner, .incompatibleStateAssociation:
            failure = fact(.invalidIdentity, .observableState, .component, .contained)
        case .staleRegistrationReport:
            failure = fact(.invalidIdentity, .observableState, .operation, .contained)
        case .identityGenerationExhausted:
            failure = fact(.invalidIdentity, .observableState, .runtime, .safetyNotProven)
        case .captureRevisionMismatch:
            failure = fact(.invalidProvenance, .presentationIntegration, .component, .contained)
        case .reservedFailureCapacityExhausted:
            failure = fact(.capacityExhausted, .presentationIntegration, .runtime, .safetyNotProven)
        case .mutationPhaseViolation:
            failure = fact(
                .invalidPhase,
                .observableState,
                .activeCycle,
                stableStateProven ? .contained : .safetyNotProven
            )
        case .observableStateReentrancyViolation:
            failure = fact(.reentrancyViolation, .observableState, .activeCycle, .safetyNotProven)
        case .observableStateInvariantViolation:
            failure = fact(.invariantViolation, .observableState, .runtime, .safetyNotProven)
        }
        return failure
    }

    private static func fact(
        _ condition: GiftUIConditionID,
        _ origin: GiftUIFailureOrigin,
        _ scope: GiftUIAffectedScope,
        _ containment: GiftUIContainment
    ) -> GiftUIFailureFact {
        GiftUIFailureFact(
            condition: condition,
            origin: origin,
            affectedScope: scope,
            containment: containment
        )
    }
}
