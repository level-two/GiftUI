import Testing

@testable import GiftUIExecution
@testable import GiftUIFailureCore
@testable import GiftUIFailureExecution

private let mappedContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 17),
    semanticRevision: SemanticRevision(rawValue: 23),
    candidateFrame: CandidateFrameID(rawValue: 31),
    phase: .admitting
)

@Test
func everyAdmissionResultMapsAfterMechanicalEffectsWithExactContext() {
    let cases:
        [(
            ExecutionAdmissionResult,
            GiftUIConditionID?,
            GiftUIFailureOrigin?,
            GiftUIAffectedScope?
        )] = [
            (.queued, nil, nil, nil),
            (.capacityRefused, .capacityExhausted, .execution, .operation),
            (.unavailable, .requiredFacilityUnavailable, .execution, .runtime),
            (.invalidValue, .invalidValue, .execution, .operation),
            (.invalidProvenance, .invalidProvenance, .execution, .operation),
        ]

    for (result, condition, origin, scope) in cases {
        let admission = ExecutionAdmissionOutcome(
            result: result,
            context: mappedContext
        )
        let mapped = GiftUIExecutionFailureAdapter.admission(
            admission,
            mechanicalEffectsComplete: true
        )
        #expect(mapped?.context == mappedContext)

        switch mapped?.outcome {
        case .success? where result == .queued:
            break
        case .failure(let fact)?:
            #expect(fact.condition == condition)
            #expect(fact.origin == origin)
            #expect(fact.affectedScope == scope)
            #expect(fact.containment == .contained)
        default:
            Issue.record("unexpected admission mapping for \(result)")
        }
    }
}

@Test
func admissionMappingCannotPrecedePointerCancellationEffects() {
    let admission = ExecutionAdmissionOutcome(
        result: .invalidProvenance,
        context: mappedContext
    )
    #expect(
        GiftUIExecutionFailureAdapter.admission(
            admission,
            mechanicalEffectsComplete: false
        ) == nil
    )
}

@Test
func everyExecutionErrorMapsToExactFactAndPreservedContext() {
    let cases:
        [(
            ExecutionError,
            GiftUIAffectedScope,
            Bool,
            GiftUIConditionID,
            GiftUIFailureOrigin,
            GiftUIContainment
        )] = [
            (.invalidValue, .operation, true, .invalidValue, .execution, .contained),
            (.arithmeticOverflow, .operation, true, .arithmeticOverflow, .foundation, .contained),
            (.capacityExhausted, .activeCycle, true, .capacityExhausted, .execution, .contained),
            (.capacityExhausted, .candidateFrame, true, .capacityExhausted, .execution, .contained),
            (.identityExhausted, .operation, true, .invalidIdentity, .execution, .contained),
            (.identityExhausted, .activeCycle, true, .invalidIdentity, .execution, .contained),
            (.identityExhausted, .runtime, false, .invalidIdentity, .execution, .safetyNotProven),
            (.invalidProvenance, .operation, true, .invalidProvenance, .execution, .contained),
            (.invalidPhase, .activeCycle, true, .invalidPhase, .execution, .contained),
            (
                .reentrancyViolation, .activeCycle, true, .reentrancyViolation, .execution,
                .safetyNotProven
            ),
            (
                .requiredFacilityUnavailable, .runtime, true, .requiredFacilityUnavailable,
                .execution, .contained
            ),
            (
                .invariantViolation, .runtime, true, .invariantViolation, .execution,
                .safetyNotProven
            ),
        ]

    for (error, scope, safeReuse, condition, origin, containment) in cases {
        let mapped = GiftUIExecutionFailureAdapter.execution(
            error,
            context: mappedContext,
            provenAffectedScope: scope,
            safeReuseProven: safeReuse,
            mechanicalEffectsComplete: true
        )
        #expect(mapped?.context == mappedContext)
        #expect(mapped?.fact.condition == condition)
        #expect(mapped?.fact.origin == origin)
        #expect(mapped?.fact.affectedScope == scope)
        #expect(mapped?.fact.containment == containment)
    }
}

@Test
func executionMappingRejectsUnprovenScopeOrIncompleteCycleEffects() {
    for error in ExecutionError.fixtureCases {
        #expect(
            GiftUIExecutionFailureAdapter.execution(
                error,
                context: mappedContext,
                provenAffectedScope: .component,
                safeReuseProven: false,
                mechanicalEffectsComplete: true
            ) == nil
        )
        #expect(
            GiftUIExecutionFailureAdapter.execution(
                error,
                context: mappedContext,
                provenAffectedScope: .runtime,
                safeReuseProven: false,
                mechanicalEffectsComplete: false
            ) == nil
        )
    }
}

extension ExecutionError {
    fileprivate static let fixtureCases: [ExecutionError] = [
        .invalidValue,
        .arithmeticOverflow,
        .capacityExhausted,
        .identityExhausted,
        .invalidProvenance,
        .invalidPhase,
        .reentrancyViolation,
        .requiredFacilityUnavailable,
        .invariantViolation,
    ]
}
