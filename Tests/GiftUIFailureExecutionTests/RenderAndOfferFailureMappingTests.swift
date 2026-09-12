import Testing

@testable import GiftUIExecution
@testable import GiftUIFailureCore
@testable import GiftUIFailureExecution
@testable import GiftUIRenderCore

private let offerContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 10),
    semanticRevision: SemanticRevision(rawValue: 11),
    candidateFrame: CandidateFrameID(rawValue: 12),
    phase: .offering
)

private enum RenderMappingOwner: Equatable, Sendable {
    case unused
}

private func offered(
    _ failure: RunCycleFailure<RenderMappingOwner>,
    effectsComplete: Bool = true
) -> GiftUICorrelatedFailure<ExecutionContext>? {
    GiftUIExecutionFailureAdapter.offeredFailure(
        failure,
        context: offerContext,
        mechanicalEffectsComplete: effectsComplete
    )
}

@Test
func everyMappableRenderErrorPreservesExactOwnerMapping() {
    let cases:
        [(
            RenderProductionError,
            GiftUIConditionID,
            GiftUIFailureOrigin,
            GiftUIAffectedScope,
            GiftUIContainment
        )] = [
            (.invalidInput, .invalidValue, .rendering, .candidateFrame, .contained),
            (.arithmeticOverflow, .arithmeticOverflow, .foundation, .operation, .contained),
            (.capacityExhausted, .capacityExhausted, .rendering, .candidateFrame, .contained),
            (.incompatibleTextResource, .invalidValue, .rendering, .candidateFrame, .contained),
            (
                .reentrancyViolation, .reentrancyViolation, .rendering, .activeCycle,
                .safetyNotProven
            ),
            (.invariantViolation, .invariantViolation, .rendering, .runtime, .safetyNotProven),
        ]

    for (error, condition, origin, scope, containment) in cases {
        let mapped = offered(.renderProduction(error))
        #expect(mapped?.context == offerContext)
        #expect(mapped?.fact.condition == condition)
        #expect(mapped?.fact.origin == origin)
        #expect(mapped?.fact.affectedScope == scope)
        #expect(mapped?.fact.containment == containment)
    }
}

@Test
func sinkRefusalUsesOnlyTheRenderProducerRefusalRoute() {
    #expect(
        offered(.renderProduction(.sinkRefused)) == nil
    )
    let mapped = offered(.nonRetryableRefusal(.renderProducer))
    #expect(mapped?.fact.condition == .nonRetryableRefusal)
    #expect(mapped?.fact.origin == .rendering)
    #expect(mapped?.fact.affectedScope == .candidateFrame)
    #expect(mapped?.fact.containment == .contained)
}

@Test
func endpointRefusalRemainsDistinctFromRenderProducerRefusal() {
    let mapped = offered(.nonRetryableRefusal(.endpoint))
    #expect(mapped?.fact.condition == .nonRetryableRefusal)
    #expect(mapped?.fact.origin == .backend)
    #expect(mapped?.fact.affectedScope == .candidateFrame)
}

@Test
func frameOfferMapsOnlyLegalCoordinatorFailures() {
    let invalid = offered(.frameOffer(.invalidEnvelope))
    #expect(invalid?.fact.condition == .invalidValue)
    #expect(invalid?.fact.origin == .backend)
    #expect(invalid?.fact.affectedScope == .candidateFrame)
    #expect(invalid?.fact.containment == .contained)

    let contract = offered(.frameOffer(.contractViolation))
    #expect(contract?.fact.condition == .invariantViolation)
    #expect(contract?.fact.origin == .backend)
    #expect(contract?.fact.affectedScope == .runtime)
    #expect(contract?.fact.containment == .safetyNotProven)
}

@Test
func impossibleFrameOfferFailuresCannotReplaceProducerError() {
    let failures: [RunCycleFailure<RenderMappingOwner>] = [
        .frameOffer(.insufficientCapacity),
        .frameOffer(.producerFailed),
    ]
    for failure in failures {
        #expect(offered(failure) == nil)
    }
}

@Test
func noOfferMappingCanPrecedeMandatoryAbortAndQuiescence() {
    #expect(
        offered(.frameOffer(.invalidEnvelope), effectsComplete: false) == nil
    )
    #expect(
        offered(.nonRetryableRefusal(.endpoint), effectsComplete: false) == nil
    )
}
