import GiftUIRenderCore

struct RecordingAcceptedFrame: Equatable, Sendable {
    let provenance: FrameProvenance
    let operationCount: UInt16
    let positionedGlyphCount: UInt16
}

struct RecordingFrameSink: RenderOperationSink, Sendable {
    private enum State: UInt8, Equatable, Sendable {
        case poisoned = 0
        case idle = 1
        case recording = 2
        case positionedGlyphs = 3
        case finished = 4
    }

    let capacity: RenderSinkCapacity
    private(set) var reservationWasMade = false
    private(set) var retainedProducerError: RenderProductionError?
    private var state: State = .poisoned
    private var expectedOperations: UInt16 = 0
    private var expectedGlyphs: UInt16 = 0
    private var observedOperations: UInt16 = 0
    private var observedGlyphs: UInt16 = 0
    private var remainingGroupGlyphs: UInt16 = 0
    private var vocabularyViolated = false

    init(capacity: RenderSinkCapacity) {
        self.capacity = capacity
    }

    var acceptedCounts: (operations: UInt16, glyphs: UInt16)? {
        guard state == .finished, !vocabularyViolated else { return nil }
        return (observedOperations, observedGlyphs)
    }

    mutating func beginOfferBorrow(reservationWasMade: Bool) {
        self.reservationWasMade = reservationWasMade
        retainedProducerError = nil
        state = .idle
        expectedOperations = 0
        expectedGlyphs = 0
        observedOperations = 0
        observedGlyphs = 0
        remainingGroupGlyphs = 0
        vocabularyViolated = false
    }

    mutating func recordProducerError(_ error: RenderProductionError) {
        if retainedProducerError == nil {
            retainedProducerError = error
        }
    }

    mutating func poisonAfterReturn() {
        reservationWasMade = false
        state = .poisoned
        expectedOperations = 0
        expectedGlyphs = 0
        observedOperations = 0
        observedGlyphs = 0
        remainingGroupGlyphs = 0
        vocabularyViolated = false
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        guard state == .idle,
            header.operationCount <= capacity.maximumOperations,
            header.positionedGlyphCount <= capacity.maximumPositionedGlyphs
        else { return rejectVocabulary() }
        expectedOperations = header.operationCount
        expectedGlyphs = header.positionedGlyphCount
        state = .recording
        return true
    }

    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        _ = operation
        guard state == .recording, incrementOperation() else {
            return rejectVocabulary()
        }
        return true
    }

    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        guard state == .recording,
            incrementOperation(),
            operation.glyphCount <= expectedGlyphs - observedGlyphs
        else { return rejectVocabulary() }
        remainingGroupGlyphs = operation.glyphCount
        state = .positionedGlyphs
        return true
    }

    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        _ = glyph
        guard state == .positionedGlyphs, remainingGroupGlyphs > 0 else {
            return rejectVocabulary()
        }
        remainingGroupGlyphs -= 1
        observedGlyphs += 1
        return true
    }

    mutating func endPositionedGlyphs() -> Bool {
        guard state == .positionedGlyphs, remainingGroupGlyphs == 0 else {
            return rejectVocabulary()
        }
        state = .recording
        return true
    }

    mutating func finish() -> Bool {
        guard state == .recording,
            observedOperations == expectedOperations,
            observedGlyphs == expectedGlyphs
        else { return rejectVocabulary() }
        state = .finished
        return true
    }

    mutating func discard() {
        guard state != .poisoned else { return }
        state = .idle
        expectedOperations = 0
        expectedGlyphs = 0
        observedOperations = 0
        observedGlyphs = 0
        remainingGroupGlyphs = 0
        vocabularyViolated = false
    }

    private mutating func incrementOperation() -> Bool {
        let (count, overflow) = observedOperations.addingReportingOverflow(1)
        guard !overflow, count <= expectedOperations else { return false }
        observedOperations = count
        return true
    }

    private mutating func rejectVocabulary() -> Bool {
        vocabularyViolated = true
        return false
    }
}

struct RecordingSynchronousFrameEndpoint: SynchronousFrameEndpoint, Sendable {
    private let maximumDownstreamSlots: UInt16
    private(set) var occupiedDownstreamSlots: UInt16 = 0
    private(set) var bodyCallCount: UInt16 = 0
    private(set) var reservationOutstanding = false
    private(set) var retainedProducerError: RenderProductionError?
    private(set) var acceptedFrame: RecordingAcceptedFrame?
    private(set) var sink: RecordingFrameSink
    var acceptsEnvelope = true

    init?(
        maximumDownstreamSlots: UInt16,
        sinkCapacity: RenderSinkCapacity
    ) {
        guard maximumDownstreamSlots > 0 else { return nil }
        self.maximumDownstreamSlots = maximumDownstreamSlots
        sink = RecordingFrameSink(capacity: sinkCapacity)
    }

    mutating func probeSinkAfterReturn(
        _ header: RenderPlanHeader
    ) -> Bool {
        sink.begin(header)
    }

    mutating func offer(
        provenance: FrameProvenance,
        body: (inout RecordingFrameSink) -> FrameStreamResult
    ) -> FrameOfferResult {
        guard acceptsEnvelope else {
            return FrameOfferResult(
                disposition: .failed,
                failure: .invalidEnvelope
            )!
        }
        guard occupiedDownstreamSlots < maximumDownstreamSlots else {
            return FrameOfferResult(
                disposition: .backpressured,
                failure: nil
            )!
        }

        reservationOutstanding = true
        sink.beginOfferBorrow(reservationWasMade: true)
        if bodyCallCount < UInt16.max { bodyCallCount += 1 }
        let streamResult = body(&sink)
        retainedProducerError = sink.retainedProducerError
        let acceptedCounts = sink.acceptedCounts
        sink.poisonAfterReturn()
        reservationOutstanding = false

        switch streamResult {
        case .complete:
            guard let acceptedCounts else {
                return failed(.contractViolation)
            }
            occupiedDownstreamSlots += 1
            acceptedFrame = RecordingAcceptedFrame(
                provenance: provenance,
                operationCount: acceptedCounts.operations,
                positionedGlyphCount: acceptedCounts.glyphs
            )
            return FrameOfferResult(disposition: .accepted, failure: nil)!
        case .producerFailed:
            guard retainedProducerError != nil else {
                return failed(.contractViolation)
            }
            return failed(.producerFailed)
        case .insufficientCapacity:
            guard retainedProducerError == .capacityExhausted else {
                return failed(.contractViolation)
            }
            return failed(.insufficientCapacity)
        case .endpointRefused:
            guard retainedProducerError == .sinkRefused else {
                return failed(.contractViolation)
            }
            return FrameOfferResult(
                disposition: .nonRetryableRefusal,
                failure: nil
            )!
        case .contractViolation:
            return failed(.contractViolation)
        }
    }

    private func failed(_ failure: FrameOfferFailure) -> FrameOfferResult {
        FrameOfferResult(disposition: .failed, failure: failure)!
    }
}
