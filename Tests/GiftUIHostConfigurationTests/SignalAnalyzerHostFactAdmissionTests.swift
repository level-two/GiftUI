import GiftUIExecution
import GiftUIFailureCore
import GiftUIRuntimeCore
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation
import Testing

@testable import GiftUIHostConfiguration

private struct SignalAnalyzerMutationPipelineOwner: RuntimeCompletePipelineOwner {
    let admission: DynamicSignalAnalyzerHostFactAdmission
    let model: SignalAnalyzerViewModel
    var deferredAfterSeal: SignalAnalyzerPresentationFact?
    private(set) var appliedFacts: [SignalAnalyzerPresentationFact] = []
    private(set) var finalizationCount = 0
    private var changed = false

    init(
        admission: DynamicSignalAnalyzerHostFactAdmission,
        model: SignalAnalyzerViewModel,
        deferredAfterSeal: SignalAnalyzerPresentationFact?
    ) {
        self.admission = admission
        self.model = model
        self.deferredAfterSeal = deferredAfterSeal
    }

    mutating func admitAndSeal() -> RuntimePipelineStepResult {
        admission.seal() ? .advanced : .failure(.execution(.requiredFacilityUnavailable))
    }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult {
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
            switch model.apply(fact) {
            case .applied(let factChanged): changed = changed || factChanged
            case .rejected: return .failure(.execution(.invariantViolation))
            }
        }
        return .applied(changed)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult { .advanced }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult {
        .advanced
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult { .advanced }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult { .advanced }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult { .advanced }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult { .advanced }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult {
        .published(
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
    mutating func finalizePipeline() { finalizationCount += 1 }
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

@Test func sealedAnalyzerFactsApplyOnceInsideTheProductionMutationPipeline() {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    let model = makeMutationModel()
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
