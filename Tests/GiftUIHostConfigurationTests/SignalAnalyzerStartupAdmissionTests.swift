import GiftUIFailureCore
import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Test(
    "real source terminal startup is quiescent before reserved admission",
    arguments: [UInt32.max, UInt32.max - 1])
func realSourceStartupTerminalAdmission(initialRevision: UInt32) {
    let source = DeterministicSignalDataSource()
    let repository = DefaultSignalAcquisitionRepository(
        source: source, initialRevision: initialRevision)
    let model = SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository))
    let admission = StartupFactAdmission(source: source, model: model)
    let failures = StartupFailureFactory()
    let adapter = SignalAnalyzerPresentationAdmissionAdapter(
        observeCapture: ObserveSignalCaptureUseCase(repository: repository),
        observeState: ObserveAcquisitionStateUseCase(repository: repository),
        admission: admission, failureFactory: failures)
    #expect(adapter.startObserving() == .started(captureSequence: 1, stateSequence: 2))
    #expect(throws: SignalAcquisitionUnavailableError.self) { try repository.start() }
    #expect(source.activeGeneration == nil)
    #expect(failures.completions == 1)
    #expect(failures.policyCalls == 0)
    #expect(admission.facts.count == (initialRevision == .max ? 3 : 4))
    #expect(
        admission.facts.filter {
            if case .acquisitionState = $0 { return true }
            return false
        }.count == 1)
    #expect(model.state == SignalAnalyzerViewState())
    let count = admission.facts.count
    repository.clear()
    #expect(throws: SignalAcquisitionUnavailableError.self) { try repository.start() }
    #expect(!source.deliverScheduledTransition(generation: 1))
    #expect(admission.facts.count == count)
}

private final class StartupFactAdmission: SignalAnalyzerFactAdmission {
    let source: DeterministicSignalDataSource
    let model: SignalAnalyzerViewModel
    var facts: [SignalAnalyzerPresentationFact] = []
    init(source: DeterministicSignalDataSource, model: SignalAnalyzerViewModel) {
        self.source = source
        self.model = model
    }
    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome {
        #expect(model.state == SignalAnalyzerViewState())
        if case .operationalFailure = fact {
            #expect(source.activeGeneration == nil)
        }
        facts.append(fact)
        return .accepted(sequence: UInt32(facts.count))
    }
}

private final class StartupFailureFactory: SignalAnalyzerOperationalFailureFactory {
    var completions = 0
    var policyCalls = 0
    func failure(
        for rejection: SignalSinkDeliveryRejection, context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure {
        policyCalls += 1
        return failure(
            for: .captureRevisionExhausted,
            diagnostic: SignalAnalyzerDiagnostic(
                exactUTF8: Array("unexpected admission rejection".utf8))!)
    }
    func failure(
        for condition: SignalAnalyzerRepositoryCondition, diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .nonRetryableRefusal, origin: .presentationIntegration,
                affectedScope: .runtime, containment: .contained), diagnostic: diagnostic)
    }
    func completeRepositoryFailure(
        _ failure: SignalAnalyzerOperationalFailure, condition: SignalAnalyzerRepositoryCondition,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        completions += 1
    }
}
