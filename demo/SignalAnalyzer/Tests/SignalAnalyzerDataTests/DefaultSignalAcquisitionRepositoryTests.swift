import SignalAnalyzerData
import SignalAnalyzerDomain
import XCTest

@MainActor
final class DefaultSignalAcquisitionRepositoryTests: XCTestCase {
    func testAccumulatesOrdersClearsAndTrimsTransitions() throws {
        let source = ControlledSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(
            dataSource: source,
            maximumCaptureDuration: .seconds(1)
        )
        let captures = CaptureRecorder()
        repository.startObservingCapture(sink: captures)
        try repository.start()

        source.emit(transition(channel: 2, at: 0.7, level: .high))
        XCTAssertEqual(captures.latest?.transitions.count, 1)
        XCTAssertEqual(captures.latest?.duration, .milliseconds(700))

        source.emit(transition(channel: 1, at: 0.4, level: .high))
        XCTAssertEqual(captures.latest?.transitions.map(\.timestamp), [.milliseconds(400), .milliseconds(700)])

        source.emit(transition(channel: 1, at: 2.0, level: .low))
        XCTAssertEqual(captures.latest?.transitions.map(\.timestamp), [.seconds(2)])
        XCTAssertEqual(captures.latest?.duration, .seconds(2))

        repository.clear()
        XCTAssertEqual(captures.latest, .empty())
    }

    func testStateStartStopAndRestartAreForwardedWithoutDuplicateStarts() throws {
        let source = ControlledSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(dataSource: source)
        let states = StateRecorder()
        repository.startObservingAcquisitionState(sink: states)

        XCTAssertEqual(states.latest, .idle)
        try repository.start()
        XCTAssertEqual(states.latest, .running)
        try repository.start()
        XCTAssertEqual(source.startCount, 1)

        repository.stop()
        XCTAssertEqual(states.latest, .stopped)
        try repository.start()
        XCTAssertEqual(states.latest, .running)
        XCTAssertEqual(source.startCount, 2)
    }

    private func transition(
        channel: Int,
        at seconds: Double,
        level: DigitalLevel
    ) -> SignalTransition {
        SignalTransition(
            channelID: SignalChannelID(rawValue: channel),
            timestamp: .seconds(seconds),
            level: level
        )
    }
}

@MainActor
private final class ControlledSignalDataSource: SignalDataSource {
    private var sink: (any SignalTransitionSink)?
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private var isRunning = false

    func start(sink: some SignalTransitionSink) throws {
        guard !isRunning else { return }
        self.sink = sink
        isRunning = true
        startCount += 1
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        stopCount += 1
    }

    func emit(_ transition: SignalTransition) {
        guard isRunning else { return }
        sink?.receive(transition)
    }
}

@MainActor
private final class CaptureRecorder: SignalCaptureSink {
    private(set) var latest: SignalCapture?

    func receive(_ capture: SignalCapture) {
        latest = capture
    }
}

@MainActor
private final class StateRecorder: AcquisitionStateSink {
    private(set) var latest: AcquisitionState?

    func receive(_ state: AcquisitionState) {
        latest = state
    }
}
