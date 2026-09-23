import GiftUIDisplayCore
import GiftUIHostConfiguration
import GiftUIRuntimeCore

package enum StaticSignalAnalyzerNRFPresentationHealthResult: Equatable, Sendable {
    case noAcceptedOffer
    case unchanged(inputEligible: Bool)
    case transition(HostEndpointHealthTransition)
    case rejected(HostEndpointHealthError)
    case commitHealthMismatch
}

/// Reconciles target-owned health after the synchronous offer has drained.
/// A terminal transition closes input before another opportunity can begin.
package enum StaticSignalAnalyzerNRFPresentationHealth {
    package static func reconcile<Target: DisplayTarget>(
        presentation: StaticSignalAnalyzerNRFPresentationTransactionResult?,
        endpoint: borrowing StaticSignalAnalyzerNRFEndpoint<Target>,
        application: inout StaticSignalAnalyzerNRFApplicationOwner,
        controller: inout HostEndpointHealthController
    ) -> StaticSignalAnalyzerNRFPresentationHealthResult {
        guard case .handoff(.offered(let offer, let resolution)) = presentation,
            offer.disposition == .accepted
        else { return .noAcceptedOffer }

        let transition = controller.consumeAcceptedOffer(
            from: endpoint,
            responsibilityTransferred: endpoint.sink.presentationResponsibilityAccepted,
            streamDrained: endpoint.sink.isIdleForOffer
        )
        switch transition {
        case .success(.unchanged):
            if case .committed = resolution {
                guard controller.enableInputAfterCommittedOffer(from: endpoint) else {
                    application.quiesceInput()
                    _ = controller.requireFreshConstruction(for: .terminalUnavailability)
                    return .commitHealthMismatch
                }
            }
            return .unchanged(inputEligible: controller.inputIsEligible)
        case .success(let change):
            application.quiesceInput()
            return .transition(change)
        case .failure(let error):
            application.quiesceInput()
            return .rejected(error)
        }
    }
}
