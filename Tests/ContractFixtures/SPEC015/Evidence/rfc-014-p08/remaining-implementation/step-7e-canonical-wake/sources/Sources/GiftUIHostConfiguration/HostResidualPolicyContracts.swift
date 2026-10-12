import GiftUIFailureCore

package protocol MVPHostResidualPolicyTable: ~Copyable {
    var fatalHookIsAvailable: Bool { get }
    borrowing func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions
    borrowing func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition
}

package protocol MVPHostResidualPolicy: GiftUIResidualFailurePolicy
where Context == HostResidualPolicyContext {}

package enum HostResidualPolicyContext: UInt8, Equatable, Sendable {
    case startupValidation = 0
    case activation = 1
    case presentationBackpressure = 2
    case presentationRetryableRefusal = 3
    case presentationUnavailable = 4
    case containedCandidateFailure = 5
    case staleInputOrRegistration = 6
    case backendOperationalFailure = 7
    case safetyNotProven = 8
}
