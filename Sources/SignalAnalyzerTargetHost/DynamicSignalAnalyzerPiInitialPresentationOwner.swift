import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
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
        self.envelopeValidator = envelopeValidator
        self.provenance = provenance
        self.presentationRevision = presentationRevision
        publishedSemanticRevision = provenance.semanticRevision
    }

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
        retainFailure(result)
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
        retainFailure(result)
        lastPipelineResult = result
        switch result {
        case .failed(let record):
            return .failure(.presentation(.pipeline(failureContext(record), record)))
        case .completed:
            if let offer = attemptOffer, offer.disposition != .accepted {
                return .failure(.presentation(.offer(offer)))
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
        retainedFailure = RuntimeFocusedFailureState()
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

    private mutating func retainFailure(_ result: RuntimeCompletePipelineResult<OwnerFailure>) {
        if case .failed(let record) = result, case .focusedOwner(let failure) = record.failure {
            retainedFailure.captureFirst(failure, context: failureContext(record))
        }
    }

    private func failureContext(
        _ record: RuntimePipelineFailureRecord<SignalAnalyzerCycleOwnerFailure>
    ) -> ExecutionContext {
        ExecutionContext(
            cycle: attemptCycle!, semanticRevision: attemptSemanticRevision,
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
        semanticChanged = semanticChanged || pipeline.applicationIsDirty
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
        guard let attemptSemanticRevision, let attemptModel else {
            return .failure(.execution(.identityExhausted))
        }
        let failure = pipeline.expandSemantics(
            model: attemptModel, injectingFailure: injectingFailure)
        return step(failure)
    }

    package mutating func resolveLayout() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.resolveLayout(injectingFailure: injectingFailure)
        if failure != nil { pipeline.cleanup(.resetLayoutCandidate) }
        return step(failure)
    }

    package mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.invokeCanvases(
            cycle: attemptCycle!, semanticRevision: attemptSemanticRevision!,
            injectingFailure: injectingFailure)
        if failure != nil { pipeline.cleanup(.resetDrawingPlan) }
        return step(failure)
    }

    package mutating func preflightCombinedRender() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        let failure = pipeline.preflightRender(injectingFailure: injectingFailure)
        if failure != nil { pipeline.cleanup(.resetRenderWorkspace) }
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
        case .nonRetryableRefusal: return .nonRetryableRefusal(.endpoint)
        case .failed: return .failure(.frameOffer(offer.failure!))
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
    }

    package mutating func finalizePipeline() {
        pipeline.finalizeApplicationOpportunity()
        attemptAdmission?.endProducer()
        if let admission = attemptAdmission { while admission.takeNextSealed() != nil {} }
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
