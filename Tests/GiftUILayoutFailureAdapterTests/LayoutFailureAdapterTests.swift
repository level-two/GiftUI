import GiftUIFailureCore
import Testing

@testable import GiftUILayout
@testable import GiftUILayoutFailureAdapterFixture

@Test
func everyLayoutErrorMapsToItsExactOwnerFact() {
    let rows: [(LayoutError, GiftUIFailureFact)] = [
        (
            .invalidDeclaration,
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        ),
        (
            .arithmeticOverflow,
            GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .operation,
                containment: .contained
            )
        ),
        (
            .capacityExhausted,
            GiftUIFailureFact(
                condition: .capacityExhausted,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .contained
            )
        ),
        (
            .reentrancyViolation,
            GiftUIFailureFact(
                condition: .reentrancyViolation,
                origin: .layout,
                affectedScope: .activeCycle,
                containment: .contained
            )
        ),
        (
            .invariantViolation,
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .safetyNotProven
            )
        ),
    ]

    for (error, expected) in rows {
        #expect(GiftUILayoutFailureAdapterFixture.fact(for: error) == expected)
    }
}

@Test
func invalidLimitsMapBeforeTheFirstCycle() {
    #expect(
        GiftUILayoutFailureAdapterFixture.invalidLimitsFact
            == GiftUIFailureFact(
                condition: .invalidValue,
                origin: .layout,
                affectedScope: .runtime,
                containment: .contained
            )
    )
}
