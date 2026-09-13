import SignalAnalyzerData
import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer deterministic data source")
struct DeterministicSignalDataSourceTests {
    @Test("first start emits four lows and repeated start is idempotent")
    func initialStart() throws {
        let source = DeterministicSignalDataSource(seed: 1_234)
        let sink = SourceTransitionSink()

        try source.start(sink: sink)
        let generation = source.activeGeneration
        try source.start(sink: sink)

        #expect(generation == 1)
        #expect(source.activeGeneration == generation)
        #expect(sink.transitions.map(\.channelID.rawValue) == [1, 2, 3, 4])
        #expect(sink.transitions.allSatisfy { $0.timestamp == .zero && $0.level == .low })
    }

    @Test("host-driven delivery uses accelerated delay and resumes conceptual state")
    func pauseResume() throws {
        let scale = SignalSourceTimingScale(numerator: 1, denominator: 10)!
        let source = DeterministicSignalDataSource(seed: 1_234, timingScale: scale)
        let sink = SourceTransitionSink()
        try source.start(sink: sink)
        let firstGeneration = source.activeGeneration!
        #expect(source.nextScheduledDelay == .milliseconds(8))
        #expect(source.deliverScheduledTransition(generation: firstGeneration))
        #expect(sink.transitions.last?.timestamp == .milliseconds(80))

        source.stop()
        #expect(!source.deliverScheduledTransition(generation: firstGeneration))
        try source.start(sink: sink)
        #expect(source.activeGeneration == 2)
        #expect(source.nextScheduledDelay == .milliseconds(8))
        #expect(source.deliverScheduledTransition(generation: 2))
        #expect(sink.transitions.last?.timestamp == .milliseconds(160))
        #expect(sink.transitions.filter { $0.timestamp == .zero }.count == 4)
    }

    @Test("generation exhaustion and teardown reject later work")
    func terminalLifecycle() throws {
        let sink = SourceTransitionSink()
        let exhausted = DeterministicSignalDataSource(initialGeneration: .max)
        #expect(throws: SignalSourceGenerationError.self) { try exhausted.start(sink: sink) }

        let shutdown = DeterministicSignalDataSource()
        try shutdown.start(sink: sink)
        let generation = shutdown.activeGeneration!
        shutdown.shutdown()
        #expect(!shutdown.deliverScheduledTransition(generation: generation))
        #expect(throws: SignalSourceGenerationError.self) { try shutdown.start(sink: sink) }
    }

    @Test("a second conforming source substitutes without repository changes")
    func sourceSubstitution() throws {
        let source = FixtureSignalSource()
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let sink = SourceCaptureSink()
        repository.startObservingCapture(sink: sink)

        try repository.start()

        #expect(sink.publications.count == 2)
        #expect(repository.captureRevision == 1)
        #expect(repository.currentCapture.transitions.first?.channelID.rawValue == 4)
    }
}

private final class SourceTransitionSink: SignalTransitionSink {
    var transitions: [SignalTransition] = []
    func receive(_ transition: SignalTransition) { transitions.append(transition) }
}

private final class FixtureSignalSource: SignalDataSource {
    private var active = false
    func start(sink: some SignalTransitionSink) throws {
        guard !active else { return }
        active = true
        sink.receive(
            SignalTransition(
                channelID: SignalChannelID(rawValue: 4),
                timestamp: .milliseconds(12),
                level: .high
            )
        )
    }
    func stop() { active = false }
}

private final class SourceCaptureSink: SignalCaptureSink {
    var publications: [SignalCapturePublication] = []
    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        publications.append(publication)
        return .accepted(sequence: UInt32(publications.count))
    }
}
