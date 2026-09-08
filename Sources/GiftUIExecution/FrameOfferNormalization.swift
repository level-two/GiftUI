import GiftUIRenderCore

struct RecordingFrameBodyObservation: Equatable, Sendable {
    let wasCalled: Bool
    let streamResult: FrameStreamResult?
    let retainedError: RenderProductionError?

    init?(
        wasCalled: Bool,
        streamResult: FrameStreamResult?,
        retainedError: RenderProductionError?
    ) {
        guard wasCalled == (streamResult != nil) else { return nil }
        guard wasCalled || retainedError == nil else { return nil }
        self.wasCalled = wasCalled
        self.streamResult = streamResult
        self.retainedError = retainedError
    }

    static let notCalled = Self(
        wasCalled: false,
        streamResult: nil,
        retainedError: nil
    )!
}

enum RecordingNormalizedOffer: Equatable, Sendable {
    case accepted
    case operational(ExecutionOperational)
    case failure(RunCycleFailure<RecordingCycleOwnerFailure>)
}

enum RecordingRenderProductionAdapter {
    static func observe(
        error: RenderProductionError?
    ) -> RecordingFrameBodyObservation {
        guard let error else {
            return RecordingFrameBodyObservation(
                wasCalled: true,
                streamResult: .complete,
                retainedError: nil
            )!
        }

        let streamResult: FrameStreamResult =
            switch error {
            case .capacityExhausted:
                .insufficientCapacity
            case .sinkRefused:
                .endpointRefused
            case .invariantViolation:
                .contractViolation
            case .invalidInput,
                .arithmeticOverflow,
                .incompatibleTextResource,
                .reentrancyViolation:
                .producerFailed
            }
        return RecordingFrameBodyObservation(
            wasCalled: true,
            streamResult: streamResult,
            retainedError: error
        )!
    }
}

enum RecordingFrameOfferNormalizer {
    static func normalize(
        observation: RecordingFrameBodyObservation,
        endpointResult: FrameOfferResult
    ) -> RecordingNormalizedOffer {
        guard observation.wasCalled else {
            return normalizeWithoutBody(endpointResult)
        }

        switch (
            observation.streamResult,
            observation.retainedError,
            endpointResult.disposition,
            endpointResult.failure
        ) {
        case (.complete?, nil, .accepted, nil):
            return .accepted
        case (.producerFailed?, let error?, .failed, .producerFailed?):
            return .failure(.renderProduction(error))
        case (
            .insufficientCapacity?,
            .capacityExhausted?,
            .failed,
            .insufficientCapacity?
        ):
            return .failure(.renderProduction(.capacityExhausted))
        case (
            .endpointRefused?,
            .sinkRefused?,
            .nonRetryableRefusal,
            nil
        ):
            return .failure(.nonRetryableRefusal(.renderProducer))
        case (
            .contractViolation?,
            .invariantViolation?,
            .failed,
            .contractViolation?
        ):
            return .failure(.renderProduction(.invariantViolation))
        default:
            return .failure(.frameOffer(.contractViolation))
        }
    }

    private static func normalizeWithoutBody(
        _ endpointResult: FrameOfferResult
    ) -> RecordingNormalizedOffer {
        switch (endpointResult.disposition, endpointResult.failure) {
        case (.backpressured, nil):
            return .operational(.backpressured)
        case (.retryableRefusal, nil):
            return .operational(.retryableRefusal)
        case (.nonRetryableRefusal, nil):
            return .failure(.nonRetryableRefusal(.endpoint))
        case (.failed, .invalidEnvelope?):
            return .failure(.frameOffer(.invalidEnvelope))
        case (.failed, .contractViolation?):
            return .failure(.frameOffer(.contractViolation))
        default:
            return .failure(.frameOffer(.contractViolation))
        }
    }
}
