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
