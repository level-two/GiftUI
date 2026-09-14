import GiftUIFailureCore
import Testing

@testable import GiftUIHostConfiguration

private struct HealthSource: MVPHostEndpointHealthSource {
    var value: GiftUIOperationalHealth

    borrowing func health() -> GiftUIOperationalHealth { value }
}

private let transportFailure = GiftUIFailureFact(
    condition: .requiredFacilityUnavailable,
    origin: .presentationIntegration,
    affectedScope: .component,
    containment: .contained
)

private let invariantFailure = GiftUIFailureFact(
    condition: .invariantViolation,
    origin: .backend,
    affectedScope: .runtime,
    containment: .safetyNotProven
)

@Test func unchangedEndpointHealthPreservesInputAndCurrentInstance() {
    let source = HealthSource(value: GiftUIOperationalHealth())
    var controller = HostEndpointHealthController(
        initialHealth: source.health(),
        inputIsEligible: true
    )!

    #expect(
        controller.consumeAcceptedOffer(
            from: source,
            responsibilityTransferred: false,
            streamDrained: false
        ) == .success(.unchanged)
    )
    #expect(controller.inputIsEligible)
    #expect(!controller.requiresFreshConstruction)
}

@Test func transferredTransportFailureIsObservedAfterDrainAndHealthUpdate() {
    var health = GiftUIOperationalHealth()
    health.recordFailure(transportFailure, resultingState: .unavailable)
    let source = HealthSource(value: health)
    var controller = HostEndpointHealthController(
        initialHealth: GiftUIOperationalHealth(),
        inputIsEligible: true
    )!

    let transition = controller.consumeAcceptedOffer(
        from: source,
        responsibilityTransferred: true,
        streamDrained: true
    )

    #expect(
        transition
            == .success(
                .backendOperationalFailure(
                    fact: transportFailure,
                    effects: [
                        .drainTransferredStream,
                        .updateEndpointHealth,
                        .quiesceInput,
                    ]
                )
            )
    )
    #expect(!controller.inputIsEligible)
    #expect(controller.requiresFreshConstruction)
    #expect(controller.freshConstructionReason == .terminalUnavailability)

    let request = try? transition.get().residualRouteRequest()
    #expect(request?.context == .backendOperationalFailure)
    #expect(request?.attemptOrdinal == 0)
    #expect(request?.attemptLimit == 1)
    #expect(
        request?.completedEffects == [
            .drainTransferredStream,
            .updateEndpointHealth,
            .quiesceInput,
        ]
    )
    if case .failure(let fact) = request?.outcome {
        #expect(fact == transportFailure)
    } else {
        Issue.record("expected a backend failure route outcome")
    }
}

@Test func transferredInvariantFailurePreservesSafetyNotProvenFact() {
    var health = GiftUIOperationalHealth()
    health.recordFailure(invariantFailure, resultingState: .quiesced)
    let source = HealthSource(value: health)
    var controller = HostEndpointHealthController(
        initialHealth: GiftUIOperationalHealth(),
        inputIsEligible: true
    )!

    #expect(
        controller.consumeAcceptedOffer(
            from: source,
            responsibilityTransferred: true,
            streamDrained: true
        )
            == .success(
                .backendOperationalFailure(
                    fact: invariantFailure,
                    effects: [
                        .drainTransferredStream,
                        .updateEndpointHealth,
                        .quiesceInput,
                    ]
                )
            )
    )
}

@Test(
    arguments: [
        (false, true, HostEndpointHealthError.failureBeforeResponsibilityTransfer),
        (true, false, HostEndpointHealthError.transferredStreamNotDrained),
    ]
)
func failureCannotRouteBeforeBothMandatoryEndpointEffects(
    responsibilityTransferred: Bool,
    streamDrained: Bool,
    expected: HostEndpointHealthError
) {
    var health = GiftUIOperationalHealth()
    health.recordFailure(transportFailure, resultingState: .unavailable)
    let source = HealthSource(value: health)
    var controller = HostEndpointHealthController(
        initialHealth: GiftUIOperationalHealth(),
        inputIsEligible: true
    )!

    #expect(
        controller.consumeAcceptedOffer(
            from: source,
            responsibilityTransferred: responsibilityTransferred,
            streamDrained: streamDrained
        ) == .failure(expected)
    )
    #expect(!controller.inputIsEligible)
    #expect(controller.requiresFreshConstruction)
}

@Test func endpointHealthCountersCannotRegress() {
    var initial = GiftUIOperationalHealth()
    initial.recordOperational(
        GiftUIOperationalFact(
            kind: .noChange,
            origin: .presentationIntegration,
            affectedScope: .component
        ),
        resultingState: .available
    )
    let source = HealthSource(value: GiftUIOperationalHealth())
    var controller = HostEndpointHealthController(
        initialHealth: initial,
        inputIsEligible: true
    )!

    #expect(
        controller.consumeAcceptedOffer(
            from: source,
            responsibilityTransferred: false,
            streamDrained: false
        ) == .failure(.counterRegression)
    )
}

@Test(arguments: HostFreshConstructionReason.allCases)
func everyForbiddenReactivationCauseRequiresFreshConstruction(
    reason: HostFreshConstructionReason
) {
    var controller = HostEndpointHealthController(
        initialHealth: GiftUIOperationalHealth(),
        inputIsEligible: true
    )!

    #expect(
        controller.requireFreshConstruction(for: reason)
            == .freshConstructionRequired(reason)
    )
    #expect(!controller.inputIsEligible)
    #expect(controller.requiresFreshConstruction)
    #expect(controller.freshConstructionReason == reason)
}

@Test func terminalControllerRejectsLaterHealthConsumption() {
    let source = HealthSource(value: GiftUIOperationalHealth())
    var controller = HostEndpointHealthController(
        initialHealth: source.health(),
        inputIsEligible: true
    )!
    _ = controller.requireFreshConstruction(for: .identityExhaustion)

    #expect(
        controller.consumeAcceptedOffer(
            from: source,
            responsibilityTransferred: false,
            streamDrained: false
        ) == .failure(.currentInstanceUnavailable)
    )
}

@Test func nonPristineInitialHealthCannotCreateAHostHealthObserver() {
    var unavailable = GiftUIOperationalHealth()
    unavailable.recordFailure(transportFailure, resultingState: .unavailable)

    #expect(
        HostEndpointHealthController(
            initialHealth: unavailable,
            inputIsEligible: false
        ) == nil
    )
}
