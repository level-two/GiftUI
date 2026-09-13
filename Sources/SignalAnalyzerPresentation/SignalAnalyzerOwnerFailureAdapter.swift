import GiftUIFailureCore
import SignalAnalyzerDomain

package enum SignalAnalyzerMandatoryEffect: UInt8, Equatable, Sendable {
    case rejectWithoutOverwrite
    case reservedFailureAttempted
    case detachObservation
    case stopAcquisitionDelivery
    case preserveLastCompleteRevision
    case removePartialCandidate
    case preserveExistingModel
    case markPresentationFailed
    case schedulePacedRetry
    case discardPartialPublication
    case preventNormalCycle
    case requireFreshGraph
    case quiesceAffectedScope
    case quiesceRuntimeHealth
}

package protocol SignalAnalyzerMandatoryEffectSink {
    func apply(_ effect: SignalAnalyzerMandatoryEffect)
}

package struct SignalAnalyzerResidualFailurePolicy: GiftUIResidualFailurePolicy {
    package init() {}

    package mutating func disposition(
        for input: GiftUIResidualPolicyInput<SignalAnalyzerResidualPolicyContext>
    ) -> GiftUIResidualDisposition {
        if input.allowed.contains(.continueOperation),
            input.context == .modelReplacement || input.context == .modelChangeReport
        {
            return .continueOperation
        }
        return .quiesceAffectedScope
    }
}

package final class SignalAnalyzerOwnerFailureAdapter<Effects>:
    SignalAnalyzerOperationalFailureFactory
where Effects: SignalAnalyzerMandatoryEffectSink {
    private let effects: Effects
    private let stopAcquisition: StopSignalAcquisitionUseCase
    private var policy = SignalAnalyzerResidualFailurePolicy()
    package private(set) var lastDisposition: GiftUIResidualDisposition?

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
        switch condition {
        case .mutationPhaseViolation where stableStateProven:
            apply(.preserveLastCompleteRevision, .schedulePacedRetry)
            lastDisposition = nil
        case .stateLocationCapacityExhausted, .registrationCapacityExhausted:
            if context == .initialModelAttachment {
                effects.apply(.removePartialCandidate)
                offer(
                    failure.failure, context: context,
                    allowed: [.quiesceAffectedScope, .invokeFatalHook])
            } else {
                apply(.removePartialCandidate, .preserveExistingModel)
                offer(
                    failure.failure, context: context,
                    allowed: [.continueOperation, .quiesceAffectedScope])
            }
        case .replacementStagingExhausted, .duplicateModelOwner, .incompatibleStateAssociation:
            if existingLiveModel {
                apply(.removePartialCandidate, .preserveExistingModel)
                offer(
                    failure.failure, context: context,
                    allowed: [.continueOperation, .quiesceAffectedScope])
            } else {
                effects.apply(.removePartialCandidate)
                offer(
                    failure.failure, context: context,
                    allowed: [.quiesceAffectedScope, .invokeFatalHook])
            }
        case .staleRegistrationReport:
            effects.apply(.preserveLastCompleteRevision)
            offer(failure.failure, context: context, allowed: [.continueOperation])
        case .captureRevisionMismatch:
            apply(
                .preserveLastCompleteRevision, .markPresentationFailed, .detachObservation,
                .requireFreshGraph)
            offer(failure.failure, context: context, allowed: [.quiesceAffectedScope])
        case .identityGenerationExhausted, .reservedFailureCapacityExhausted:
            apply(.preserveLastCompleteRevision, .preventNormalCycle, .requireFreshGraph)
            offer(
                failure.failure, context: context,
                allowed: [.quiesceAffectedScope, .invokeFatalHook])
        case .mutationPhaseViolation, .observableStateReentrancyViolation,
            .observableStateInvariantViolation:
            apply(.discardPartialPublication, .quiesceRuntimeHealth, .preventNormalCycle)
            offer(
                failure.failure, context: context,
                allowed: [.quiesceAffectedScope, .invokeFatalHook])
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
