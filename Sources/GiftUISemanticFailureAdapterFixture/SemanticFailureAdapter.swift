import GiftUIFailureCore
import GiftUISemanticCore

package enum GiftUISemanticFailureAdapterFixture {
    package static func fact(
        for error: SemanticExpansionError
    ) -> GiftUIFailureFact {
        let condition: GiftUIConditionID
        let containment: GiftUIContainment
        switch error {
        case .capacityExhausted:
            condition = .capacityExhausted
            containment = .contained
        case .invalidIdentity:
            condition = .invalidIdentity
            containment = .contained
        case .reentrancyViolation:
            condition = .reentrancyViolation
            containment = .contained
        case .invariantViolation:
            condition = .invariantViolation
            containment = .safetyNotProven
        }
        return GiftUIFailureFact(
            condition: condition,
            origin: .semantic,
            affectedScope: .activeCycle,
            containment: containment
        )
    }

    package static let invalidLimitsFact = GiftUIFailureFact(
        condition: .invalidValue,
        origin: .semantic,
        affectedScope: .runtime,
        containment: .contained
    )
}
