import GiftUIFailureCore
import SignalAnalyzerDomain

package enum SignalAnalyzerFailureNormalizer {
    package static func operationalFailure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        switch condition {
        case .captureRevisionExhausted:
            return SignalAnalyzerOperationalFailure(
                failure: fact(.invalidProvenance, .semantic, .component, .safetyNotProven),
                diagnostic: diagnostic
            )
        }
    }

    package static func operationalFailure(
        for rejection: SignalSinkDeliveryRejection,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        let failure: GiftUIFailureFact
        switch rejection {
        case .snapshotCapacityExhausted, .factCapacityExhausted:
            failure = fact(.capacityExhausted, .presentationIntegration, .component, .contained)
        case .runtimeUnavailable:
            failure = fact(.requiredFacilityUnavailable, .execution, .runtime, .safetyNotProven)
        case .sequenceExhausted:
            failure = fact(.invalidProvenance, .presentationIntegration, .runtime, .safetyNotProven)
        }
        return SignalAnalyzerOperationalFailure(failure: failure, diagnostic: diagnostic)
    }

    package static func operationalFailure(
        for condition: SignalAnalyzerRuntimeCondition,
        stableStateProven: Bool,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        let failure: GiftUIFailureFact
        switch condition {
        case .stateLocationCapacityExhausted, .registrationCapacityExhausted:
            failure = fact(.capacityExhausted, .observableState, .component, .contained)
        case .replacementStagingExhausted:
            failure = fact(.capacityExhausted, .observableState, .operation, .contained)
        case .duplicateModelOwner, .incompatibleStateAssociation:
            failure = fact(.invalidIdentity, .observableState, .component, .contained)
        case .staleRegistrationReport:
            failure = fact(.invalidIdentity, .observableState, .operation, .contained)
        case .identityGenerationExhausted:
            failure = fact(.invalidIdentity, .observableState, .runtime, .safetyNotProven)
        case .captureRevisionMismatch:
            failure = fact(.invalidProvenance, .presentationIntegration, .component, .contained)
        case .reservedFailureCapacityExhausted:
            failure = fact(.capacityExhausted, .presentationIntegration, .runtime, .safetyNotProven)
        case .mutationPhaseViolation:
            failure = fact(
                .invalidPhase,
                .observableState,
                .activeCycle,
                stableStateProven ? .contained : .safetyNotProven
            )
        case .observableStateReentrancyViolation:
            failure = fact(.reentrancyViolation, .observableState, .activeCycle, .safetyNotProven)
        case .observableStateInvariantViolation:
            failure = fact(.invariantViolation, .observableState, .runtime, .safetyNotProven)
        }
        return SignalAnalyzerOperationalFailure(failure: failure, diagnostic: diagnostic)
    }

    private static func fact(
        _ condition: GiftUIConditionID,
        _ origin: GiftUIFailureOrigin,
        _ scope: GiftUIAffectedScope,
        _ containment: GiftUIContainment
    ) -> GiftUIFailureFact {
        GiftUIFailureFact(
            condition: condition,
            origin: origin,
            affectedScope: scope,
            containment: containment
        )
    }
}

package struct DefaultSignalAnalyzerOperationalFailureFactory:
    SignalAnalyzerOperationalFailureFactory
{
    package init() {}

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
        SignalAnalyzerFailureNormalizer.operationalFailure(
            for: condition,
            diagnostic: diagnostic
        )
    }

    private func diagnostic(_ text: String) -> SignalAnalyzerDiagnostic {
        SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!
    }
}
