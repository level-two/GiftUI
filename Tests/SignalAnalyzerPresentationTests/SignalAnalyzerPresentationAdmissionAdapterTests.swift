import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer Presentation admission adapter")
struct SignalAnalyzerPresentationAdmissionAdapterTests {
    @Test("start admits both immediate current values and is idempotent")
    func successfulStart() {
        let repository = AdapterRepository()
        let admission = AdapterAdmission(outcomes: [.accepted(sequence: 4), .accepted(sequence: 5)])
        let adapter = makeAdapter(repository: repository, admission: admission)

        #expect(adapter.startObserving() == .started(captureSequence: 4, stateSequence: 5))
        #expect(adapter.startObserving() == .alreadyStarted)
        #expect(repository.captureStarts == 1)
        #expect(repository.stateStarts == 1)
        #expect(admission.facts.count == 2)
    }

    @Test("partial start rejection detaches both and preserves original rejection")
    func rejectedStart() {
        let repository = AdapterRepository()
        let admission = AdapterAdmission(outcomes: [
            .accepted(sequence: 1),
            .rejected(.factCapacityExhausted),
            .accepted(sequence: 2),
        ])
        let adapter = makeAdapter(repository: repository, admission: admission)

        #expect(adapter.startObserving() == .rejected(.factCapacityExhausted))
        #expect(repository.captureStops == 1)
        #expect(repository.stateStops == 1)
        #expect(admission.facts.count == 3)
        guard case .operationalFailure = admission.facts.last else {
            Issue.record("expected reserved operational failure")
            return
        }
    }

    @Test("callbacks translate once and active rejection reports once")
    func callbackMapping() {
        let repository = AdapterRepository()
        let admission = AdapterAdmission(outcomes: [
            .rejected(.runtimeUnavailable),
            .accepted(sequence: 2),
        ])
        let adapter = makeAdapter(repository: repository, admission: admission)
        let outcome = adapter.receive(.idle)

        #expect(outcome == .rejected(.runtimeUnavailable))
        #expect(admission.facts.count == 2)
        #expect(admission.facts.first == .acquisitionState(.idle))
        guard case .operationalFailure = admission.facts.last else {
            Issue.record("expected one rejection report")
            return
        }
    }

    @Test("stop detaches both exactly once")
    func stop() {
        let repository = AdapterRepository()
        let admission = AdapterAdmission(outcomes: [.accepted(sequence: 1), .accepted(sequence: 2)])
        let adapter = makeAdapter(repository: repository, admission: admission)
        _ = adapter.startObserving()

        adapter.stopObserving()
        adapter.stopObserving()

        #expect(repository.captureStops == 1)
        #expect(repository.stateStops == 1)
    }

    @Test("terminal revision failure admits exactly one reserved fact and invokes no policy")
    func terminalRevisionFailure() {
        let repository = AdapterRepository()
        let admission = AdapterAdmission(outcomes: [
            .accepted(sequence: 1), .accepted(sequence: 2), .accepted(sequence: 9),
        ])
        let factory = AdapterFailureFactory()
        let adapter = SignalAnalyzerPresentationAdmissionAdapter(
            observeCapture: ObserveSignalCaptureUseCase(repository: repository),
            observeState: ObserveAcquisitionStateUseCase(repository: repository),
            admission: admission,
            failureFactory: factory
        )
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array("capture revision exhausted".utf8))!
        #expect(adapter.startObserving() == .started(captureSequence: 1, stateSequence: 2))

        let outcome = adapter.receive(
            .terminalFailure(condition: .captureRevisionExhausted, diagnostic: diagnostic)
        )

        #expect(outcome == .accepted(sequence: 9))
        #expect(admission.facts.count == 3)
        guard case .operationalFailure(let failure) = admission.facts[2] else {
            Issue.record("expected exactly one reserved terminal fact")
            return
        }
        #expect(failure.diagnostic == diagnostic)
        #expect(factory.repositoryCompletionCount == 1)
        #expect(factory.policyCallCount == 0)
        #expect(repository.captureStops == 1)
        #expect(repository.stateStops == 1)
    }

    private func makeAdapter(
        repository: AdapterRepository,
        admission: AdapterAdmission
    ) -> SignalAnalyzerPresentationAdmissionAdapter {
        SignalAnalyzerPresentationAdmissionAdapter(
            observeCapture: ObserveSignalCaptureUseCase(repository: repository),
            observeState: ObserveAcquisitionStateUseCase(repository: repository),
            admission: admission,
            failureFactory: AdapterFailureFactory()
        )
    }
}

private final class AdapterRepository: SignalAcquisitionRepository {
    var captureStarts = 0
    var stateStarts = 0
    var captureStops = 0
    var stateStops = 0

    func startObservingCapture(sink: some SignalCaptureSink) {
        captureStarts += 1
        _ = sink.receive(.snapshot(revision: 0, capture: .empty()))
    }
    func stopObservingCapture() { captureStops += 1 }
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        stateStarts += 1
        _ = sink.receive(.idle)
    }
    func stopObservingAcquisitionState() { stateStops += 1 }
    func start() throws {}
    func stop() {}
    func clear() {}
}

private final class AdapterAdmission: SignalAnalyzerFactAdmission {
    var outcomes: [SignalSinkDeliveryOutcome]
    var facts: [SignalAnalyzerPresentationFact] = []

    init(outcomes: [SignalSinkDeliveryOutcome]) { self.outcomes = outcomes }

    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome {
        facts.append(fact)
        return outcomes.removeFirst()
    }
}

private final class AdapterFailureFactory: SignalAnalyzerOperationalFailureFactory {
    var repositoryCompletionCount = 0
    var policyCallCount = 0

    func failure(
        for rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure {
        _ = rejection
        _ = context
        return failure(diagnostic: "admission rejected")
    }

    func completeAdmissionFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        _ = failure
        _ = rejection
        _ = context
        _ = reservedOutcome
        policyCallCount += 1
    }

    func completeRepositoryFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        condition: SignalAnalyzerRepositoryCondition,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        _ = failure
        _ = condition
        _ = reservedOutcome
        repositoryCompletionCount += 1
    }

    func failure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        _ = condition
        return failure(diagnostic: diagnostic)
    }

    private func failure(diagnostic text: String) -> SignalAnalyzerOperationalFailure {
        failure(diagnostic: SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!)
    }

    private func failure(diagnostic: SignalAnalyzerDiagnostic) -> SignalAnalyzerOperationalFailure {
        SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .nonRetryableRefusal,
                origin: .presentationIntegration,
                affectedScope: .runtime,
                containment: .contained
            ),
            diagnostic: diagnostic
        )
    }
}
