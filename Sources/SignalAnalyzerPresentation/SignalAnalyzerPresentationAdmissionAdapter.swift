import SignalAnalyzerDomain

package protocol SignalAnalyzerOperationalFailureFactory {
    func failure(
        for rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure

    func failure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure

    func completeAdmissionFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext,
        reservedOutcome: SignalSinkDeliveryOutcome
    )

    func completeRepositoryFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        condition: SignalAnalyzerRepositoryCondition,
        reservedOutcome: SignalSinkDeliveryOutcome
    )
}

package extension SignalAnalyzerOperationalFailureFactory {
    func completeAdmissionFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {}

    func completeRepositoryFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        condition: SignalAnalyzerRepositoryCondition,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {}
}

package final class SignalAnalyzerPresentationAdmissionAdapter: SignalCaptureSink,
    AcquisitionStateSink
{
    private let observeCapture: ObserveSignalCaptureUseCase
    private let observeState: ObserveAcquisitionStateUseCase
    private let admission: any SignalAnalyzerFactAdmission
    private let failureFactory: any SignalAnalyzerOperationalFailureFactory
    private var isObserving = false
    private var isStarting = false
    private var captureStartOutcome: SignalSinkDeliveryOutcome?
    private var stateStartOutcome: SignalSinkDeliveryOutcome?

    package init(
        observeCapture: ObserveSignalCaptureUseCase,
        observeState: ObserveAcquisitionStateUseCase,
        admission: any SignalAnalyzerFactAdmission,
        failureFactory: any SignalAnalyzerOperationalFailureFactory
    ) {
        self.observeCapture = observeCapture
        self.observeState = observeState
        self.admission = admission
        self.failureFactory = failureFactory
    }

    package func startObserving() -> SignalAnalyzerObservationStartOutcome {
        guard !isObserving, !isStarting else { return .alreadyStarted }
        isStarting = true
        captureStartOutcome = nil
        stateStartOutcome = nil

        observeCapture.start(sink: self)
        guard case .accepted(let captureSequence) = captureStartOutcome else {
            return rejectStart(captureStartOutcome)
        }
        observeState.start(sink: self)
        guard case .accepted(let stateSequence) = stateStartOutcome else {
            return rejectStart(stateStartOutcome)
        }

        isStarting = false
        isObserving = true
        return .started(captureSequence: captureSequence, stateSequence: stateSequence)
    }

    package func stopObserving() {
        guard isObserving || isStarting else { return }
        observeCapture.stop()
        observeState.stop()
        isObserving = false
        isStarting = false
    }

    package func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        let outcome: SignalSinkDeliveryOutcome
        let reportsRejection: Bool
        switch publication {
        case .snapshot(let revision, let capture):
            outcome = admission.submit(.captureSnapshot(revision: revision, capture: capture))
            reportsRejection = true
        case .mutation(let revision, let change):
            outcome = admission.submit(.captureMutation(revision: revision, change: change))
            reportsRejection = true
        case .terminalFailure(let condition, let diagnostic):
            let failure = failureFactory.failure(for: condition, diagnostic: diagnostic)
            outcome = admission.submit(.operationalFailure(failure))
            stopObserving()
            failureFactory.completeRepositoryFailure(
                failure,
                condition: condition,
                reservedOutcome: outcome
            )
            reportsRejection = false
        }
        recordStartOutcome(outcome, capture: true)
        if reportsRejection { reportActiveRejection(outcome) }
        return outcome
    }

    package func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome {
        let outcome = admission.submit(.acquisitionState(state))
        recordStartOutcome(outcome, capture: false)
        reportActiveRejection(outcome)
        return outcome
    }

    private func recordStartOutcome(_ outcome: SignalSinkDeliveryOutcome, capture: Bool) {
        guard isStarting else { return }
        if capture { captureStartOutcome = outcome } else { stateStartOutcome = outcome }
    }

    private func reportActiveRejection(_ outcome: SignalSinkDeliveryOutcome) {
        guard !isStarting, case .rejected(let rejection) = outcome else { return }
        let failure = failureFactory.failure(for: rejection, context: .activeDelivery)
        let reservedOutcome = admission.submit(.operationalFailure(failure))
        stopObserving()
        failureFactory.completeAdmissionFailure(
            failure,
            rejection: rejection,
            context: .activeDelivery,
            reservedOutcome: reservedOutcome
        )
    }

    private func rejectStart(
        _ outcome: SignalSinkDeliveryOutcome?
    ) -> SignalAnalyzerObservationStartOutcome {
        observeCapture.stop()
        observeState.stop()
        isStarting = false
        guard case .rejected(let rejection) = outcome else {
            return .rejected(.runtimeUnavailable)
        }
        let failure = failureFactory.failure(for: rejection, context: .observationStart)
        let reservedOutcome = admission.submit(.operationalFailure(failure))
        failureFactory.completeAdmissionFailure(
            failure,
            rejection: rejection,
            context: .observationStart,
            reservedOutcome: reservedOutcome
        )
        return .rejected(rejection)
    }
}
