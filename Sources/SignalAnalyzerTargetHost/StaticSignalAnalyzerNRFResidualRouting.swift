import GiftUIHostConfiguration

package enum StaticSignalAnalyzerNRFResidualRoutingResult: Equatable, Sendable {
    case noBackendFailure
    case routed(HostResidualRouteResult)
    case containmentRequired
}

/// Routes only a completed backend failure after the health owner has drained
/// the stream, updated health, and quiesced input. Other outcomes retain their
/// own failure or recovery disposition.
package enum StaticSignalAnalyzerNRFResidualRouting {
    package static func route<
        Table: MVPHostResidualPolicyTable,
        Policy: MVPHostResidualPolicy,
        InvariantOwner: MVPHostInvariantFailureOwner,
        FatalHook: MVPHostFatalHook,
        Diagnostic: MVPHostDiagnosticProjection
    >(
        _ result: StaticSignalAnalyzerNRFPacedPresentationResult,
        table: borrowing Table,
        policy: inout Policy,
        invariantOwner: inout InvariantOwner,
        fatalHook: inout FatalHook,
        diagnostic: inout Diagnostic
    ) -> StaticSignalAnalyzerNRFResidualRoutingResult {
        guard case .completed(_, _, _, let health) = result else {
            return .noBackendFailure
        }
        switch health {
        case .transition(let transition):
            guard let request = transition.residualRouteRequest() else {
                return .containmentRequired
            }
            return .routed(
                HostResidualFailureRouting.route(
                    request,
                    table: table,
                    policy: &policy,
                    invariantOwner: &invariantOwner,
                    fatalHook: &fatalHook,
                    diagnostic: &diagnostic
                )
            )
        case .noAcceptedOffer, .unchanged:
            return .noBackendFailure
        case .rejected, .commitHealthMismatch:
            return .containmentRequired
        }
    }
}
