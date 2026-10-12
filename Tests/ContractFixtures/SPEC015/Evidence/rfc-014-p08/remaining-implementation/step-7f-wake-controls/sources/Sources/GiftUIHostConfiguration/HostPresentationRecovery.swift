import GiftUIExecution

package enum HostPresentationRecoveryDisposition: UInt8, Equatable, Sendable {
    case pendingBackpressure = 0
    case pendingRetryableRefusal = 1
    case unavailable = 2
    case satisfied = 3
}

package struct HostPresentationRecoveryTransition: Equatable, Sendable {
    package let disposition: HostPresentationRecoveryDisposition
    package let pendingIntent: PresentationPendingIntent?
    package let policyContext: HostResidualPolicyContext?
    package let policyAttemptOrdinal: UInt8
    package let policyAttemptLimit: UInt8
    package let completedEffects: HostMandatoryEffects
    package let inputIsEligible: Bool
}

package struct HostPresentationRecovery: Sendable {
    private let maximumRetryableRefusals: UInt8
    package private(set) var pendingIntent: PresentationPendingIntent?
    package private(set) var inputIsEligible = true
    package private(set) var isAvailable = true

    package init?(maximumRetryableRefusals: UInt8) {
        guard maximumRetryableRefusals > 0 else { return nil }
        self.maximumRetryableRefusals = maximumRetryableRefusals
    }

    package mutating func recordBackpressure(
        revision: SemanticRevision
    ) -> HostPresentationRecoveryTransition {
        guard isAvailable else { return unavailableTransition() }
        let count =
            pendingIntent?.semanticRevision == revision
            ? pendingIntent!.retryableRefusalCount : 0
        pendingIntent = PresentationPendingIntent(
            semanticRevision: revision,
            retryableRefusalCount: count
        )
        return transition(
            disposition: .pendingBackpressure,
            context: .presentationBackpressure,
            ordinal: 0,
            effects: [.discardCandidate, .retainPendingIntent, .preserveRefusalCount]
        )
    }

    package mutating func recordRetryableRefusal(
        revision: SemanticRevision
    ) -> HostPresentationRecoveryTransition {
        guard isAvailable else { return unavailableTransition() }
        let previous =
            pendingIntent?.semanticRevision == revision
            ? pendingIntent!.retryableRefusalCount : 0
        guard previous < maximumRetryableRefusals - 1 else {
            return makeUnavailable()
        }
        pendingIntent = PresentationPendingIntent(
            semanticRevision: revision,
            retryableRefusalCount: previous + 1
        )
        return transition(
            disposition: .pendingRetryableRefusal,
            context: .presentationRetryableRefusal,
            ordinal: previous,
            effects: [.discardCandidate, .retainPendingIntent]
        )
    }

    package mutating func recordNonRetryableRefusal()
        -> HostPresentationRecoveryTransition
    {
        guard isAvailable else { return unavailableTransition() }
        return makeUnavailable()
    }

    package mutating func recordAccepted(
        revision: SemanticRevision
    ) -> HostPresentationRecoveryTransition {
        guard isAvailable else { return unavailableTransition() }
        if pendingIntent?.semanticRevision == revision { pendingIntent = nil }
        return transition(
            disposition: .satisfied,
            context: nil,
            ordinal: 0,
            effects: []
        )
    }

    private mutating func makeUnavailable() -> HostPresentationRecoveryTransition {
        pendingIntent = nil
        inputIsEligible = false
        isAvailable = false
        return unavailableTransition()
    }

    private func unavailableTransition() -> HostPresentationRecoveryTransition {
        transition(
            disposition: .unavailable,
            context: .presentationUnavailable,
            ordinal: 0,
            effects: [.clearPendingIntent, .quiesceInput]
        )
    }

    private func transition(
        disposition: HostPresentationRecoveryDisposition,
        context: HostResidualPolicyContext?,
        ordinal: UInt8,
        effects: HostMandatoryEffects
    ) -> HostPresentationRecoveryTransition {
        HostPresentationRecoveryTransition(
            disposition: disposition,
            pendingIntent: pendingIntent,
            policyContext: context,
            policyAttemptOrdinal: ordinal,
            policyAttemptLimit: context == .presentationBackpressure
                || context == .presentationRetryableRefusal
                ? maximumRetryableRefusals : 1,
            completedEffects: effects,
            inputIsEligible: inputIsEligible
        )
    }
}
