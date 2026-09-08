import GiftUI
import Testing

@testable import GiftUIExecution

@Test
func everyLegalOperationalEventSetRetainsAllEventsAndExactPrimary() {
    let eventSets: [ExecutionOperationalEvents] = [
        [],
        .noChange,
        .deferredToLaterAdmission,
        [.noChange, .deferredToLaterAdmission],
        .superseded,
        [.superseded, .deferredToLaterAdmission],
        .backpressured,
        [.backpressured, .superseded],
        [.backpressured, .deferredToLaterAdmission],
        [.backpressured, .superseded, .deferredToLaterAdmission],
        .retryableRefusal,
        [.retryableRefusal, .superseded],
        [.retryableRefusal, .deferredToLaterAdmission],
        [.retryableRefusal, .superseded, .deferredToLaterAdmission],
    ]

    for events in eventSets {
        var phases = activeFinalizerPhases(through: .deriving)
        var finalizer = RecordingCycleFinalizer<RecordingFixtureOwnerFailure>()
        finalizer.recordOperational(events)
        let result = finalizer.finalize(
            summary: finalizerSummary(events: events),
            phases: &phases
        )

        if events.isEmpty {
            guard case .success(let summary) = result else {
                Issue.record("empty event set did not select success")
                continue
            }
            #expect(summary.operationalEvents.isEmpty)
        } else {
            guard case .operational(let primary, let summary) = result else {
                Issue.record("event set did not select operational: \(events.rawValue)")
                continue
            }
            #expect(primary == expectedPrimary(for: events))
            #expect(summary.operationalEvents == events)
        }
    }
}

@Test
func failureAlwaysPrecedesOperationalAndRetainsCompleteSummary() {
    var phases = activeFinalizerPhases(through: .offering)
    var finalizer = RecordingCycleFinalizer<RecordingFixtureOwnerFailure>()
    let events: ExecutionOperationalEvents = [
        .retryableRefusal,
        .superseded,
        .deferredToLaterAdmission,
    ]
    finalizer.recordOperational(events)
    let context = phases.context
    finalizer.captureFirstFailure(.focusedOwner(.layout), context: context)
    finalizer.captureFirstFailure(
        .execution(.invariantViolation),
        context: phases.context
    )

    let result = finalizer.finalize(
        summary: finalizerSummary(events: events),
        phases: &phases
    )
    guard case .failure(let retainedContext, .focusedOwner(.layout), let summary) = result else {
        Issue.record("failure did not outrank operational events")
        return
    }
    #expect(retainedContext == context)
    #expect(summary?.operationalEvents == events)
}

@Test
func everyActiveExitFinalizesOnceReleasesResourcesAndReturnsIdle() {
    let phasesToExit: [ExecutionPhase] = [
        .admitting,
        .mutating,
        .deriving,
        .publishing,
        .offering,
    ]

    for phase in phasesToExit {
        var phases = activeFinalizerPhases(through: phase)
        var finalizer = RecordingCycleFinalizer<RecordingFixtureOwnerFailure>()
        let result = finalizer.finalize(
            summary: finalizerSummary(events: []),
            phases: &phases
        )
        guard case .success(let summary) = result else {
            Issue.record("failed to finalize from \(phase)")
            continue
        }
        #expect(summary.cycle == RunCycleID(rawValue: 0))
        #expect(finalizer.finalizingCount == 1)
        #expect(!finalizer.scratchHeld)
        #expect(!finalizer.borrowHeld)
        #expect(finalizer.didFinalize)
        #expect(finalizer.finalContext?.phase == .idle)
        #expect(finalizer.finalContext?.cycle == nil)
        #expect(finalizer.finalContext?.candidateFrame == nil)
        #expect(finalizer.finalize(summary: summary, phases: &phases) == nil)
        #expect(finalizer.finalizingCount == 1)
    }
}

private func expectedPrimary(
    for events: ExecutionOperationalEvents
) -> ExecutionOperational {
    if events.contains(.retryableRefusal) { return .retryableRefusal }
    if events.contains(.backpressured) { return .backpressured }
    if events.contains(.superseded) { return .superseded }
    if events.contains(.deferredToLaterAdmission) {
        return .deferredToLaterAdmission
    }
    return .noChange
}

private func activeFinalizerPhases(
    through target: ExecutionPhase
) -> ExecutionPhaseMachine {
    var phases = ExecutionPhaseMachine()
    var cycles = RunCycleIDAllocator()
    #expect(phases.beginCycle(reservingFrom: &cycles) == nil)
    if target == .admitting { return phases }
    #expect(phases.transition(to: .mutating) == nil)
    if target == .mutating { return phases }
    #expect(phases.transition(to: .deriving) == nil)
    if target == .deriving { return phases }
    #expect(phases.transition(to: .publishing) == nil)
    if target == .publishing { return phases }
    #expect(phases.transition(to: .offering) == nil)
    return phases
}

private func finalizerSummary(
    events: ExecutionOperationalEvents
) -> RunCycleSummary {
    let limits = ExecutionLimits(
        maximumInputEvents: 1,
        maximumStateChangeFacts: 1,
        maximumCompletionFacts: 0,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 1,
        maximumCommittedActions: 1
    )!
    let admission = AdmissionSummary(
        inputEventCount: 0,
        stateChangeFactCount: 0,
        completionFactCount: 0,
        semanticActionCount: 0,
        includesDirtyRederivation: false,
        includesPresentationRecovery: false,
        limits: limits
    )!
    let publishes =
        events.contains(.superseded)
        || events.contains(.backpressured)
        || events.contains(.retryableRefusal)
    let aborts =
        events.contains(.backpressured)
        || events.contains(.retryableRefusal)
    return RunCycleSummary(
        cycle: RunCycleID(rawValue: 0),
        admission: admission,
        semanticRevision: publishes ? SemanticRevision(rawValue: 2) : nil,
        semanticDisposition: publishes ? .published : .unchanged,
        logicalFrameDisposition: aborts ? .aborted : .notProduced,
        committedPresentationRevision: nil,
        presentationIntentState: aborts ? .pending : .satisfied,
        presentationPending: aborts
            ? PresentationPendingIntent(
                semanticRevision: SemanticRevision(rawValue: 2),
                retryableRefusalCount: 0
            )
            : nil,
        operationalEvents: events
    )!
}
