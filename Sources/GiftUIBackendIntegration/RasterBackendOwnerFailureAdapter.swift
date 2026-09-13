import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore

package enum RasterFailureDetectionPoint: UInt8, Equatable, Sendable {
    case construction = 0
    case preBody = 1
    case postBegin = 2
    case postAcceptance = 3
}

package struct RasterBackendFailureMapping: Equatable, Sendable {
    package let rasterError: RasterBackendError?
    package let displayError: DisplayTargetError?
    package let fact: GiftUIFailureFact
}

package enum RasterBackendOwnerFailureAdapter {
    package static func map(
        _ error: RasterBackendError,
        at point: RasterFailureDetectionPoint
    ) -> RasterBackendFailureMapping {
        let fact: GiftUIFailureFact
        switch (point, error) {
        case (.construction, .arithmeticOverflow):
            fact = failure(.arithmeticOverflow, .foundation, .runtime, .contained)
        case (.construction, .capacityExhausted):
            fact = failure(.capacityExhausted, .hostComposition, .runtime, .contained)
        case (.construction, _):
            fact = failure(
                .invariantViolation,
                .hostComposition,
                .runtime,
                .safetyNotProven
            )
        case (.preBody, .invalidEnvelope), (.preBody, .invalidGeometry):
            fact = failure(.invalidValue, .backend, .candidateFrame, .contained)
        case (_, .reentrancyViolation):
            fact = failure(
                .reentrancyViolation,
                .backend,
                .runtime,
                .safetyNotProven
            )
        case (.postAcceptance, .displayFailure):
            fact = failure(
                .requiredFacilityUnavailable,
                .presentationIntegration,
                .component,
                .contained
            )
        default:
            fact = failure(
                .invariantViolation,
                .backend,
                .runtime,
                .safetyNotProven
            )
        }
        return RasterBackendFailureMapping(
            rasterError: error,
            displayError: nil,
            fact: fact
        )
    }

    package static func map(
        _ error: DisplayTargetError,
        at point: RasterFailureDetectionPoint
    ) -> RasterBackendFailureMapping {
        let fact: GiftUIFailureFact
        switch (point, error) {
        case (.postAcceptance, .transportUnavailable):
            fact = failure(
                .requiredFacilityUnavailable,
                .presentationIntegration,
                .component,
                .contained
            )
        case (_, .reentrancyViolation):
            fact = failure(
                .reentrancyViolation,
                .backend,
                .runtime,
                .safetyNotProven
            )
        default:
            fact = failure(
                .invariantViolation,
                .backend,
                .runtime,
                .safetyNotProven
            )
        }
        return RasterBackendFailureMapping(
            rasterError: nil,
            displayError: error,
            fact: fact
        )
    }

    private static func failure(
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
