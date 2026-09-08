import GiftUI

enum RecordingCandidateOrigin: UInt8, Equatable, Sendable {
    case newPublication = 0
    case unchangedRecovery = 1

    var allocationPhase: ExecutionPhase {
        switch self {
        case .newPublication: .publishing
        case .unchangedRecovery: .deriving
        }
    }
}

enum RecordingPreOfferCondition: UInt8, Equatable, Sendable {
    case ready = 0
    case facilityUnavailableBeforeCandidate = 1
    case facilityUnavailableAfterCandidate = 2
    case directContractFailure = 3
}

struct RecordingCandidateReservation: Equatable, Sendable {
    let provenance: FrameProvenance
    let presentationRevision: PresentationRevision
}

enum RecordingCandidateOfferOutcome: Equatable, Sendable {
    case offered(RecordingCandidateReservation, FrameOfferResult)
    case failure(
        ExecutionContext,
        RunCycleFailure<RecordingCycleOwnerFailure>,
        LogicalFrameDisposition
    )
}

struct RecordingCandidateOfferCoordinator: Sendable {
    private var candidates: CandidateFrameIDAllocator
    private var presentations: PresentationRevisionAllocator
    private(set) var endpoint: RecordingSynchronousFrameEndpoint
    private(set) var offerCallCount: UInt8 = 0

    init(
        candidates: CandidateFrameIDAllocator = CandidateFrameIDAllocator(),
        presentations: PresentationRevisionAllocator = PresentationRevisionAllocator(),
        endpoint: RecordingSynchronousFrameEndpoint
    ) {
        self.candidates = candidates
        self.presentations = presentations
        self.endpoint = endpoint
    }

    mutating func prepareAndOffer(
        origin: RecordingCandidateOrigin,
        cycle: RunCycleID,
        semanticRevision: SemanticRevision,
        condition: RecordingPreOfferCondition = .ready,
        envelopeValid: Bool = true,
        body: (inout RecordingFrameSink) -> FrameStreamResult
    ) -> RecordingCandidateOfferOutcome {
        let allocationPhase = origin.allocationPhase
        guard offerCallCount == 0 else {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: nil,
                phase: allocationPhase,
                failure: .execution(.reentrancyViolation),
                disposition: .notProduced
            )
        }
        if condition == .facilityUnavailableBeforeCandidate {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: nil,
                phase: allocationPhase,
                failure: .execution(.requiredFacilityUnavailable),
                disposition: .notProduced
            )
        }
        guard let candidate = candidates.reserve() else {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: nil,
                phase: allocationPhase,
                failure: .execution(.identityExhausted),
                disposition: .notProduced
            )
        }
        if condition == .facilityUnavailableAfterCandidate {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: candidate,
                phase: allocationPhase,
                failure: .execution(.requiredFacilityUnavailable),
                disposition: .aborted
            )
        }
        guard let presentation = presentations.reserve() else {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: candidate,
                phase: allocationPhase,
                failure: .execution(.identityExhausted),
                disposition: .aborted
            )
        }
        if condition == .directContractFailure {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: candidate,
                phase: allocationPhase,
                failure: .frameOffer(.contractViolation),
                disposition: .aborted
            )
        }

        let provenance = FrameProvenance(
            cycle: cycle,
            semanticRevision: semanticRevision,
            candidateFrame: candidate
        )
        let reservation = RecordingCandidateReservation(
            provenance: provenance,
            presentationRevision: presentation
        )
        endpoint.acceptsEnvelope = envelopeValid
        offerCallCount = 1
        let result = endpoint.offer(provenance: provenance, body: body)
        if result.disposition == .failed, let endpointFailure = result.failure {
            return failure(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidate: candidate,
                phase: .offering,
                failure: .frameOffer(endpointFailure),
                disposition: .aborted
            )
        }
        return .offered(reservation, result)
    }

    private func failure(
        cycle: RunCycleID,
        semanticRevision: SemanticRevision,
        candidate: CandidateFrameID?,
        phase: ExecutionPhase,
        failure: RunCycleFailure<RecordingCycleOwnerFailure>,
        disposition: LogicalFrameDisposition
    ) -> RecordingCandidateOfferOutcome {
        .failure(
            ExecutionContext(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidateFrame: candidate,
                phase: phase
            ),
            failure,
            disposition
        )
    }
}
