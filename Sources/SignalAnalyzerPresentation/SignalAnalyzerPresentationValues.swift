import GiftUI
import GiftUIFailureCore
import SignalAnalyzerDomain

package enum VisibleTimeWindow: Equatable, Sendable {
    case oneSecond
    case twoSeconds
    case fiveSeconds

    package var duration: Duration {
        switch self {
        case .oneSecond: .seconds(1)
        case .twoSeconds: .seconds(2)
        case .fiveSeconds: .seconds(5)
        }
    }
}

package struct SignalAnalyzerViewState: Equatable, Sendable {
    package var acquisitionState: AcquisitionState
    package var capture: SignalCapture
    package var visibleWindow: VisibleTimeWindow
    package var errorMessage: SignalAnalyzerDiagnostic?

    package init(
        acquisitionState: AcquisitionState = .idle,
        capture: SignalCapture = .empty(),
        visibleWindow: VisibleTimeWindow = .twoSeconds,
        errorMessage: SignalAnalyzerDiagnostic? = nil
    ) {
        self.acquisitionState = acquisitionState
        self.capture = capture
        self.visibleWindow = visibleWindow
        self.errorMessage = errorMessage
    }
}

package enum SignalAnalyzerAction: UInt16, GiftUIAction {
    case start = 0
    case stop = 1
    case clear = 2
    case selectOneSecond = 3
    case selectTwoSeconds = 4
    case selectFiveSeconds = 5
}

package enum SignalAnalyzerPresentationFact: Equatable, Sendable {
    case captureSnapshot(revision: UInt32, capture: SignalCapture)
    case captureMutation(revision: UInt32, change: SignalCaptureChange)
    case acquisitionState(AcquisitionState)
    case operationalFailure(SignalAnalyzerOperationalFailure)
}

package struct SignalAnalyzerOperationalFailure: Equatable, Sendable {
    package let failure: GiftUIFailureFact
    package let diagnostic: SignalAnalyzerDiagnostic

    package init(failure: GiftUIFailureFact, diagnostic: SignalAnalyzerDiagnostic) {
        self.failure = failure
        self.diagnostic = diagnostic
    }
}

package enum SignalAnalyzerObservationStartOutcome: Equatable, Sendable {
    case started(captureSequence: UInt32, stateSequence: UInt32)
    case alreadyStarted
    case rejected(SignalSinkDeliveryRejection)
}

package enum SignalAnalyzerResidualPolicyContext: UInt8, Equatable, Sendable {
    case observationStart
    case activeDelivery
    case initialModelAttachment
    case modelReplacement
    case modelChangeReport
    case captureFactApplication
}

package enum SignalAnalyzerRuntimeCondition: UInt8, Equatable, Sendable {
    case stateLocationCapacityExhausted
    case registrationCapacityExhausted
    case replacementStagingExhausted
    case duplicateModelOwner
    case incompatibleStateAssociation
    case staleRegistrationReport
    case mutationPhaseViolation
    case observableStateReentrancyViolation
    case observableStateInvariantViolation
    case captureRevisionMismatch
    case reservedFailureCapacityExhausted
    case identityGenerationExhausted
}

package protocol SignalAnalyzerFactAdmission {
    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome
}

package enum SignalAnalyzerFactApplicationOutcome: Equatable, Sendable {
    case applied(changed: Bool)
    case rejected(SignalAnalyzerRuntimeCondition)
}

package final class SignalAnalyzerViewModel: _GiftUIObservableReference {
    package private(set) var state = SignalAnalyzerViewState()
    package private(set) var captureRevision: UInt32 = 0

    private let startAcquisition: StartSignalAcquisitionUseCase
    private let stopAcquisition: StopSignalAcquisitionUseCase
    private let clearCapture: ClearSignalCaptureUseCase
    private var changeSink: _GiftUIObservableChangeSink?

    package init(
        startAcquisition: StartSignalAcquisitionUseCase,
        stopAcquisition: StopSignalAcquisitionUseCase,
        clearCapture: ClearSignalCaptureUseCase
    ) {
        self.startAcquisition = startAcquisition
        self.stopAcquisition = stopAcquisition
        self.clearCapture = clearCapture
    }

    package var visibleRange: Range<Duration> {
        let window = state.visibleWindow.duration
        let end = max(window, state.capture.duration)
        return max(.zero, end - window) ..< end
    }

    package func startTapped() {
        let clearedError = state.errorMessage != nil
        state.errorMessage = nil
        reportChange(if: clearedError)
        do {
            try startAcquisition.execute()
        } catch let failure as any SignalAnalyzerDiagnosticError {
            let changed = state.errorMessage != failure.signalAnalyzerDiagnostic
            state.errorMessage = failure.signalAnalyzerDiagnostic
            reportChange(if: changed)
        } catch {
            let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: Array("start failed".utf8))!
            let changed = state.errorMessage != diagnostic
            state.errorMessage = diagnostic
            reportChange(if: changed)
        }
    }

    package func stopTapped() {
        stopAcquisition.execute()
    }

    package func clearTapped() {
        clearCapture.execute()
    }

    package func visibleDurationChanged(_ window: VisibleTimeWindow) {
        let changed = state.visibleWindow != window
        state.visibleWindow = window
        reportChange(if: changed)
    }

    package func apply(
        _ fact: SignalAnalyzerPresentationFact
    ) -> SignalAnalyzerFactApplicationOutcome {
        let previousState = state

        switch fact {
        case .captureSnapshot(let revision, let capture):
            let publication = SignalCapturePublication.snapshot(
                revision: revision,
                capture: capture
            )
            guard
                case .applied(let next) = publication.replay(
                    on: SignalCaptureRevisionState(
                        revision: captureRevision,
                        capture: state.capture
                    )
                )
            else {
                return .rejected(.captureRevisionMismatch)
            }
            captureRevision = next.revision
            state.capture = next.capture

        case .captureMutation(let revision, let change):
            let publication = SignalCapturePublication.mutation(
                revision: revision,
                change: change
            )
            guard
                case .applied(let next) = publication.replay(
                    on: SignalCaptureRevisionState(
                        revision: captureRevision,
                        capture: state.capture
                    )
                )
            else {
                return .rejected(.captureRevisionMismatch)
            }
            captureRevision = next.revision
            state.capture = next.capture

        case .acquisitionState(let acquisitionState):
            state.acquisitionState = acquisitionState
            if case .failed(let diagnostic) = acquisitionState {
                state.errorMessage = diagnostic
            }

        case .operationalFailure(let failure):
            state.acquisitionState = .failed(failure.diagnostic)
            state.errorMessage = failure.diagnostic
        }

        let changed = state != previousState
        reportChange(if: changed)
        return .applied(changed: changed)
    }

    package func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        let attachment = sink.attachment
        changeSink = consume sink
        return attachment
    }

    package func _giftUIDetachChangeSink(_ attachment: _GiftUIObservationAttachment) {
        guard changeSink?.attachment == attachment else { return }
        changeSink = nil
    }

    private func reportChange(if changed: Bool) {
        guard changed, changeSink != nil else { return }
        _ = changeSink!.reportChange()
    }
}

package struct SignalAnalyzerActionHandler: GiftUIActionHandler {
    package init() {}

    package mutating func handle(
        _ action: SignalAnalyzerAction,
        model: borrowing SignalAnalyzerViewModel
    ) {
        switch action {
        case .start: model.startTapped()
        case .stop: model.stopTapped()
        case .clear: model.clearTapped()
        case .selectOneSecond: model.visibleDurationChanged(.oneSecond)
        case .selectTwoSeconds: model.visibleDurationChanged(.twoSeconds)
        case .selectFiveSeconds: model.visibleDurationChanged(.fiveSeconds)
        }
    }
}
