import SignalAnalyzerData
import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer repository lifecycle and failures")
struct SignalAcquisitionRepositoryLifecycleTests {
    @Test("sink replacement and detachment are immediate and refusal does not roll back")
    func captureSinkLifecycle() throws {
        let source = LifecycleSource()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let first = LifecycleCaptureSink(outcome: .rejected(.factCapacityExhausted))
        repository.startObservingCapture(sink: first)
        try repository.start()
        source.emit(1)
        #expect(repository.captureRevision == 1)
        #expect(repository.lastCaptureDeliveryOutcome == .rejected(.factCapacityExhausted))

        let second = LifecycleCaptureSink(outcome: .accepted(sequence: 9))
        repository.startObservingCapture(sink: second)
        #expect(second.publications == [.snapshot(revision: 1, capture: repository.currentCapture)])
        source.emit(2)
        #expect(first.publications.count == 2)
        #expect(second.publications.count == 2)
        repository.stopObservingCapture()
        source.emit(3)
        #expect(second.publications.count == 2)
        #expect(repository.captureRevision == 3)
    }

    @Test("observation does not retain the dynamic sink")
    func weakSinkLifetime() {
        let source = LifecycleSource()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        var sink: LifecycleCaptureSink? = LifecycleCaptureSink(outcome: .accepted(sequence: 1))
        weak let weakSink = sink
        repository.startObservingCapture(sink: sink!)
        sink = nil
        #expect(weakSink == nil)
    }

    @Test("state sink replacement, detachment, and action idempotence are exact")
    func stateSinkLifecycle() throws {
        let source = LifecycleSource()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let first = LifecycleStateSink()
        repository.startObservingAcquisitionState(sink: first)
        try repository.start()
        try repository.start()
        #expect(source.startCount == 1)

        let second = LifecycleStateSink()
        repository.startObservingAcquisitionState(sink: second)
        #expect(second.states == [.running])
        repository.stop()
        repository.stop()
        #expect(source.stopCount == 1)
        #expect(first.states == [.idle, .running])
        #expect(second.states == [.running, .stopped])

        repository.stopObservingAcquisitionState()
        try repository.start()
        #expect(second.states == [.running, .stopped])
    }

    @Test("startup failure stops partial activation and carries published diagnostic")
    func startupFailure() {
        let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: Array("startup failed".utf8))!
        let source = LifecycleSource()
        source.failure = LifecycleSource.Failure(signalAnalyzerDiagnostic: diagnostic)
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let sink = LifecycleStateSink()
        repository.startObservingAcquisitionState(sink: sink)

        #expect(throws: LifecycleSource.Failure.self) { try repository.start() }
        #expect(source.stopCount == 1)
        #expect(repository.acquisitionState == .failed(diagnostic))
        #expect(sink.states.last == .failed(diagnostic))
    }

    @Test("invalid and out-of-horizon input follow distinct failure paths")
    func sourceFailures() throws {
        let source = LifecycleSource()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let states = LifecycleStateSink()
        repository.startObservingAcquisitionState(sink: states)
        try repository.start()
        source.emit(31_000)
        source.emit(0)
        #expect(repository.outOfHorizonDropCount == 1)
        #expect(repository.acquisitionState == .running)

        source.emit(-1)
        guard case .failed(let diagnostic) = repository.acquisitionState else {
            Issue.record("expected failed state")
            return
        }
        #expect(diagnostic.utf8ByteCount > 0)
        #expect(source.stopCount == 1)
    }

    @Test("revision exhaustion publishes once and permanently quiesces the graph")
    func revisionExhaustion() throws {
        let source = LifecycleSource()
        let repository = DefaultSignalAcquisitionRepository(source: source, initialRevision: .max)
        let captures = LifecycleCaptureSink(outcome: .accepted(sequence: 1))
        let states = LifecycleStateSink()
        repository.startObservingCapture(sink: captures)
        repository.startObservingAcquisitionState(sink: states)
        try repository.start()
        let stateCount = states.states.count
        source.emit(1)

        guard
            case .terminalFailure(.captureRevisionExhausted, let diagnostic) = captures.publications
                .last
        else {
            Issue.record("expected terminal revision failure")
            return
        }
        #expect(diagnostic.utf8ByteCount > 0)
        #expect(states.states.count == stateCount)
        #expect(source.stopCount == 1)
        let publicationCount = captures.publications.count
        repository.clear()
        #expect(throws: SignalAcquisitionUnavailableError.self) { try repository.start() }
        source.emit(2)
        #expect(captures.publications.count == publicationCount)
    }

    @Test("clear at maximum revision uses the same terminal procedure")
    func clearRevisionExhaustion() {
        let source = LifecycleSource()
        let repository = DefaultSignalAcquisitionRepository(source: source, initialRevision: .max)
        let captures = LifecycleCaptureSink(outcome: .accepted(sequence: 1))
        repository.startObservingCapture(sink: captures)

        repository.clear()
        #expect(repository.captureRevision == .max)
        #expect(source.stopCount == 0)
        guard case .terminalFailure(.captureRevisionExhausted, _) = captures.publications.last
        else {
            Issue.record("expected terminal failure from Clear")
            return
        }
    }
}

private final class LifecycleSource: SignalDataSource {
    struct Failure: SignalDataSourceDiagnosticError {
        let signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic
    }
    var failure: Failure?
    var startCount = 0
    var stopCount = 0
    private var sink: (any SignalTransitionSink)?

    func start(sink: some SignalTransitionSink) throws {
        startCount += 1
        self.sink = sink
        if let failure { throw failure }
    }

    func stop() {
        stopCount += 1
        sink = nil
    }

    func emit(_ milliseconds: Int) {
        sink?.receive(
            SignalTransition(
                channelID: SignalChannelID(rawValue: 1),
                timestamp: .milliseconds(milliseconds),
                level: .high
            )
        )
    }
}

private final class LifecycleCaptureSink: SignalCaptureSink {
    let outcome: SignalSinkDeliveryOutcome
    var publications: [SignalCapturePublication] = []

    init(outcome: SignalSinkDeliveryOutcome) { self.outcome = outcome }

    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        publications.append(publication)
        return outcome
    }
}

private final class LifecycleStateSink: AcquisitionStateSink {
    var states: [AcquisitionState] = []

    func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome {
        states.append(state)
        return .accepted(sequence: UInt32(states.count))
    }
}
