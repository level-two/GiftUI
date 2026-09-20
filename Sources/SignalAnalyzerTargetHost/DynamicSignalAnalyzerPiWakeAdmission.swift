import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation

/// Adds host wake notification after, and only after, production fact admission.
package final class DynamicSignalAnalyzerPiWakeAdmission: SignalAnalyzerFactAdmission {
    private let base: DynamicSignalAnalyzerHostFactAdmission
    private let recordAcceptedFact: () -> Void

    package init(
        base: DynamicSignalAnalyzerHostFactAdmission,
        recordAcceptedFact: @escaping () -> Void
    ) {
        self.base = base
        self.recordAcceptedFact = recordAcceptedFact
    }

    package func submit(
        _ fact: SignalAnalyzerPresentationFact
    ) -> SignalSinkDeliveryOutcome {
        let outcome = base.submit(fact)
        if case .accepted = outcome { recordAcceptedFact() }
        return outcome
    }
}
