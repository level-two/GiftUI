import GiftUIFailureCore

@usableFromInline
package enum HostResidualPolicyTableValidation {
    @inlinable
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

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    @usableFromInline
    package static func expectedRow(
        for context: HostResidualPolicyContext
    ) -> (
        allowed: GiftUIAllowedDispositions,
        selection: GiftUIResidualDisposition
    ) {
        switch context {
        case .presentationBackpressure, .presentationRetryableRefusal:
            return (
                GiftUIDispositionOptionProjection.options(
                    .requestPacedRetry, .quiesceAffectedScope),
                .requestPacedRetry
            )
        case .containedCandidateFailure:
            return (
                GiftUIDispositionOptionProjection.options(
                    .continueOperation, .quiesceAffectedScope),
                .continueOperation
            )
        case .staleInputOrRegistration:
            return (
                GiftUIDispositionOptionProjection.option(.continueOperation), .continueOperation
            )
        case .safetyNotProven:
            return (
                GiftUIDispositionOptionProjection.options(.quiesceAffectedScope, .invokeFatalHook),
                .quiesceAffectedScope
            )
        case .startupValidation, .activation, .presentationUnavailable,
            .backendOperationalFailure:
            return (
                GiftUIDispositionOptionProjection.option(.quiesceAffectedScope),
                .quiesceAffectedScope
            )
        }
    }
}
