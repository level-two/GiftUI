import GiftUIFailureCore
import SignalAnalyzerDomain

package final class SignalAnalyzerOwnerFailureAdapter<Effects>:
    SignalAnalyzerOperationalFailureFactory
where Effects: SignalAnalyzerMandatoryEffectSink {
    private let effects: Effects
    private let stopAcquisition: StopSignalAcquisitionUseCase
    private var policy = SignalAnalyzerResidualFailurePolicy()
    package private(set) var lastDisposition: GiftUIResidualDisposition?
    package private(set) var policyCallCount: UInt8 = 0
    package private(set) var lastPolicyContext: SignalAnalyzerResidualPolicyContext?
    package private(set) var lastAllowedDispositions: GiftUIAllowedDispositions?

    package init(effects: Effects, stopAcquisition: StopSignalAcquisitionUseCase) {
        self.effects = effects
        self.stopAcquisition = stopAcquisition
    }

    package func failure(
        for rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure {
        _ = context
        return SignalAnalyzerFailureNormalizer.operationalFailure(
            for: rejection,
            diagnostic: diagnostic("signal fact admission rejected")
        )
    }

    package func failure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        SignalAnalyzerFailureNormalizer.operationalFailure(for: condition, diagnostic: diagnostic)
    }

    package func completeAdmissionFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        apply(.rejectWithoutOverwrite, .reservedFailureAttempted)
        if context == .observationStart {
            effects.apply(.detachObservation)
        } else {
            effects.apply(.stopAcquisitionDelivery)
            stopAcquisition.execute()
        }

        let allowed: GiftUIAllowedDispositions
        switch rejection {
        case .snapshotCapacityExhausted, .factCapacityExhausted:
            allowed = [.quiesceAffectedScope]
        case .runtimeUnavailable, .sequenceExhausted:
            apply(.preserveLastCompleteRevision, .preventNormalCycle, .requireFreshGraph)
            allowed = [.quiesceAffectedScope, .invokeFatalHook]
        }
        if case .rejected = reservedOutcome {
            apply(.preserveLastCompleteRevision, .preventNormalCycle, .requireFreshGraph)
            let reservedFailure = SignalAnalyzerFailureNormalizer.operationalFailure(
                for: .reservedFailureCapacityExhausted,
                stableStateProven: false,
                diagnostic: failure.diagnostic
            )
            offer(
                reservedFailure.failure,
                context: context,
                allowed: [.quiesceAffectedScope, .invokeFatalHook]
            )
            return
        }
        offer(failure.failure, context: context, allowed: allowed)
    }

    package func completeRepositoryFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        condition: SignalAnalyzerRepositoryCondition,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        _ = failure
        _ = condition
        _ = reservedOutcome
        apply(.rejectWithoutOverwrite, .stopAcquisitionDelivery)
        stopAcquisition.execute()
        apply(
            .reservedFailureAttempted,
            .detachObservation,
            .quiesceAffectedScope,
            .requireFreshGraph
        )
        lastDisposition = nil
    }

    package func handleRuntimeFailure(
        _ condition: SignalAnalyzerRuntimeCondition,
        context: SignalAnalyzerResidualPolicyContext,
        stableStateProven: Bool,
        existingLiveModel: Bool,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        let failure = SignalAnalyzerFailureNormalizer.operationalFailure(
            for: condition,
            stableStateProven: stableStateProven,
            diagnostic: diagnostic
        )
        let rule = SignalAnalyzerRuntimeFailureRule.evaluate(
            condition,
            context: context, stableStateProven: stableStateProven,
            existingLiveModel: existingLiveModel)
        var effectIndex: UInt8 = 0
        while let effect = rule.effect(at: effectIndex) {
            effects.apply(effect)
            effectIndex += 1
        }
        if let allowed = rule.allowed {
            offer(failure.failure, context: context, allowed: allowed)
        } else {
            lastDisposition = nil
        }
        return failure
    }

    private func offer(
        _ failure: GiftUIFailureFact,
        context: SignalAnalyzerResidualPolicyContext,
        allowed: GiftUIAllowedDispositions
    ) {
        guard
            let input = GiftUIResidualPolicyInput(
                outcome: GiftUIOutcome<Void>.failure(failure),
                context: context,
                allowed: allowed,
                attemptOrdinal: 0,
                attemptLimit: 1
            )
        else {
            apply(.quiesceRuntimeHealth, .preventNormalCycle)
            lastDisposition = nil
            return
        }
        policyCallCount += 1
        lastPolicyContext = context
        lastAllowedDispositions = allowed
        let disposition = policy.disposition(for: input)
        let selected = GiftUIAllowedDispositions(rawValue: 1 << disposition.rawValue)
        guard allowed.contains(selected) else {
            apply(.quiesceRuntimeHealth, .preventNormalCycle)
            lastDisposition = nil
            return
        }
        if disposition == .quiesceAffectedScope { effects.apply(.quiesceAffectedScope) }
        lastDisposition = disposition
    }

    private func apply(_ values: SignalAnalyzerMandatoryEffect...) {
        for value in values { effects.apply(value) }
    }

    private func diagnostic(_ text: String) -> SignalAnalyzerDiagnostic {
        SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!
    }
}
