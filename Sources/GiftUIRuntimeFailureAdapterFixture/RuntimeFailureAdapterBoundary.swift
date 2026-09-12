import GiftUIFailureCore
import GiftUIFailureExecution
import GiftUIRuntimeCore

package enum GiftUIRuntimeFailureAdapter {
    package static func validation(
        _ error: RuntimeProfileValidationError
    ) -> GiftUIFailureFact {
        switch error {
        case .invalidLimits, .incompatibleLimits:
            fact(.invalidValue, .hostComposition, .contained)
        case .missingStorage, .insufficientStorage:
            fact(.capacityExhausted, .hostComposition, .contained)
        case .arithmeticOverflow:
            fact(.arithmeticOverflow, .foundation, .contained)
        case .staticCanvasTableInvalid, .invariantViolation:
            fact(.invariantViolation, .hostComposition, .safetyNotProven)
        }
    }

    package static func preservingFocusedOwner(
        _ correlated: CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>
    ) -> CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>? {
        correlated
    }

    private static func fact(
        _ condition: GiftUIConditionID,
        _ origin: GiftUIFailureOrigin,
        _ containment: GiftUIContainment
    ) -> GiftUIFailureFact {
        GiftUIFailureFact(
            condition: condition,
            origin: origin,
            affectedScope: .runtime,
            containment: containment
        )
    }
}
