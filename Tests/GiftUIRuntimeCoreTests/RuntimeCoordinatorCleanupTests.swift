import Testing

@testable import GiftUIRuntimeCore

private let allCleanupActions = RuntimeCleanupActions(rawValue: 0x01FF)

private let allCoordinatorStages: [RuntimeCoordinatorStage] = [
    .observableBindingOrSemanticExpansion,
    .layout,
    .canvasInvocationOrPlan,
    .combinedRenderPreflight,
    .interactionBuildOrGeneration,
    .offerProductionOrEndpoint,
    .acceptedOffer,
]

private let cleanupRows: [(RuntimeCoordinatorStage, [RuntimeCleanupAction])] = [
    (
        .observableBindingOrSemanticExpansion,
        [
            .releaseCanvasCallable,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    ),
    (
        .layout,
        [
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    ),
    (
        .canvasInvocationOrPlan,
        [
            .releaseCanvasCallable,
            .resetDrawingPlan,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    ),
    (
        .combinedRenderPreflight,
        [
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    ),
    (
        .interactionBuildOrGeneration,
        [
            .discardInteractionCandidate,
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    ),
    (
        .offerProductionOrEndpoint,
        [
            .discardInteractionCandidate,
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetAttemptStorage,
        ]
    ),
    (
        .acceptedOffer,
        [.commitInteractionCandidate, .resetAttemptStorage]
    ),
]

@Test
func cleanupOracleCoversEveryStageWithExactOrderedActions() {
    #expect(cleanupRows.map(\.0) == allCoordinatorStages)
    for (stage, expected) in cleanupRows {
        let plan = RuntimeCoordinatorCleanupOracle.plan(after: stage)
        #expect(plan.stage == stage)
        #expect(!plan.laterFallibleWorkIsPermitted)
        var tracker = RuntimeCleanupTracker(plan: plan, acquired: allCleanupActions)
        var actual: [RuntimeCleanupAction] = []
        while let action = tracker.takeNext() {
            actual.append(action)
        }
        #expect(actual == expected)
        #expect(tracker.isComplete)
        #expect(tracker.takeNext() == nil)
    }
}

@Test
func cleanupRunsOnlyForObligationsThatActuallyBegan() {
    let acquired: RuntimeCleanupActions = [
        .resetLayoutCandidate,
        .discardSemanticCandidate,
        .resetAttemptStorage,
    ]
    let plan = RuntimeCoordinatorCleanupOracle.plan(after: .interactionBuildOrGeneration)
    var tracker = RuntimeCleanupTracker(plan: plan, acquired: acquired)
    var actual: [RuntimeCleanupAction] = []
    while let action = tracker.takeNext() {
        actual.append(action)
    }

    #expect(
        actual
            == [
                .resetLayoutCandidate,
                .discardSemanticCandidate,
                .resetAttemptStorage,
            ]
    )
}

@Test
func mutationApplicationIsAtMostOnceAndNeverBecomesCleanupWork() {
    var mutation = RuntimeMutationApplicationState()
    let first = mutation.markApplied()
    let replay = mutation.markApplied()

    #expect(first)
    #expect(!replay)
    #expect(mutation.wasApplied)
    for stage in allCoordinatorStages {
        let plan = RuntimeCoordinatorCleanupOracle.plan(after: stage)
        #expect(plan.actions.rawValue & ~allCleanupActions.rawValue == 0)
    }
}

@Test
func prepublicationAndPostpublicationPlansRespectCandidateBoundaries() {
    let prepublication = RuntimeCoordinatorCleanupOracle.plan(after: .interactionBuildOrGeneration)
    #expect(prepublication.actions.contains(.discardSemanticCandidate))
    #expect(prepublication.actions.contains(.discardObservableCandidate))
    #expect(prepublication.actions.contains(.discardInteractionCandidate))

    let postpublication = RuntimeCoordinatorCleanupOracle.plan(after: .offerProductionOrEndpoint)
    #expect(!postpublication.actions.contains(.discardSemanticCandidate))
    #expect(!postpublication.actions.contains(.discardObservableCandidate))
    #expect(postpublication.actions.contains(.discardInteractionCandidate))

    let accepted = RuntimeCoordinatorCleanupOracle.plan(after: .acceptedOffer)
    #expect(accepted.actions.contains(.commitInteractionCandidate))
    #expect(!accepted.actions.contains(.discardInteractionCandidate))
}
