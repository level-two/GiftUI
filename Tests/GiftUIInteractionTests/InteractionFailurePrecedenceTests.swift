import Testing

@testable import GiftUIInteraction

@Test
func everyIndividualFailureSelectsItself() {
    for error in precedenceOrder {
        var failures = InteractionVisibleFailures()
        failures.insert(error)
        #expect(InteractionFailurePrecedence.select(from: failures) == error)
    }
}

@Test
func everySimultaneousPairSelectsTheHigherPrecedenceFailure() {
    for higherIndex in precedenceOrder.indices {
        for lowerIndex in precedenceOrder.indices where lowerIndex > higherIndex {
            var failures = InteractionVisibleFailures()
            failures.insert(precedenceOrder[lowerIndex])
            failures.insert(precedenceOrder[higherIndex])
            #expect(
                InteractionFailurePrecedence.select(from: failures)
                    == precedenceOrder[higherIndex]
            )
        }
    }
}

@Test
func emptyFailureSetSelectsNothingAndInsertionIsIdempotent() {
    var failures = InteractionVisibleFailures()
    #expect(InteractionFailurePrecedence.select(from: failures) == nil)
    failures.insert(.invalidPhase)
    failures.insert(.invalidPhase)
    #expect(InteractionFailurePrecedence.select(from: failures) == .invalidPhase)
}

private let precedenceOrder: [InteractionError] = [
    .reentrancyViolation,
    .invalidPhase,
    .incompatibleActionDomain,
    .missingModelTarget,
    .invalidIdentity,
    .invalidGeometry,
    .invalidActionValue,
    .capacityExhausted,
    .invariantViolation,
]
