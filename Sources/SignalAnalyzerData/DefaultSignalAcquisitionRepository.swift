import SignalAnalyzerDomain

package protocol SignalDataSourceDiagnosticError: SignalAnalyzerDiagnosticError {}

package struct SignalAcquisitionStartError: SignalAnalyzerDiagnosticError, Equatable, Sendable {
    package let signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic
}

package struct SignalAcquisitionUnavailableError: SignalAnalyzerDiagnosticError, Equatable, Sendable
{
    package let signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic
}

package final class DefaultSignalAcquisitionRepository: SignalAcquisitionRepository,
    SignalTransitionSink
{
    package private(set) var acquisitionState: AcquisitionState = .idle
    package private(set) var outOfHorizonDropCount: UInt32 = 0
    package private(set) var lastCaptureDeliveryOutcome: SignalSinkDeliveryOutcome?
    package private(set) var lastStateDeliveryOutcome: SignalSinkDeliveryOutcome?
    package var captureRevision: UInt32 { store.revision }
    package var currentCapture: SignalCapture { store.capture }

    private let source: any SignalDataSource
    private var store = SignalCaptureStore()
    private weak var captureSink: AnyObject?
    private weak var stateSink: AnyObject?
    private var isTerminal = false
    private var isSourceActive = false
    private var terminalDiagnostic: SignalAnalyzerDiagnostic?

    package init(source: any SignalDataSource, initialRevision: UInt32 = 0) {
        self.source = source
        store = SignalCaptureStore(initialRevision: initialRevision)
    }

    package func startObservingCapture(sink: some SignalCaptureSink) {
        captureSink = sink as AnyObject
        lastCaptureDeliveryOutcome = sink.receive(
            .snapshot(revision: store.revision, capture: store.capture)
        )
    }

    package func stopObservingCapture() {
        captureSink = nil
    }

    package func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        stateSink = sink as AnyObject
        lastStateDeliveryOutcome = sink.receive(acquisitionState)
    }

    package func stopObservingAcquisitionState() {
        stateSink = nil
    }

    package func start() throws {
        if isTerminal {
            throw SignalAcquisitionUnavailableError(signalAnalyzerDiagnostic: terminalDiagnostic!)
        }
        guard acquisitionState != .running else { return }
        do {
            try source.start(sink: self)
            isSourceActive = true
            acquisitionState = .running
            publishState()
        } catch let failure as any SignalDataSourceDiagnosticError {
            source.stop()
            isSourceActive = false
            let diagnostic = failure.signalAnalyzerDiagnostic
            acquisitionState = .failed(diagnostic)
            publishState()
            throw failure
        } catch {
            source.stop()
            isSourceActive = false
            let diagnostic = SignalAnalyzerDiagnostic(
                exactUTF8: Array("source start failed".utf8)
            )!
            acquisitionState = .failed(diagnostic)
            publishState()
            throw SignalAcquisitionStartError(signalAnalyzerDiagnostic: diagnostic)
        }
    }

    package func stop() {
        guard !isTerminal, acquisitionState == .running else { return }
        source.stop()
        isSourceActive = false
        acquisitionState = .stopped
        publishState()
    }

    package func clear() {
        guard !isTerminal else { return }
        handle(store.clear())
    }

    package func receive(_ transition: SignalTransition) {
        guard !isTerminal else { return }
        switch store.receive(transition) {
        case .accepted(let publication):
            publishCapture(publication)
        case .rejected(.outsideRetainedHistory):
            if outOfHorizonDropCount < .max {
                outOfHorizonDropCount += 1
            }
        case .rejected(.invalidTransition):
            failSourceContract()
        case .rejected(.revisionExhausted):
            failRevision()
        }
    }

    private func handle(_ result: SignalCaptureStoreResult) {
        switch result {
        case .accepted(let publication): publishCapture(publication)
        case .rejected(.revisionExhausted): failRevision()
        case .rejected: break
        }
    }

    private func publishCapture(_ publication: SignalCapturePublication) {
        guard let sink = captureSink as? any SignalCaptureSink else { return }
        lastCaptureDeliveryOutcome = sink.receive(publication)
    }

    private func publishState() {
        guard let sink = stateSink as? any AcquisitionStateSink else { return }
        lastStateDeliveryOutcome = sink.receive(acquisitionState)
    }

    private func failSourceContract() {
        source.stop()
        isSourceActive = false
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array("invalid source transition".utf8))!
        acquisitionState = .failed(diagnostic)
        publishState()
    }

    private func failRevision() {
        if isSourceActive {
            source.stop()
            isSourceActive = false
        }
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array("capture revision exhausted".utf8))!
        acquisitionState = .failed(diagnostic)
        isTerminal = true
        terminalDiagnostic = diagnostic
        publishCapture(
            .terminalFailure(condition: .captureRevisionExhausted, diagnostic: diagnostic)
        )
    }
}
