import GiftUI
import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer Presentation integration")
struct SignalAnalyzerPresentationIntegrationTests {
    @Test("start clears old error before execution and defers the published failure fact")
    func startFailureOrdering() {
        let events = IntegrationEvents()
        let diagnostic = integrationDiagnostic("source unavailable")
        let repository = FailingIntegrationRepository(diagnostic: diagnostic, events: events)
        let admission = IntegrationAdmission()
        let adapter = makeIntegrationAdapter(repository: repository, admission: admission)
        let model = makeIntegrationModel(repository: repository)

        #expect(adapter.startObserving() == .started(captureSequence: 1, stateSequence: 2))
        admission.facts.removeAll()
        _ = model.apply(.acquisitionState(.failed(integrationDiagnostic("old error"))))
        let attachment = _GiftUIObservationAttachment(slot: 0, generation: 0)
        _ = model._giftUIAttachChangeSink(
            _GiftUIObservableChangeSink(
                attachment: attachment,
                reportRoute: { _ in
                    events.values.append("model-change")
                    return .dirtied
                }
            )
        )
        admission.onSubmit = { fact in
            guard case .acquisitionState(.failed(let admitted)) = fact else { return }
            #expect(admitted == diagnostic)
            #expect(model.state.errorMessage == nil)
            events.values.append("admission-failed")
        }

        model.startTapped()

        #expect(
            events.values == [
                "model-change",
                "executor-start",
                "admission-failed",
                "model-change",
            ])
        #expect(model.state.errorMessage == diagnostic)
        #expect(model.state.acquisitionState == .failed(integrationDiagnostic("old error")))
        #expect(admission.facts == [.acquisitionState(.failed(diagnostic))])

        #expect(model.apply(admission.facts[0]) == .applied(changed: true))
        #expect(model.state.acquisitionState == .failed(diagnostic))
        #expect(model.state.errorMessage == diagnostic)
    }
}

private final class IntegrationEvents {
    var values: [String] = []
}

private struct IntegrationStartFailure: SignalAnalyzerDiagnosticError {
    let signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic
}

private final class FailingIntegrationRepository: SignalAcquisitionRepository {
    private let diagnostic: SignalAnalyzerDiagnostic
    private let events: IntegrationEvents
    private weak var captureSink: AnyObject?
    private weak var stateSink: AnyObject?

    init(diagnostic: SignalAnalyzerDiagnostic, events: IntegrationEvents) {
        self.diagnostic = diagnostic
        self.events = events
    }

    func startObservingCapture(sink: some SignalCaptureSink) {
        captureSink = sink as AnyObject
        _ = sink.receive(.snapshot(revision: 0, capture: .empty()))
    }

    func stopObservingCapture() { captureSink = nil }

    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        stateSink = sink as AnyObject
        _ = sink.receive(.idle)
    }

    func stopObservingAcquisitionState() { stateSink = nil }

    func start() throws {
        events.values.append("executor-start")
        if let sink = stateSink as? any AcquisitionStateSink {
            _ = sink.receive(.failed(diagnostic))
        }
        throw IntegrationStartFailure(signalAnalyzerDiagnostic: diagnostic)
    }

    func stop() {}
    func clear() {
        if let sink = captureSink as? any SignalCaptureSink {
            _ = sink.receive(
                .mutation(revision: 1, change: .reset(baseRevision: 0, baselines: .allLow)))
        }
    }
}

private final class IntegrationAdmission: SignalAnalyzerFactAdmission {
    var facts: [SignalAnalyzerPresentationFact] = []
    var onSubmit: ((SignalAnalyzerPresentationFact) -> Void)?
    private var nextSequence: UInt32 = 1

    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome {
        facts.append(fact)
        onSubmit?(fact)
        defer { nextSequence += 1 }
        return .accepted(sequence: nextSequence)
    }
}

private struct IntegrationFailureFactory: SignalAnalyzerOperationalFailureFactory {
    func failure(
        for rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure {
        _ = rejection
        _ = context
        return makeFailure(integrationDiagnostic("admission rejected"))
    }

    func failure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        _ = condition
        return makeFailure(diagnostic)
    }

    private func makeFailure(
        _ diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .nonRetryableRefusal,
                origin: .presentationIntegration,
                affectedScope: .component,
                containment: .contained
            ),
            diagnostic: diagnostic
        )
    }
}

private func makeIntegrationAdapter(
    repository: any SignalAcquisitionRepository,
    admission: IntegrationAdmission
) -> SignalAnalyzerPresentationAdmissionAdapter {
    SignalAnalyzerPresentationAdmissionAdapter(
        observeCapture: ObserveSignalCaptureUseCase(repository: repository),
        observeState: ObserveAcquisitionStateUseCase(repository: repository),
        admission: admission,
        failureFactory: IntegrationFailureFactory()
    )
}

private func makeIntegrationModel(
    repository: any SignalAcquisitionRepository
) -> SignalAnalyzerViewModel {
    SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private func integrationDiagnostic(_ text: String) -> SignalAnalyzerDiagnostic {
    SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!
}
