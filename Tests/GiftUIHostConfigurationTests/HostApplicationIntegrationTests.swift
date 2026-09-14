import GiftUIFailureCore
import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@testable import GiftUIHostConfiguration

private enum ApplicationExecutorMode: Equatable {
    case sameThread
    case distinctExecutor
}

private final class RecordingApplicationExecutor {
    private var gate = HostApplicationOpportunityGate()
    private var pending: (() -> Void)?
    private(set) var events: [String] = []

    func submit(
        mode: ApplicationExecutorMode,
        _ operation: @escaping () -> Void
    ) -> HostApplicationOpportunityAdmission {
        let admission = gate.begin()
        guard admission == .admitted else { return admission }
        events.append("application-begin")
        switch mode {
        case .sameThread:
            operation()
            finish()
        case .distinctExecutor:
            pending = operation
        }
        return admission
    }

    func drain() {
        guard let pending else { return }
        self.pending = nil
        pending()
        finish()
    }

    private func finish() {
        events.append("application-end")
        #expect(gate.complete() == nil)
    }
}

private final class IntegratedFactAdmission: SignalAnalyzerFactAdmission {
    private var storage = HostSequencedFactAdmission<
        SignalAnalyzerPresentationFact,
        SignalAnalyzerPresentationFact,
        SignalAnalyzerPresentationFact
    >(
        producerLimits: HostFactProducerLimits(
            transition: 20,
            bootstrap: 2,
            action: 6
        )!
    )!
    private(set) var callbackModelStates: [SignalAnalyzerViewState] = []
    private var bootstrapIsComplete = false
    weak var model: SignalAnalyzerViewModel?

    func completeBootstrap() {
        bootstrapIsComplete = true
    }

    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome {
        if let model { callbackModelStates.append(model.state) }
        let outcome: HostFactAdmissionOutcome
        switch fact {
        case .captureSnapshot:
            outcome = storage.admitSnapshot(fact, category: .bootstrap)
        case .acquisitionState:
            outcome = storage.admitCompact(
                fact,
                category: bootstrapIsComplete ? .action : .bootstrap
            )
        case .captureMutation:
            outcome = storage.admitCompact(fact, category: .transition)
        case .operationalFailure:
            outcome = storage.admitReservedFailure(fact)
        }
        return map(outcome)
    }

    func applySealed(
        to model: SignalAnalyzerViewModel,
        expectedChanged: Bool
    ) -> [SignalAnalyzerPresentationFact] {
        guard storage.seal() else { return [] }
        var applied: [SignalAnalyzerPresentationFact] = []
        while let sealed = storage.takeNextSealed() {
            let fact: SignalAnalyzerPresentationFact
            switch sealed {
            case .snapshot(let value), .compact(let value), .reservedFailure(let value):
                fact = value.value
            }
            applied.append(fact)
            #expect(model.apply(fact) == .applied(changed: expectedChanged))
        }
        return applied
    }

    private func map(_ outcome: HostFactAdmissionOutcome) -> SignalSinkDeliveryOutcome {
        switch outcome {
        case .accepted(let sequence): .accepted(sequence: sequence)
        case .rejected(.snapshotCapacityExhausted): .rejected(.snapshotCapacityExhausted)
        case .rejected(.sequenceExhausted): .rejected(.sequenceExhausted)
        case .rejected(.unavailable): .rejected(.runtimeUnavailable)
        case .rejected:
            .rejected(.factCapacityExhausted)
        }
    }
}

private struct IntegratedFailureFactory: SignalAnalyzerOperationalFailureFactory {
    func failure(
        for rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure {
        _ = rejection
        _ = context
        return failure(diagnostic: "admission rejected")
    }

    func failure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        _ = condition
        return SignalAnalyzerOperationalFailure(
            failure: failure(diagnostic: "repository failed").failure,
            diagnostic: diagnostic
        )
    }

    private func failure(diagnostic: String) -> SignalAnalyzerOperationalFailure {
        SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .presentationIntegration,
                affectedScope: .component,
                containment: .contained
            ),
            diagnostic: SignalAnalyzerDiagnostic(exactUTF8: Array(diagnostic.utf8))!
        )
    }
}

private struct ApplicationIntegrationReport: Equatable {
    let observation: SignalAnalyzerObservationStartOutcome
    let executorEvents: [String]
    let bootstrapFacts: [SignalAnalyzerPresentationFact]
    let laterFacts: [SignalAnalyzerPresentationFact]
    let callbackModelStates: [SignalAnalyzerViewState]
    let modelStateBeforeLaterApplication: SignalAnalyzerViewState
    let finalModelState: SignalAnalyzerViewState
}

@Test func sameThreadAndDistinctApplicationExecutorsProduceEquivalentAdmission() {
    let sameThread = runApplicationIntegration(mode: .sameThread)
    let distinct = runApplicationIntegration(mode: .distinctExecutor)

    #expect(sameThread == distinct)
    #expect(
        sameThread.observation
            == .started(captureSequence: 1, stateSequence: 2)
    )
    #expect(
        sameThread.executorEvents
            == Array(repeating: ["application-begin", "application-end"], count: 3)
            .flatMap(\.self)
    )
    #expect(sameThread.bootstrapFacts.count == 2)
    #expect(sameThread.laterFacts.count == 6)
    #expect(
        sameThread.callbackModelStates
            == Array(repeating: SignalAnalyzerViewState(), count: 8)
    )
    #expect(sameThread.modelStateBeforeLaterApplication == SignalAnalyzerViewState())
    #expect(sameThread.finalModelState.acquisitionState == .running)
    #expect(sameThread.finalModelState.capture.transitions.count == 5)
}

private func runApplicationIntegration(
    mode: ApplicationExecutorMode
) -> ApplicationIntegrationReport {
    let source = DeterministicSignalDataSource()
    let repository = DefaultSignalAcquisitionRepository(source: source)
    let admission = IntegratedFactAdmission()
    let adapter = SignalAnalyzerPresentationAdmissionAdapter(
        observeCapture: ObserveSignalCaptureUseCase(repository: repository),
        observeState: ObserveAcquisitionStateUseCase(repository: repository),
        admission: admission,
        failureFactory: IntegratedFailureFactory()
    )
    let model = SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
    admission.model = model
    let executor = RecordingApplicationExecutor()
    var observation: SignalAnalyzerObservationStartOutcome?

    #expect(
        executor.submit(mode: mode) {
            observation = adapter.startObserving()
        } == .admitted
    )
    if mode == .distinctExecutor {
        #expect(observation == nil)
        #expect(admission.callbackModelStates.isEmpty)
        executor.drain()
    }

    let bootstrapFacts = admission.applySealed(to: model, expectedChanged: false)
    admission.completeBootstrap()

    #expect(
        executor.submit(mode: mode) {
            model.startTapped()
        } == .admitted
    )
    if mode == .distinctExecutor { executor.drain() }

    #expect(source.activeGeneration == 1)
    var deliveredTransition = false
    #expect(
        executor.submit(mode: mode) {
            deliveredTransition = source.deliverScheduledTransition(generation: 1)
        } == .admitted
    )
    if mode == .distinctExecutor { #expect(!deliveredTransition) }
    if mode == .distinctExecutor { executor.drain() }
    #expect(deliveredTransition)

    let stateBeforeLaterApplication = model.state
    let laterFacts = admission.applySealed(to: model, expectedChanged: true)
    return ApplicationIntegrationReport(
        observation: observation!,
        executorEvents: executor.events,
        bootstrapFacts: bootstrapFacts,
        laterFacts: laterFacts,
        callbackModelStates: admission.callbackModelStates,
        modelStateBeforeLaterApplication: stateBeforeLaterApplication,
        finalModelState: model.state
    )
}
