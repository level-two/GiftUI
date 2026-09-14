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
    weak var model: SignalAnalyzerViewModel?

    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome {
        if let model { callbackModelStates.append(model.state) }
        let outcome: HostFactAdmissionOutcome
        switch fact {
        case .captureSnapshot:
            outcome = storage.admitSnapshot(fact, category: .bootstrap)
        case .acquisitionState:
            outcome = storage.admitCompact(fact, category: .bootstrap)
        case .captureMutation:
            outcome = storage.admitCompact(fact, category: .transition)
        case .operationalFailure:
            outcome = storage.admitReservedFailure(fact)
        }
        return map(outcome)
    }

    func applySealed(to model: SignalAnalyzerViewModel) -> [SignalAnalyzerPresentationFact] {
        guard storage.seal() else { return [] }
        var applied: [SignalAnalyzerPresentationFact] = []
        while let sealed = storage.takeNextSealed() {
            let fact: SignalAnalyzerPresentationFact
            switch sealed {
            case .snapshot(let value), .compact(let value), .reservedFailure(let value):
                fact = value.value
            }
            applied.append(fact)
            #expect(model.apply(fact) == .applied(changed: false))
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
    let admittedFacts: [SignalAnalyzerPresentationFact]
    let callbackModelStates: [SignalAnalyzerViewState]
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
    #expect(sameThread.executorEvents == ["application-begin", "application-end"])
    #expect(
        sameThread.callbackModelStates == [SignalAnalyzerViewState(), SignalAnalyzerViewState()])
    #expect(sameThread.finalModelState == SignalAnalyzerViewState())
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

    let admitted = admission.applySealed(to: model)
    return ApplicationIntegrationReport(
        observation: observation!,
        executorEvents: executor.events,
        admittedFacts: admitted,
        callbackModelStates: admission.callbackModelStates,
        finalModelState: model.state
    )
}
