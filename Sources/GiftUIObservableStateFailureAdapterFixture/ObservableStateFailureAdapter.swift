import GiftUIFailureCore
import GiftUIObservableState

package enum ObservableStateFailureDetectionContext: UInt8, Equatable, Sendable {
    case initialOrCandidateBinding = 0
    case replacement = 1
    case candidateAttachment = 2
    case replacementAttachment = 3
    case retiredReport = 4
    case activeCycle = 5
    case runtime = 6
}

package struct ObservableStateVisibleFailures: OptionSet, Equatable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue & 0x0003_FFFF
    }

    package static func failure(_ error: ObservableStateError) -> Self {
        Self(rawValue: 1 << UInt32(error.rawValue))
    }
}

package struct CorrelatedObservableStateFailure: Equatable, Sendable {
    package let localError: ObservableStateError
    package let detectionContext: ObservableStateFailureDetectionContext
    package let fact: GiftUIFailureFact
}

package enum GiftUIObservableStateFailureAdapter {
    package static func selectFocusedFailure(
        from visible: ObservableStateVisibleFailures
    ) -> ObservableStateError? {
        if visible.contains(.failure(.reentrancyViolation)) { return .reentrancyViolation }
        if visible.contains(.failure(.invalidPhaseSafetyNotProven)) {
            return .invalidPhaseSafetyNotProven
        }
        if visible.contains(.failure(.invalidPhaseContained)) { return .invalidPhaseContained }
        if visible.contains(.failure(.incompatibleAssociation)) { return .incompatibleAssociation }
        if visible.contains(.failure(.staleModel)) { return .staleModel }
        if visible.contains(.failure(.duplicateOwner)) { return .duplicateOwner }
        if visible.contains(.failure(.registrationGenerationExhausted)) {
            return .registrationGenerationExhausted
        }
        if visible.contains(.failure(.modelGenerationExhausted)) {
            return .modelGenerationExhausted
        }
        if visible.contains(.failure(.retainedModel)) { return .retainedModel }
        if visible.contains(.failure(.modelCapacityExhausted)) { return .modelCapacityExhausted }
        if visible.contains(.failure(.ownerCapacityExhausted)) { return .ownerCapacityExhausted }
        if visible.contains(.failure(.locationCapacityExhausted)) {
            return .locationCapacityExhausted
        }
        if visible.contains(.failure(.registrationCapacityExhausted)) {
            return .registrationCapacityExhausted
        }
        if visible.contains(.failure(.associationStagingCapacityExhausted)) {
            return .associationStagingCapacityExhausted
        }
        if visible.contains(.failure(.replacementStagingCapacityExhausted)) {
            return .replacementStagingCapacityExhausted
        }
        if visible.contains(.failure(.staleAttachment)) { return .staleAttachment }
        if visible.contains(.failure(.modelReadOutOfBounds)) { return .modelReadOutOfBounds }
        if visible.contains(.failure(.invariantViolation)) { return .invariantViolation }
        return nil
    }

    package static func map(
        _ error: ObservableStateError,
        detectedAt context: ObservableStateFailureDetectionContext,
        mandatoryEffectsComplete: Bool
    ) -> CorrelatedObservableStateFailure? {
        guard mandatoryEffectsComplete, let mapped = mapping(error, context: context) else {
            return nil
        }
        return CorrelatedObservableStateFailure(
            localError: error,
            detectionContext: context,
            fact: GiftUIFailureFact(
                condition: mapped.condition,
                origin: .observableState,
                affectedScope: mapped.scope,
                containment: mapped.containment
            )
        )
    }

    package static func residualInput(
        for failure: CorrelatedObservableStateFailure,
        priorRootExists: Bool,
        residualPolicyPermitted: Bool
    ) -> GiftUIResidualPolicyInput<ObservableStateFailureDetectionContext>? {
        guard residualPolicyPermitted else { return nil }

        let allowed: GiftUIAllowedDispositions
        switch (failure.localError, failure.detectionContext) {
        case (.invalidPhaseContained, .activeCycle):
            return nil
        case (.staleAttachment, .retiredReport):
            allowed = .continueOperation
        case (.modelCapacityExhausted, .replacement),
            (.ownerCapacityExhausted, .replacement),
            (.retainedModel, .replacement),
            (.staleModel, .replacement),
            (.modelReadOutOfBounds, .activeCycle),
            (.registrationCapacityExhausted, .replacement),
            (.replacementStagingCapacityExhausted, .replacement),
            (.duplicateOwner, .replacement),
            (.incompatibleAssociation, .replacement),
            (.staleAttachment, .replacementAttachment):
            allowed = [.continueOperation, .quiesceAffectedScope]
        case (.modelGenerationExhausted, .runtime),
            (.registrationGenerationExhausted, .runtime),
            (.invalidPhaseSafetyNotProven, .activeCycle),
            (.reentrancyViolation, .activeCycle),
            (.invariantViolation, .runtime):
            allowed = [.quiesceAffectedScope, .invokeFatalHook]
        case (.modelCapacityExhausted, .initialOrCandidateBinding),
            (.ownerCapacityExhausted, .initialOrCandidateBinding),
            (.locationCapacityExhausted, .initialOrCandidateBinding),
            (.registrationCapacityExhausted, .initialOrCandidateBinding),
            (.associationStagingCapacityExhausted, .activeCycle),
            (.duplicateOwner, .initialOrCandidateBinding),
            (.incompatibleAssociation, .initialOrCandidateBinding),
            (.staleAttachment, .candidateAttachment):
            if priorRootExists {
                allowed = [.continueOperation, .quiesceAffectedScope]
            } else {
                allowed = [.quiesceAffectedScope, .invokeFatalHook]
            }
        default:
            return nil
        }

        return GiftUIResidualPolicyInput(
            outcome: .failure(failure.fact),
            context: failure.detectionContext,
            allowed: allowed,
            attemptOrdinal: 0,
            attemptLimit: 1
        )
    }

    private static func mapping(
        _ error: ObservableStateError,
        context: ObservableStateFailureDetectionContext
    ) -> (
        condition: GiftUIConditionID,
        scope: GiftUIAffectedScope,
        containment: GiftUIContainment
    )? {
        switch (error, context) {
        case (.modelCapacityExhausted, .initialOrCandidateBinding),
            (.ownerCapacityExhausted, .initialOrCandidateBinding),
            (.locationCapacityExhausted, .initialOrCandidateBinding),
            (.registrationCapacityExhausted, .initialOrCandidateBinding):
            (.capacityExhausted, .component, .contained)
        case (.modelCapacityExhausted, .replacement),
            (.ownerCapacityExhausted, .replacement),
            (.retainedModel, .replacement),
            (.registrationCapacityExhausted, .replacement),
            (.replacementStagingCapacityExhausted, .replacement):
            (.capacityExhausted, .operation, .contained)
        case (.associationStagingCapacityExhausted, .activeCycle):
            (.capacityExhausted, .activeCycle, .contained)
        case (.modelGenerationExhausted, .runtime), (.registrationGenerationExhausted, .runtime):
            (.invalidIdentity, .runtime, .safetyNotProven)
        case (.duplicateOwner, .initialOrCandidateBinding),
            (.incompatibleAssociation, .initialOrCandidateBinding),
            (.staleAttachment, .candidateAttachment):
            (.invalidIdentity, .component, .contained)
        case (.duplicateOwner, .replacement),
            (.incompatibleAssociation, .replacement),
            (.staleAttachment, .replacementAttachment),
            (.staleAttachment, .retiredReport):
            (.invalidIdentity, .operation, .contained)
        case (.staleModel, .replacement), (.staleModel, .initialOrCandidateBinding),
            (.staleModel, .activeCycle):
            (.invalidIdentity, .operation, .contained)
        case (.modelReadOutOfBounds, .activeCycle):
            (.invalidValue, .activeCycle, .contained)
        case (.invalidPhaseContained, .activeCycle):
            (.invalidPhase, .activeCycle, .contained)
        case (.invalidPhaseSafetyNotProven, .activeCycle):
            (.invalidPhase, .activeCycle, .safetyNotProven)
        case (.reentrancyViolation, .activeCycle):
            (.reentrancyViolation, .activeCycle, .safetyNotProven)
        case (.invariantViolation, .runtime):
            (.invariantViolation, .runtime, .safetyNotProven)
        default:
            nil
        }
    }
}
