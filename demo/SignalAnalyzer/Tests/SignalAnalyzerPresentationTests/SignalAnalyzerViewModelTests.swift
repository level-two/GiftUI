import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import XCTest

@MainActor
final class SignalAnalyzerViewModelTests: XCTestCase {
    func testObservationUpdatesCaptureAndAcquisitionState() async throws {
        let repository = PresentationRepositorySpy()
        let viewModel = makeViewModel(repository: repository)
        viewModel.startObserving()

        let capture = SignalCapture(
            channels: SignalChannel.standard,
            transitions: [
                SignalTransition(
                    channelID: SignalChannelID(rawValue: 3),
                    timestamp: .milliseconds(250),
                    level: .high
                )
            ],
            duration: .milliseconds(250)
        )
        repository.emit(capture)
        repository.emit(.running)
        try await waitUntil {
            viewModel.state.capture == capture && viewModel.state.acquisitionState == .running
        }

        XCTAssertEqual(viewModel.state.capture, capture)
        XCTAssertEqual(viewModel.state.acquisitionState, .running)
        viewModel.stopObserving()
        XCTAssertNil(repository.captureSink)
        XCTAssertNil(repository.stateSink)
    }

    func testActionsReachUseCasesAndWindowSelectionChanges() {
        let repository = PresentationRepositorySpy()
        let viewModel = makeViewModel(repository: repository)

        viewModel.startTapped()
        viewModel.stopTapped()
        viewModel.clearTapped()

        XCTAssertEqual(repository.calls, [.start, .stop, .clear])
        viewModel.visibleDurationChanged(.fiveSeconds)
        XCTAssertEqual(viewModel.state.visibleWindow, .fiveSeconds)
    }

    private func makeViewModel(repository: PresentationRepositorySpy) -> SignalAnalyzerViewModel {
        SignalAnalyzerViewModel(
            observeCapture: ObserveSignalCaptureUseCase(repository: repository),
            observeAcquisitionState: ObserveAcquisitionStateUseCase(repository: repository),
            startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
            clearCapture: ClearSignalCaptureUseCase(repository: repository)
        )
    }

    private func waitUntil(
        timeout: Duration = .seconds(1),
        condition: @escaping @MainActor () -> Bool
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
private final class PresentationRepositorySpy: SignalAcquisitionRepository {
    enum Call: Equatable {
        case start
        case stop
        case clear
    }

    private(set) weak var captureSink: (any SignalCaptureSink)?
    private(set) weak var stateSink: (any AcquisitionStateSink)?
    private(set) var calls: [Call] = []

    func startObservingCapture(sink: some SignalCaptureSink) { captureSink = sink }
    func stopObservingCapture() { captureSink = nil }
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) { stateSink = sink }
    func stopObservingAcquisitionState() { stateSink = nil }
    func start() throws { calls.append(.start) }
    func stop() { calls.append(.stop) }
    func clear() { calls.append(.clear) }
    func emit(_ capture: SignalCapture) { captureSink?.receive(capture) }
    func emit(_ state: AcquisitionState) { stateSink?.receive(state) }
}
