import SignalAnalyzerDomain
import XCTest

@MainActor
final class SignalAcquisitionUseCaseTests: XCTestCase {
    func testActionUseCasesDelegateToRepository() throws {
        let repository = RepositorySpy()

        try StartSignalAcquisitionUseCase(repository: repository).execute()
        StopSignalAcquisitionUseCase(repository: repository).execute()
        ClearSignalCaptureUseCase(repository: repository).execute()

        XCTAssertEqual(repository.recordedCalls, [.start, .stop, .clear])
    }

    func testObserveUseCasesConnectAndDisconnectSinks() {
        let repository = RepositorySpy()
        let captures = CaptureSinkSpy()
        let states = StateSinkSpy()
        let observeCapture = ObserveSignalCaptureUseCase(repository: repository)
        let observeState = ObserveAcquisitionStateUseCase(repository: repository)

        observeCapture.start(sink: captures)
        observeState.start(sink: states)

        let capture = SignalCapture(
            channels: SignalChannel.standard,
            transitions: [
                SignalTransition(
                    channelID: SignalChannelID(rawValue: 1),
                    timestamp: .milliseconds(100),
                    level: .high
                )
            ],
            duration: .milliseconds(100)
        )
        repository.emit(capture)
        repository.emit(.running)

        XCTAssertEqual(captures.received, capture)
        XCTAssertEqual(states.received, .running)

        observeCapture.stop()
        observeState.stop()
        XCTAssertNil(repository.captureSink)
        XCTAssertNil(repository.stateSink)
    }
}

@MainActor
private final class RepositorySpy: SignalAcquisitionRepository {
    enum Call: Equatable {
        case start
        case stop
        case clear
    }

    private(set) weak var captureSink: (any SignalCaptureSink)?
    private(set) weak var stateSink: (any AcquisitionStateSink)?
    private(set) var recordedCalls: [Call] = []

    func startObservingCapture(sink: some SignalCaptureSink) { captureSink = sink }
    func stopObservingCapture() { captureSink = nil }
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) { stateSink = sink }
    func stopObservingAcquisitionState() { stateSink = nil }
    func start() throws { recordedCalls.append(.start) }
    func stop() { recordedCalls.append(.stop) }
    func clear() { recordedCalls.append(.clear) }
    func emit(_ capture: SignalCapture) { captureSink?.receive(capture) }
    func emit(_ state: AcquisitionState) { stateSink?.receive(state) }
}

@MainActor
private final class CaptureSinkSpy: SignalCaptureSink {
    private(set) var received: SignalCapture?
    func receive(_ capture: SignalCapture) { received = capture }
}

@MainActor
private final class StateSinkSpy: AcquisitionStateSink {
    private(set) var received: AcquisitionState?
    func receive(_ state: AcquisitionState) { received = state }
}
