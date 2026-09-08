import GiftUI
import Testing

@testable import GiftUIExecution

private struct RecordingEventBuffer: RecordingCycleEventSink {
    var events: [RecordingCycleEvent] = []

    mutating func record(_ event: borrowing RecordingCycleEvent) {
        events.append(copy event)
    }
}

private struct RecordingWakeRequester: ExecutionWakeRequester, Sendable {
    var requestCount: UInt16 = 0

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
    }
}

private let recordingLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 1,
    maximumSemanticActions: 2,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

private func coordinator(
    path: RecordingCyclePath
) -> RecordingCycleCoordinator<RecordingEventBuffer, RecordingWakeRequester> {
    RecordingCycleCoordinator(
        path: path,
        limits: recordingLimits,
        sink: RecordingEventBuffer(),
        requester: RecordingWakeRequester()
    )!
}

@Test
func unchangedRecordingCycleUsesCanonicalPhaseAndResultEvents() {
    var subject = coordinator(path: .unchanged)
    subject.requestWake(.admittedWork)
    let result = subject.runOpportunity()

    guard case .operational(.noChange, let summary) = result else {
        Issue.record("unchanged cycle selected the wrong result")
        return
    }
    #expect(summary.cycle == RunCycleID(rawValue: 0))
    #expect(summary.semanticDisposition == .unchanged)
    #expect(summary.operationalEvents == .noChange)
    #expect(
        subject.sink.events.map(\.kind)
            == [
                .wakeTransition,
                .wakeTaken,
                .admitting,
                .mutating,
                .deriving,
                .finalizing,
                .resultSelected,
                .idleAuthoritativeState,
            ]
    )
    #expect(subject.sink.events[1].wakeReasons == .admittedWork)
    #expect(subject.sink.events.last?.context.phase == .idle)
}

@Test
func publishedRecordingCycleCoversPublishingOfferingAndAuthoritativeState() {
    var subject = coordinator(path: .publishedAndOffered)
    subject.requestWake([.semanticDirty, .presentationPending])
    let result = subject.runOpportunity()

    guard case .success(let summary) = result else {
        Issue.record("published cycle selected the wrong result")
        return
    }
    #expect(summary.semanticRevision == SemanticRevision(rawValue: 0))
    #expect(summary.semanticDisposition == .published)
    #expect(summary.logicalFrameDisposition == .committed)
    #expect(
        summary.committedPresentationRevision
            == PresentationRevision(rawValue: 0)
    )
    #expect(
        subject.sink.events.map(\.kind)
            == [
                .wakeTransition,
                .wakeTaken,
                .admitting,
                .mutating,
                .deriving,
                .publishing,
                .offering,
                .finalizing,
                .resultSelected,
                .idleAuthoritativeState,
            ]
    )
    let idle = subject.sink.events.last
    #expect(idle?.context.phase == .idle)
    #expect(idle?.context.semanticRevision == SemanticRevision(rawValue: 0))
    #expect(
        idle?.committedPresentationRevision
            == PresentationRevision(rawValue: 0)
    )
}

@Test
func wakeTransitionsCoalesceAndLaterCyclesUseFreshIdentities() {
    var subject = coordinator(path: .publishedAndOffered)
    subject.requestWake(.admittedWork)
    subject.requestWake(.semanticDirty)
    #expect(subject.wakeAccumulator.requester.requestCount == 1)
    #expect(subject.sink.events.map(\.kind) == [.wakeTransition])

    _ = subject.runOpportunity()
    subject.requestWake(.presentationPending)
    let second = subject.runOpportunity()
    #expect(subject.wakeAccumulator.requester.requestCount == 2)
    guard case .success(let summary) = second else {
        Issue.record("second cycle selected the wrong result")
        return
    }
    #expect(summary.cycle == RunCycleID(rawValue: 1))
    #expect(summary.semanticRevision == SemanticRevision(rawValue: 1))
    #expect(
        summary.committedPresentationRevision
            == PresentationRevision(rawValue: 1)
    )
}

@Test
func coordinatorIsDrivenThroughTheOpportunityRunnerProtocol() {
    func run<Runner: ExecutionOpportunityRunner>(
        _ runner: inout Runner
    ) -> RunCycleResult<Runner.OwnerFailure> {
        runner.runOpportunity()
    }

    var subject = coordinator(path: .unchanged)
    let result = run(&subject)
    guard case .operational(.noChange, _) = result else {
        Issue.record("protocol-driven cycle selected the wrong result")
        return
    }
}
