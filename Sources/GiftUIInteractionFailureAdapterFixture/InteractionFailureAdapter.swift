import GiftUIFailureCore
import GiftUIFailureExecution
import GiftUIInteraction

package enum InteractionFailureDetector: UInt8, Equatable, Sendable {
    case interaction = 0
    case coordinator = 1
}

package struct CorrelatedInteractionFailure<Context>: Equatable, Sendable
where Context: Equatable & Sendable {
    package let localError: InteractionError
    package let detector: InteractionFailureDetector
    package let failure: GiftUICorrelatedFailure<Context>
}

package enum InteractionFailureAdapter {
    package static func map<Context>(
        _ error: InteractionError,
        detectedBy detector: InteractionFailureDetector,
        context: Context,
        mandatoryEffectsComplete: Bool
    ) -> CorrelatedInteractionFailure<Context>?
    where Context: Equatable & Sendable {
        guard mandatoryEffectsComplete, detectorIsValid(detector, for: error) else {
            return nil
        }

        let fact: GiftUIFailureFact
        switch error {
        case .capacityExhausted:
            fact = makeFact(.capacityExhausted, .interaction, .candidateFrame, .contained)
        case .invalidIdentity:
            fact = makeFact(.invalidIdentity, .interaction, .candidateFrame, .contained)
        case .invalidGeometry, .incompatibleActionDomain, .invalidActionValue:
            fact = makeFact(.invalidValue, .interaction, .candidateFrame, .contained)
        case .missingModelTarget:
            fact = makeFact(.invalidIdentity, .observableState, .candidateFrame, .contained)
        case .invalidPhase:
            fact = makeFact(.invalidPhase, .interaction, .activeCycle, .safetyNotProven)
        case .reentrancyViolation:
            fact = makeFact(
                .reentrancyViolation,
                .interaction,
                .activeCycle,
                .safetyNotProven
            )
        case .invariantViolation:
            fact = makeFact(.invariantViolation, .interaction, .runtime, .safetyNotProven)
        }

        return CorrelatedInteractionFailure(
            localError: error,
            detector: detector,
            failure: GiftUICorrelatedFailure(fact: fact, context: context)
        )
    }

    private static func detectorIsValid(
        _ detector: InteractionFailureDetector,
        for error: InteractionError
    ) -> Bool {
        switch error {
        case .capacityExhausted, .invalidIdentity, .invalidGeometry, .invalidPhase,
            .reentrancyViolation, .invariantViolation:
            detector == .interaction
        case .incompatibleActionDomain, .invalidActionValue, .missingModelTarget:
            detector == .coordinator
        }
    }

    private static func makeFact(
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
