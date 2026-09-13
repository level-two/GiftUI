import GiftUIDrawing
import GiftUIFailureCore

package enum GiftUIDrawingFailureAdapterFixture {
    package static func fact(for error: DrawingProductionError) -> GiftUIFailureFact {
        switch error {
        case .invalidValue, .invalidPathState:
            fact(.invalidValue, .rendering, .activeCycle, .contained)
        case .arithmeticOverflow:
            fact(.arithmeticOverflow, .foundation, .operation, .contained)
        case .capacityExhausted, .operationCapacityExhausted:
            fact(.capacityExhausted, .rendering, .activeCycle, .contained)
        case .invalidScope, .invalidPhase:
            fact(.invalidPhase, .rendering, .activeCycle, .safetyNotProven)
        case .reentrancyViolation:
            fact(.reentrancyViolation, .rendering, .activeCycle, .safetyNotProven)
        case .invariantViolation:
            combinedStreamInvariant
        }
    }

    package static let idleSinkRefusal = fact(
        .nonRetryableRefusal,
        .rendering,
        .candidateFrame,
        .contained
    )

    package static let combinedStreamInvariant = fact(
        .invariantViolation,
        .rendering,
        .runtime,
        .safetyNotProven
    )

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
