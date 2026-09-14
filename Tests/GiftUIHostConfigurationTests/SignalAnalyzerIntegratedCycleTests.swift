import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUIRuntimeStatic
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation
import Testing

private protocol IntegratedFactAdmission: SignalAnalyzerFactAdmission {
    func beginProducer(_ category: HostFactProducerCategory) -> Bool
    func endProducer()
    func seal() -> Bool
    func takeNextSealed()
        -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
}

extension DynamicSignalAnalyzerHostFactAdmission: IntegratedFactAdmission {}
extension StaticSignalAnalyzerHostFactAdmission: IntegratedFactAdmission {}

private final class IntegratedRepository: SignalAcquisitionRepository {
    private(set) var calls: [String] = []

    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws { calls.append("start") }
    func stop() { calls.append("stop") }
    func clear() { calls.append("clear") }
}

private struct IntegratedActionRecords: InteractionCommittedActionView {
    func committedRecord(for identity: UInt16) -> BoundActionRecord<UInt16>? {
        guard identity == 6 else { return nil }
        return BoundActionRecord(
            identity: identity,
            generation: ActionGeneration(rawValue: 4),
            isEnabled: true,
            hitBounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 1, height: 1)!
            )!,
            paintOrder: 0,
            action: BoundedApplicationAction(
                code: SignalAnalyzerAction.selectTwoSeconds.rawValue
            ),
            targetGeneration: ObservableTargetGeneration(rawValue: 0)
        )
    }
}

private let integratedCapturedAction = CapturedAction(
    identity: UInt16(6),
    generation: ActionGeneration(rawValue: 4)
)

private struct IntegratedRootHooks {
    let setPhase: (ExecutionPhase) -> Void
    let isDirty: () -> Bool
    let beginCandidate: () -> ObservableStateResult
    let encounterPreserved: () -> ObservableStateResult
    let publishCandidate: () -> ObservableStateResult
    let dispatchAction: () -> InteractionDispatchResult
}

private struct IntegratedCycleTranscript: Equatable {
    let admissionSequences: [UInt32]
    let wakeDirectives: [HostWakeDirective]
    let stages: [RuntimeCompletePipelineStage]
    let appliedSequences: [UInt32]
    let dirtyTransitions: UInt16
    let actionResult: InteractionDispatchResult?
    let semanticRevision: SemanticRevision?
    let drawingStrokeCount: UInt16
    let result: RuntimeCompletePipelineResult
    let cleanup: [RuntimeCleanupAction]
    let wakePendingAfterCompletion: Bool
    let finalState: SignalAnalyzerViewState
}

private struct IntegratedCycleOwner: RuntimeCompletePipelineOwner {
    let admission: any IntegratedFactAdmission
    let model: SignalAnalyzerViewModel
    let root: IntegratedRootHooks
    let offer: RuntimePipelineOfferResult
    private(set) var stages: [RuntimeCompletePipelineStage] = []
    private(set) var appliedSequences: [UInt32] = []
    private(set) var dirtyTransitions: UInt16 = 0
    private(set) var actionResult: InteractionDispatchResult?
    private(set) var drawingStrokeCount: UInt16 = 0
    private(set) var cleanupActions: [RuntimeCleanupAction] = []
    private(set) var disposition: RuntimePipelineDisposition?
    private var changed = false

    init(
        admission: any IntegratedFactAdmission,
        model: SignalAnalyzerViewModel,
        root: IntegratedRootHooks,
        offer: RuntimePipelineOfferResult
    ) {
        self.admission = admission
        self.model = model
        self.root = root
        self.offer = offer
    }

    mutating func admitAndSeal() -> RuntimePipelineStepResult {
        stages.append(.admissionAndSeal)
        return admission.seal()
            ? .advanced
            : .failure(.execution(.requiredFacilityUnavailable))
    }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult {
        stages.append(.applyAdmittedWork)
        root.setPhase(.mutating)
        while let next = admission.takeNextSealed() {
            appliedSequences.append(next.0)
            let wasDirty = root.isDirty()
            switch model.apply(next.2) {
            case .applied(let factChanged):
                changed = changed || factChanged
                if !wasDirty, root.isDirty() { dirtyTransitions += 1 }
            case .rejected:
                return .failure(.execution(.invariantViolation))
            }
        }
        actionResult = root.dispatchAction()
        guard actionResult == .dispatched else {
            return .failure(.execution(.invariantViolation))
        }
        return .applied(changed)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult {
        stages.append(.freezeObservableMutation)
        root.setPhase(.deriving)
        return .advanced
    }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult {
        stages.append(.observableCandidateAndSemanticExpansion)
        guard root.beginCandidate() == .success(.candidateStarted),
            root.encounterPreserved() == .success(.preserved)
        else {
            return .failure(.execution(.invariantViolation))
        }
        return .advanced
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult {
        stages.append(.layout)
        return .advanced
    }

    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult {
        stages.append(.canvasInvocationAndPlan)
        drawingStrokeCount = 5
        return .advanced
    }

    mutating func preflightCombinedRender() -> RuntimePipelineStepResult {
        stages.append(.combinedRenderPreflight)
        return .advanced
    }

    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult {
        stages.append(.interactionCandidate)
        return .advanced
    }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult {
        stages.append(.semanticAndObservablePublication)
        root.setPhase(.publishing)
        guard case .success = root.publishCandidate() else {
            return .failure(.execution(.invariantViolation))
        }
        return .published(
            RuntimePipelinePublication(
                semanticRevision: SemanticRevision(rawValue: 1),
                changed: changed
            )
        )
    }

    mutating func allocateCandidate() -> RuntimePipelineStepResult {
        stages.append(.candidateAllocation)
        return .advanced
    }

    mutating func offerAndProduce() -> RuntimePipelineOfferResult {
        stages.append(.offerAndProduction)
        return offer
    }

    mutating func cleanup(_ action: RuntimeCleanupAction) {
        cleanupActions.append(action)
    }

    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        self.disposition = disposition
    }

    mutating func finalizePipeline() {
        root.setPhase(.idle)
    }
}

@Test(arguments: [false, true])
func integratedAnalyzerCycleIsProfileEquivalent(retryableOffer: Bool) {
    let offer: RuntimePipelineOfferResult =
        retryableOffer
        ? .retryableRefusal
        : .accepted(PresentationRevision(rawValue: 1))
    let dynamic = dynamicIntegratedTranscript(offer: offer)
    let fixed = staticIntegratedTranscript(offer: offer)

    #expect(dynamic == fixed)
    #expect(dynamic.admissionSequences == Array(UInt32(1) ... UInt32(20)))
    #expect(dynamic.appliedSequences == dynamic.admissionSequences)
    #expect(dynamic.wakeDirectives.first == .requestWake)
    #expect(dynamic.wakeDirectives.dropFirst().allSatisfy { $0 == .coalesced })
    #expect(dynamic.dirtyTransitions == 1)
    #expect(dynamic.actionResult == .dispatched)
    #expect(dynamic.semanticRevision == SemanticRevision(rawValue: 1))
    #expect(dynamic.drawingStrokeCount == 5)
    #expect(dynamic.finalState.acquisitionState == .stopped)
    #expect(dynamic.finalState.visibleWindow == .twoSeconds)
    #expect(dynamic.wakePendingAfterCompletion == retryableOffer)
}

private func dynamicIntegratedTranscript(
    offer: RuntimePipelineOfferResult
) -> IntegratedCycleTranscript {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    let repository = IntegratedRepository()
    let model = makeIntegratedModel(repository: repository)
    let root = DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(capacity: 1)
    var state = State(wrappedValue: model)
    _ = root.beginCandidate()
    _ = root.encounter(
        structuralIdentity: 1,
        declarationOrdinal: 0,
        state: &state,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: IntegratedActionRecords(),
        root: root
    )
    let hooks = IntegratedRootHooks(
        setPhase: { root.setExecutionPhase($0) },
        isDirty: { root.isDirty },
        beginCandidate: { root.beginCandidate() },
        encounterPreserved: {
            var state = State(wrappedValue: model)
            return root.encounter(
                structuralIdentity: 1,
                declarationOrdinal: 0,
                state: &state,
                replacementRoute: { _ in }
            )
        },
        publishCandidate: { root.finishCandidate(.publish) },
        dispatchAction: { dispatcher.dispatch(integratedCapturedAction) }
    )
    return runIntegratedTranscript(
        admission: admission,
        model: model,
        root: hooks,
        offer: offer
    )
}

private func staticIntegratedTranscript(
    offer: RuntimePipelineOfferResult
) -> IntegratedCycleTranscript {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(
        structuralIdentity: 1,
        declarationOrdinal: 0
    )
    var admissionStorage = StaticSignalAnalyzerHostFactAdmissionStorage()
    let repository = IntegratedRepository()
    let model = makeIntegratedModel(repository: repository)

    return withUnsafeMutablePointer(to: &root) { rootPointer in
        withUnsafeMutablePointer(to: &admissionStorage) { admissionPointer in
            _ = rootPointer.pointee.beginCandidate()
            _ = rootPointer.pointee.withEncounter(
                state: State(wrappedValue: model),
                replacementRoute: { _ in },
                reportRoute: { attachment in
                    rootPointer.pointee.acceptReport(attachment)
                },
                body: { _ in () }
            )
            _ = rootPointer.pointee.finishCandidate(.publish)
            var dispatcher = StaticSignalAnalyzerActionDispatcher.make(
                records: IntegratedActionRecords(),
                root: rootPointer
            )
            let hooks = IntegratedRootHooks(
                setPhase: { rootPointer.pointee.setExecutionPhase($0) },
                isDirty: { rootPointer.pointee.isDirty },
                beginCandidate: { rootPointer.pointee.beginCandidate() },
                encounterPreserved: {
                    let result = rootPointer.pointee.withEncounter(
                        state: State(wrappedValue: model),
                        replacementRoute: { _ in },
                        reportRoute: { attachment in
                            rootPointer.pointee.acceptReport(attachment)
                        },
                        body: { _ in () }
                    )
                    switch result {
                    case .bound(let outcome, ()): return outcome
                    case .failure(let failure): return .failure(failure)
                    }
                },
                publishCandidate: {
                    rootPointer.pointee.finishCandidate(.publish)
                },
                dispatchAction: {
                    dispatcher.dispatch(integratedCapturedAction)
                }
            )
            return runIntegratedTranscript(
                admission: StaticSignalAnalyzerHostFactAdmission(
                    storage: admissionPointer
                ),
                model: model,
                root: hooks,
                offer: offer
            )
        }
    }
}

private func runIntegratedTranscript(
    admission: any IntegratedFactAdmission,
    model: SignalAnalyzerViewModel,
    root: IntegratedRootHooks,
    offer: RuntimePipelineOfferResult
) -> IntegratedCycleTranscript {
    var pacing = makeIntegratedPacingController()
    var admissionSequences: [UInt32] = []
    var wakeDirectives: [HostWakeDirective] = []

    #expect(admission.beginProducer(.transition))
    for index in 1 ... 20 {
        let state: AcquisitionState = index.isMultiple(of: 2) ? .stopped : .running
        guard
            case .accepted(let sequence) =
                admission.submit(.acquisitionState(state))
        else {
            Issue.record("integrated admission rejected a conforming fact")
            continue
        }
        admissionSequences.append(sequence)
        guard
            case .success(let directive) =
                pacing.recordAcceptedFact(at: UInt64(index))
        else {
            Issue.record("integrated pacing rejected a conforming fact")
            continue
        }
        wakeDirectives.append(directive)
    }
    admission.endProducer()
    #expect(pacing.beginOpportunity(at: 250_000) == .began(.admittedWork))

    var owner = IntegratedCycleOwner(
        admission: admission,
        model: model,
        root: root,
        offer: offer
    )
    let result = RuntimeCompletePipeline.run(owner: &owner)
    let semanticRevision: SemanticRevision?
    let disposition: RuntimePipelineDisposition?
    switch result {
    case .completed(let completion):
        semanticRevision = completion.publication.semanticRevision
        disposition = completion.disposition
    case .failed:
        semanticRevision = nil
        disposition = nil
    }
    if let disposition, !disposition.wakeReasons.isEmpty {
        _ = pacing.record(disposition.wakeReasons, at: 250_000)
    }
    #expect(pacing.completeOpportunity(at: 250_000) == nil)
    #expect(admission.takeNextSealed() == nil)

    return IntegratedCycleTranscript(
        admissionSequences: admissionSequences,
        wakeDirectives: wakeDirectives,
        stages: owner.stages,
        appliedSequences: owner.appliedSequences,
        dirtyTransitions: owner.dirtyTransitions,
        actionResult: owner.actionResult,
        semanticRevision: semanticRevision,
        drawingStrokeCount: owner.drawingStrokeCount,
        result: result,
        cleanup: owner.cleanupActions,
        wakePendingAfterCompletion: pacing.wakeIsOutstanding,
        finalState: model.state
    )
}

private func makeIntegratedModel(
    repository: IntegratedRepository
) -> SignalAnalyzerViewModel {
    SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private func makeIntegratedPacingController() -> HostWakePacingController {
    HostWakePacingController(
        policy: HostPacingPolicy(
            minimumFrameIntervalMicroseconds: 250_000,
            maximumFactServiceLatencyMicroseconds: 250_000,
            minimumAcceptedTransitionSpacingMicroseconds: 12_500,
            maximumTransitionFactsPerServiceWindow: 20,
            maximumBootstrapFactsPerServiceWindow: 2,
            maximumActionInducedFactsPerServiceWindow: 6,
            maximumRetryableRefusals: 3
        )!,
        initialFrameOriginMicroseconds: 0
    )
}
