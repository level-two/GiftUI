import GiftUIDrawing
import GiftUIDrawingFailureAdapterFixture
import GiftUIFailureCore
import Testing

@Test func drawingFailuresMapToTheExactOwnerFacts() {
    let contained:
        [(DrawingProductionError, GiftUIConditionID, GiftUIFailureOrigin, GiftUIAffectedScope)] = [
            (.invalidValue, .invalidValue, .rendering, .activeCycle),
            (.invalidPathState, .invalidValue, .rendering, .activeCycle),
            (.arithmeticOverflow, .arithmeticOverflow, .foundation, .operation),
            (.capacityExhausted, .capacityExhausted, .rendering, .activeCycle),
            (.operationCapacityExhausted, .capacityExhausted, .rendering, .activeCycle),
        ]
    for (error, condition, origin, scope) in contained {
        #expect(
            GiftUIDrawingFailureAdapterFixture.fact(for: error)
                == GiftUIFailureFact(
                    condition: condition,
                    origin: origin,
                    affectedScope: scope,
                    containment: .contained
                )
        )
    }

    let unsafe: [(DrawingProductionError, GiftUIConditionID, GiftUIAffectedScope)] = [
        (.invalidScope, .invalidPhase, .activeCycle),
        (.invalidPhase, .invalidPhase, .activeCycle),
        (.reentrancyViolation, .reentrancyViolation, .activeCycle),
        (.invariantViolation, .invariantViolation, .runtime),
    ]
    for (error, condition, scope) in unsafe {
        #expect(
            GiftUIDrawingFailureAdapterFixture.fact(for: error)
                == GiftUIFailureFact(
                    condition: condition,
                    origin: .rendering,
                    affectedScope: scope,
                    containment: .safetyNotProven
                )
        )
    }
}

@Test func offerTimeDrawingFailuresRemainSeparateFromDerivationFailures() {
    #expect(
        GiftUIDrawingFailureAdapterFixture.idleSinkRefusal
            == GiftUIFailureFact(
                condition: .nonRetryableRefusal,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .contained
            )
    )
    #expect(
        GiftUIDrawingFailureAdapterFixture.combinedStreamInvariant
            == GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .rendering,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
    )
}
