import GiftUIFailureCore
import GiftUILayout

package enum GiftUILayoutFailureAdapterFixture {
    package static func fact(for error: LayoutError) -> GiftUIFailureFact {
        switch error {
        case .invalidDeclaration:
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        case .arithmeticOverflow:
            GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .operation,
                containment: .contained
            )
        case .capacityExhausted:
            GiftUIFailureFact(
                condition: .capacityExhausted,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        case .reentrancyViolation:
            GiftUIFailureFact(
                condition: .reentrancyViolation,
                origin: .layout,
                affectedScope: .activeCycle,
                containment: .contained
            )
        case .invariantViolation:
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .safetyNotProven
            )
        }
    }

    package static let invalidLimitsFact = GiftUIFailureFact(
        condition: .invalidValue,
        origin: .layout,
        affectedScope: .runtime,
        containment: .contained
    )
}
