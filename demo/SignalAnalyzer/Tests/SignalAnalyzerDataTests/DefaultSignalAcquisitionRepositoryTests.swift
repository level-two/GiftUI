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
        XCTAssertEqual(captures.latest?.retainedLowerBound, .seconds(1))
        XCTAssertEqual(captures.latest?.baselineLevel(for: SignalChannelID(rawValue: 1)), .high)
        XCTAssertEqual(captures.latest?.baselineLevel(for: SignalChannelID(rawValue: 2)), .high)

        repository.clear()
        XCTAssertEqual(captures.latest?.transitions, [])
        XCTAssertEqual(captures.latest?.duration, .zero)
        XCTAssertEqual(captures.latest?.retainedLowerBound, .zero)
        XCTAssertEqual(captures.latest?.baselineLevel(for: SignalChannelID(rawValue: 1)), .low)
        XCTAssertEqual(captures.latest?.baselineLevel(for: SignalChannelID(rawValue: 2)), .high)

        source.emit(transition(channel: 1, at: 2.25, level: .high))
        XCTAssertEqual(captures.latest?.transitions.map(\.timestamp), [.milliseconds(250)])
        XCTAssertEqual(captures.latest?.duration, .milliseconds(250))
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

    func testStableOrderingPreservesArrivalOrderForEqualTimestamps() throws {
        let source = ControlledSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(dataSource: source)
        let captures = CaptureRecorder()
        repository.startObservingCapture(sink: captures)
        try repository.start()

        source.emit(transition(channel: 1, at: 1, level: .high))
        source.emit(transition(channel: 1, at: 2, level: .high))
        source.emit(transition(channel: 1, at: 1, level: .low))

        XCTAssertEqual(
            captures.latest?.transitions.map(\.timestamp),
            [.seconds(1), .seconds(1), .seconds(2)]
        )
        XCTAssertEqual(
            captures.latest?.transitions.map(\.level),
            [.high, .low, .high]
        )
    }

    func testInvalidChannelStopsSourceAndPublishesFailure() throws {
        let source = ControlledSignalDataSource()
        var diagnostics: [String] = []
        let repository = DefaultSignalAcquisitionRepository(
            dataSource: source,
            diagnosticHandler: { diagnostics.append($0) }
        )
        let captures = CaptureRecorder()
        let states = StateRecorder()
        repository.startObservingCapture(sink: captures)
        repository.startObservingAcquisitionState(sink: states)
        try repository.start()
        let captureCount = captures.values.count

        source.emit(transition(channel: 5, at: 1, level: .high))

        XCTAssertEqual(source.stopCount, 1)
        XCTAssertEqual(captures.values.count, captureCount)
        guard case let .failed(message) = states.latest else {
            return XCTFail("Expected a failed acquisition state")
        }
        XCTAssertFalse(message.isEmpty)
        XCTAssertEqual(diagnostics, [message])
    }

    func testNegativeTimestampStopsSourceWithoutMutatingCapture() throws {
        let source = ControlledSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(dataSource: source)
        let captures = CaptureRecorder()
        let states = StateRecorder()
        repository.startObservingCapture(sink: captures)
        repository.startObservingAcquisitionState(sink: states)
        try repository.start()
        let captureCount = captures.values.count

        source.emit(transition(channel: 1, at: -0.1, level: .high))

        XCTAssertEqual(source.stopCount, 1)
        XCTAssertEqual(captures.values.count, captureCount)
        guard case .failed = states.latest else {
            return XCTFail("Expected a failed acquisition state")
        }
    }

    func testOutOfHorizonTransitionIsDroppedAndDiagnosed() throws {
        let source = ControlledSignalDataSource()
        var diagnostics: [String] = []
        let repository = DefaultSignalAcquisitionRepository(
            dataSource: source,
            maximumCaptureDuration: .seconds(1),
            diagnosticHandler: { diagnostics.append($0) }
        )
        let captures = CaptureRecorder()
        repository.startObservingCapture(sink: captures)
        try repository.start()
        source.emit(transition(channel: 1, at: 2, level: .high))
        let captureCount = captures.values.count

        source.emit(transition(channel: 1, at: 0.5, level: .low))

        XCTAssertEqual(captures.values.count, captureCount)
        XCTAssertEqual(diagnostics.count, 1)
        XCTAssertEqual(captures.latest?.transitions.map(\.timestamp), [.seconds(2)])
    }

    func testCapacityEvictionPreservesChannelBaseline() throws {
        let source = ControlledSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(
            dataSource: source,
            maximumTransitionCount: 2
        )
        let captures = CaptureRecorder()
        repository.startObservingCapture(sink: captures)
        try repository.start()

        source.emit(transition(channel: 1, at: 1, level: .high))
        source.emit(transition(channel: 2, at: 2, level: .high))
        source.emit(transition(channel: 1, at: 3, level: .low))

        XCTAssertEqual(captures.latest?.transitions.map(\.timestamp), [.seconds(2), .seconds(3)])
        XCTAssertEqual(captures.latest?.retainedLowerBound, .seconds(1))
        XCTAssertEqual(captures.latest?.baselineLevel(for: SignalChannelID(rawValue: 1)), .high)
    }

    func testStaleTransitionAfterStopIsIgnoredAndDiagnosed() throws {
        let source = ControlledSignalDataSource()
        var diagnostics: [String] = []
        let repository = DefaultSignalAcquisitionRepository(
            dataSource: source,
            diagnosticHandler: { diagnostics.append($0) }
        )
        let captures = CaptureRecorder()
        repository.startObservingCapture(sink: captures)
        try repository.start()
        repository.stop()
        let captureCount = captures.values.count

        source.forceEmit(transition(channel: 1, at: 1, level: .high))

        XCTAssertEqual(captures.values.count, captureCount)
        XCTAssertEqual(diagnostics.count, 1)
    }

    func testStartFailureStopsPartiallyStartedSource() {
        let source = PartiallyStartingSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(dataSource: source)
        let states = StateRecorder()
        repository.startObservingAcquisitionState(sink: states)

        XCTAssertThrowsError(try repository.start())
        XCTAssertFalse(source.isRunning)
        XCTAssertEqual(source.stopCount, 1)
        guard case let .failed(message) = states.latest else {
            return XCTFail("Expected a failed acquisition state")
        }
        XCTAssertEqual(message, "Start failed")
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

    func forceEmit(_ transition: SignalTransition) {
        sink?.receive(transition)
    }
}

@MainActor
private final class PartiallyStartingSignalDataSource: SignalDataSource {
    private(set) var isRunning = false
    private(set) var stopCount = 0

    func start(sink: some SignalTransitionSink) throws {
        isRunning = true
        throw StartFailure()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        stopCount += 1
    }
}

private struct StartFailure: LocalizedError {
    var errorDescription: String? { "Start failed" }
}

@MainActor
private final class CaptureRecorder: SignalCaptureSink {
    private(set) var values: [SignalCapture] = []

    var latest: SignalCapture? { values.last }

    func receive(_ capture: SignalCapture) {
        values.append(capture)
    }
}

@MainActor
private final class StateRecorder: AcquisitionStateSink {
    private(set) var values: [AcquisitionState] = []

    var latest: AcquisitionState? { values.last }

    func receive(_ state: AcquisitionState) {
        values.append(state)
    }
}
