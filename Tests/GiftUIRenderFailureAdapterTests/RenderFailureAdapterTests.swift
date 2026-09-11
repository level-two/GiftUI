import GiftUIFailureCore
import Testing

@testable import GiftUIRenderFailureAdapterFixture
@testable import GiftUIRenderLowering

@Test
func everyRenderProductionErrorMapsToItsExactOwnerFact() {
    let rows: [(RenderProductionResult, GiftUIFailureFact)] = [
        (
            .failure(.invalidInput),
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        ),
        (
            .failure(.arithmeticOverflow),
            GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .operation,
                containment: .contained
            )
        ),
        (
            .failure(.capacityExhausted),
            GiftUIFailureFact(
                condition: .capacityExhausted,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        ),
        (
            .failure(.incompatibleTextResource),
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        ),
        (
            .failure(.sinkRefused),
            GiftUIFailureFact(
                condition: .nonRetryableRefusal,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        ),
        (
            .failure(.reentrancyViolation),
            GiftUIFailureFact(
                condition: .reentrancyViolation,
                origin: .rendering,
                affectedScope: .activeCycle,
                containment: .safetyNotProven
            )
        ),
        (
            .failure(.invariantViolation),
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .rendering,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
        ),
    ]

    for (result, expected) in rows {
        #expect(GiftUIRenderFailureAdapterFixture.fact(for: result) == expected)
    }
}
