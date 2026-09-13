import SignalAnalyzerData
import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer repository retention integration")
struct DefaultSignalAcquisitionRepositoryTests {
    @Test(
        "clear preserves each acquisition state and publishes one exact reset",
        arguments: [
            AcquisitionState.idle,
            .running,
            .stopped,
            .failed(SignalAnalyzerDiagnostic(exactUTF8: Array("failed".utf8))!),
        ])
    func clearPreservesState(expectedState: AcquisitionState) throws {
        let source = RepositorySourceSpy()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let sink = RepositoryCaptureSink()
        repository.startObservingCapture(sink: sink)

        switch expectedState {
        case .idle: break
        case .running: try repository.start()
        case .stopped:
            try repository.start()
            repository.stop()
        case .failed:
            source.startFailure = RepositorySourceSpy.Failure.start
            #expect(throws: RepositorySourceSpy.Failure.start) { try repository.start() }
        }
        let stateBeforeClear = repository.acquisitionState
        let countBeforeClear = sink.publications.count

        repository.clear()

        #expect(repository.acquisitionState == stateBeforeClear)
        #expect(sink.publications.count == countBeforeClear + 1)
        guard case .mutation(_, .reset(_, let baselines)) = sink.publications.last else {
            Issue.record("expected one reset mutation")
            return
        }
        #expect(baselines == .allLow)
    }

    @Test("source transitions publish exact replayable mutations")
    func sourceMutation() throws {
        let source = RepositorySourceSpy()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let sink = RepositoryCaptureSink()
        repository.startObservingCapture(sink: sink)
        try repository.start()

        source.emit(timestamp: 10, level: .high)
        source.emit(timestamp: 5, level: .low)

        var state = SignalCaptureRevisionState.initial
        for publication in sink.publications.dropFirst() {
            guard case .applied(let next) = publication.replay(on: state) else {
                Issue.record("expected replayable mutation")
                return
            }
            state = next
        }
        #expect(state.revision == 2)
        #expect(
            state.capture.transitions.map(\.timestamp) == [.milliseconds(5), .milliseconds(10)])
    }
}

private final class RepositorySourceSpy: SignalDataSource {
    enum Failure: Error { case start }
    var startFailure: Failure?
    private var sink: (any SignalTransitionSink)?

    func start(sink: some SignalTransitionSink) throws {
        if let startFailure { throw startFailure }
        self.sink = sink
    }

    func stop() { sink = nil }

    func emit(timestamp: Int, level: DigitalLevel) {
        sink?.receive(
            SignalTransition(
                channelID: SignalChannelID(rawValue: 1),
                timestamp: .milliseconds(timestamp),
                level: level
            )
        )
    }
}

private final class RepositoryCaptureSink: SignalCaptureSink {
    var publications: [SignalCapturePublication] = []

    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        publications.append(publication)
        return .accepted(sequence: UInt32(publications.count))
    }
}
