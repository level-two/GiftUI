import GiftUIExecution
import GiftUIFailureCore
import GiftUIRuntimeCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@testable import GiftUIHostConfiguration

private final class RecordingSignalAnalyzerHostAdmission: SignalAnalyzerFactAdmission {
    private var category: HostFactProducerCategory?
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

    func begin(_ category: HostFactProducerCategory) -> Bool {
        guard self.category == nil else { return false }
        self.category = category
        return true
    }

    func end() {
        category = nil
    }

    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome {
        let outcome: HostFactAdmissionOutcome
        switch fact {
        case .operationalFailure:
            outcome = storage.admitReservedFailure(fact)
        case .captureSnapshot:
            guard let category else { return .rejected(.runtimeUnavailable) }
            outcome = storage.admitSnapshot(fact, category: category)
        case .captureMutation, .acquisitionState:
            guard let category else { return .rejected(.runtimeUnavailable) }
            outcome = storage.admitCompact(fact, category: category)
        }
        return map(outcome)
    }

    func seal() -> Bool { storage.seal() }

    func takeNext() -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)? {
        guard let stored = storage.takeNextSealed() else { return nil }
        return switch stored {
        case .snapshot(let fact): (fact.sequence, .snapshot, fact.value)
        case .compact(let fact): (fact.sequence, .compact, fact.value)
        case .reservedFailure(let fact):
            (fact.sequence, .reservedFailure, fact.value)
        }
    }

    private func map(_ outcome: HostFactAdmissionOutcome) -> SignalSinkDeliveryOutcome {
        switch outcome {
        case .accepted(let sequence): .accepted(sequence: sequence)
        case .rejected(.snapshotCapacityExhausted):
            .rejected(.snapshotCapacityExhausted)
        case .rejected(.sequenceExhausted): .rejected(.sequenceExhausted)
        case .rejected(.unavailable): .rejected(.runtimeUnavailable)
        case .rejected(.compactCapacityExhausted),
            .rejected(.reservedFailureCapacityExhausted),
            .rejected(.producerCategoryExhausted):
            .rejected(.factCapacityExhausted)
        }
    }
}

private struct SignalAnalyzerMutationPipelineOwner: RuntimeCompletePipelineOwner {
    let admission: RecordingSignalAnalyzerHostAdmission
    let model: SignalAnalyzerViewModel
    var deferredAfterSeal: SignalAnalyzerPresentationFact?
    private(set) var appliedFacts: [SignalAnalyzerPresentationFact] = []
    private(set) var finalizationCount = 0
    private var changed = false

    init(
        admission: RecordingSignalAnalyzerHostAdmission,
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
            guard admission.begin(.action) else {
                return .failure(.execution(.reentrancyViolation))
            }
            let outcome = admission.submit(deferredAfterSeal)
            admission.end()
            guard case .accepted = outcome else {
                return .failure(.execution(.invariantViolation))
            }
            self.deferredAfterSeal = nil
        }

        while let (_, _, fact) = admission.takeNext() {
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
    let admission = RecordingSignalAnalyzerHostAdmission()
    #expect(admission.begin(.action))
    let state = SignalAnalyzerPresentationFact.acquisitionState(.running)
    #expect(admission.submit(state) == .accepted(sequence: 1))
    admission.end()

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

    #expect(admission.begin(.bootstrap))
    let snapshot = SignalAnalyzerPresentationFact.captureSnapshot(
        revision: 0,
        capture: .empty()
    )
    #expect(admission.submit(snapshot) == .accepted(sequence: 3))
    admission.end()

    let didSeal = admission.seal()
    #expect(didSeal)
    expectNext(admission, sequence: 1, kind: .compact, fact: state)
    expectNext(admission, sequence: 2, kind: .reservedFailure, fact: failure)
    expectNext(admission, sequence: 3, kind: .snapshot, fact: snapshot)
    #expect(admission.takeNext() == nil)
}

@Test func analyzerClassifierRequiresHostProducerContextForOrdinaryFacts() {
    let admission = RecordingSignalAnalyzerHostAdmission()
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
    let admission = RecordingSignalAnalyzerHostAdmission()
    #expect(admission.begin(.bootstrap))
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
    admission.end()
}

@Test func sealedAnalyzerFactsApplyOnceInsideTheProductionMutationPipeline() {
    let admission = RecordingSignalAnalyzerHostAdmission()
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

    #expect(admission.begin(.bootstrap))
    #expect(admission.submit(snapshot) == .accepted(sequence: 1))
    #expect(admission.submit(running) == .accepted(sequence: 2))
    admission.end()

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
    #expect(admission.takeNext() == nil)
}

private func expectNext(
    _ admission: RecordingSignalAnalyzerHostAdmission,
    sequence: UInt32,
    kind: HostSequencedFactKind,
    fact: SignalAnalyzerPresentationFact
) {
    guard let next = admission.takeNext() else {
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
