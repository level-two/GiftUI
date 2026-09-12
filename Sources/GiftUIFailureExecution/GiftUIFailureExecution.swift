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

public struct GiftUICorrelatedFailure<Context> {
    public let fact: GiftUIFailureFact
    public let context: Context
    public let annotations: GiftUIFailureAnnotations

    public init(
        fact: GiftUIFailureFact,
        context: Context,
        annotations: GiftUIFailureAnnotations = .init()
    ) {
        self.fact = fact
        self.context = context
        self.annotations = annotations
    }
}

extension GiftUICorrelatedFailure: Sendable where Context: Sendable {}
extension GiftUICorrelatedFailure: Equatable where Context: Equatable {}

package struct CorrelatedFocusedOwnerFailure<OwnerFailure>: Equatable, Sendable
where OwnerFailure: Equatable & Sendable {
    package let context: ExecutionContext
    package let failure: OwnerFailure

    package init(context: ExecutionContext, failure: OwnerFailure) {
        self.context = context
        self.failure = failure
    }
}

package struct CorrelatedExecutionOperational: Equatable, Sendable {
    package let context: ExecutionContext
    package let fact: GiftUIOperationalFact
    package let completeEvents: ExecutionOperationalEvents
    package let attemptOrdinal: UInt8
    package let attemptLimit: UInt8
}

package enum GiftUIExecutionFailureAdapter {
    package static func operational(
        _ primary: ExecutionOperational,
        completeEvents: ExecutionOperationalEvents,
        context: ExecutionContext,
        attemptOrdinal: UInt8,
        attemptLimit: UInt8,
        mechanicalEffectsComplete: Bool
    ) -> CorrelatedExecutionOperational? {
        guard mechanicalEffectsComplete,
            attemptLimit > 0,
            attemptOrdinal < attemptLimit,
            primaryOperationalEvent(in: completeEvents) == primary
        else { return nil }

        let fact: GiftUIOperationalFact
        switch primary {
        case .noChange:
            fact = operationalFact(.noChange, .execution, .activeCycle)
        case .backpressured:
            fact = operationalFact(.backpressured, .backend, .candidateFrame)
        case .retryableRefusal:
            fact = operationalFact(.retryableRefusal, .backend, .candidateFrame)
        case .superseded:
            fact = operationalFact(.superseded, .execution, .candidateFrame)
        case .deferredToLaterAdmission:
            fact = operationalFact(.deferredToLaterAdmission, .execution, .activeCycle)
        }
        return CorrelatedExecutionOperational(
            context: context,
            fact: fact,
            completeEvents: completeEvents,
            attemptOrdinal: attemptOrdinal,
            attemptLimit: attemptLimit
        )
    }

    package static func residualInput(
        for operational: CorrelatedExecutionOperational,
        allowed: GiftUIAllowedDispositions
    ) -> GiftUIResidualPolicyInput<ExecutionContext>? {
        GiftUIResidualPolicyInput(
            outcome: .operational(operational.fact),
            context: operational.context,
            allowed: allowed,
            attemptOrdinal: operational.attemptOrdinal,
            attemptLimit: operational.attemptLimit
        )
    }

    package static func offeredFailure<OwnerFailure>(
        _ failure: RunCycleFailure<OwnerFailure>,
        context: ExecutionContext,
        mechanicalEffectsComplete: Bool
    ) -> GiftUICorrelatedFailure<ExecutionContext>?
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
        return GiftUICorrelatedFailure(fact: mapped, context: context)
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
    ) -> GiftUICorrelatedFailure<ExecutionContext>? {
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
        return GiftUICorrelatedFailure(fact: mapped, context: context)
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

    private static func operationalFact(
        _ kind: GiftUIOperationalKind,
        _ origin: GiftUIFailureOrigin,
        _ scope: GiftUIAffectedScope
    ) -> GiftUIOperationalFact {
        GiftUIOperationalFact(
            kind: kind,
            origin: origin,
            affectedScope: scope
        )
    }

    private static func primaryOperationalEvent(
        in events: ExecutionOperationalEvents
    ) -> ExecutionOperational? {
        if events.contains(.retryableRefusal) { return .retryableRefusal }
        if events.contains(.backpressured) { return .backpressured }
        if events.contains(.superseded) { return .superseded }
        if events.contains(.deferredToLaterAdmission) {
            return .deferredToLaterAdmission
        }
        if events.contains(.noChange) { return .noChange }
        return nil
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
