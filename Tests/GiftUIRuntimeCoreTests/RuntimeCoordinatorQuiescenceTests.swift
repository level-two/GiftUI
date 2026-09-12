import GiftUIExecution
import Testing

@testable import GiftUIRuntimeCore

private let idleQuiescenceActions: [RuntimeQuiescenceAction] = [
    .refuseAdmission,
    .cancelPointerSources,
    .detachObservableRegistrations,
    .releaseAdmissionQueues,
    .releaseCommittedRouting,
    .resetAllStorage,
]

private let activeQuiescenceActions: [RuntimeQuiescenceAction] = [
    .refuseAdmission,
    .cancelPointerSources,
    .finishActiveCycleContainment,
    .detachObservableRegistrations,
    .releaseAdmissionQueues,
    .releaseCommittedRouting,
    .resetAllStorage,
]

@Test
func idleAndActiveQuiescencePlansHaveExactFiniteOrder() {
    for (origin, expected) in [
        (RuntimeQuiescenceOrigin.idle, idleQuiescenceActions),
        (.activeCycle, activeQuiescenceActions),
    ] {
        let plan = RuntimeCoordinatorQuiescenceOracle.plan(origin: origin)
        var tracker = RuntimeQuiescenceTracker(plan: plan)
        var actual: [RuntimeQuiescenceAction] = []
        while let action = tracker.takeNext() {
            actual.append(action)
        }
        #expect(actual == expected)
        #expect(tracker.isComplete)
        #expect(tracker.takeNext() == nil)
        #expect(plan.prohibitedCalls == .all)
    }
}

@Test
func activeQuiescenceFinishesOnlyMandatoryContainmentBeforeTeardown() {
    let plan = RuntimeCoordinatorQuiescenceOracle.plan(origin: .activeCycle)
    #expect(plan.actions.contains(.finishActiveCycleContainment))
    #expect(plan.actions.contains(.resetAllStorage))
    #expect(plan.prohibitedCalls.contains(.newCycle))
    #expect(plan.prohibitedCalls.contains(.endpointOffer))
    #expect(plan.prohibitedCalls.contains(.handler))
    #expect(plan.prohibitedCalls.contains(.diagnostic))
}

@Test
func lifecycleQuiescenceIsSynchronousFromIdleAndDeferredOnlyForActiveContainment() {
    var idle = makeIdleRuntimeCoordinatorLifecycle()
    idle.requestQuiescence()
    #expect(idle.state == .quiescent)
    #expect(idle.beginAdmission() == .requiredFacilityUnavailable)

    var active = makeIdleRuntimeCoordinatorLifecycle()
    let admitting = ExecutionContext(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )
    #expect(active.beginOpportunity(context: admitting) == nil)
    active.requestQuiescence()
    active.requestQuiescence()
    #expect(active.state == .active)
    #expect(
        active.finishOpportunity(
            context: ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
        ) == nil
    )
    #expect(active.state == .quiescent)
    let didTearDown = active.completeTeardown()
    #expect(didTearDown)
    #expect(active.state == .tornDown)
    #expect(active.beginAdmission() == .requiredFacilityUnavailable)
}
