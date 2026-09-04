import GiftUIFailureCore
import GiftUITextResources

package enum GiftUITextResourceFailureAdapterFixture {
    package static func assemblyFact(
        for error: TextResourceValidationError
    ) -> GiftUIFailureFact {
        let condition: GiftUIConditionID
        switch error {
        case .unsupportedSchema,
            .invalidCount,
            .malformedMetrics,
            .malformedMapping,
            .malformedRasterRecord:
            condition = .invalidValue
        case .invalidIdentity,
            .incompatibleViews,
            .integrityMismatch:
            condition = .invalidIdentity
        case .capacityExceeded:
            condition = .capacityExhausted
        }
        return GiftUIFailureFact(
            condition: condition,
            origin: .hostComposition,
            affectedScope: .runtime,
            containment: .contained
        )
    }

    package static let unexpectedLayoutLookup = GiftUIFailureFact(
        condition: .invariantViolation,
        origin: .layout,
        affectedScope: .candidateFrame,
        containment: .safetyNotProven
    )

    package static let unexpectedRenderLookup = GiftUIFailureFact(
        condition: .invariantViolation,
        origin: .rendering,
        affectedScope: .candidateFrame,
        containment: .safetyNotProven
    )

    package static let layoutArithmeticOverflow = GiftUIFailureFact(
        condition: .arithmeticOverflow,
        origin: .foundation,
        affectedScope: .operation,
        containment: .contained
    )

    package static let requiredRenderRealizationLoss = GiftUIFailureFact(
        condition: .requiredFacilityUnavailable,
        origin: .rendering,
        affectedScope: .runtime,
        containment: .contained
    )
}
