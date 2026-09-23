import GiftUIFailureCore
import SignalAnalyzerPresentation

/// The host-facing adapter keeps the accepted portable failure value while
/// the Embedded Swift storage uses its bounded inline representation.
extension StaticSignalAnalyzerNRFCaptureFactAdmission {
    package mutating func admitOperationalFailure(
        _ value: SignalAnalyzerOperationalFailure
    ) -> StaticSignalAnalyzerNRFCaptureAdmissionOutcome {
        admitOperationalFailure(
            conditionRawValue: value.failure.condition.rawValue,
            originRawValue: value.failure.origin.rawValue,
            affectedScopeRawValue: value.failure.affectedScope.rawValue,
            containmentRawValue: value.failure.containment.rawValue,
            diagnostic: value.diagnostic
        )
    }
}

extension StaticSignalAnalyzerNRFOperationalFailureFact {
    package var portableValue: SignalAnalyzerOperationalFailure? {
        guard let origin = GiftUIFailureOrigin(rawValue: originRawValue),
            let scope = GiftUIAffectedScope(rawValue: affectedScopeRawValue),
            let containment = GiftUIContainment(rawValue: containmentRawValue)
        else { return nil }
        return SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: GiftUIConditionID(rawValue: conditionRawValue),
                origin: origin,
                affectedScope: scope,
                containment: containment
            ),
            diagnostic: diagnostic
        )
    }
}
