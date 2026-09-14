import GiftUIExecution
import GiftUIHostConfiguration
import SignalAnalyzerDomain
import SignalAnalyzerPresentation

/// Dynamic-target classification and fixed admission storage for Signal Analyzer facts.
package final class DynamicSignalAnalyzerHostFactAdmission: SignalAnalyzerFactAdmission {
    private var activeProducer: HostFactProducerCategory?
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

    package init() {}

    package func beginProducer(_ category: HostFactProducerCategory) -> Bool {
        guard activeProducer == nil else { return false }
        activeProducer = category
        return true
    }

    package func endProducer() {
        activeProducer = nil
    }

    package func submit(
        _ fact: SignalAnalyzerPresentationFact
    ) -> SignalSinkDeliveryOutcome {
        let outcome: HostFactAdmissionOutcome
        switch fact {
        case .captureSnapshot:
            guard let activeProducer else { return .rejected(.runtimeUnavailable) }
            outcome = storage.admitSnapshot(fact, category: activeProducer)
        case .captureMutation, .acquisitionState:
            guard let activeProducer else { return .rejected(.runtimeUnavailable) }
            outcome = storage.admitCompact(fact, category: activeProducer)
        case .operationalFailure:
            outcome = storage.admitReservedFailure(fact)
        }
        return map(outcome)
    }

    package func seal() -> Bool {
        storage.seal()
    }

    package func takeNextSealed()
        -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
    {
        guard let stored = storage.takeNextSealed() else { return nil }
        return switch stored {
        case .snapshot(let fact): (fact.sequence, .snapshot, fact.value)
        case .compact(let fact): (fact.sequence, .compact, fact.value)
        case .reservedFailure(let fact):
            (fact.sequence, .reservedFailure, fact.value)
        }
    }

    package func quiesce() {
        storage.quiesce()
    }

    package func discardAll() {
        activeProducer = nil
        storage.discardAll()
    }

    private func map(
        _ outcome: HostFactAdmissionOutcome
    ) -> SignalSinkDeliveryOutcome {
        switch outcome {
        case .accepted(let sequence): .accepted(sequence: sequence)
        case .rejected(.snapshotCapacityExhausted):
            .rejected(.snapshotCapacityExhausted)
        case .rejected(.sequenceExhausted):
            .rejected(.sequenceExhausted)
        case .rejected(.unavailable):
            .rejected(.runtimeUnavailable)
        case .rejected(.compactCapacityExhausted),
            .rejected(.reservedFailureCapacityExhausted),
            .rejected(.producerCategoryExhausted):
            .rejected(.factCapacityExhausted)
        }
    }
}
