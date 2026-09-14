import GiftUIFailureCore
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
