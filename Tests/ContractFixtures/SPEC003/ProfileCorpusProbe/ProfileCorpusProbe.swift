import GiftUIFailureCore

public enum GiftUIFailureProfileCorpusProbe {
    public static func checksum() -> UInt32 {
        // corpus-case: policy-continue
        guard policyCase(
            context: 0,
            outcome: .operational(.init(
                kind: .noChange,
                origin: .semantic,
                affectedScope: .operation
            )),
            allowed: [.continueOperation, .quiesceAffectedScope],
            attemptOrdinal: 0,
            attemptLimit: 1
        ) == 0,
        // corpus-case: policy-retry
        policyCase(
            context: 1,
            outcome: .operational(.init(
                kind: .backpressured,
                origin: .inputIntegration,
                affectedScope: .operation
            )),
            allowed: [.requestPacedRetry, .markFacilityUnavailable],
            attemptOrdinal: 0,
            attemptLimit: 3
        ) == 1,
        // corpus-case: policy-unavailable
        policyCase(
            context: 2,
            outcome: .failure(.init(
                condition: .requiredFacilityUnavailable,
                origin: .hostComposition,
                affectedScope: .component,
                containment: .contained
            )),
            allowed: [.markFacilityUnavailable, .quiesceAffectedScope],
            attemptOrdinal: 0,
            attemptLimit: 1
        ) == 2,
        // corpus-case: policy-quiesce
        policyCase(
            context: 3,
            outcome: .failure(invariantFact),
            allowed: [.quiesceAffectedScope, .invokeFatalHook],
            attemptOrdinal: 0,
            attemptLimit: 1
        ) == 3,
        // corpus-case: policy-fatal
        policyCase(
            context: 4,
            outcome: .failure(invariantFact),
            allowed: [.quiesceAffectedScope, .invokeFatalHook],
            attemptOrdinal: 0,
            attemptLimit: 1
        ) == 4,
        // corpus-case: owner-invalid-nil
        ownerInvariantCase(selector: 0) == 29,
        // corpus-case: owner-unlisted-return
        ownerInvariantCase(selector: 1) == 30 else {
            return 0
        }
        return 69
    }

    private struct CorpusPolicy: GiftUIResidualFailurePolicy {
        mutating func disposition(
            for input: GiftUIResidualPolicyInput<UInt8>
        ) -> GiftUIResidualDisposition {
            switch input.context {
            case 0: .continueOperation
            case 1: .requestPacedRetry
            case 2: .markFacilityUnavailable
            case 3: .quiesceAffectedScope
            default: .invokeFatalHook
            }
        }
    }

    private static func policyCase(
        context: UInt8,
        outcome: GiftUIOutcome<Void>,
        allowed: GiftUIAllowedDispositions,
        attemptOrdinal: UInt8,
        attemptLimit: UInt8
    ) -> UInt32 {
        guard let input = GiftUIResidualPolicyInput(
            outcome: outcome,
            context: context,
            allowed: allowed,
            attemptOrdinal: attemptOrdinal,
            attemptLimit: attemptLimit
        ) else {
            return UInt32.max
        }
        var policy = CorpusPolicy()
        return UInt32(policy.disposition(for: input).rawValue)
    }

    private static func ownerInvariantCase(selector: UInt8) -> UInt32 {
        var policyInvocationCount: UInt32 = 0
        if selector == 1 {
            policyInvocationCount = 1
        }
        var health = GiftUIOperationalHealth()
        health.recordFailure(invariantFact, resultingState: .quiesced)
        return UInt32(invariantFact.condition.rawValue)
            &+ UInt32(invariantFact.origin.rawValue)
            &+ UInt32(invariantFact.affectedScope.rawValue)
            &+ UInt32(invariantFact.containment.rawValue)
            &+ UInt32(health.state.rawValue)
            &+ policyInvocationCount
    }

    private static let invariantFact = GiftUIFailureFact(
        condition: .invariantViolation,
        origin: .hostComposition,
        affectedScope: .runtime,
        containment: .safetyNotProven
    )
}
