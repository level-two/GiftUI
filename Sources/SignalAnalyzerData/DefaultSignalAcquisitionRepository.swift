import SignalAnalyzerDomain

package protocol SignalDataSourceDiagnosticError: Error {
    var signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic { get }
}

package final class DefaultSignalAcquisitionRepository: SignalAcquisitionRepository,
    SignalTransitionSink
{
    package private(set) var acquisitionState: AcquisitionState = .idle
    package private(set) var outOfHorizonDropCount: UInt32 = 0

    private let source: any SignalDataSource
    private var store = SignalCaptureStore()
    private weak var captureSink: AnyObject?
    private weak var stateSink: AnyObject?
    private var isTerminal = false

    package init(source: any SignalDataSource) {
        self.source = source
    }

    package func startObservingCapture(sink: some SignalCaptureSink) {
        _ = sink.receive(.snapshot(revision: store.revision, capture: store.capture))
        captureSink = sink as AnyObject
    }

    package func stopObservingCapture() {
        captureSink = nil
    }

    package func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        _ = sink.receive(acquisitionState)
        stateSink = sink as AnyObject
    }

    package func stopObservingAcquisitionState() {
        stateSink = nil
    }

    package func start() throws {
        guard !isTerminal, acquisitionState != .running else { return }
        do {
            try source.start(sink: self)
            acquisitionState = .running
            publishState()
        } catch {
            source.stop()
            let diagnostic =
                (error as? any SignalDataSourceDiagnosticError)?.signalAnalyzerDiagnostic
                ?? SignalAnalyzerDiagnostic(exactUTF8: Array("source start failed".utf8))!
            acquisitionState = .failed(diagnostic)
            publishState()
            throw error
        }
    }

    package func stop() {
        guard !isTerminal, acquisitionState == .running else { return }
        source.stop()
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
            outOfHorizonDropCount &+= 1
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
        _ = sink.receive(publication)
    }

    private func publishState() {
        guard let sink = stateSink as? any AcquisitionStateSink else { return }
        _ = sink.receive(acquisitionState)
    }

    private func failSourceContract() {
        source.stop()
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array("invalid source transition".utf8))!
        acquisitionState = .failed(diagnostic)
        publishState()
    }

    private func failRevision() {
        source.stop()
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array("capture revision exhausted".utf8))!
        acquisitionState = .failed(diagnostic)
        isTerminal = true
        publishCapture(
            .terminalFailure(condition: .captureRevisionExhausted, diagnostic: diagnostic)
        )
    }
}
