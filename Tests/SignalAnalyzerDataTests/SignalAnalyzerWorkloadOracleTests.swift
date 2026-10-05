import SignalAnalyzerData
import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer 30-second workload oracle")
struct SignalAnalyzerWorkloadOracleTests {
    @Test("2400 delivered events preserve replay and five-second inclusive history")
    func completeWorkload() throws {
        let source = WorkloadSource()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let captures = WorkloadCaptureSink()
        let states = WorkloadStateSink()
        repository.startObservingCapture(sink: captures)
        repository.startObservingAcquisitionState(sink: states)

        try repository.start()

        #expect(source.emittedCount == 2_404)
        #expect(repository.captureRevision == 2_404)
        #expect(repository.currentCapture.transitions.count == 404)
        #expect(captures.publications.count == 2_405)
        #expect(captures.outcomes == Array(UInt32(1) ... UInt32(2_405)))
        #expect(states.states == [.idle, .running])
        #expect(states.outcomes == [1, 2])
        #expect(repository.outOfHorizonDropCount == 0)

        var replay = SignalCaptureRevisionState.initial
        var mutationCount = 0
        for publication in captures.publications.dropFirst() {
            guard case .applied(let next) = publication.replay(on: replay) else {
                Issue.record("publication \(mutationCount + 1) did not replay")
                return
            }
            replay = next
            mutationCount += 1
        }
        #expect(mutationCount == 2_404)
        #expect(replay.revision == repository.captureRevision)
        #expect(replay.capture == repository.currentCapture)

        let transitions = repository.currentCapture.transitions
        #expect(repository.currentCapture.retainedLowerBound == .seconds(25))
        #expect(transitions.prefix(4).map(\.timestamp) == Array(repeating: .seconds(25), count: 4))
        #expect(transitions.prefix(4).map(\.channelID.rawValue) == [1, 2, 3, 4])
        #expect(transitions.last?.timestamp == .seconds(30))
        for (index, value) in transitions.enumerated() {
            #expect(value.timestamp == .milliseconds((500 + index / 4) * 50))
            #expect(value.channelID.rawValue == index % 4 + 1)
        }

    }
}

private final class WorkloadSource: SignalDataSource {
    private(set) var emittedCount = 0
    private var active = false

    func start(sink: some SignalTransitionSink) throws {
        guard !active else { return }
        active = true
        for channel in 1 ... 4 {
            sink.receive(
                SignalTransition(
                    channelID: SignalChannelID(rawValue: channel),
                    timestamp: .zero,
                    level: .low
                )
            )
            emittedCount += 1
        }
        for cycle in 1 ... 600 {
            for channel in 1 ... 4 {
                sink.receive(
                    SignalTransition(
                        channelID: SignalChannelID(rawValue: channel),
                        timestamp: .milliseconds(cycle * 50),
                        level: cycle.isMultiple(of: 2) ? .low : .high
                    )
                )
                emittedCount += 1
            }
        }
    }

    func stop() { active = false }
}

private final class WorkloadCaptureSink: SignalCaptureSink {
    private(set) var publications: [SignalCapturePublication] = []
    private(set) var outcomes: [UInt32] = []

    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        publications.append(publication)
        let sequence = UInt32(publications.count)
        outcomes.append(sequence)
        return .accepted(sequence: sequence)
    }
}

private final class WorkloadStateSink: AcquisitionStateSink {
    private(set) var states: [AcquisitionState] = []
    private(set) var outcomes: [UInt32] = []

    func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome {
        states.append(state)
        let sequence = UInt32(states.count)
        outcomes.append(sequence)
        return .accepted(sequence: sequence)
    }
}
