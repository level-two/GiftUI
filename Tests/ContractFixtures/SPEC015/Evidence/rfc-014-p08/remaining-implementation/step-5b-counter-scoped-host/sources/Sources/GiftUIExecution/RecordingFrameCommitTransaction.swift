import GiftUI

struct RecordingPresentationState: Equatable, Sendable {
    let presentationRevision: PresentationRevision
    let logicalFrameToken: UInt16
    let hitGeometryToken: UInt16
    let actionTableToken: UInt16
    let routingToken: UInt16
}

enum RecordingEndpointHealth: UInt8, Equatable, Sendable {
    case ready = 0
    case accepted = 1
    case unavailable = 2
}

enum RecordingFrameCommitOutcome: Equatable, Sendable {
    case committed(RecordingPresentationState)
    case aborted(RecordingNormalizedOffer)
    case failure(RunCycleFailure<RecordingCycleOwnerFailure>)
}

struct RecordingFrameCommitTransaction: Equatable, Sendable {
    private(set) var publishedSemanticRevision: SemanticRevision
    private(set) var committedState: RecordingPresentationState?
    private(set) var stagedState: RecordingPresentationState?
    private(set) var stagedCandidate: CandidateFrameID?
    private(set) var candidateAborted = false
    private(set) var endpointHealth: RecordingEndpointHealth = .ready
    private(set) var didFinish = false

    init(
        publishedSemanticRevision: SemanticRevision,
        committedState: RecordingPresentationState?
    ) {
        self.publishedSemanticRevision = publishedSemanticRevision
        self.committedState = committedState
    }

    mutating func stage(
        candidate: CandidateFrameID,
        state: RecordingPresentationState
    ) -> ExecutionError? {
        guard stagedState == nil, !didFinish else {
            return .reentrancyViolation
        }
        stagedCandidate = candidate
        stagedState = state
        candidateAborted = false
        return nil
    }

    mutating func finish(
        normalizedOffer: RecordingNormalizedOffer,
        completeConsumptionAndReservation: Bool,
        irreversibleOutputObserved: Bool
    ) -> RecordingFrameCommitOutcome {
        guard !didFinish, let stagedState, stagedCandidate != nil else {
            return .failure(.execution(.invalidPhase))
        }
        didFinish = true

        if irreversibleOutputObserved, normalizedOffer != .accepted {
            abortStagedState()
            endpointHealth = .unavailable
            return .failure(.frameOffer(.contractViolation))
        }

        switch normalizedOffer {
        case .accepted:
            guard completeConsumptionAndReservation else {
                abortStagedState()
                endpointHealth = .unavailable
                return .failure(.frameOffer(.contractViolation))
            }
            committedState = stagedState
            self.stagedState = nil
            stagedCandidate = nil
            endpointHealth = .accepted
            return .committed(stagedState)
        case .operational, .failure:
            abortStagedState()
            return .aborted(normalizedOffer)
        }
    }

    private mutating func abortStagedState() {
        stagedState = nil
        stagedCandidate = nil
        candidateAborted = true
    }
}
