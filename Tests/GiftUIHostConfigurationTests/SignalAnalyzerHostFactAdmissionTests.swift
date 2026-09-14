import GiftUI
import GiftUIExecution
import GiftUIFailureCore
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation
import Testing

@testable import GiftUIHostConfiguration

private struct SignalAnalyzerMutationPipelineOwner: RuntimeCompletePipelineOwner {
    let admission: DynamicSignalAnalyzerHostFactAdmission
    let model: SignalAnalyzerViewModel
    let observableRoot: DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
    var deferredAfterSeal: SignalAnalyzerPresentationFact?
    private(set) var appliedFacts: [SignalAnalyzerPresentationFact] = []
    private(set) var dirtyTransitionCount = 0
    private(set) var publishedStates: [SignalAnalyzerViewState] = []
    private(set) var finalizationCount = 0
    private var changed = false

    init(
        admission: DynamicSignalAnalyzerHostFactAdmission,
        model: SignalAnalyzerViewModel,
        observableRoot: DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt32>,
        deferredAfterSeal: SignalAnalyzerPresentationFact?
    ) {
        self.admission = admission
        self.model = model
        self.observableRoot = observableRoot
        self.deferredAfterSeal = deferredAfterSeal
    }

    mutating func admitAndSeal() -> RuntimePipelineStepResult {
        admission.seal() ? .advanced : .failure(.execution(.requiredFacilityUnavailable))
    }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult {
        observableRoot.setExecutionPhase(.mutating)
        if let deferredAfterSeal {
            guard admission.beginProducer(.action) else {
                return .failure(.execution(.reentrancyViolation))
            }
            let outcome = admission.submit(deferredAfterSeal)
            admission.endProducer()
            guard case .accepted = outcome else {
                return .failure(.execution(.invariantViolation))
            }
            self.deferredAfterSeal = nil
        }

        while let (_, _, fact) = admission.takeNextSealed() {
            appliedFacts.append(fact)
            let wasDirty = observableRoot.isDirty
            switch model.apply(fact) {
            case .applied(let factChanged):
                changed = changed || factChanged
                if !wasDirty, observableRoot.isDirty {
                    dirtyTransitionCount += 1
                }
            case .rejected: return .failure(.execution(.invariantViolation))
            }
        }
        return .applied(changed)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult {
        observableRoot.setExecutionPhase(.deriving)
        return .advanced
    }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult {
        guard observableRoot.beginCandidate() == .success(.candidateStarted) else {
            return .failure(.execution(.invariantViolation))
        }
        var state = State(wrappedValue: model)
        switch observableRoot.encounter(
            structuralIdentity: 0x5341_0100,
            declarationOrdinal: 0,
            state: &state,
            replacementRoute: { _ in }
        ) {
        case .success(.preserved):
            return .advanced
        case .failure(let failure):
            _ = observableRoot.finishCandidate(.discard)
            return .failure(.focusedOwner(.observableState(failure)))
        case .success:
            _ = observableRoot.finishCandidate(.discard)
            return .failure(.execution(.invariantViolation))
        }
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult { .advanced }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult { .advanced }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult { .advanced }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult { .advanced }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult {
        observableRoot.setExecutionPhase(.publishing)
        guard case .success = observableRoot.finishCandidate(.publish) else {
            return .failure(.execution(.invariantViolation))
        }
        publishedStates.append(model.state)
        return .published(
            RuntimePipelinePublication(
                semanticRevision: SemanticRevision(rawValue: 1),
                changed: changed
            )
        )
    }

    mutating func allocateCandidate() -> RuntimePipelineStepResult { .advanced }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult { .backpressured }
    mutating func cleanup(_ action: RuntimeCleanupAction) {}
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {}
    mutating func finalizePipeline() {
        observableRoot.setExecutionPhase(.idle)
        finalizationCount += 1
    }
}

private protocol AnalyzerFactAdmissionTestEndpoint: SignalAnalyzerFactAdmission {
    func beginProducer(_ category: HostFactProducerCategory) -> Bool
    func endProducer()
    func seal() -> Bool
    func takeNextSealed()
        -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
}

extension DynamicSignalAnalyzerHostFactAdmission: AnalyzerFactAdmissionTestEndpoint {}
extension StaticSignalAnalyzerHostFactAdmission: AnalyzerFactAdmissionTestEndpoint {}

private struct FactAdmissionTranscript: Equatable {
    let outcomes: [SignalSinkDeliveryOutcome]
    let sequences: [UInt32]
    let kinds: [HostSequencedFactKind]
    let facts: [SignalAnalyzerPresentationFact]
}

@Test func analyzerClassifierMapsAllFactFamiliesIntoIndependentStores() {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    #expect(admission.beginProducer(.action))
    let state = SignalAnalyzerPresentationFact.acquisitionState(.running)
    #expect(admission.submit(state) == .accepted(sequence: 1))
    admission.endProducer()

    let failure = SignalAnalyzerPresentationFact.operationalFailure(
        SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .invalidValue,
                origin: .presentationIntegration,
                affectedScope: .component,
                containment: .contained
            ),
            diagnostic: SignalAnalyzerDiagnostic(exactUTF8: Array("failure".utf8))!
        )
    )
    #expect(admission.submit(failure) == .accepted(sequence: 2))

    #expect(admission.beginProducer(.bootstrap))
    let snapshot = SignalAnalyzerPresentationFact.captureSnapshot(
        revision: 0,
        capture: .empty()
    )
    #expect(admission.submit(snapshot) == .accepted(sequence: 3))
    admission.endProducer()

    let didSeal = admission.seal()
    #expect(didSeal)
    expectNext(admission, sequence: 1, kind: .compact, fact: state)
    expectNext(admission, sequence: 2, kind: .reservedFailure, fact: failure)
    expectNext(admission, sequence: 3, kind: .snapshot, fact: snapshot)
    #expect(admission.takeNextSealed() == nil)
}

@Test func analyzerClassifierRequiresHostProducerContextForOrdinaryFacts() {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    #expect(
        admission.submit(.acquisitionState(.idle))
            == .rejected(.runtimeUnavailable)
    )
    #expect(
        admission.submit(.captureSnapshot(revision: 0, capture: .empty()))
            == .rejected(.runtimeUnavailable)
    )
}

@Test func analyzerClassifierPreservesExactApplicationRejectionVocabulary() {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    #expect(admission.beginProducer(.bootstrap))
    #expect(
        admission.submit(.captureSnapshot(revision: 0, capture: .empty()))
            == .accepted(sequence: 1)
    )
    #expect(
        admission.submit(.captureSnapshot(revision: 0, capture: .empty()))
            == .rejected(.snapshotCapacityExhausted)
    )
    #expect(admission.submit(.acquisitionState(.idle)) == .accepted(sequence: 2))
    #expect(
        admission.submit(.acquisitionState(.running))
            == .rejected(.factCapacityExhausted)
    )
    admission.endProducer()
}

@Test func dynamicAndStaticAnalyzerAdmissionProduceEqualOrderedTranscripts() {
    let dynamic = runFactAdmissionTranscript(
        endpoint: DynamicSignalAnalyzerHostFactAdmission()
    )
    var storage = StaticSignalAnalyzerHostFactAdmissionStorage()
    let fixed = withUnsafeMutablePointer(to: &storage) {
        runFactAdmissionTranscript(
            endpoint: StaticSignalAnalyzerHostFactAdmission(storage: $0)
        )
    }

    #expect(dynamic == fixed)
    #expect(
        dynamic.outcomes == [
            .accepted(sequence: 1),
            .accepted(sequence: 2),
            .accepted(sequence: 3),
        ]
    )
    #expect(dynamic.sequences == [1, 2, 3])
    #expect(dynamic.kinds == [.compact, .reservedFailure, .snapshot])
}

@Test func sealedAnalyzerFactsApplyOnceInsideTheProductionMutationPipeline() {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    let model = makeMutationModel()
    let observableRoot = makeObservableRoot(model)
    let transition = SignalTransition(
        channelID: SignalChannelID(rawValue: 1),
        timestamp: .milliseconds(10),
        level: .high
    )
    let capture = SignalCapture(
        transitions: [transition],
        duration: .milliseconds(10)
    )!
    let snapshot = SignalAnalyzerPresentationFact.captureSnapshot(
        revision: 1,
        capture: capture
    )
    let running = SignalAnalyzerPresentationFact.acquisitionState(.running)
    let deferred = SignalAnalyzerPresentationFact.acquisitionState(.stopped)

    #expect(admission.beginProducer(.bootstrap))
    #expect(admission.submit(snapshot) == .accepted(sequence: 1))
    #expect(admission.submit(running) == .accepted(sequence: 2))
    admission.endProducer()

    var first = SignalAnalyzerMutationPipelineOwner(
        admission: admission,
        model: model,
        observableRoot: observableRoot,
        deferredAfterSeal: deferred
    )
    let firstResult = RuntimeCompletePipeline.run(owner: &first)
    guard case .completed(let firstCompletion) = firstResult else {
        Issue.record("expected the first analyzer mutation opportunity to complete")
        return
    }
    #expect(first.appliedFacts == [snapshot, running])
    #expect(first.finalizationCount == 1)
    #expect(firstCompletion.publication.changed)
    #expect(model.captureRevision == 1)
    #expect(model.state.capture == capture)
    #expect(model.state.acquisitionState == .running)

    var second = SignalAnalyzerMutationPipelineOwner(
        admission: admission,
        model: model,
        observableRoot: observableRoot,
        deferredAfterSeal: nil
    )
    let secondResult = RuntimeCompletePipeline.run(owner: &second)
    guard case .completed(let secondCompletion) = secondResult else {
        Issue.record("expected the deferred analyzer mutation opportunity to complete")
        return
    }
    #expect(second.appliedFacts == [deferred])
    #expect(second.finalizationCount == 1)
    #expect(secondCompletion.publication.changed)
    #expect(model.state.acquisitionState == .stopped)
    #expect(admission.takeNextSealed() == nil)
}

@Test func twentyAnalyzerFactsBecomeOneDirtyTransitionAndOneCompletePublication() {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    let model = makeMutationModel()
    let observableRoot = makeObservableRoot(model)
    var pacing = makeFactPacingController()
    var wakeCount = 0

    #expect(admission.beginProducer(.transition))
    for index in 1 ... 20 {
        let state: AcquisitionState = index.isMultiple(of: 2) ? .stopped : .running
        #expect(admission.submit(.acquisitionState(state)) == .accepted(sequence: UInt32(index)))
        if pacing.recordAcceptedFact(at: UInt64(index)) == .success(.requestWake) {
            wakeCount += 1
        }
    }
    admission.endProducer()

    #expect(wakeCount == 1)
    #expect(observableRoot.isDirty == false)
    #expect(pacing.schedule(at: 249_999) == .wait(untilMicroseconds: 250_000))
    #expect(pacing.beginOpportunity(at: 250_000) == .began(.admittedWork))

    var owner = SignalAnalyzerMutationPipelineOwner(
        admission: admission,
        model: model,
        observableRoot: observableRoot,
        deferredAfterSeal: nil
    )
    let result = RuntimeCompletePipeline.run(owner: &owner)
    #expect(pacing.completeOpportunity(at: 250_000) == nil)

    guard case .completed(let completion) = result else {
        Issue.record("expected the twenty-fact analyzer opportunity to complete")
        return
    }
    #expect(owner.appliedFacts.count == 20)
    #expect(owner.dirtyTransitionCount == 1)
    #expect(owner.publishedStates == [model.state])
    #expect(owner.finalizationCount == 1)
    #expect(completion.publication.changed)
    #expect(completion.publication.semanticRevision == SemanticRevision(rawValue: 1))
    #expect(model.state.acquisitionState == .stopped)
    #expect(!observableRoot.isDirty)
    #expect(pacing.accumulatedReasons.isEmpty)
}

private func expectNext(
    _ admission: DynamicSignalAnalyzerHostFactAdmission,
    sequence: UInt32,
    kind: HostSequencedFactKind,
    fact: SignalAnalyzerPresentationFact
) {
    guard let next = admission.takeNextSealed() else {
        Issue.record("expected sealed analyzer fact")
        return
    }
    #expect(next.0 == sequence)
    #expect(next.1 == kind)
    #expect(next.2 == fact)
}

private func runFactAdmissionTranscript<Endpoint>(
    endpoint: Endpoint
) -> FactAdmissionTranscript where Endpoint: AnalyzerFactAdmissionTestEndpoint {
    let state = SignalAnalyzerPresentationFact.acquisitionState(.running)
    let failure = SignalAnalyzerPresentationFact.operationalFailure(
        SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .invalidValue,
                origin: .presentationIntegration,
                affectedScope: .component,
                containment: .contained
            ),
            diagnostic: SignalAnalyzerDiagnostic(exactUTF8: Array("failure".utf8))!
        )
    )
    let snapshot = SignalAnalyzerPresentationFact.captureSnapshot(
        revision: 0,
        capture: .empty()
    )
    var outcomes: [SignalSinkDeliveryOutcome] = []
    #expect(endpoint.beginProducer(.action))
    outcomes.append(endpoint.submit(state))
    endpoint.endProducer()
    outcomes.append(endpoint.submit(failure))
    #expect(endpoint.beginProducer(.bootstrap))
    outcomes.append(endpoint.submit(snapshot))
    endpoint.endProducer()
    #expect(endpoint.seal())

    var sequences: [UInt32] = []
    var kinds: [HostSequencedFactKind] = []
    var facts: [SignalAnalyzerPresentationFact] = []
    while let next = endpoint.takeNextSealed() {
        sequences.append(next.0)
        kinds.append(next.1)
        facts.append(next.2)
    }
    return FactAdmissionTranscript(
        outcomes: outcomes,
        sequences: sequences,
        kinds: kinds,
        facts: facts
    )
}

private final class MutationRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}

private func makeMutationModel() -> SignalAnalyzerViewModel {
    let repository = MutationRepository()
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private func makeObservableRoot(
    _ model: SignalAnalyzerViewModel
) -> DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt32> {
    let root = DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt32>(capacity: 1)
    var state = State(wrappedValue: model)
    #expect(root.beginCandidate() == .success(.candidateStarted))
    #expect(
        root.encounter(
            structuralIdentity: 0x5341_0100,
            declarationOrdinal: 0,
            state: &state,
            replacementRoute: { _ in }
        ) == .success(.materialized)
    )
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    return root
}

private func makeFactPacingController() -> HostWakePacingController {
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
