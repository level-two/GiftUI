import Foundation
import Observation
import SignalAnalyzerDomain

package enum VisibleTimeWindow: Double, Sendable {
    case oneSecond = 1
    case twoSeconds = 2
    case fiveSeconds = 5

    var duration: Duration { .seconds(rawValue) }
}

package struct SignalAnalyzerViewState: Equatable, Sendable {
    package var acquisitionState: AcquisitionState
    package var capture: SignalCapture
    package var visibleWindow: VisibleTimeWindow
    package var errorMessage: String?

    init(
        acquisitionState: AcquisitionState = .idle,
        capture: SignalCapture = .empty(),
        visibleWindow: VisibleTimeWindow = .twoSeconds,
        errorMessage: String? = nil
    ) {
        self.acquisitionState = acquisitionState
        self.capture = capture
        self.visibleWindow = visibleWindow
        self.errorMessage = errorMessage
    }
}

@Observable
@MainActor
package final class SignalAnalyzerViewModel: SignalCaptureSink, AcquisitionStateSink {
    package private(set) var state = SignalAnalyzerViewState()

    private let observeCapture: ObserveSignalCaptureUseCase
    private let observeAcquisitionState: ObserveAcquisitionStateUseCase
    private let startAcquisition: StartSignalAcquisitionUseCase
    private let stopAcquisition: StopSignalAcquisitionUseCase
    private let clearCapture: ClearSignalCaptureUseCase

    @ObservationIgnored private var isObserving = false

    package init(
        observeCapture: ObserveSignalCaptureUseCase,
        observeAcquisitionState: ObserveAcquisitionStateUseCase,
        startAcquisition: StartSignalAcquisitionUseCase,
        stopAcquisition: StopSignalAcquisitionUseCase,
        clearCapture: ClearSignalCaptureUseCase
    ) {
        self.observeCapture = observeCapture
        self.observeAcquisitionState = observeAcquisitionState
        self.startAcquisition = startAcquisition
        self.stopAcquisition = stopAcquisition
        self.clearCapture = clearCapture
    }

    var visibleRange: Range<Duration> {
        let window = state.visibleWindow.duration
        let end = max(window, state.capture.duration)
        return max(.zero, end - window)..<end
    }

    package func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        observeCapture.start(sink: self)
        observeAcquisitionState.start(sink: self)
    }

    package func stopObserving() {
        guard isObserving else { return }
        observeCapture.stop()
        observeAcquisitionState.stop()
        isObserving = false
    }

    package func startTapped() {
        state.errorMessage = nil
        do {
            try startAcquisition.execute()
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }

    package func stopTapped() {
        stopAcquisition.execute()
    }

    package func clearTapped() {
        clearCapture.execute()
    }

    package func visibleDurationChanged(_ window: VisibleTimeWindow) {
        state.visibleWindow = window
    }

    func dismissError() {
        state.errorMessage = nil
    }

    package func receive(_ capture: SignalCapture) {
        state.capture = capture
    }

    package func receive(_ acquisitionState: AcquisitionState) {
        state.acquisitionState = acquisitionState
        if case let .failed(message) = acquisitionState {
            state.errorMessage = message
        }
    }
}
