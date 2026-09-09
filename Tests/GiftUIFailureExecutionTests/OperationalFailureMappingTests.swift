import Testing

@testable import GiftUIExecution
@testable import GiftUIFailureCore
@testable import GiftUIFailureExecution

private let operationalContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 8),
    semanticRevision: SemanticRevision(rawValue: 13),
    candidateFrame: CandidateFrameID(rawValue: 21),
    phase: .finalizing
)

@Test
func everyOperationalPrimaryMapsExactFactAndCorrelation() {
    let cases:
        [(
            ExecutionOperational,
            ExecutionOperationalEvents,
            GiftUIOperationalKind,
            GiftUIFailureOrigin,
            GiftUIAffectedScope
        )] = [
            (.noChange, .noChange, .noChange, .execution, .activeCycle),
            (.backpressured, .backpressured, .backpressured, .backend, .candidateFrame),
            (.retryableRefusal, .retryableRefusal, .retryableRefusal, .backend, .candidateFrame),
            (.superseded, .superseded, .superseded, .execution, .candidateFrame),
            (
                .deferredToLaterAdmission,
                .deferredToLaterAdmission,
                .deferredToLaterAdmission,
                .execution,
                .activeCycle
            ),
        ]

    for (primary, events, kind, origin, scope) in cases {
        let mapped = GiftUIExecutionFailureAdapter.operational(
            primary,
            completeEvents: events,
            context: operationalContext,
            attemptOrdinal: 0,
            attemptLimit: 3,
            mechanicalEffectsComplete: true
        )
        #expect(mapped?.context == operationalContext)
        #expect(mapped?.fact.kind == kind)
        #expect(mapped?.fact.origin == origin)
        #expect(mapped?.fact.affectedScope == scope)
        #expect(mapped?.completeEvents == events)
    }
}

@Test
func completeEventSetUsesExactPrimaryPrecedenceWithoutLoss() {
    let events: ExecutionOperationalEvents = [
        .retryableRefusal,
        .superseded,
        .deferredToLaterAdmission,
    ]
    let mapped = GiftUIExecutionFailureAdapter.operational(
        .retryableRefusal,
        completeEvents: events,
        context: operationalContext,
        attemptOrdinal: 2,
        attemptLimit: 5,
        mechanicalEffectsComplete: true
    )
    #expect(mapped?.completeEvents == events)
    #expect(mapped?.attemptOrdinal == 2)
    #expect(mapped?.attemptLimit == 5)
}

@Test
func mappingRejectsWrongPrimaryInvalidAttemptsAndIncompleteEffects() {
    #expect(
        GiftUIExecutionFailureAdapter.operational(
            .superseded,
            completeEvents: [.backpressured, .superseded],
            context: operationalContext,
            attemptOrdinal: 0,
            attemptLimit: 1,
            mechanicalEffectsComplete: true
        ) == nil
    )
    for (ordinal, limit) in [(UInt8(0), UInt8(0)), (2, 2)] {
        #expect(
            GiftUIExecutionFailureAdapter.operational(
                .noChange,
                completeEvents: .noChange,
                context: operationalContext,
                attemptOrdinal: ordinal,
                attemptLimit: limit,
                mechanicalEffectsComplete: true
            ) == nil
        )
    }
    #expect(
        GiftUIExecutionFailureAdapter.operational(
            .backpressured,
            completeEvents: .backpressured,
            context: operationalContext,
            attemptOrdinal: 0,
            attemptLimit: 2,
            mechanicalEffectsComplete: false
        ) == nil
    )
}

@Test
func residualPolicyInputPreservesAttemptsAndRestrictsPacedRetry() {
    let retryable = GiftUIExecutionFailureAdapter.operational(
        .retryableRefusal,
        completeEvents: .retryableRefusal,
        context: operationalContext,
        attemptOrdinal: 1,
        attemptLimit: 3,
        mechanicalEffectsComplete: true
    )!
    let paced = GiftUIExecutionFailureAdapter.residualInput(
        for: retryable,
        allowed: .requestPacedRetry
    )
    #expect(paced?.attemptOrdinal == 1)
    #expect(paced?.attemptLimit == 3)
    #expect(paced?.context == operationalContext)

    let exhausted = GiftUIExecutionFailureAdapter.operational(
        .retryableRefusal,
        completeEvents: .retryableRefusal,
        context: operationalContext,
        attemptOrdinal: 2,
        attemptLimit: 3,
        mechanicalEffectsComplete: true
    )!
    #expect(
        GiftUIExecutionFailureAdapter.residualInput(
            for: exhausted,
            allowed: .requestPacedRetry
        ) == nil
    )

    let noChange = GiftUIExecutionFailureAdapter.operational(
        .noChange,
        completeEvents: .noChange,
        context: operationalContext,
        attemptOrdinal: 0,
        attemptLimit: 1,
        mechanicalEffectsComplete: true
    )!
    for allowed in [
        GiftUIAllowedDispositions.continueOperation,
        .markFacilityUnavailable,
        .quiesceAffectedScope,
        .invokeFatalHook,
    ] {
        #expect(
            GiftUIExecutionFailureAdapter.residualInput(
                for: noChange,
                allowed: allowed
            ) != nil
        )
    }
    #expect(
        GiftUIExecutionFailureAdapter.residualInput(
            for: noChange,
            allowed: .requestPacedRetry
        ) == nil
    )
}
