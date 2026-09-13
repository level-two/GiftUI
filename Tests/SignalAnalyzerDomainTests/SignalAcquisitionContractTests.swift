import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer synchronous Domain contracts")
struct SignalAcquisitionContractTests {
    @Test("capture observation delegates attach and detach exactly once")
    func captureObservation() {
        let repository = RepositorySpy()
        let sink = CaptureSinkSpy()
        let useCase = ObserveSignalCaptureUseCase(repository: repository)

        useCase.start(sink: sink)
        useCase.stop()

        #expect(repository.captureAttachCount == 1)
        #expect(repository.captureDetachCount == 1)
        #expect(sink.publications == [.snapshot(revision: 0, capture: .empty())])
        #expect(repository.captureOutcome == .accepted(sequence: 11))
    }

    @Test("state observation delegates attach and detach exactly once")
    func stateObservation() {
        let repository = RepositorySpy()
        let sink = StateSinkSpy()
        let useCase = ObserveAcquisitionStateUseCase(repository: repository)

        useCase.start(sink: sink)
        useCase.stop()

        #expect(repository.stateAttachCount == 1)
        #expect(repository.stateDetachCount == 1)
        #expect(sink.states == [.idle])
        #expect(repository.stateOutcome == .accepted(sequence: 12))
    }

    @Test("action use cases synchronously delegate once")
    func acquisitionActions() throws {
        let repository = RepositorySpy()

        try StartSignalAcquisitionUseCase(repository: repository).execute()
        StopSignalAcquisitionUseCase(repository: repository).execute()
        ClearSignalCaptureUseCase(repository: repository).execute()

        #expect(repository.startCount == 1)
        #expect(repository.stopCount == 1)
        #expect(repository.clearCount == 1)
    }

    @Test("start preserves the repository failure")
    func startFailure() {
        let repository = RepositorySpy()
        repository.startError = .unavailable

        #expect(throws: RepositorySpy.Failure.unavailable) {
            try StartSignalAcquisitionUseCase(repository: repository).execute()
        }
        #expect(repository.startCount == 1)
    }

    @Test("source boundary installs its transition sink synchronously")
    func sourceBoundary() throws {
        let source = SourceSpy()
        let sink = TransitionSinkSpy()

        try source.start(sink: sink)
        source.stop()

        #expect(source.startCount == 1)
        #expect(source.stopCount == 1)
        #expect(sink.transitions.count == 1)
        #expect(sink.transitions.first?.timestamp == .microseconds(1))
    }
}

private final class RepositorySpy: SignalAcquisitionRepository {
    enum Failure: Error {
        case unavailable
    }

    var captureAttachCount = 0
    var captureDetachCount = 0
    var stateAttachCount = 0
    var stateDetachCount = 0
    var startCount = 0
    var stopCount = 0
    var clearCount = 0
    var startError: Failure?
    var captureOutcome: SignalSinkDeliveryOutcome?
    var stateOutcome: SignalSinkDeliveryOutcome?

    func startObservingCapture(sink: some SignalCaptureSink) {
        captureAttachCount += 1
        captureOutcome = sink.receive(.snapshot(revision: 0, capture: .empty()))
    }

    func stopObservingCapture() {
        captureDetachCount += 1
    }

    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        stateAttachCount += 1
        stateOutcome = sink.receive(.idle)
    }

    func stopObservingAcquisitionState() {
        stateDetachCount += 1
    }

    func start() throws {
        startCount += 1
        if let startError {
            throw startError
        }
    }

    func stop() {
        stopCount += 1
    }

    func clear() {
        clearCount += 1
    }
}

private final class CaptureSinkSpy: SignalCaptureSink {
    var publications: [SignalCapturePublication] = []

    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        publications.append(publication)
        return .accepted(sequence: 11)
    }
}

private final class StateSinkSpy: AcquisitionStateSink {
    var states: [AcquisitionState] = []

    func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome {
        states.append(state)
        return .accepted(sequence: 12)
    }
}

private final class TransitionSinkSpy: SignalTransitionSink {
    var transitions: [SignalTransition] = []

    func receive(_ transition: SignalTransition) {
        transitions.append(transition)
    }
}

private final class SourceSpy: SignalDataSource {
    var startCount = 0
    var stopCount = 0

    func start(sink: some SignalTransitionSink) throws {
        startCount += 1
        sink.receive(
            SignalTransition(
                channelID: SignalChannelID(rawValue: 1),
                timestamp: .microseconds(1),
                level: .high
            )
        )
    }

    func stop() {
        stopCount += 1
    }
}
