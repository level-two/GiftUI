import GiftUIFailureCore
import GiftUIRenderLowering

package enum GiftUIRenderFailureAdapterFixture {
    package static func fact(for result: RenderProductionResult) -> GiftUIFailureFact? {
        guard case .failure(let error) = result else { return nil }

        return switch error {
        case .invalidInput:
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .rendering,
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
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        case .incompatibleTextResource:
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        case .sinkRefused:
            GiftUIFailureFact(
                condition: .nonRetryableRefusal,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        case .reentrancyViolation:
            GiftUIFailureFact(
                condition: .reentrancyViolation,
                origin: .rendering,
                affectedScope: .activeCycle,
                containment: .safetyNotProven
            )
        case .invariantViolation:
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .rendering,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
        }
    }
}
