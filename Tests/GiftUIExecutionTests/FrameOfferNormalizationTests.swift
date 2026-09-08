import GiftUIRenderCore
import Testing

@testable import GiftUIExecution

private let normalizationEndpointResults: [FrameOfferResult] = [
    FrameOfferResult(disposition: .accepted, failure: nil)!,
    FrameOfferResult(disposition: .backpressured, failure: nil)!,
    FrameOfferResult(disposition: .retryableRefusal, failure: nil)!,
    FrameOfferResult(disposition: .nonRetryableRefusal, failure: nil)!,
    FrameOfferResult(disposition: .failed, failure: .invalidEnvelope)!,
    FrameOfferResult(disposition: .failed, failure: .insufficientCapacity)!,
    FrameOfferResult(disposition: .failed, failure: .producerFailed)!,
    FrameOfferResult(disposition: .failed, failure: .contractViolation)!,
]

@Test
func productionAdapterPreservesEveryExactRenderError() {
    let errors: [RenderProductionError] = [
        .invalidInput,
        .arithmeticOverflow,
        .capacityExhausted,
        .incompatibleTextResource,
        .sinkRefused,
        .reentrancyViolation,
        .invariantViolation,
    ]

    #expect(
        RecordingRenderProductionAdapter.observe(error: nil)
            == RecordingFrameBodyObservation(
                wasCalled: true,
                streamResult: .complete,
                retainedError: nil
            )
    )
    for error in errors {
        let observation = RecordingRenderProductionAdapter.observe(error: error)
        #expect(observation.retainedError == error)
        let endpointResult = matchingEndpointResult(for: observation.streamResult!)
        let normalized = RecordingFrameOfferNormalizer.normalize(
            observation: observation,
            endpointResult: endpointResult
        )
        if error == .sinkRefused {
            #expect(
                normalized
                    == .failure(.nonRetryableRefusal(.renderProducer))
            )
        } else {
            #expect(normalized == .failure(.renderProduction(error)))
        }
    }
}

@Test
func noBodyRowsNormalizeExactEndpointOutcomesAndOrigins() {
    let expected: [RecordingNormalizedOffer] = [
        .failure(.frameOffer(.contractViolation)),
        .operational(.backpressured),
        .operational(.retryableRefusal),
        .failure(.nonRetryableRefusal(.endpoint)),
        .failure(.frameOffer(.invalidEnvelope)),
        .failure(.frameOffer(.contractViolation)),
        .failure(.frameOffer(.contractViolation)),
        .failure(.frameOffer(.contractViolation)),
    ]

    for index in normalizationEndpointResults.indices {
        #expect(
            RecordingFrameOfferNormalizer.normalize(
                observation: .notCalled,
                endpointResult: normalizationEndpointResults[index]
            ) == expected[index]
        )
    }
}

@Test
func everyBodyObservationAndEndpointPairingNormalizesExhaustively() {
    let streamResults: [FrameStreamResult] = [
        .complete,
        .producerFailed,
        .insufficientCapacity,
        .endpointRefused,
        .contractViolation,
    ]
    let retainedErrors: [RenderProductionError?] = [
        nil,
        .invalidInput,
        .arithmeticOverflow,
        .capacityExhausted,
        .incompatibleTextResource,
        .sinkRefused,
        .reentrancyViolation,
        .invariantViolation,
    ]

    for streamResult in streamResults {
        for retainedError in retainedErrors {
            let observation = RecordingFrameBodyObservation(
                wasCalled: true,
                streamResult: streamResult,
                retainedError: retainedError
            )!
            for endpointResult in normalizationEndpointResults {
                let normalized = RecordingFrameOfferNormalizer.normalize(
                    observation: observation,
                    endpointResult: endpointResult
                )
                #expect(
                    normalized
                        == independentlyExpectedNormalization(
                            observation: observation,
                            endpointResult: endpointResult
                        )
                )
            }
        }
    }
}

@Test
func observationRejectsCalledAndPayloadContradictions() {
    #expect(
        RecordingFrameBodyObservation(
            wasCalled: false,
            streamResult: .complete,
            retainedError: nil
        ) == nil
    )
    #expect(
        RecordingFrameBodyObservation(
            wasCalled: true,
            streamResult: nil,
            retainedError: nil
        ) == nil
    )
    #expect(
        RecordingFrameBodyObservation(
            wasCalled: false,
            streamResult: nil,
            retainedError: .invalidInput
        ) == nil
    )
}

private func matchingEndpointResult(
    for streamResult: FrameStreamResult
) -> FrameOfferResult {
    switch streamResult {
    case .complete:
        FrameOfferResult(disposition: .accepted, failure: nil)!
    case .producerFailed:
        FrameOfferResult(disposition: .failed, failure: .producerFailed)!
    case .insufficientCapacity:
        FrameOfferResult(disposition: .failed, failure: .insufficientCapacity)!
    case .endpointRefused:
        FrameOfferResult(disposition: .nonRetryableRefusal, failure: nil)!
    case .contractViolation:
        FrameOfferResult(disposition: .failed, failure: .contractViolation)!
    }
}

private func independentlyExpectedNormalization(
    observation: RecordingFrameBodyObservation,
    endpointResult: FrameOfferResult
) -> RecordingNormalizedOffer {
    let pair = (endpointResult.disposition, endpointResult.failure)
    return switch (observation.streamResult, observation.retainedError, pair) {
    case (.complete?, nil, (.accepted, nil)):
        .accepted
    case (.producerFailed?, let error?, (.failed, .producerFailed?)):
        .failure(.renderProduction(error))
    case (
        .insufficientCapacity?,
        .capacityExhausted?,
        (.failed, .insufficientCapacity?)
    ):
        .failure(.renderProduction(.capacityExhausted))
    case (
        .endpointRefused?,
        .sinkRefused?,
        (.nonRetryableRefusal, nil)
    ):
        .failure(.nonRetryableRefusal(.renderProducer))
    case (
        .contractViolation?,
        .invariantViolation?,
        (.failed, .contractViolation?)
    ):
        .failure(.renderProduction(.invariantViolation))
    default:
        .failure(.frameOffer(.contractViolation))
    }
}
