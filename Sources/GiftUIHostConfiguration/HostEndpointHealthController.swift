import GiftUIBackendIntegration
import GiftUIFailureCore

package protocol MVPHostEndpointHealthSource {
    borrowing func health() -> GiftUIOperationalHealth
}

extension OneShotRasterBackendEndpoint: MVPHostEndpointHealthSource {}

package enum HostFreshConstructionReason: UInt8, CaseIterable, Equatable, Sendable {
    case terminalUnavailability = 0
    case identityExhaustion = 1
    case graphChange = 2
    case resourceChange = 3
    case extentChange = 4
    case policyChange = 5
    case immutableConfigurationChange = 6
}

package enum HostEndpointHealthError: UInt8, Error, Equatable, Sendable {
    case invalidInitialHealth = 0
    case currentInstanceUnavailable = 1
    case counterRegression = 2
    case failureBeforeResponsibilityTransfer = 3
    case transferredStreamNotDrained = 4
    case invalidPostFailureHealth = 5
}

package enum HostEndpointHealthTransition: Equatable, Sendable {
    case unchanged
    case backendOperationalFailure(
        fact: GiftUIFailureFact,
        effects: HostMandatoryEffects
    )
    case freshConstructionRequired(HostFreshConstructionReason)

    package func residualRouteRequest() -> HostResidualRouteRequest? {
        guard case .backendOperationalFailure(let fact, let effects) = self else {
            return nil
        }
        return HostResidualRouteRequest(
            outcome: .failure(fact),
            context: .backendOperationalFailure,
            completedEffects: effects,
            attemptOrdinal: 0,
            attemptLimit: 1
        )
    }
}

package struct HostEndpointHealthController: Sendable {
    private var observedTransitionCount: UInt32
    private var observedOperationalCount: UInt32
    private var observedFailureCount: UInt32

    package private(set) var inputIsEligible: Bool
    package private(set) var requiresFreshConstruction = false
    package private(set) var freshConstructionReason: HostFreshConstructionReason?

    package init?(
        initialHealth: GiftUIOperationalHealth,
        inputIsEligible: Bool
    ) {
        guard initialHealth.state == .available,
            initialHealth.transitionCount == 0,
            initialHealth.failureCount == 0
        else { return nil }
        observedTransitionCount = initialHealth.transitionCount
        observedOperationalCount = initialHealth.operationalCount
        observedFailureCount = initialHealth.failureCount
        self.inputIsEligible = inputIsEligible
    }

    package mutating func consumeAcceptedOffer<Source: MVPHostEndpointHealthSource>(
        from source: borrowing Source,
        responsibilityTransferred: Bool,
        streamDrained: Bool
    ) -> Result<HostEndpointHealthTransition, HostEndpointHealthError> {
        guard !requiresFreshConstruction else {
            return .failure(.currentInstanceUnavailable)
        }
        let health = source.health()
        guard health.transitionCount >= observedTransitionCount,
            health.operationalCount >= observedOperationalCount,
            health.failureCount >= observedFailureCount
        else {
            return failClosed(.counterRegression)
        }

        let failureChanged = health.failureCount != observedFailureCount
        guard failureChanged else {
            observedTransitionCount = health.transitionCount
            observedOperationalCount = health.operationalCount
            return .success(.unchanged)
        }
        guard responsibilityTransferred else {
            return failClosed(.failureBeforeResponsibilityTransfer)
        }
        guard streamDrained else {
            return failClosed(.transferredStreamNotDrained)
        }
        guard health.state == .unavailable || health.state == .quiesced else {
            return failClosed(.invalidPostFailureHealth)
        }

        observedTransitionCount = health.transitionCount
        observedOperationalCount = health.operationalCount
        observedFailureCount = health.failureCount
        inputIsEligible = false
        requiresFreshConstruction = true
        freshConstructionReason = .terminalUnavailability

        let fact: GiftUIFailureFact
        if health.state == .quiesced {
            fact = GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .backend,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
        } else {
            fact = GiftUIFailureFact(
                condition: .requiredFacilityUnavailable,
                origin: .presentationIntegration,
                affectedScope: .component,
                containment: .contained
            )
        }
        return .success(
            .backendOperationalFailure(
                fact: fact,
                effects: [
                    .drainTransferredStream,
                    .updateEndpointHealth,
                    .quiesceInput,
                ]
            )
        )
    }

    package mutating func requireFreshConstruction(
        for reason: HostFreshConstructionReason
    ) -> HostEndpointHealthTransition {
        inputIsEligible = false
        requiresFreshConstruction = true
        freshConstructionReason = reason
        return .freshConstructionRequired(reason)
    }

    private mutating func failClosed(
        _ error: HostEndpointHealthError
    ) -> Result<HostEndpointHealthTransition, HostEndpointHealthError> {
        inputIsEligible = false
        requiresFreshConstruction = true
        freshConstructionReason = .terminalUnavailability
        return .failure(error)
    }
}
