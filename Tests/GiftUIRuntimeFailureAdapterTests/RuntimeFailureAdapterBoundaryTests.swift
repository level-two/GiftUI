import GiftUIExecution
import GiftUIFailureCore
import GiftUIFailureExecution
import GiftUIRuntimeCore
import GiftUIRuntimeFailureAdapterFixture
import Testing

@Test
func runtimeFailureAdapterTargetLoadsBesideRuntimeCore() {}

@Test
func everyValidationErrorMapsToItsExactRuntimeFact() {
    let containedInvalidValue = GiftUIFailureFact(
        condition: .invalidValue,
        origin: .hostComposition,
        affectedScope: .runtime,
        containment: .contained
    )
    let containedCapacity = GiftUIFailureFact(
        condition: .capacityExhausted,
        origin: .hostComposition,
        affectedScope: .runtime,
        containment: .contained
    )
    let rows: [(RuntimeProfileValidationError, GiftUIFailureFact)] = [
        (.invalidLimits, containedInvalidValue),
        (.incompatibleLimits, containedInvalidValue),
        (.missingStorage, containedCapacity),
        (.insufficientStorage, containedCapacity),
        (
            .arithmeticOverflow,
            GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .runtime,
                containment: .contained
            )
        ),
        (
            .staticCanvasTableInvalid,
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .hostComposition,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
        ),
        (
            .invariantViolation,
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .hostComposition,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
        ),
    ]

    for (error, expected) in rows {
        #expect(GiftUIRuntimeFailureAdapter.validation(error) == expected)
    }
}

@Test
func everyFocusedOwnerCaseSurvivesExecutionCorrelationExactly() {
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 2),
        semanticRevision: SemanticRevision(rawValue: 3),
        candidateFrame: CandidateFrameID(rawValue: 4),
        phase: .deriving
    )
    let failures: [RuntimeOwnerFailure] = [
        .semantic(.capacityExhausted),
        .layout(.arithmeticOverflow),
        .observableState(.staleAttachment),
        .interaction(.missingModelTarget),
        .drawing(.invalidPathState),
    ]

    for expected in failures {
        let correlated = GiftUIExecutionFailureAdapter.focusedOwner(
            from: RunCycleFailure.focusedOwner(expected),
            context: context
        )
        guard let correlated,
            let preserved = GiftUIRuntimeFailureAdapter.preservingFocusedOwner(correlated)
        else {
            Issue.record("expected focused-owner correlation")
            continue
        }
        #expect(preserved.context == context)
        #expect(preserved.failure == expected)
    }
}

@Test
func runtimeOwnerFailureFitsExecutionOwnerFailureCeiling() {
    #expect(MemoryLayout<RuntimeOwnerFailure>.size <= 2)
    #expect(MemoryLayout<RuntimeOwnerFailure>.stride <= 2)
}

@Test
func focusedOwnerFactsPreserveExactOwnerMeaningAndExecutionCorrelation() {
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 5),
        semanticRevision: SemanticRevision(rawValue: 6),
        candidateFrame: CandidateFrameID(rawValue: 7),
        phase: .deriving
    )
    let rows: [(RuntimeOwnerFailure, GiftUIFailureFact)] = [
        (
            .semantic(.invalidIdentity),
            ownerFact(.invalidIdentity, .semantic, .activeCycle, .contained)
        ),
        (
            .layout(.arithmeticOverflow),
            ownerFact(.arithmeticOverflow, .foundation, .operation, .contained)
        ),
        (
            .observableState(.associationStagingCapacityExhausted),
            ownerFact(.capacityExhausted, .observableState, .activeCycle, .contained)
        ),
        (
            .interaction(.missingModelTarget),
            ownerFact(.invalidIdentity, .observableState, .candidateFrame, .contained)
        ),
        (
            .drawing(.invalidScope),
            ownerFact(.invalidPhase, .rendering, .activeCycle, .safetyNotProven)
        ),
    ]

    for (failure, expectedFact) in rows {
        let correlated = CorrelatedFocusedOwnerFailure(context: context, failure: failure)
        let mapped = GiftUIRuntimeFailureAdapter.focusedOwner(
            correlated,
            cleanupContainment: .none
        )
        #expect(mapped.correlated == correlated)
        #expect(mapped.fact == expectedFact)
    }
}

@Test
func secondaryCleanupOnlyWidensContainmentAndResidualInputUsesCorrelatedContext() {
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 8),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .deriving
    )
    let correlated = CorrelatedFocusedOwnerFailure(
        context: context,
        failure: RuntimeOwnerFailure.semantic(.capacityExhausted)
    )
    let widened = GiftUIRuntimeFailureAdapter.focusedOwner(
        correlated,
        cleanupContainment: .safetyNotProven
    )

    #expect(widened.correlated == correlated)
    #expect(widened.fact.condition == .capacityExhausted)
    #expect(widened.fact.origin == .semantic)
    #expect(widened.fact.affectedScope == .activeCycle)
    #expect(widened.fact.containment == .safetyNotProven)
    let residual = GiftUIResidualPolicyInput(
        outcome: GiftUIOutcome.failure(widened.fact),
        context: widened.correlated.context,
        allowed: .quiesceAffectedScope,
        attemptOrdinal: 0,
        attemptLimit: 1
    )
    #expect(residual?.context == context)
    guard case .failure(let residualFact) = residual?.outcome else {
        Issue.record("expected residual failure input")
        return
    }
    #expect(residualFact == widened.fact)
}

@Test
func diagnosticSelectionCannotAlterFocusedOwnerMapping() {
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 9),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .deriving
    )
    let correlated = CorrelatedFocusedOwnerFailure(
        context: context,
        failure: RuntimeOwnerFailure.drawing(.capacityExhausted)
    )
    let baseline = GiftUIRuntimeFailureAdapter.focusedOwner(
        correlated,
        cleanupContainment: .contained
    )

    for _ in 0 ..< 4 {
        #expect(
            GiftUIRuntimeFailureAdapter.focusedOwner(
                correlated,
                cleanupContainment: .contained
            ) == baseline
        )
    }
}

private func ownerFact(
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
