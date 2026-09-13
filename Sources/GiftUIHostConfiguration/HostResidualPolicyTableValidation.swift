import GiftUIFailureCore

package enum HostResidualPolicyTableValidation {
    package static func validate<Table>(
        _ table: borrowing Table
    ) -> Bool where Table: MVPHostResidualPolicyTable {
        for rawValue in UInt8(0) ... 8 {
            let context = HostResidualPolicyContext(rawValue: rawValue)!
            let expected = expectedRow(for: context)
            guard table.allowed(for: context) == expected.allowed,
                table.selection(for: context) == expected.selection
            else { return false }
        }
        return true
    }

    private static func expectedRow(
        for context: HostResidualPolicyContext
    ) -> (
        allowed: GiftUIAllowedDispositions,
        selection: GiftUIResidualDisposition
    ) {
        switch context {
        case .presentationBackpressure, .presentationRetryableRefusal:
            return (
                [.requestPacedRetry, .quiesceAffectedScope],
                .requestPacedRetry
            )
        case .containedCandidateFailure:
            return (
                [.continueOperation, .quiesceAffectedScope],
                .continueOperation
            )
        case .staleInputOrRegistration:
            return (.continueOperation, .continueOperation)
        case .safetyNotProven:
            return (
                [.quiesceAffectedScope, .invokeFatalHook],
                .quiesceAffectedScope
            )
        case .startupValidation, .activation, .presentationUnavailable,
            .backendOperationalFailure:
            return (.quiesceAffectedScope, .quiesceAffectedScope)
        }
    }
}
