import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIReferenceTextResources
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import SignalAnalyzerHost
import SignalAnalyzerPresentation

#if os(Linux)
    import Glibc
#endif

package enum DynamicSignalAnalyzerPiInitialPresentationState: UInt8, Equatable, Sendable {
    case ready = 0
    case inputEligible = 1
    case quiescent = 2
}

package enum DynamicSignalAnalyzerPiInitialPresentationFailure: Equatable, Sendable {
    case invalidLifecycle
    case presentation(DynamicSignalAnalyzerPresentationFailure)
    case offer(FrameOfferResult)
    case interaction
    case endpointHealth(HostEndpointHealthTransition)
    case endpointHealthFailure(HostEndpointHealthError)
    case pipeline(ExecutionContext, RuntimePipelineFailureRecord<SignalAnalyzerCycleOwnerFailure>)
}

package enum DynamicSignalAnalyzerPiInitialPresentationResult: Equatable, Sendable {
    case presented(DynamicSignalAnalyzerPresentationSummary)
    case failure(DynamicSignalAnalyzerPiInitialPresentationFailure)
}

package enum DynamicSignalAnalyzerPiInputRejection: UInt8, Equatable, Sendable {
    case inputIneligible = 0
    case stalePresentation = 1
    case outOfOrder = 2
}

package enum DynamicSignalAnalyzerPiInputResult: Equatable, Sendable {
    case captured
    case continued
    case dispatched(InteractionDispatchResult)
    case ignored
    case cancelled
    case rejected(DynamicSignalAnalyzerPiInputRejection)
}

/// Owns the first production Dynamic presentation transaction for the Pi host.
/// Input becomes eligible only after the physical target accepts the frame and
/// the matching interaction candidate commits.
package struct DynamicSignalAnalyzerPiInitialPresentationOwner<Target>
where Target: DisplayTarget {
    private var pipeline: DynamicSignalAnalyzerPresentationPipeline<GiftUIReferenceTextMetricsView>
    private var endpoint: DynamicSignalAnalyzerPiEndpoint<Target>
    private let envelopeValidator: DynamicSignalAnalyzerFrameEnvelopeValidator
    private var provenance: FrameProvenance
    private var presentationRevision: PresentationRevision
    private var activeInputSource: InputSourceID?
    private var activeInputSequence: PointerSequenceID?
    private var lastInputOrdinal: InputOrdinal?
    private var capturedAction: CapturedAction<DynamicSemanticIdentity>?
    private var model: SignalAnalyzerViewModel?

    package private(set) var state: DynamicSignalAnalyzerPiInitialPresentationState = .ready
    private var attemptModel: SignalAnalyzerViewModel?
    private var attemptAdmission: DynamicSignalAnalyzerHostFactAdmission?
    private var attemptEvents: [NormalizedPointerEvent] = []
    private var attemptCorrelations: DynamicSignalAnalyzerPiCorrelationOwner?
    private var attemptFixedCorrelation: DynamicSignalAnalyzerPiPresentationCorrelation?
    private var attemptCycle: RunCycleID?
    private var attemptSemanticRevision: SemanticRevision?
    private var attemptCorrelation: DynamicSignalAnalyzerPiPresentationCorrelation?
    private var attemptSummary: DynamicSignalAnalyzerPresentationSummary?
    private var derivesPresentation = false
    private var semanticChanged = false
    private var presentationPending = false
    private var requiresSemanticRetry = false
    private var recovery = HostPresentationRecovery(
        maximumRetryableRefusals: GeneratedSignalAnalyzerPresets.raspberryPiDynamic().pacing
            .maximumRetryableRefusals)!
    private var health: HostEndpointHealthController
    private var applicationFailureOwner: (any DynamicSignalAnalyzerApplicationFailureHandling)?
    private var applicationFailureWasAlreadyHandled = false
    private var attemptApplicationFailure: SignalAnalyzerRuntimeCondition?
    package private(set) var residualPolicy = SignalAnalyzerCycleResidualPolicyOwner()
    package private(set) var lastNormalizedFailure: GiftUIFailureFact?
    package private(set) var lastRecoveryTransition: HostPresentationRecoveryTransition?
    package private(set) var lastHealthFailure: HostEndpointHealthError?
    package private(set) var lastHealthTransition: HostEndpointHealthTransition?

    private var publishedSemanticRevision: SemanticRevision
    package var injectingFailure: DynamicSignalAnalyzerPresentationFailure?
    package private(set) var retainedFailure = RuntimeFocusedFailureState<
        SignalAnalyzerCycleOwnerFailure
    >()
    private var attemptOffer: FrameOfferResult?
    private var applicationSummary = DynamicSignalAnalyzerFactApplicationSummary(
        factCount: 0, changed: false)
    private var inputSummary = DynamicSignalAnalyzerPiInputDrainSummary(
        eventCount: 0, dispatchedActionCount: 0, cancelledOrRejectedCount: 0)
    package private(set) var lastPipelineResult:
        RuntimeCompletePipelineResult<SignalAnalyzerCycleOwnerFailure>?
    package private(set) var pipelineFinalizationCount: UInt32 = 0
    package private(set) var lastPresentedSummary: DynamicSignalAnalyzerPresentationSummary?

    package init?(
        target: consuming Target,
        limits: RuntimeProfileLimits,
        maximumRecordedTraversalIdentities: UInt16,
        effectivePresentation: EffectiveRasterPresentation,
        provenance: FrameProvenance,
        presentationRevision: PresentationRevision
    ) {
        let envelopeValidator = DynamicSignalAnalyzerFrameEnvelopeValidator(
            expected: provenance
        )
        guard
            let pipeline = DynamicSignalAnalyzerPresentationPipeline(
                textMetrics: DynamicSignalAnalyzerPiAssembly.textResources.metrics,
                limits: limits,
                maximumRecordedTraversalIdentities: maximumRecordedTraversalIdentities,
                logicalWidth: 240,
                logicalHeight: 240
            ),
            let endpoint = DynamicSignalAnalyzerPiEndpointFactory.make(
                target: target,
                validator: envelopeValidator,
                effectivePresentation: effectivePresentation
            )
        else { return nil }
        self.pipeline = pipeline
        self.endpoint = endpoint
        health = HostEndpointHealthController(
            initialHealth: endpoint.health(), inputIsEligible: false)!
        self.envelopeValidator = envelopeValidator
        self.provenance = provenance
        self.presentationRevision = presentationRevision
        publishedSemanticRevision = provenance.semanticRevision
    }

    package mutating func installApplicationFailureOwner(
        _ owner: any DynamicSignalAnalyzerApplicationFailureHandling
    ) {
        applicationFailureOwner = owner
    }

    package var pendingWakeReasons: ExecutionWakeReasons {
        guard state == .inputEligible else { return [] }
        var reasons: ExecutionWakeReasons
        switch lastPipelineResult {
        case .completed(let completion): reasons = completion.disposition.wakeReasons
        case .failed(let failure): reasons = failure.disposition.wakeReasons
        case nil: reasons = []
        }
        if presentationPending { reasons.insert(.presentationPending) }
        if requiresSemanticRetry { reasons.insert(.semanticDirty) }
        return reasons
    }

    package var lastCleanupActions: RuntimeCleanupActions { pipeline.lastFailureCleanupActions }

    package var lastCommittedPresentationRevision: PresentationRevision { presentationRevision }
    package var pendingPresentationIntent: PresentationPendingIntent? { recovery.pendingIntent }
    package var inputIsEligible: Bool { state == .inputEligible }
    package var currentPresentationRevision: PresentationRevision? {
        inputIsEligible ? presentationRevision : nil
    }

    package var eligibleActionCount: UInt16 {
        inputIsEligible ? pipeline.committedActionCount : 0
    }

    package borrowing func eligibleAction(
        at index: UInt16
    ) -> BoundActionRecord<DynamicSemanticIdentity>? {
        guard inputIsEligible else { return nil }
        return pipeline.committedAction(at: index)
    }

    package mutating func presentInitial(
        model: SignalAnalyzerViewModel
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        guard state == .ready else { return .failure(.invalidLifecycle) }

        return present(
            model: model,
            provenance: provenance,
            presentationRevision: presentationRevision
        )
    }

    package mutating func presentInitial(
        model: SignalAnalyzerViewModel,
        correlations: DynamicSignalAnalyzerPiCorrelationOwner
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        guard state == .ready else { return .failure(.invalidLifecycle) }
        prepareOpportunity(
            model: model, cycle: provenance.cycle, admission: nil, events: [],
            correlations: correlations, fixed: nil, force: true)
        attemptCycle = nil
        let result = RuntimeCompletePipeline.run(owner: &self)
        finishResult(result)
        lastPipelineResult = result
        return presentationResult(result)
    }

    package mutating func presentNext(
        model: SignalAnalyzerViewModel,
        provenance: FrameProvenance,
        presentationRevision: PresentationRevision
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        guard state == .inputEligible else { return .failure(.invalidLifecycle) }

        return present(
            model: model,
            provenance: provenance,
            presentationRevision: presentationRevision
        )
    }

    package mutating func presentNext(
        provenance: FrameProvenance,
        presentationRevision: PresentationRevision
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        guard let model else { return .failure(.invalidLifecycle) }
        return presentNext(
            model: model,
            provenance: provenance,
            presentationRevision: presentationRevision
        )
    }

    package func applySealedFacts(
        from admission: DynamicSignalAnalyzerHostFactAdmission
    ) -> DynamicSignalAnalyzerFactApplicationResult {
        guard state == .inputEligible else { return .unavailable(mutationApplied: false) }
        return pipeline.applySealedFacts(from: admission)
    }

    package func beginApplicationMutation() -> Bool {
        state == .inputEligible && pipeline.beginApplicationMutation()
    }

    package func endApplicationMutation() -> Bool? {
        guard state == .inputEligible else { return nil }
        return pipeline.endApplicationMutation()
    }

    private mutating func present(
        model: SignalAnalyzerViewModel,
        provenance: FrameProvenance,
        presentationRevision: PresentationRevision
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        prepareOpportunity(
            model: model, cycle: provenance.cycle, admission: nil, events: [],
            correlations: nil,
            fixed: DynamicSignalAnalyzerPiPresentationCorrelation(
                provenance: provenance, presentationRevision: presentationRevision), force: true)
        let result = RuntimeCompletePipeline.run(owner: &self)
        finishResult(result)
        lastPipelineResult = result
        return presentationResult(result)
    }

    package mutating func runOwnedOpportunity(
        admission: DynamicSignalAnalyzerHostFactAdmission, events: [NormalizedPointerEvent],
        cycle: RunCycleID, correlations: DynamicSignalAnalyzerPiCorrelationOwner?,
        fixed: DynamicSignalAnalyzerPiPresentationCorrelation?
    ) -> DynamicSignalAnalyzerPiInputOpportunityResult {
        guard let model, state == .inputEligible else { return .failure(.mutationUnavailable) }
        prepareOpportunity(
            model: model, cycle: cycle, admission: admission, events: events,
            correlations: correlations, fixed: fixed, force: false)
        let result = RuntimeCompletePipeline.run(owner: &self)
        finishResult(result)
        lastPipelineResult = result
        switch result {
        case .failed(let record):
            return .failure(.presentation(.pipeline(failureContext(record), record)))
        case .completed:
            if let lastHealthFailure {
                return .failure(.presentation(.endpointHealthFailure(lastHealthFailure)))
            }
            if let offer = attemptOffer, offer.disposition != .accepted {
                return .failure(.presentation(.offer(offer)))
            }
            if let transition = lastHealthTransition, transition.residualRouteRequest() != nil {
                return .failure(.presentation(.endpointHealth(transition)))
            }
            return .completed(
                DynamicSignalAnalyzerPiOpportunitySummary(
                    application: applicationSummary,
                    input: inputSummary, presentation: attemptSummary))
        }
    }

    private mutating func prepareOpportunity(
        model: SignalAnalyzerViewModel, cycle: RunCycleID,
        admission: DynamicSignalAnalyzerHostFactAdmission?, events: [NormalizedPointerEvent],
        correlations: DynamicSignalAnalyzerPiCorrelationOwner?,
        fixed: DynamicSignalAnalyzerPiPresentationCorrelation?, force: Bool
    ) {
        pipeline.prepareAttempt()
        retainedFailure = RuntimeFocusedFailureState()
        applicationFailureWasAlreadyHandled = false
        attemptApplicationFailure = nil
        lastRecoveryTransition = nil
        lastHealthFailure = nil
        lastHealthTransition = nil
        lastNormalizedFailure = nil
        attemptModel = model
        attemptCycle = cycle
        attemptAdmission = admission
        attemptEvents = events
        attemptCorrelations = correlations
        attemptFixedCorrelation = fixed
        attemptSemanticRevision = nil
        attemptCorrelation = nil
        attemptSummary = nil
        attemptOffer = nil
        semanticChanged = force
        derivesPresentation = force
        applicationSummary = DynamicSignalAnalyzerFactApplicationSummary(
            factCount: 0, changed: false)
        inputSummary = DynamicSignalAnalyzerPiInputDrainSummary(
            eventCount: 0, dispatchedActionCount: 0, cancelledOrRejectedCount: 0)
    }

    private mutating func finishResult(_ result: RuntimeCompletePipelineResult<OwnerFailure>) {
        switch result {
        case .failed(let record):
            let context = failureContext(record)
            if case .focusedOwner(let failure) = record.failure {
                retainedFailure.captureFirst(failure, context: context)
            }
            let fact = SignalAnalyzerCycleFailureNormalizer.cycleFailure(
                record.failure, context: context)
            lastNormalizedFailure = fact
            if applicationFailureWasAlreadyHandled {
                lastNormalizedFailure = applicationFailureOwner?.lastFailureFact ?? fact
                residualPolicy.noPolicy(.focusedOwnerFinal)
            } else if case .focusedOwner(.application) = record.failure {
                residualPolicy.noPolicy(.focusedOwnerFinal)
            } else if record.failure
                == .focusedOwner(.runtime(.observableState(.invalidPhaseContained)))
            {
                requiresSemanticRetry = true
                residualPolicy.noPolicy(.observableContainedPhase)
            } else if fact.containment == .safetyNotProven {
                quiesce()
                residualPolicy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .safetyNotProven,
                        completedEffects: [.discardPartialWork, .preventNormalCycle],
                        attemptOrdinal: 0, attemptLimit: 1))
            } else if record.stage == .offerAndProduction || record.stage == .candidateAllocation {
                lastRecoveryTransition = recovery.recordNonRetryableRefusal()
                presentationPending = false
                quiesce()
                residualPolicy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .presentationUnavailable,
                        completedEffects: [.clearPendingIntent, .quiesceInput], attemptOrdinal: 0,
                        attemptLimit: 1))
            } else if state == .ready {
                quiesce()
                residualPolicy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .activation,
                        completedEffects: [.containActivation], attemptOrdinal: 0, attemptLimit: 1))
            } else {
                residualPolicy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .containedCandidateFailure,
                        completedEffects: [.discardCandidate, .preservePriorRoot],
                        attemptOrdinal: 0, attemptLimit: 1))
            }
        case .completed(let completion):
            if lastHealthFailure != nil {
                let fact = GiftUIFailureFact(
                    condition: .invariantViolation, origin: .hostComposition,
                    affectedScope: .runtime, containment: .safetyNotProven)
                lastNormalizedFailure = fact
                residualPolicy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .safetyNotProven,
                        completedEffects: [.discardPartialWork, .preventNormalCycle],
                        attemptOrdinal: 0, attemptLimit: 1))
            } else if let transition = lastHealthTransition,
                let request = transition.residualRouteRequest()
            {
                residualPolicy.route(request)
            } else if let transition = lastRecoveryTransition,
                let context = transition.policyContext
            {
                let outcome: GiftUIOutcome<Void>
                if transition.disposition == .unavailable {
                    outcome = .failure(
                        GiftUIFailureFact(
                            condition: .nonRetryableRefusal, origin: .backend,
                            affectedScope: .candidateFrame, containment: .contained))
                } else {
                    outcome = .operational(
                        GiftUIOperationalFact(
                            kind: completion.operational == .backpressured
                                ? .backpressured : .retryableRefusal,
                            origin: .backend, affectedScope: .candidateFrame))
                }
                residualPolicy.route(
                    HostResidualRouteRequest(
                        outcome: outcome, context: context,
                        completedEffects: transition.completedEffects,
                        attemptOrdinal: transition.policyAttemptOrdinal,
                        attemptLimit: transition.policyAttemptLimit))
            } else {
                residualPolicy.noPolicy(.success)
            }
        }
        if residualPolicy.preventsNormalCycle { quiesce() }
    }

    private func failureContext(
        _ record: RuntimePipelineFailureRecord<SignalAnalyzerCycleOwnerFailure>
    ) -> ExecutionContext {
        ExecutionContext(
            cycle: attemptCycle, semanticRevision: attemptSemanticRevision,
            candidateFrame: attemptCorrelation?.provenance.candidateFrame,
            phase: phase(for: record.stage))
    }

    private func phase(for stage: RuntimeCompletePipelineStage) -> ExecutionPhase {
        switch stage {
        case .admissionAndSeal: .admitting
        case .applyAdmittedWork, .freezeObservableMutation: .mutating
        case .semanticAndObservablePublication: .publishing
        case .candidateAllocation, .offerAndProduction: .offering
        default: .deriving
        }
    }

    private func presentationResult(
        _ result: RuntimeCompletePipelineResult<SignalAnalyzerCycleOwnerFailure>
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        switch result {
        case .failed(let record):
            if let offer = attemptOffer { return .failure(.offer(offer)) }
            return .failure(.pipeline(failureContext(record), record))
        case .completed:
            if let lastHealthFailure { return .failure(.endpointHealthFailure(lastHealthFailure)) }
            if let transition = lastHealthTransition, transition.residualRouteRequest() != nil {
                return .failure(.endpointHealth(transition))
            }
            if let offer = attemptOffer, offer.disposition != .accepted {
                return .failure(.offer(offer))
            }
            guard let summary = attemptSummary else { return .failure(.invalidLifecycle) }
            return .presented(summary)
        }
    }

    package mutating func handle(
        _ event: NormalizedPointerEvent
    ) -> DynamicSignalAnalyzerPiInputResult {
        guard inputIsEligible else { return .rejected(.inputIneligible) }
        guard event.presentationRevision == presentationRevision else {
            cancelInputSequence()
            return .rejected(.stalePresentation)
        }

        switch event.phase {
        case .down:
            guard event.ordinal.rawValue == 0 else {
                cancelInputSequence()
                return .rejected(.outOfOrder)
            }
            activeInputSource = event.source
            activeInputSequence = event.sequence
            lastInputOrdinal = event.ordinal
            switch pipeline.resolveDown(at: event.position) {
            case .captured(let captured):
                capturedAction = captured
                return .captured
            case .ignored:
                capturedAction = nil
                return .ignored
            case .cancelled, .continued, .activationAdmitted:
                cancelInputSequence()
                return .cancelled
            }
        case .move, .up:
            guard activeInputSource == event.source,
                activeInputSequence == event.sequence,
                let previous = lastInputOrdinal,
                previous.rawValue < UInt32.max,
                event.ordinal.rawValue == previous.rawValue + 1
            else {
                cancelInputSequence()
                return .rejected(.outOfOrder)
            }
            lastInputOrdinal = event.ordinal
            guard let capturedAction else {
                if event.phase == .up { cancelInputSequence() }
                return .ignored
            }
            if event.phase == .move {
                switch pipeline.resolveMove(capturedAction, at: event.position) {
                case .continued:
                    return .continued
                case .cancelled, .ignored:
                    self.capturedAction = nil
                    return .cancelled
                case .captured, .activationAdmitted:
                    cancelInputSequence()
                    return .cancelled
                }
            }
            defer { cancelInputSequence() }
            switch pipeline.resolveUp(capturedAction, at: event.position) {
            case .activationAdmitted(let admitted):
                return .dispatched(pipeline.dispatch(admitted))
            case .cancelled, .ignored:
                return .cancelled
            case .captured, .continued:
                return .cancelled
            }
        }
    }

    package mutating func quiesce() {
        cancelInputSequence()
        state = .quiescent
        _ = health.requireFreshConstruction(for: .terminalUnavailability)
        attemptAdmission?.quiesce()
    }

    private mutating func cancelInputSequence() {
        activeInputSource = nil
        activeInputSequence = nil
        lastInputOrdinal = nil
        capturedAction = nil
    }
}

extension DynamicSignalAnalyzerPiInitialPresentationOwner: RuntimeCompletePipelineOwner {
    package typealias OwnerFailure = SignalAnalyzerCycleOwnerFailure

    package mutating func admitAndSeal() -> RuntimePipelineStepResult<OwnerFailure> {
        guard state != .quiescent else { return .failure(.execution(.invalidPhase)) }
        if let applicationFailureOwner, !applicationFailureOwner.isAvailable {
            applicationFailureWasAlreadyHandled = true
            quiesce()
            if let condition = applicationFailureOwner.terminalCondition {
                return .failure(.focusedOwner(.application(condition)))
            }
            return .failure(.execution(.requiredFacilityUnavailable))
        }
        if attemptCycle == nil {
            guard let cycle = attemptCorrelations?.reserveOpportunityCycle() else {
                return .failure(.execution(.identityExhausted))
            }
            attemptCycle = cycle
        }
        _ = attemptAdmission?.seal()
        return .advanced
    }

    package mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<OwnerFailure> {
        var applied = false
        if let admission = attemptAdmission {
            switch pipeline.applySealedFacts(from: admission) {
            case .applied(let summary):
                applicationSummary = summary
                applied = summary.factCount != 0
            case .rejected(let condition, let mutationApplied):
                attemptApplicationFailure = condition
                return .failure(
                    .focusedOwner(.application(condition)), mutationApplied: mutationApplied)
            case .unavailable(let mutationApplied):
                return .failure(
                    .execution(.requiredFacilityUnavailable), mutationApplied: mutationApplied)
            }
        }
        if !attemptEvents.isEmpty {
            guard pipeline.beginApplicationMutation() else {
                return .failure(.execution(.invalidPhase), mutationApplied: applied)
            }
            guard attemptAdmission?.beginProducer(.action) == true else {
                return .failure(.execution(.reentrancyViolation), mutationApplied: applied)
            }
            var dispatched: UInt16 = 0
            var cancelled: UInt16 = 0
            for event in attemptEvents {
                switch handle(event) {
                case .dispatched(.dispatched):
                    dispatched += 1
                    applied = true
                case .cancelled, .rejected, .dispatched: cancelled += 1
                case .captured, .continued, .ignored: break
                }
            }
            attemptAdmission?.endProducer()
            inputSummary = DynamicSignalAnalyzerPiInputDrainSummary(
                eventCount: UInt16(attemptEvents.count),
                dispatchedActionCount: dispatched, cancelledOrRejectedCount: cancelled)
        }
        semanticChanged = semanticChanged || pipeline.applicationIsDirty || requiresSemanticRetry
        derivesPresentation = semanticChanged || presentationPending
        return .applied(applied)
    }

    package mutating func freezeObservableMutation() -> RuntimePipelineStepResult<OwnerFailure> {
        pipeline.freezeApplicationMutation()
        return .advanced
    }

    package mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<
        OwnerFailure
    > {
        guard derivesPresentation else {
            attemptSemanticRevision = publishedSemanticRevision
            return .advanced
        }
        attemptSemanticRevision =
            semanticChanged
            ? (attemptFixedCorrelation?.provenance.semanticRevision
                ?? attemptCorrelations?.reserveSemanticRevision())
            : publishedSemanticRevision
        guard attemptSemanticRevision != nil, let attemptModel else {
            return .failure(.execution(.identityExhausted))
        }
        let failure = pipeline.expandSemantics(
            model: attemptModel, injectingFailure: injectingFailure)
        return step(failure)
    }

    package mutating func resolveLayout() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.resolveLayout(injectingFailure: injectingFailure)
        return step(failure)
    }

    package mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.invokeCanvases(
            cycle: attemptCycle!, semanticRevision: attemptSemanticRevision!,
            injectingFailure: injectingFailure)
        return step(failure)
    }

    package mutating func preflightCombinedRender() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.preflightRender(injectingFailure: injectingFailure)
        return step(failure)
    }

    package mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.buildInteraction(injectingFailure: injectingFailure)

        return step(failure)
    }

    package mutating func publishSemanticAndObservableCandidate()
        -> RuntimePipelinePublicationResult<OwnerFailure>
    {
        if derivesPresentation {
            if let failure = pipeline.publishObservableCandidate() {
                return .failure(mapped(failure))
            }
            guard let summary = pipeline.preparedSummary else {
                return .failure(.execution(.invariantViolation))
            }
            attemptSummary = summary
            publishedSemanticRevision = attemptSemanticRevision!
            requiresSemanticRetry = false
        }
        return .published(
            RuntimePipelinePublication(
                semanticRevision: attemptSemanticRevision!, changed: semanticChanged))
    }

    package mutating func allocateCandidate() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        attemptCorrelation =
            attemptFixedCorrelation
            ?? attemptCorrelations?.reservePresentation(
                for: attemptCycle!, semanticRevision: attemptSemanticRevision!)
        return attemptCorrelation == nil ? .failure(.execution(.identityExhausted)) : .advanced
    }

    package mutating func offerAndProduce() -> RuntimePipelineOfferResult<OwnerFailure> {
        guard derivesPresentation else { return .noChange }
        let correlation = attemptCorrelation!
        envelopeValidator.install(correlation.provenance)
        let offer = pipeline.offer(
            endpoint: &endpoint, provenance: correlation.provenance,
            expectedHeader: attemptSummary!.render)
        attemptOffer = offer
        switch offer.disposition {
        case .accepted: return .accepted(correlation.presentationRevision)
        case .backpressured: return .backpressured
        case .retryableRefusal: return .retryableRefusal
        case .nonRetryableRefusal:
            return .nonRetryableRefusal(
                endpoint.retainedProducerError == .sinkRefused ? .renderProducer : .endpoint)
        case .failed:
            if let error = endpoint.retainedProducerError {
                return .failure(.renderProduction(error))
            }
            return .failure(.frameOffer(offer.failure!))
        }
    }

    package mutating func cleanup(_ action: RuntimeCleanupAction) {
        guard derivesPresentation else { return }
        if action == .commitInteractionCandidate {
            let correlation = attemptCorrelation!
            guard
                pipeline.resolveInteraction(
                    offer: attemptOffer!, presentationRevision: correlation.presentationRevision)
                    == .committed(correlation.presentationRevision)
            else {
                quiesce()
                return
            }
            cancelInputSequence()
            provenance = correlation.provenance
            presentationRevision = correlation.presentationRevision
            model = attemptModel
            state = .inputEligible
            lastPresentedSummary = attemptSummary
        } else {
            pipeline.cleanup(action)
        }
    }

    package mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        presentationPending = disposition.presentationIntentState == .pending
        guard let offer = attemptOffer else { return }
        switch offer.disposition {
        case .accepted:
            lastRecoveryTransition = recovery.recordAccepted(revision: attemptSemanticRevision!)
            switch health.consumeAcceptedOffer(
                from: endpoint,
                responsibilityTransferred: endpoint.sink.presentationResponsibilityAccepted,
                streamDrained: endpoint.sink.streamCompleted)
            {
            case .success(let transition):
                lastHealthTransition = transition
                if transition.residualRouteRequest() != nil {
                    quiesce()
                } else if !health.enableInputAfterCommittedOffer(from: endpoint) {
                    quiesce()
                }
            case .failure(let error):
                lastHealthFailure = error
                quiesce()
            }
        case .backpressured:
            lastRecoveryTransition = recovery.recordBackpressure(revision: attemptSemanticRevision!)
        case .retryableRefusal:
            lastRecoveryTransition = recovery.recordRetryableRefusal(
                revision: attemptSemanticRevision!)
        case .nonRetryableRefusal: lastRecoveryTransition = recovery.recordNonRetryableRefusal()
        case .failed: break
        }
        if let transition = lastRecoveryTransition, transition.disposition == .unavailable {
            presentationPending = false
            quiesce()
        }
    }

    package mutating func finalizePipeline() {
        attemptAdmission?.endProducer()
        if let admission = attemptAdmission { while admission.takeNextSealed() != nil {} }
        if let condition = attemptApplicationFailure {
            _ = pipeline.beginApplicationMutation()
            if let applicationFailureOwner {
                if applicationFailureOwner.handle(condition) { quiesce() }
            } else {
                quiesce()
            }
        }
        pipeline.finalizeApplicationOpportunity()
        attemptEvents.removeAll(keepingCapacity: true)
        pipelineFinalizationCount += 1
    }

    private func step(_ failure: DynamicSignalAnalyzerPresentationFailure?)
        -> RuntimePipelineStepResult<OwnerFailure>
    {
        failure.map { .failure(mapped($0)) } ?? .advanced
    }

    private func mapped(_ failure: DynamicSignalAnalyzerPresentationFailure) -> RunCycleFailure<
        OwnerFailure
    > {
        switch failure {
        case .observable(let error): return .focusedOwner(.runtime(.observableState(error)))
        case .semantic(let error): return .focusedOwner(.runtime(.semantic(error)))
        case .layout(let error): return .focusedOwner(.runtime(.layout(error)))
        case .drawing(let error): return .focusedOwner(.runtime(.drawing(error)))
        case .interaction(let error): return .focusedOwner(.runtime(.interaction(error)))
        case .runtime(let failure): return .focusedOwner(.runtime(failure))
        case .render(let error): return .renderProduction(error)
        case .execution(let error): return .execution(error)
        case .invariantViolation: return .execution(.invariantViolation)
        }
    }
}
