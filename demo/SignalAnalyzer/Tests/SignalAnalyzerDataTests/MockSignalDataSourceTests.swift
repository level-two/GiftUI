import SignalAnalyzerData
import SignalAnalyzerDomain
import XCTest

@MainActor
final class MockSignalDataSourceTests: XCTestCase {
    func testEmitsDeterministicMultiChannelEventsInTimestampOrder() async throws {
        let source = MockSignalDataSource(configuration: .accelerated)
        let recorder = TransitionRecorder()

        try source.start(sink: recorder)
        try source.start(sink: recorder)
        try await waitUntil { recorder.count >= 20 }
        source.stop()

        let events = Array(recorder.transitions.prefix(20))
        XCTAssertEqual(events.count, 20)
        XCTAssertEqual(Set(events.map(\.channelID)), Set(SignalChannel.standard.map(\.id)))
        XCTAssertEqual(events.map(\.timestamp), events.map(\.timestamp).sorted())

        let uniqueEvents = Set(
            events.map {
                "\($0.channelID.rawValue)-\($0.timestamp.components.seconds)-\($0.timestamp.components.attoseconds)"
            })
        XCTAssertEqual(
            uniqueEvents.count, events.count, "Repeated start must not create duplicate generators")
    }

    func testStopPreventsAdditionalEventsAndRestartResumes() async throws {
        let source = MockSignalDataSource(configuration: .accelerated)
        let recorder = TransitionRecorder()

        try source.start(sink: recorder)
        try await Task.sleep(for: .milliseconds(20))
        source.stop()
        try await Task.sleep(for: .milliseconds(10))
        let stoppedCount = recorder.count
        try await Task.sleep(for: .milliseconds(25))
        XCTAssertEqual(recorder.count, stoppedCount)

        try source.start(sink: recorder)
        try await Task.sleep(for: .milliseconds(20))
        source.stop()
        XCTAssertGreaterThan(recorder.count, stoppedCount)
    }

    func testEmitsExactBurstAndSeededRandomPatterns() async throws {
        let source = MockSignalDataSource(configuration: .accelerated)
        let recorder = TransitionRecorder()

        try source.start(sink: recorder)
        try await waitUntil {
            recorder.transitions.filter { $0.channelID.rawValue == 3 }.count >= 5
                && recorder.transitions.filter { $0.channelID.rawValue == 4 }.count >= 4
        }
        source.stop()

        XCTAssertEqual(
            Array(timestamps(for: 3, in: recorder.transitions).prefix(5)),
            [
                .zero, .milliseconds(80), .milliseconds(160), .milliseconds(240),
                .milliseconds(1_440),
            ]
        )
        XCTAssertEqual(
            Array(timestamps(for: 4, in: recorder.transitions).prefix(4)),
            expectedRandomTimestamps(seed: 1_234, count: 4)
        )
    }

    func testRunningRepositoryAndSourceDeallocateWithoutExplicitStop() async throws {
        weak var weakRepository: DefaultSignalAcquisitionRepository?

        do {
            let source = MockSignalDataSource(configuration: .accelerated)
            let repository = DefaultSignalAcquisitionRepository(dataSource: source)
            try repository.start()
            weakRepository = repository
        }

        try await waitUntil { weakRepository == nil }
        XCTAssertNil(weakRepository)
    }

    private func timestamps(
        for channel: Int,
        in transitions: [SignalTransition]
    ) -> [Duration] {
        transitions
            .filter { $0.channelID.rawValue == channel }
            .map(\.timestamp)
    }

    private func expectedRandomTimestamps(seed: UInt64, count: Int) -> [Duration] {
        var state = seed
        var timestamp = Duration.zero
        var result = [timestamp]
        for _ in 1 ..< count {
            state = state &* 6_364_136_223_846_793_005 &+ 1
            timestamp += .milliseconds(180 + Int(state % 420))
            result.append(timestamp)
        }
        return result
    }

    private func waitUntil(
        timeout: Duration = .seconds(1),
        condition: @escaping () -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while !condition() {
            if clock.now >= deadline {
                XCTFail("Condition was not met before timeout")
                return
            }
            try await Task.sleep(for: .milliseconds(5))
        }
    }
}

@MainActor
private final class TransitionRecorder: SignalTransitionSink {
    private var recordedTransitions: [SignalTransition] = []

    var transitions: [SignalTransition] { recordedTransitions }

    var count: Int { recordedTransitions.count }

    func receive(_ transition: SignalTransition) {
        recordedTransitions.append(transition)
    }
}
