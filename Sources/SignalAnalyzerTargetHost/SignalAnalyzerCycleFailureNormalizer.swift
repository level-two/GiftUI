import GiftUIExecution
import GiftUIFailureCore
import GiftUIRuntimeCore
import SignalAnalyzerPresentation

/// Application-owned normalization above the framework Runtime Core boundary.
package enum SignalAnalyzerCycleFailureNormalizer {
    package static func focusedOwner(
        _ failure: SignalAnalyzerCycleOwnerFailure,
        context: ExecutionContext
    ) -> GiftUIFailureFact {
        switch failure {
        case .runtime(let failure): return frameworkOwner(failure, context: context)
        case .application(let condition):
            return SignalAnalyzerRuntimeFailureNormalizer.fact(
                for: condition, stableStateProven: false)
        }
    }

    package static func cycleFailure(
        _ failure: RunCycleFailure<SignalAnalyzerCycleOwnerFailure>,
        context: ExecutionContext
    ) -> GiftUIFailureFact {
        switch failure {
        case .focusedOwner(let failure): return focusedOwner(failure, context: context)
        case .execution(let error):
            switch error {
            case .invalidValue: return fact(.invalidValue, .execution, .operation, .contained)
            case .arithmeticOverflow:
                return fact(.arithmeticOverflow, .foundation, .operation, .contained)
            case .capacityExhausted:
                return fact(.capacityExhausted, .execution, .activeCycle, .contained)
            case .identityExhausted:
                return fact(.invalidIdentity, .execution, .runtime, .safetyNotProven)
            case .invalidProvenance:
                return fact(.invalidProvenance, .execution, .operation, .contained)
            case .invalidPhase: return fact(.invalidPhase, .execution, .activeCycle, .contained)
            case .reentrancyViolation:
                return fact(.reentrancyViolation, .execution, .activeCycle, .safetyNotProven)
            case .requiredFacilityUnavailable:
                return fact(.requiredFacilityUnavailable, .execution, .runtime, .contained)
            case .invariantViolation:
                return fact(.invariantViolation, .execution, .runtime, .safetyNotProven)
            }
        case .renderProduction(let error):
            switch error {
            case .invalidInput, .incompatibleTextResource:
                return fact(.invalidValue, .rendering, .candidateFrame, .contained)
            case .arithmeticOverflow:
                return fact(.arithmeticOverflow, .foundation, .operation, .contained)
            case .capacityExhausted:
                return fact(.capacityExhausted, .rendering, .candidateFrame, .contained)
            case .sinkRefused:
                return fact(.nonRetryableRefusal, .rendering, .candidateFrame, .contained)
            case .reentrancyViolation:
                return fact(.reentrancyViolation, .rendering, .activeCycle, .safetyNotProven)
            case .invariantViolation:
                return fact(.invariantViolation, .rendering, .runtime, .safetyNotProven)
            }
        case .frameOffer(let error):
            switch error {
            case .invalidEnvelope: return fact(.invalidValue, .backend, .candidateFrame, .contained)
            case .contractViolation, .insufficientCapacity, .producerFailed:
                // Producer failures must arrive through their retained focused error.
                return fact(.invariantViolation, .backend, .runtime, .safetyNotProven)
            }
        case .nonRetryableRefusal(let origin):
            return fact(
                .nonRetryableRefusal, origin == .renderProducer ? .rendering : .backend,
                .candidateFrame, .contained)
        }
    }

    private static func frameworkOwner(_ failure: RuntimeOwnerFailure, context: ExecutionContext)
        -> GiftUIFailureFact
    {
        switch failure {
        case .semantic(let error):
            switch error {
            case .capacityExhausted:
                fact(.capacityExhausted, .semantic, .activeCycle, .contained)
            case .invalidIdentity:
                fact(.invalidIdentity, .semantic, .activeCycle, .contained)
            case .reentrancyViolation:
                fact(.reentrancyViolation, .semantic, .activeCycle, .contained)
            case .invariantViolation:
                fact(.invariantViolation, .semantic, .activeCycle, .safetyNotProven)
            }
        case .layout(let error):
            switch error {
            case .invalidDeclaration:
                fact(.invalidValue, .layout, .candidateFrame, .contained)
            case .arithmeticOverflow:
                fact(.arithmeticOverflow, .foundation, .operation, .contained)
            case .capacityExhausted:
                fact(.capacityExhausted, .layout, .candidateFrame, .contained)
            case .reentrancyViolation:
                fact(.reentrancyViolation, .layout, .activeCycle, .contained)
            case .invariantViolation:
                fact(.invariantViolation, .layout, .candidateFrame, .safetyNotProven)
            }
        case .observableState(let error):
            switch error {
            case .locationCapacityExhausted, .registrationCapacityExhausted:
                fact(.capacityExhausted, .observableState, .component, .contained)
            case .associationStagingCapacityExhausted:
                fact(.capacityExhausted, .observableState, .activeCycle, .contained)
            case .replacementStagingCapacityExhausted:
                fact(.capacityExhausted, .observableState, .operation, .contained)
            case .registrationGenerationExhausted:
                fact(.invalidIdentity, .observableState, .runtime, .safetyNotProven)
            case .duplicateOwner, .incompatibleAssociation, .staleAttachment:
                fact(
                    .invalidIdentity,
                    .observableState,
                    context.phase == .mutating ? .operation : .component,
                    .contained
                )
            case .invalidPhaseContained:
                fact(.invalidPhase, .observableState, .activeCycle, .contained)
            case .invalidPhaseSafetyNotProven:
                fact(.invalidPhase, .observableState, .activeCycle, .safetyNotProven)
            case .reentrancyViolation:
                fact(.reentrancyViolation, .observableState, .activeCycle, .safetyNotProven)
            case .invariantViolation:
                fact(.invariantViolation, .observableState, .runtime, .safetyNotProven)
            }
        case .interaction(let error):
            switch error {
            case .capacityExhausted:
                fact(.capacityExhausted, .interaction, .candidateFrame, .contained)
            case .invalidIdentity:
                fact(.invalidIdentity, .interaction, .candidateFrame, .contained)
            case .invalidGeometry, .incompatibleActionDomain, .invalidActionValue:
                fact(.invalidValue, .interaction, .candidateFrame, .contained)
            case .missingModelTarget:
                fact(.invalidIdentity, .observableState, .candidateFrame, .contained)
            case .invalidPhase:
                fact(.invalidPhase, .interaction, .activeCycle, .safetyNotProven)
            case .reentrancyViolation:
                fact(.reentrancyViolation, .interaction, .activeCycle, .safetyNotProven)
            case .invariantViolation:
                fact(.invariantViolation, .interaction, .runtime, .safetyNotProven)
            }
        case .drawing(let error):
            switch error {
            case .invalidValue, .invalidPathState:
                fact(.invalidValue, .rendering, .activeCycle, .contained)
            case .arithmeticOverflow:
                fact(.arithmeticOverflow, .foundation, .operation, .contained)
            case .capacityExhausted, .operationCapacityExhausted:
                fact(.capacityExhausted, .rendering, .activeCycle, .contained)
            case .invalidScope, .invalidPhase:
                fact(.invalidPhase, .rendering, .activeCycle, .safetyNotProven)
            case .reentrancyViolation:
                fact(.reentrancyViolation, .rendering, .activeCycle, .safetyNotProven)
            case .invariantViolation:
                fact(.invariantViolation, .rendering, .runtime, .safetyNotProven)
            }
        }
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
}
