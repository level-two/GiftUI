import GiftUIExecution
import GiftUIFailureCore

package struct CorrelatedExecutionOutcome: Sendable {
    package let context: ExecutionContext
    package let outcome: GiftUIOutcome<Void>

    package init(
        context: ExecutionContext,
        outcome: GiftUIOutcome<Void>
    ) {
        self.context = context
        self.outcome = outcome
    }
}

package struct CorrelatedExecutionFailure: Equatable, Sendable {
    package let context: ExecutionContext
    package let fact: GiftUIFailureFact

    package init(context: ExecutionContext, fact: GiftUIFailureFact) {
        self.context = context
        self.fact = fact
    }
}

package enum GiftUIExecutionFailureAdapter {
    package static func admission(
        _ admission: ExecutionAdmissionOutcome,
        mechanicalEffectsComplete: Bool
    ) -> CorrelatedExecutionOutcome? {
        guard mechanicalEffectsComplete else { return nil }

        let outcome: GiftUIOutcome<Void>
        switch admission.result {
        case .queued:
            outcome = .success(())
        case .capacityRefused:
            outcome = .failure(
                fact(
                    condition: .capacityExhausted,
                    origin: .execution,
                    scope: .operation,
                    containment: .contained
                ))
        case .unavailable:
            outcome = .failure(
                fact(
                    condition: .requiredFacilityUnavailable,
                    origin: .execution,
                    scope: .runtime,
                    containment: .contained
                ))
        case .invalidValue:
            outcome = .failure(
                fact(
                    condition: .invalidValue,
                    origin: .execution,
                    scope: .operation,
                    containment: .contained
                ))
        case .invalidProvenance:
            outcome = .failure(
                fact(
                    condition: .invalidProvenance,
                    origin: .execution,
                    scope: .operation,
                    containment: .contained
                ))
        }
        return CorrelatedExecutionOutcome(
            context: admission.context,
            outcome: outcome
        )
    }

    package static func execution(
        _ error: ExecutionError,
        context: ExecutionContext,
        provenAffectedScope: GiftUIAffectedScope,
        safeReuseProven: Bool,
        mechanicalEffectsComplete: Bool
    ) -> CorrelatedExecutionFailure? {
        guard mechanicalEffectsComplete else { return nil }

        let mapped: GiftUIFailureFact
        switch error {
        case .invalidValue:
            guard provenAffectedScope == .operation else { return nil }
            mapped = fact(.invalidValue, .execution, .operation, .contained)
        case .arithmeticOverflow:
            guard provenAffectedScope == .operation else { return nil }
            mapped = fact(.arithmeticOverflow, .foundation, .operation, .contained)
        case .capacityExhausted:
            guard
                provenAffectedScope == .activeCycle
                    || provenAffectedScope == .candidateFrame
            else { return nil }
            mapped = fact(
                .capacityExhausted,
                .execution,
                provenAffectedScope,
                .contained
            )
        case .identityExhausted:
            guard
                provenAffectedScope == .operation
                    || provenAffectedScope == .activeCycle
                    || provenAffectedScope == .runtime
            else { return nil }
            mapped = fact(
                .invalidIdentity,
                .execution,
                provenAffectedScope,
                safeReuseProven ? .contained : .safetyNotProven
            )
        case .invalidProvenance:
            guard provenAffectedScope == .operation else { return nil }
            mapped = fact(.invalidProvenance, .execution, .operation, .contained)
        case .invalidPhase:
            guard provenAffectedScope == .activeCycle else { return nil }
            mapped = fact(.invalidPhase, .execution, .activeCycle, .contained)
        case .reentrancyViolation:
            guard provenAffectedScope == .activeCycle else { return nil }
            mapped = fact(
                .reentrancyViolation,
                .execution,
                .activeCycle,
                .safetyNotProven
            )
        case .requiredFacilityUnavailable:
            guard provenAffectedScope == .runtime else { return nil }
            mapped = fact(
                .requiredFacilityUnavailable,
                .execution,
                .runtime,
                .contained
            )
        case .invariantViolation:
            guard provenAffectedScope == .runtime else { return nil }
            mapped = fact(
                .invariantViolation,
                .execution,
                .runtime,
                .safetyNotProven
            )
        }
        return CorrelatedExecutionFailure(context: context, fact: mapped)
    }

    private static func fact(
        _ condition: GiftUIConditionID,
        _ origin: GiftUIFailureOrigin,
        _ scope: GiftUIAffectedScope,
        _ containment: GiftUIContainment
    ) -> GiftUIFailureFact {
        GiftUIFailureFact(
            condition: condition,
            origin: origin,
            affectedScope: scope,
            containment: containment
        )
    }

    private static func fact(
        condition: GiftUIConditionID,
        origin: GiftUIFailureOrigin,
        scope: GiftUIAffectedScope,
        containment: GiftUIContainment
    ) -> GiftUIFailureFact {
        fact(condition, origin, scope, containment)
    }
}
