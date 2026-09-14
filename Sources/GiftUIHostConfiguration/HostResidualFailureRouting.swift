import GiftUIFailureCore

package struct HostMandatoryEffects: OptionSet, Equatable, Sendable {
    package let rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    package static let discardValidationProjections = Self(rawValue: 1 << 0)
    package static let containActivation = Self(rawValue: 1 << 1)
    package static let retainPendingIntent = Self(rawValue: 1 << 2)
    package static let preserveRefusalCount = Self(rawValue: 1 << 3)
    package static let clearPendingIntent = Self(rawValue: 1 << 4)
    package static let quiesceInput = Self(rawValue: 1 << 5)
    package static let discardCandidate = Self(rawValue: 1 << 6)
    package static let preservePriorRoot = Self(rawValue: 1 << 7)
    package static let rejectStaleWork = Self(rawValue: 1 << 8)
    package static let cancelAffectedSequence = Self(rawValue: 1 << 9)
    package static let drainTransferredStream = Self(rawValue: 1 << 10)
    package static let updateEndpointHealth = Self(rawValue: 1 << 11)
    package static let discardPartialWork = Self(rawValue: 1 << 12)
    package static let preventNormalCycle = Self(rawValue: 1 << 13)
}

package enum HostNoPolicyReason: UInt8, CaseIterable, Equatable, Sendable {
    case success = 0
    case targetLocalInputDrop = 1
    case pointerCancellation = 2
    case observableContainedPhase = 3
    case focusedOwnerFinal = 4
}

package struct HostResidualRouteRequest {
    package let outcome: GiftUIOutcome<Void>
    package let context: HostResidualPolicyContext
    package let completedEffects: HostMandatoryEffects
    package let attemptOrdinal: UInt8
    package let attemptLimit: UInt8

    package init(
        outcome: GiftUIOutcome<Void>,
        context: HostResidualPolicyContext,
        completedEffects: HostMandatoryEffects,
        attemptOrdinal: UInt8,
        attemptLimit: UInt8
    ) {
        self.outcome = outcome
        self.context = context
        self.completedEffects = completedEffects
        self.attemptOrdinal = attemptOrdinal
        self.attemptLimit = attemptLimit
    }
}

package enum HostResidualRouteResult: Equatable, Sendable {
    case noPolicyCall(HostNoPolicyReason)
    case selected(GiftUIResidualDisposition)
    case safetyNotProven(fatalHookInvoked: Bool)
}

package protocol MVPHostFatalHook {
    mutating func invoke()
}

package protocol MVPHostDiagnosticProjection {
    mutating func project(
        context: HostResidualPolicyContext,
        disposition: GiftUIResidualDisposition
    ) -> Bool
}

package enum HostResidualFailureRouting {
    package static func noPolicyCall(
        _ reason: HostNoPolicyReason
    ) -> HostResidualRouteResult {
        .noPolicyCall(reason)
    }

    package static func route<
        Table: MVPHostResidualPolicyTable,
        Policy: MVPHostResidualPolicy,
        FatalHook: MVPHostFatalHook,
        Diagnostic: MVPHostDiagnosticProjection
    >(
        _ request: HostResidualRouteRequest,
        table: borrowing Table,
        policy: inout Policy,
        fatalHook: inout FatalHook,
        diagnostic: inout Diagnostic
    ) -> HostResidualRouteResult {
        guard HostResidualPolicyTableValidation.validate(table) else {
            return failClosed(table: table, fatalHook: &fatalHook)
        }
        let expected = HostResidualPolicyTableValidation.expectedRow(
            for: request.context
        )
        guard request.completedEffects.isSuperset(of: requiredEffects(for: request.context)),
            let input = GiftUIResidualPolicyInput(
                outcome: request.outcome,
                context: request.context,
                allowed: expected.allowed,
                attemptOrdinal: request.attemptOrdinal,
                attemptLimit: request.attemptLimit
            )
        else {
            return failClosed(table: table, fatalHook: &fatalHook)
        }
        let disposition = policy.disposition(for: input)
        guard disposition == expected.selection,
            expected.allowed.contains(
                GiftUIAllowedDispositions(rawValue: 1 << disposition.rawValue)
            )
        else {
            return failClosed(table: table, fatalHook: &fatalHook)
        }
        _ = diagnostic.project(
            context: request.context,
            disposition: disposition
        )
        return .selected(disposition)
    }

    private static func requiredEffects(
        for context: HostResidualPolicyContext
    ) -> HostMandatoryEffects {
        switch context {
        case .startupValidation:
            .discardValidationProjections
        case .activation:
            .containActivation
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

    private static func failClosed<Table: MVPHostResidualPolicyTable, FatalHook: MVPHostFatalHook>(
        table: borrowing Table,
        fatalHook: inout FatalHook
    ) -> HostResidualRouteResult {
        let invokeFatalHook = table.fatalHookIsAvailable
        if invokeFatalHook { fatalHook.invoke() }
        return .safetyNotProven(fatalHookInvoked: invokeFatalHook)
    }
}
