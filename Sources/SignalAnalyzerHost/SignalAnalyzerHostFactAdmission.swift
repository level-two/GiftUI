import GiftUIExecution
import GiftUIHostConfiguration
import SignalAnalyzerDomain
import SignalAnalyzerPresentation

/// Dynamic-target classification and fixed admission storage for Signal Analyzer facts.
package final class DynamicSignalAnalyzerHostFactAdmission: SignalAnalyzerFactAdmission {
    private var core = SignalAnalyzerHostFactAdmissionCore()

    package init() {}

    package func beginProducer(_ category: HostFactProducerCategory) -> Bool {
        core.beginProducer(category)
    }

    package func endProducer() {
        core.endProducer()
    }

    package func submit(
        _ fact: SignalAnalyzerPresentationFact
    ) -> SignalSinkDeliveryOutcome {
        core.submit(fact)
    }

    package func seal() -> Bool {
        core.seal()
    }

    package func takeNextSealed()
        -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
    {
        core.takeNextSealed()
    }

    package func quiesce() {
        core.quiesce()
    }

    package func discardAll() {
        core.discardAll()
    }
}

/// Caller-owned fixed storage used by generated Static analyzer roots.
package struct StaticSignalAnalyzerHostFactAdmissionStorage: ~Copyable {
    fileprivate var core: SignalAnalyzerHostFactAdmissionCore

    package init(nextSequence: UInt32 = 1) {
        core = SignalAnalyzerHostFactAdmissionCore(nextSequence: nextSequence)
    }
}

/// Copyable direct-dispatch handle whose storage lifetime belongs to a Static root.
package struct StaticSignalAnalyzerHostFactAdmission: SignalAnalyzerFactAdmission {
    private let storage: UnsafeMutablePointer<StaticSignalAnalyzerHostFactAdmissionStorage>

    package init(
        storage: UnsafeMutablePointer<StaticSignalAnalyzerHostFactAdmissionStorage>
    ) {
        self.storage = storage
    }

    package func beginProducer(_ category: HostFactProducerCategory) -> Bool {
        storage.pointee.core.beginProducer(category)
    }

    package func endProducer() {
        storage.pointee.core.endProducer()
    }

    package func submit(
        _ fact: SignalAnalyzerPresentationFact
    ) -> SignalSinkDeliveryOutcome {
        storage.pointee.core.submit(fact)
    }

    package func seal() -> Bool {
        storage.pointee.core.seal()
    }

    package func takeNextSealed()
        -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
    {
        storage.pointee.core.takeNextSealed()
    }

    package func quiesce() {
        storage.pointee.core.quiesce()
    }

    package func discardAll() {
        storage.pointee.core.discardAll()
    }
}

private struct SignalAnalyzerHostFactAdmissionCore: ~Copyable {
    private var activeProducer: HostFactProducerCategory?
    private var storage:
        HostSequencedFactAdmission<
            SignalAnalyzerPresentationFact,
            SignalAnalyzerPresentationFact,
            SignalAnalyzerPresentationFact
        >

    init(nextSequence: UInt32 = 1) {
        storage = HostSequencedFactAdmission(
            producerLimits: HostFactProducerLimits(
                transition: 20,
                bootstrap: 2,
                action: 6
            )!,
            nextSequence: nextSequence
        )!
    }

    mutating func beginProducer(_ category: HostFactProducerCategory) -> Bool {
        guard activeProducer == nil else { return false }
        activeProducer = category
        return true
    }

    mutating func endProducer() {
        activeProducer = nil
    }

    mutating func submit(
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

    mutating func seal() -> Bool {
        storage.seal()
    }

    mutating func takeNextSealed()
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

    mutating func quiesce() {
        storage.quiesce()
    }

    mutating func discardAll() {
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
