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

package struct CorrelatedFocusedOwnerFailure<OwnerFailure>: Equatable, Sendable
where OwnerFailure: Equatable & Sendable {
    package let context: ExecutionContext
    package let failure: OwnerFailure

    package init(context: ExecutionContext, failure: OwnerFailure) {
        self.context = context
        self.failure = failure
    }
}

package enum GiftUIExecutionFailureAdapter {
    package static func offeredFailure<OwnerFailure>(
        _ failure: RunCycleFailure<OwnerFailure>,
        context: ExecutionContext,
        mechanicalEffectsComplete: Bool
    ) -> CorrelatedExecutionFailure?
    where OwnerFailure: Equatable & Sendable {
        guard mechanicalEffectsComplete else { return nil }
        let mapped: GiftUIFailureFact
        switch failure {
        case .renderProduction(let error):
            switch error {
            case .invalidInput, .incompatibleTextResource:
                mapped = fact(.invalidValue, .rendering, .candidateFrame, .contained)
            case .arithmeticOverflow:
                mapped = fact(.arithmeticOverflow, .foundation, .operation, .contained)
            case .capacityExhausted:
                mapped = fact(.capacityExhausted, .rendering, .candidateFrame, .contained)
            case .sinkRefused:
                return nil
            case .reentrancyViolation:
                mapped = fact(.reentrancyViolation, .rendering, .activeCycle, .safetyNotProven)
            case .invariantViolation:
                mapped = fact(.invariantViolation, .rendering, .runtime, .safetyNotProven)
            }
        case .frameOffer(let offerFailure):
            switch offerFailure {
            case .invalidEnvelope:
                mapped = fact(.invalidValue, .backend, .candidateFrame, .contained)
            case .contractViolation:
                mapped = fact(.invariantViolation, .backend, .runtime, .safetyNotProven)
            case .insufficientCapacity, .producerFailed:
                return nil
            }
        case .nonRetryableRefusal(let origin):
            switch origin {
            case .renderProducer:
                mapped = fact(.nonRetryableRefusal, .rendering, .candidateFrame, .contained)
            case .endpoint:
                mapped = fact(.nonRetryableRefusal, .backend, .candidateFrame, .contained)
            }
        case .execution, .focusedOwner:
            return nil
        }
        return CorrelatedExecutionFailure(
            context: context,
            fact: mapped
        )
    }

    package static func focusedOwner<OwnerFailure>(
        from failure: RunCycleFailure<OwnerFailure>,
        context: ExecutionContext
    ) -> CorrelatedFocusedOwnerFailure<OwnerFailure>?
    where OwnerFailure: Equatable & Sendable {
        guard case .focusedOwner(let ownerFailure) = failure else { return nil }
        return CorrelatedFocusedOwnerFailure(
            context: context,
            failure: ownerFailure
        )
    }

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
