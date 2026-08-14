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

        let uniqueEvents = Set(events.map {
            "\($0.channelID.rawValue)-\($0.timestamp.components.seconds)-\($0.timestamp.components.attoseconds)"
        })
        XCTAssertEqual(uniqueEvents.count, events.count, "Repeated start must not create duplicate generators")
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
