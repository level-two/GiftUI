import GiftUIFailureCore
import GiftUIFailureExecution
import GiftUIRuntimeCore

package enum GiftUIRuntimeFailureAdapter {
    package static func validation(
        _ error: RuntimeProfileValidationError
    ) -> GiftUIFailureFact {
        switch error {
        case .invalidLimits, .incompatibleLimits:
            fact(.invalidValue, .hostComposition, .runtime, .contained)
        case .missingStorage, .insufficientStorage:
            fact(.capacityExhausted, .hostComposition, .runtime, .contained)
        case .arithmeticOverflow:
            fact(.arithmeticOverflow, .foundation, .runtime, .contained)
        case .staticCanvasTableInvalid, .invariantViolation:
            fact(.invariantViolation, .hostComposition, .runtime, .safetyNotProven)
        }
    }

    package static func preservingFocusedOwner(
        _ correlated: CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>
    ) -> CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>? {
        correlated
    }

    package static func focusedOwner(
        _ correlated: CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>,
        cleanupContainment: RuntimeCleanupFailureContainment
    ) -> CorrelatedRuntimeOwnerFailure {
        var mapped = ownerFact(correlated)
        if cleanupContainment == .safetyNotProven,
            mapped.containment == .contained
        {
            mapped = GiftUIFailureFact(
                condition: mapped.condition,
                origin: mapped.origin,
                affectedScope: mapped.affectedScope,
                containment: .safetyNotProven
            )
        }
        return CorrelatedRuntimeOwnerFailure(
            correlated: correlated,
            fact: mapped
        )
    }

    private static func ownerFact(
        _ correlated: CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>
    ) -> GiftUIFailureFact {
        switch correlated.failure {
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
                    correlated.context.phase == .mutating ? .operation : .component,
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

package struct CorrelatedRuntimeOwnerFailure: Equatable, Sendable {
    package let correlated: CorrelatedFocusedOwnerFailure<RuntimeOwnerFailure>
    package let fact: GiftUIFailureFact
}
