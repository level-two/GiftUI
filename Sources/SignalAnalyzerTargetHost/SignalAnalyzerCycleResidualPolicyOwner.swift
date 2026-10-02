import GiftUIFailureCore
import GiftUIHostConfiguration

private struct SignalAnalyzerCyclePolicyTable: MVPHostResidualPolicyTable {
    var fatalHookIsAvailable: Bool { false }
    func allowed(for context: HostResidualPolicyContext) -> GiftUIAllowedDispositions {
        HostResidualPolicyTableValidation.expectedRow(for: context).allowed
    }
    func selection(for context: HostResidualPolicyContext) -> GiftUIResidualDisposition {
        HostResidualPolicyTableValidation.expectedRow(for: context).selection
    }
}

private struct SignalAnalyzerCyclePolicy: MVPHostResidualPolicy {
    mutating func disposition(for input: GiftUIResidualPolicyInput<HostResidualPolicyContext>)
        -> GiftUIResidualDisposition
    {
        HostResidualPolicyTableValidation.expectedRow(for: input.context).selection
    }
}

private struct SignalAnalyzerCycleInvariantOwner: MVPHostInvariantFailureOwner {
    private(set) var preventsNormalCycle = false
    mutating func preventNormalRunCycle() { preventsNormalCycle = true }
    mutating func quiesceRuntimeHealth(with fact: GiftUIFailureFact) { preventsNormalCycle = true }
    mutating func propagateInvariantFailure(_ fact: GiftUIFailureFact) {
        preventsNormalCycle = true
    }
}

private struct SignalAnalyzerCycleFatalHook: MVPHostFatalHook {
    mutating func invoke() {}
}

private struct SignalAnalyzerCycleNoDiagnostic: MVPHostDiagnosticProjection {
    mutating func project(
        context: HostResidualPolicyContext, disposition: GiftUIResidualDisposition
    ) -> Bool { false }
}

/// Retains one policy record; diagnostic capacity has no effect on the decision.
package struct SignalAnalyzerCycleResidualPolicyOwner {
    package private(set) var lastFact: GiftUIFailureFact?
    package private(set) var lastContext: HostResidualPolicyContext?
    package private(set) var lastResult: HostResidualRouteResult?
    package private(set) var callCount: UInt32 = 0
    package private(set) var preventsNormalCycle = false

    package mutating func noPolicy(_ reason: HostNoPolicyReason) {
        lastFact = nil
        lastContext = nil
        lastResult = HostResidualFailureRouting.noPolicyCall(reason)
    }

    package mutating func route(_ request: HostResidualRouteRequest) {
        var policy = SignalAnalyzerCyclePolicy()
        var invariant = SignalAnalyzerCycleInvariantOwner()
        var fatal = SignalAnalyzerCycleFatalHook()
        var diagnostic = SignalAnalyzerCycleNoDiagnostic()
        lastContext = request.context
        if case .failure(let fact) = request.outcome { lastFact = fact } else { lastFact = nil }
        lastResult = HostResidualFailureRouting.route(
            request, table: SignalAnalyzerCyclePolicyTable(),
            policy: &policy, invariantOwner: &invariant, fatalHook: &fatal, diagnostic: &diagnostic)
        if callCount < UInt32.max { callCount += 1 }
        preventsNormalCycle = invariant.preventsNormalCycle
    }
}
