import GiftUIFailureCore
import GiftUIObservableState

package enum ObservableStateFailureDetectionContext: UInt8, Equatable, Sendable {
    case initialOrCandidateBinding = 0
    case replacement = 1
    case candidateAttachment = 2
    case replacementAttachmentOrRetiredReport = 3
    case activeCycle = 4
    case runtime = 5
}

package struct CorrelatedObservableStateFailure: Equatable, Sendable {
    package let localError: ObservableStateError
    package let detectionContext: ObservableStateFailureDetectionContext
    package let fact: GiftUIFailureFact
}

package enum GiftUIObservableStateFailureAdapter {
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

    private static func mapping(
        _ error: ObservableStateError,
        context: ObservableStateFailureDetectionContext
    ) -> (
        condition: GiftUIConditionID,
        scope: GiftUIAffectedScope,
        containment: GiftUIContainment
    )? {
        switch (error, context) {
        case (.locationCapacityExhausted, .initialOrCandidateBinding),
            (.registrationCapacityExhausted, .initialOrCandidateBinding):
            (.capacityExhausted, .component, .contained)
        case (.registrationCapacityExhausted, .replacement),
            (.replacementStagingCapacityExhausted, .replacement):
            (.capacityExhausted, .operation, .contained)
        case (.associationStagingCapacityExhausted, .activeCycle):
            (.capacityExhausted, .activeCycle, .contained)
        case (.registrationGenerationExhausted, .runtime):
            (.invalidIdentity, .runtime, .safetyNotProven)
        case (.duplicateOwner, .initialOrCandidateBinding),
            (.incompatibleAssociation, .initialOrCandidateBinding),
            (.staleAttachment, .candidateAttachment):
            (.invalidIdentity, .component, .contained)
        case (.duplicateOwner, .replacement),
            (.incompatibleAssociation, .replacement),
            (.staleAttachment, .replacementAttachmentOrRetiredReport):
            (.invalidIdentity, .operation, .contained)
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
