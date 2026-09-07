import GiftUIRenderCore

package struct FrameProvenance: Equatable, Sendable {
    package let cycle: RunCycleID
    package let semanticRevision: SemanticRevision
    package let candidateFrame: CandidateFrameID

    package init(
        cycle: RunCycleID,
        semanticRevision: SemanticRevision,
        candidateFrame: CandidateFrameID
    ) {
        self.cycle = cycle
        self.semanticRevision = semanticRevision
        self.candidateFrame = candidateFrame
    }
}

package enum FrameOfferDisposition: UInt8, Equatable, Sendable {
    case accepted = 0
    case backpressured = 1
    case retryableRefusal = 2
    case nonRetryableRefusal = 3
    case failed = 4
}

package enum LogicalFrameDisposition: UInt8, Equatable, Sendable {
    case notProduced = 0
    case committed = 1
    case aborted = 2
}

package enum FrameStreamResult: UInt8, Equatable, Sendable {
    case complete = 0
    case producerFailed = 1
    case insufficientCapacity = 2
    case endpointRefused = 3
    case contractViolation = 4
}

package struct FrameOfferResult: Equatable, Sendable {
    package let disposition: FrameOfferDisposition
    package let failure: FrameOfferFailure?

    package init?(
        disposition: FrameOfferDisposition,
        failure: FrameOfferFailure?
    ) {
        guard (disposition == .failed) == (failure != nil) else { return nil }
        self.disposition = disposition
        self.failure = failure
    }
}

package enum FrameOfferFailure: UInt8, Equatable, Sendable {
    case invalidEnvelope = 0
    case insufficientCapacity = 1
    case producerFailed = 2
    case contractViolation = 3
}

package enum FrameRefusalOrigin: UInt8, Equatable, Sendable {
    case renderProducer = 0
    case endpoint = 1
}

package protocol SynchronousFrameEndpoint {
    associatedtype Sink: RenderOperationSink

    mutating func offer(
        provenance: FrameProvenance,
        body: (inout Sink) -> FrameStreamResult
    ) -> FrameOfferResult
}
