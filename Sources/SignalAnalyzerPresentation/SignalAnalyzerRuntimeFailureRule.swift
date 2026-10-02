import GiftUIFailureCore

/// The fixed runtime rejection rule shared by class and caller-owned realizations.
package struct SignalAnalyzerRuntimeFailureRule {
    private let effectSequence: UInt32
    package let allowed: GiftUIAllowedDispositions?

    package func effect(at index: UInt8) -> SignalAnalyzerMandatoryEffect? {
        guard index < 4 else { return nil }
        return SignalAnalyzerMandatoryEffect(rawValue: UInt8((effectSequence >> (index * 4)) & 15))
    }

    package var effectBits: UInt16 {
        var result: UInt16 = 0
        var index: UInt8 = 0
        while let effect = effect(at: index) {
            result |= 1 << effect.rawValue
            index += 1
        }
        return result
    }

    package func contains(_ effect: SignalAnalyzerMandatoryEffect) -> Bool {
        effectBits & (1 << effect.rawValue) != 0
    }

    private static func sequence(
        _ a: SignalAnalyzerMandatoryEffect,
        _ b: SignalAnalyzerMandatoryEffect? = nil,
        _ c: SignalAnalyzerMandatoryEffect? = nil,
        _ d: SignalAnalyzerMandatoryEffect? = nil
    ) -> UInt32 {
        UInt32(a.rawValue) | UInt32(b?.rawValue ?? 15) << 4
            | UInt32(c?.rawValue ?? 15) << 8 | UInt32(d?.rawValue ?? 15) << 12
    }

    package static func evaluate(
        _ condition: SignalAnalyzerRuntimeCondition,
        context: SignalAnalyzerResidualPolicyContext,
        stableStateProven: Bool,
        existingLiveModel: Bool
    ) -> Self {
        let ordered: UInt32
        let allowed: GiftUIAllowedDispositions?
        switch condition {
        case .mutationPhaseViolation where stableStateProven:
            ordered = sequence(.preserveLastCompleteRevision, .schedulePacedRetry)
            allowed = nil
        case .stateLocationCapacityExhausted, .registrationCapacityExhausted:
            if context == .initialModelAttachment {
                ordered = sequence(.removePartialCandidate)
                allowed = [.quiesceAffectedScope, .invokeFatalHook]
            } else {
                ordered = sequence(.removePartialCandidate, .preserveExistingModel)
                allowed = [.continueOperation, .quiesceAffectedScope]
            }
        case .replacementStagingExhausted, .duplicateModelOwner, .incompatibleStateAssociation:
            if existingLiveModel {
                ordered = sequence(.removePartialCandidate, .preserveExistingModel)
                allowed = [.continueOperation, .quiesceAffectedScope]
            } else {
                ordered = sequence(.removePartialCandidate)
                allowed = [.quiesceAffectedScope, .invokeFatalHook]
            }
        case .staleRegistrationReport:
            ordered = sequence(.preserveLastCompleteRevision)
            allowed = [.continueOperation]
        case .captureRevisionMismatch:
            ordered = sequence(
                .preserveLastCompleteRevision, .markPresentationFailed,
                .detachObservation, .requireFreshGraph)
            allowed = [.quiesceAffectedScope]
        case .identityGenerationExhausted, .reservedFailureCapacityExhausted:
            ordered = sequence(
                .preserveLastCompleteRevision, .preventNormalCycle,
                .requireFreshGraph)
            allowed = [.quiesceAffectedScope, .invokeFatalHook]
        case .mutationPhaseViolation, .observableStateReentrancyViolation,
            .observableStateInvariantViolation:
            ordered = sequence(
                .discardPartialPublication, .quiesceRuntimeHealth,
                .preventNormalCycle)
            allowed = [.quiesceAffectedScope, .invokeFatalHook]
        }
        return Self(effectSequence: ordered, allowed: allowed)
    }
}
