import GiftUIFailureCore
import Testing

@testable import GiftUIHostConfiguration

private struct RoutingPolicy: MVPHostResidualPolicy {
    var override: GiftUIResidualDisposition?
    private(set) var callCount = 0
    private(set) var failure: GiftUIFailureFact?

    mutating func disposition(
        for input: GiftUIResidualPolicyInput<HostResidualPolicyContext>
    ) -> GiftUIResidualDisposition {
        callCount += 1
        if case .failure(let failure) = input.outcome {
            self.failure = failure
        }
        return override
            ?? HostResidualPolicyTableValidation.expectedRow(for: input.context).selection
    }
}

private struct DefectiveRoutingTable: MVPHostResidualPolicyTable {
    let fatalHookIsAvailable: Bool

    func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions {
        context == .activation ? .continueOperation : requiredRow(context).allowed
    }

    func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition {
        requiredRow(context).selection
    }

    private func requiredRow(
        _ context: HostResidualPolicyContext
    ) -> (allowed: GiftUIAllowedDispositions, selection: GiftUIResidualDisposition) {
        HostResidualPolicyTableValidation.expectedRow(for: context)
    }
}

private struct RoutingFatalHook: MVPHostFatalHook {
    let probe: RoutingProbe
    private(set) var callCount = 0
    mutating func invoke() {
        callCount += 1
        probe.events.append(.fatalHook)
    }
}

private final class RoutingProbe {
    enum Event: Equatable {
        case preventNormalRunCycle
        case quiesceRuntimeHealth(GiftUIFailureFact)
        case propagateInvariantFailure(GiftUIFailureFact)
        case fatalHook
    }

    var events: [Event] = []
}

private struct RoutingInvariantOwner: MVPHostInvariantFailureOwner {
    let probe: RoutingProbe
    private(set) var normalRunCycleIsAvailable = true
    private(set) var health = GiftUIOperationalHealth()

    mutating func preventNormalRunCycle() {
        normalRunCycleIsAvailable = false
        probe.events.append(.preventNormalRunCycle)
    }

    mutating func quiesceRuntimeHealth(with fact: GiftUIFailureFact) {
        health.recordFailure(fact, resultingState: .quiesced)
        probe.events.append(.quiesceRuntimeHealth(fact))
    }

    mutating func propagateInvariantFailure(_ fact: GiftUIFailureFact) {
        probe.events.append(.propagateInvariantFailure(fact))
    }

    mutating func attemptNormalRunCycle() -> Bool {
        guard normalRunCycleIsAvailable else { return false }
        return true
    }
}

private struct RoutingDiagnostic: MVPHostDiagnosticProjection {
    let succeeds: Bool
    private(set) var callCount = 0

    mutating func project(
        context _: HostResidualPolicyContext,
        disposition _: GiftUIResidualDisposition
    ) -> Bool {
        callCount += 1
        return succeeds
    }
}

@Test(arguments: Array(UInt8(0) ... UInt8(8)))
func everyHostPolicyRouteRequiresItsMandatoryEffects(rawValue: UInt8) {
    let context = HostResidualPolicyContext(rawValue: rawValue)!
    let probe = RoutingProbe()
    var policy = RoutingPolicy()
    var owner = RoutingInvariantOwner(probe: probe)
    var fatal = RoutingFatalHook(probe: probe)
    var diagnostic = RoutingDiagnostic(succeeds: true)
    let result = HostResidualFailureRouting.route(
        request(context: context, effects: []),
        table: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: true),
        policy: &policy,
        invariantOwner: &owner,
        fatalHook: &fatal,
        diagnostic: &diagnostic
    )

    #expect(result == .safetyNotProven(fatalHookInvoked: true))
    #expect(policy.callCount == 0)
    #expect(fatal.callCount == 1)
    #expect(diagnostic.callCount == 0)
    expectInvariantContainment(owner: &owner, probe: probe, fatalExpected: true)
}

@Test(arguments: Array(UInt8(0) ... UInt8(8)))
func everyHostPolicyRouteSelectsOnlyAfterMandatoryEffects(rawValue: UInt8) {
    let context = HostResidualPolicyContext(rawValue: rawValue)!
    let probe = RoutingProbe()
    var policy = RoutingPolicy()
    var owner = RoutingInvariantOwner(probe: probe)
    var fatal = RoutingFatalHook(probe: probe)
    var diagnostic = RoutingDiagnostic(succeeds: false)
    let result = HostResidualFailureRouting.route(
        request(context: context, effects: requiredEffects(context)),
        table: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: true),
        policy: &policy,
        invariantOwner: &owner,
        fatalHook: &fatal,
        diagnostic: &diagnostic
    )

    let expected = HostResidualPolicyTableValidation.expectedRow(for: context).selection
    #expect(result == .selected(expected))
    #expect(policy.callCount == 1)
    #expect(fatal.callCount == 0)
    #expect(diagnostic.callCount == 1)
    #expect(probe.events.isEmpty)
    #expect(owner.normalRunCycleIsAvailable)
    if case .failure(let failure) = request(
        context: context,
        effects: requiredEffects(context)
    ).outcome {
        #expect(policy.failure == failure)
    }
}

@Test func defectivePolicyResultBypassesTableAndUsesIndependentFatalHook() {
    let probe = RoutingProbe()
    var policy = RoutingPolicy(override: .invokeFatalHook)
    var owner = RoutingInvariantOwner(probe: probe)
    var fatal = RoutingFatalHook(probe: probe)
    var diagnostic = RoutingDiagnostic(succeeds: true)
    let result = HostResidualFailureRouting.route(
        request(context: .activation, effects: .containActivation),
        table: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: true),
        policy: &policy,
        invariantOwner: &owner,
        fatalHook: &fatal,
        diagnostic: &diagnostic
    )

    #expect(result == .safetyNotProven(fatalHookInvoked: true))
    #expect(policy.callCount == 1)
    #expect(fatal.callCount == 1)
    #expect(diagnostic.callCount == 0)
    expectInvariantContainment(owner: &owner, probe: probe, fatalExpected: true)
}

@Test func defectiveTableBypassesPolicyAndHonorsUnavailableFatalHook() {
    let probe = RoutingProbe()
    var policy = RoutingPolicy()
    var owner = RoutingInvariantOwner(probe: probe)
    var fatal = RoutingFatalHook(probe: probe)
    var diagnostic = RoutingDiagnostic(succeeds: true)
    let result = HostResidualFailureRouting.route(
        request(context: .activation, effects: .containActivation),
        table: DefectiveRoutingTable(fatalHookIsAvailable: false),
        policy: &policy,
        invariantOwner: &owner,
        fatalHook: &fatal,
        diagnostic: &diagnostic
    )

    #expect(result == .safetyNotProven(fatalHookInvoked: false))
    #expect(policy.callCount == 0)
    #expect(fatal.callCount == 0)
    #expect(diagnostic.callCount == 0)
    expectInvariantContainment(owner: &owner, probe: probe, fatalExpected: false)
}

@Test func diagnosticOutcomeCannotChangeAuthoritativeRouting() {
    let successfulProbe = RoutingProbe()
    var successfulPolicy = RoutingPolicy()
    var successfulOwner = RoutingInvariantOwner(probe: successfulProbe)
    var successfulFatal = RoutingFatalHook(probe: successfulProbe)
    var successfulDiagnostic = RoutingDiagnostic(succeeds: true)
    let successfulProjection = HostResidualFailureRouting.route(
        request(
            context: .backendOperationalFailure,
            effects: [.drainTransferredStream, .updateEndpointHealth, .quiesceInput]
        ),
        table: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: true),
        policy: &successfulPolicy,
        invariantOwner: &successfulOwner,
        fatalHook: &successfulFatal,
        diagnostic: &successfulDiagnostic
    )

    let failedProbe = RoutingProbe()
    var failedPolicy = RoutingPolicy()
    var failedOwner = RoutingInvariantOwner(probe: failedProbe)
    var failedFatal = RoutingFatalHook(probe: failedProbe)
    var failedDiagnostic = RoutingDiagnostic(succeeds: false)
    let failedProjection = HostResidualFailureRouting.route(
        request(
            context: .backendOperationalFailure,
            effects: [.drainTransferredStream, .updateEndpointHealth, .quiesceInput]
        ),
        table: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: true),
        policy: &failedPolicy,
        invariantOwner: &failedOwner,
        fatalHook: &failedFatal,
        diagnostic: &failedDiagnostic
    )

    #expect(successfulProjection == .selected(.quiesceAffectedScope))
    #expect(failedProjection == successfulProjection)
    #expect(successfulPolicy.failure == failedPolicy.failure)
    #expect(successfulProbe.events.isEmpty)
    #expect(failedProbe.events.isEmpty)
}

@Test(arguments: HostNoPolicyReason.allCases)
func explicitNoPolicyRowsInvokeNothing(reason: HostNoPolicyReason) {
    #expect(HostResidualFailureRouting.noPolicyCall(reason) == .noPolicyCall(reason))
}

private func request(
    context: HostResidualPolicyContext,
    effects: HostMandatoryEffects
) -> HostResidualRouteRequest {
    let expected = HostResidualPolicyTableValidation.expectedRow(for: context)
    let outcome: GiftUIOutcome<Void> =
        expected.allowed.contains(.requestPacedRetry)
        ? .operational(
            GiftUIOperationalFact(
                kind: context == .presentationBackpressure
                    ? .backpressured : .retryableRefusal,
                origin: .backend,
                affectedScope: .runtime
            )
        )
        : .failure(
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .hostComposition,
                affectedScope: .runtime,
                containment: context == .safetyNotProven
                    ? .safetyNotProven : .contained
            )
        )
    return HostResidualRouteRequest(
        outcome: outcome,
        context: context,
        completedEffects: effects,
        attemptOrdinal: 0,
        attemptLimit: expected.allowed.contains(.requestPacedRetry) ? 3 : 1
    )
}

private func requiredEffects(
    _ context: HostResidualPolicyContext
) -> HostMandatoryEffects {
    switch context {
    case .startupValidation: .discardValidationProjections
    case .activation: .containActivation
    case .presentationBackpressure:
        [.discardCandidate, .retainPendingIntent, .preserveRefusalCount]
    case .presentationRetryableRefusal:
        [.discardCandidate, .retainPendingIntent]
    case .presentationUnavailable:
        [.clearPendingIntent, .quiesceInput]
    case .containedCandidateFailure:
        [.discardCandidate, .preservePriorRoot]
    case .staleInputOrRegistration:
        [.rejectStaleWork, .cancelAffectedSequence]
    case .backendOperationalFailure:
        [.drainTransferredStream, .updateEndpointHealth, .quiesceInput]
    case .safetyNotProven:
        [.discardPartialWork, .preventNormalCycle]
    }
}

private func expectInvariantContainment(
    owner: inout RoutingInvariantOwner,
    probe: RoutingProbe,
    fatalExpected: Bool
) {
    let fact = GiftUIFailureFact(
        condition: .invariantViolation,
        origin: .hostComposition,
        affectedScope: .runtime,
        containment: .safetyNotProven
    )
    var expected: [RoutingProbe.Event] = [
        .preventNormalRunCycle,
        .quiesceRuntimeHealth(fact),
        .propagateInvariantFailure(fact),
    ]
    if fatalExpected { expected.append(.fatalHook) }
    #expect(probe.events == expected)
    #expect(owner.health.state == .quiesced)
    for _ in 0 ..< 3 {
        let admitted = owner.attemptNormalRunCycle()
        #expect(!admitted)
    }
}
