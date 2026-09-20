import GiftUI
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation

package enum DynamicSignalAnalyzerPiLifecyclePhase: UInt8, Equatable, Sendable {
    case valid = 0
    case runtimeConstructed = 1
    case applicationConstructed = 2
    case rootAttached = 3
    case observationInstalled = 4
    case firstPresentationAccepted = 5
    case acquisitionStarted = 6
    case active = 7
    case quiescent = 8
}

/// Owns the production Dynamic Pi application aggregate while the existing
/// host activation controller remains the sole lifecycle-ordering authority.
package struct DynamicSignalAnalyzerPiLifecycleOwner<Target>: MVPHostActivationOwner,
    MVPHostTeardownOwner
where Target: DisplayTarget {
    package typealias ActivationFailure = RaspberryPiDynamicHostActivationFailure

    private let assemblyReport: HostAssemblyReport
    private let inputSource: InputSourceID
    private let maximumRecordedTraversalIdentities: UInt16
    private let timingScale: SignalSourceTimingScale
    private let nowMicroseconds: () -> UInt64
    private let factAdmission = DynamicSignalAnalyzerHostFactAdmission()
    private let correlations = DynamicSignalAnalyzerPiCorrelationOwner()
    private let pacing: DynamicSignalAnalyzerPiWakePacingOwner

    private var target: Target?
    private var initialCorrelation: DynamicSignalAnalyzerPiPresentationCorrelation?
    private var presentationOwner: DynamicSignalAnalyzerPiInitialPresentationOwner<Target>?
    private var source: DeterministicSignalDataSource?
    private var repository: DefaultSignalAcquisitionRepository?
    private var admissionAdapter: SignalAnalyzerPresentationAdmissionAdapter?
    private var model: SignalAnalyzerViewModel?
    private var inputCoordinator: DynamicSignalAnalyzerPiInputCoordinator?
    private var assemblyReportRuntimeUseIsValid = true

    package private(set) var phase: DynamicSignalAnalyzerPiLifecyclePhase = .valid

    package init(
        target: consuming Target,
        assemblyReport: HostAssemblyReport,
        inputSource: InputSourceID,
        initialFrameOriginMicroseconds: UInt64,
        maximumRecordedTraversalIdentities: UInt16 = 203,
        timingScale: SignalSourceTimingScale = .live,
        nowMicroseconds: @escaping () -> UInt64
    ) {
        self.target = target
        self.assemblyReport = assemblyReport
        self.inputSource = inputSource
        self.maximumRecordedTraversalIdentities = maximumRecordedTraversalIdentities
        self.timingScale = timingScale
        self.nowMicroseconds = nowMicroseconds
        pacing = DynamicSignalAnalyzerPiWakePacingOwner(
            policy: HostPacingPolicy(
                minimumFrameIntervalMicroseconds:
                    assemblyReport.minimumFrameIntervalMicroseconds,
                maximumFactServiceLatencyMicroseconds:
                    assemblyReport.maximumFactServiceLatencyMicroseconds,
                minimumAcceptedTransitionSpacingMicroseconds:
                    assemblyReport.minimumAcceptedTransitionSpacingMicroseconds,
                maximumTransitionFactsPerServiceWindow:
                    assemblyReport.maximumCompactFactsPerServiceWindow - 8,
                maximumBootstrapFactsPerServiceWindow: 2,
                maximumActionInducedFactsPerServiceWindow: 6,
                maximumRetryableRefusals: assemblyReport.maximumRetryableRefusals
            )!,
            initialFrameOriginMicroseconds: initialFrameOriginMicroseconds
        )
    }

    package var inputIsEligible: Bool {
        presentationOwner?.inputIsEligible == true && inputCoordinator?.inputIsEligible == true
    }

    package var currentPresentationRevision: PresentationRevision? {
        presentationOwner?.currentPresentationRevision
    }

    package var sourceIsActive: Bool { source?.activeGeneration != nil }
    package var loopIsEstablished: Bool { phase == .active }
    package var reportRuntimeUseIsValid: Bool { assemblyReportRuntimeUseIsValid }
    package var nextScheduledSourceDelay: Duration? { source?.nextScheduledDelay }

    package mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<
        ActivationFailure
    > {
        guard phase == .valid,
            assemblyReportRuntimeUseIsValid,
            assemblyReport.kind == .raspberryPiDynamic,
            assemblyReport.profile == .dynamic,
            let target,
            let correlation = correlations.reserveInitialPresentation(),
            let owner = DynamicSignalAnalyzerPiInitialPresentationOwner(
                target: target,
                limits: assemblyReport.storageAudit.limits,
                maximumRecordedTraversalIdentities: maximumRecordedTraversalIdentities,
                effectivePresentation: assemblyReport.effectivePresentation,
                provenance: correlation.provenance,
                presentationRevision: correlation.presentationRevision
            )
        else { return fail(.configuration(.invariantViolation)) }
        self.target = nil
        initialCorrelation = correlation
        presentationOwner = owner
        phase = .runtimeConstructed
        return .advanced
    }

    package mutating func constructApplicationOwners() -> HostActivationStepResult<
        ActivationFailure
    > {
        guard phase == .runtimeConstructed, let correlation = initialCorrelation else {
            return fail(.configuration(.invariantViolation))
        }
        let source = DeterministicSignalDataSource(timingScale: timingScale)
        let repository = DefaultSignalAcquisitionRepository(source: source)
        let wakeAdmission = DynamicSignalAnalyzerPiWakeAdmission(
            base: factAdmission,
            recordAcceptedFact: { [pacing, nowMicroseconds] in
                _ = pacing.recordAcceptedFact(at: nowMicroseconds())
            }
        )
        let adapter = SignalAnalyzerPresentationAdmissionAdapter(
            observeCapture: ObserveSignalCaptureUseCase(repository: repository),
            observeState: ObserveAcquisitionStateUseCase(repository: repository),
            admission: wakeAdmission,
            failureFactory: DefaultSignalAnalyzerOperationalFailureFactory()
        )
        let model = SignalAnalyzerViewModel(
            startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
            clearCapture: ClearSignalCaptureUseCase(repository: repository)
        )
        inputCoordinator = DynamicSignalAnalyzerPiInputCoordinator(
            source: inputSource,
            capacity: assemblyReport.storageAudit.limits.execution.maximumInputEvents,
            context: ExecutionContext(
                cycle: correlation.provenance.cycle,
                semanticRevision: correlation.provenance.semanticRevision,
                candidateFrame: correlation.provenance.candidateFrame,
                phase: .idle
            ),
            factAdmission: factAdmission
        )
        self.source = source
        self.repository = repository
        admissionAdapter = adapter
        self.model = model
        phase = .applicationConstructed
        return .advanced
    }

    package mutating func attachRootModelInFirstCandidate()
        -> HostActivationStepResult<ActivationFailure>
    {
        guard phase == .applicationConstructed, model != nil, presentationOwner != nil else {
            return fail(.configuration(.invariantViolation))
        }
        phase = .rootAttached
        return .advanced
    }

    package mutating func installRepositoryObservationAndAdmitCurrentValues()
        -> HostActivationStepResult<ActivationFailure>
    {
        guard phase == .rootAttached, let admissionAdapter,
            factAdmission.beginProducer(.bootstrap)
        else { return fail(.configuration(.invariantViolation)) }
        defer { factAdmission.endProducer() }
        guard case .started = admissionAdapter.startObserving() else {
            return fail(
                .configuration(.invariantViolation),
                progress: HostActivationProgress(observationInstalled: true)
            )
        }
        phase = .observationInstalled
        return .advanced
    }

    package mutating func acceptFirstPresentationAndEnableInput()
        -> HostActivationStepResult<ActivationFailure>
    {
        guard phase == .observationInstalled, let model,
            var presentationOwner, var inputCoordinator,
            let correlation = initialCorrelation
        else { return fail(.configuration(.invariantViolation)) }
        guard case .presented = presentationOwner.presentInitial(model: model) else {
            self.presentationOwner = presentationOwner
            return fail(.endpoint(.invariantViolation))
        }
        inputCoordinator.installPhysicalPresentation(correlation.presentationRevision)
        self.presentationOwner = presentationOwner
        self.inputCoordinator = inputCoordinator
        phase = .firstPresentationAccepted
        return .advanced
    }

    package mutating func startAcquisitionThroughApplicationOpportunity()
        -> HostActivationStepResult<ActivationFailure>
    {
        guard phase == .firstPresentationAccepted,
            var presentationOwner, var inputCoordinator,
            let revision = presentationOwner.currentPresentationRevision,
            let action = startAction(in: presentationOwner)
        else { return fail(.configuration(.invariantViolation)) }
        let point = Point(
            x: action.hitBounds.origin.x + action.hitBounds.size.width / 2,
            y: action.hitBounds.origin.y + action.hitBounds.size.height / 2
        )
        guard
            case .queued = inputCoordinator.admit(
                phase: .down,
                position: point,
                source: inputSource,
                observedPresentationRevision: revision
            ),
            case .queued = inputCoordinator.admit(
                phase: .up,
                position: point,
                source: inputSource,
                observedPresentationRevision: revision
            )
        else { return fail(.configuration(.invariantViolation)) }
        let result = inputCoordinator.runOpportunity(
            into: &presentationOwner,
            correlations: correlations
        )
        self.presentationOwner = presentationOwner
        self.inputCoordinator = inputCoordinator
        guard case .completed(let summary) = result,
            summary.input.dispatchedActionCount == 1,
            source?.activeGeneration != nil
        else { return fail(.runtime(.drawing(.invariantViolation))) }
        phase = .acquisitionStarted
        return .advanced
    }

    package mutating func establishWakeAndPacingHostLoop()
        -> HostActivationStepResult<ActivationFailure>
    {
        guard phase == .acquisitionStarted else {
            return fail(.configuration(.invariantViolation))
        }
        phase = .active
        return .advanced
    }

    package mutating func service(
        at timestampMicroseconds: UInt64
    ) -> DynamicSignalAnalyzerPiPacedOpportunityResult {
        guard phase == .active, var inputCoordinator, var presentationOwner else {
            return .rejected(.unavailable)
        }
        let result = pacing.service(
            at: timestampMicroseconds,
            coordinator: &inputCoordinator,
            owner: &presentationOwner,
            correlations: correlations
        )
        self.inputCoordinator = inputCoordinator
        self.presentationOwner = presentationOwner
        return result
    }

    @discardableResult
    package func deliverScheduledSourceTransition() -> Bool {
        guard phase == .active, let source, let generation = source.activeGeneration,
            factAdmission.beginProducer(.transition)
        else { return false }
        defer { factAdmission.endProducer() }
        return source.deliverScheduledTransition(generation: generation)
    }

    package mutating func stopSourceDeliveryAndRepositoryObservation() {
        repository?.stop()
        admissionAdapter?.stopObserving()
    }

    package mutating func preventInputEligibility() {
        inputCoordinator?.quiesce()
        presentationOwner?.quiesce()
    }

    package mutating func quiesceConstructedRuntime() {
        _ = pacing.quiesce()
        presentationOwner?.quiesce()
    }

    package mutating func refuseApplicationDeliveryAndInput() {
        inputCoordinator?.quiesce()
    }

    package mutating func stopSourceDeliveryAndDetachObservations() {
        stopSourceDeliveryAndRepositoryObservation()
    }

    package mutating func cancelPointerSequencesAndHostCallbacks() {
        inputCoordinator?.quiesce()
    }

    package mutating func quiesceRuntimeAndFinalizeActiveCycle() {
        _ = pacing.quiesce()
        presentationOwner?.quiesce()
    }

    package mutating func retireObservableRegistrationAndRouting() {
        admissionAdapter?.stopObserving()
    }

    package mutating func releasePlatformOwners() {
        source?.shutdown()
        presentationOwner = nil
        target = nil
    }

    package mutating func resetProfileStorage() {
        factAdmission.discardAll()
        inputCoordinator = nil
        admissionAdapter = nil
        repository = nil
        source = nil
        model = nil
        initialCorrelation = nil
    }

    package mutating func invalidateAssemblyReportRuntimeUse() {
        assemblyReportRuntimeUseIsValid = false
        phase = .quiescent
    }

    private func startAction(
        in owner: borrowing DynamicSignalAnalyzerPiInitialPresentationOwner<Target>
    ) -> BoundActionRecord<DynamicSemanticIdentity>? {
        var index: UInt16 = 0
        while index < owner.eligibleActionCount {
            if let action = owner.eligibleAction(at: index),
                action.action.code == SignalAnalyzerAction.start.rawValue
            {
                return action
            }
            index += 1
        }
        return nil
    }

    private func fail(
        _ failure: ActivationFailure,
        progress: HostActivationProgress = HostActivationProgress()
    ) -> HostActivationStepResult<ActivationFailure> {
        .failure(failure, progress: progress)
    }
}
