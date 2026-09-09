import Testing

@testable import GiftUIExecution

private struct PendingWakeRecorder: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt8 = 0
    private(set) var reasons: ExecutionWakeReasons = []

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
        self.reasons.formUnion(reasons)
    }
}

private func makePendingCoordinator(
    maximum: UInt8 = 4
) -> RecordingPresentationPendingCoordinator<PendingWakeRecorder> {
    RecordingPresentationPendingCoordinator(
        maximumRetryableRefusals: maximum,
        requester: PendingWakeRecorder()
    )!
}

@Test
func backpressurePreservesSameRevisionCountWithoutConsumingBudget() {
    let revision = SemanticRevision(rawValue: 7)
    var subject = makePendingCoordinator()

    _ = subject.recordRetryableRefusal(for: revision)
    let transition = subject.recordBackpressure(for: revision)

    #expect(transition.intent?.retryableRefusalCount == 1)
    #expect(transition.operationalEvents == .backpressured)
    #expect(!transition.exhausted)
    #expect(subject.wakes.requester.requestCount == 1)
}

@Test
func newerBackpressureSupersedesOlderIntentAndStartsAtZero() {
    var subject = makePendingCoordinator()
    _ = subject.recordRetryableRefusal(for: SemanticRevision(rawValue: 1))

    let transition = subject.recordBackpressure(
        for: SemanticRevision(rawValue: 2)
    )

    #expect(transition.intent?.semanticRevision == SemanticRevision(rawValue: 2))
    #expect(transition.intent?.retryableRefusalCount == 0)
    #expect(
        transition.operationalEvents
            == [.backpressured, .superseded]
    )
}

@Test
func retryableRefusalStartsAtOneAndCheckedIncrements() {
    let revision = SemanticRevision(rawValue: 9)
    var subject = makePendingCoordinator()

    let first = subject.recordRetryableRefusal(for: revision)
    let second = subject.recordRetryableRefusal(for: revision)

    #expect(first.intent?.retryableRefusalCount == 1)
    #expect(second.intent?.retryableRefusalCount == 2)
    #expect(second.operationalEvents == .retryableRefusal)
    #expect(!second.operationalEvents.contains(.backpressured))
}

@Test
func newerRetryableRefusalSupersedesAndRestartsAtOne() {
    var subject = makePendingCoordinator()
    _ = subject.recordRetryableRefusal(for: SemanticRevision(rawValue: 3))
    _ = subject.recordRetryableRefusal(for: SemanticRevision(rawValue: 3))

    let transition = subject.recordRetryableRefusal(
        for: SemanticRevision(rawValue: 4)
    )

    #expect(transition.intent?.retryableRefusalCount == 1)
    #expect(
        transition.operationalEvents
            == [.retryableRefusal, .superseded]
    )
    #expect(!transition.operationalEvents.contains(.backpressured))
}

@Test
func pendingWakeCoalescesUntilSeparatelyPacedOpportunity() {
    var subject = makePendingCoordinator()
    _ = subject.recordBackpressure(for: SemanticRevision(rawValue: 1))
    _ = subject.recordBackpressure(for: SemanticRevision(rawValue: 2))
    #expect(subject.wakes.requester.requestCount == 1)

    #expect(subject.acknowledgeWakeAtIdleOpportunity() == .presentationPending)
    _ = subject.recordBackpressure(for: SemanticRevision(rawValue: 2))
    #expect(subject.wakes.requester.requestCount == 2)
}

@Test
func clearingOnlyMatchingRevisionCannotDiscardNewerIntent() {
    let latest = SemanticRevision(rawValue: 12)
    var subject = makePendingCoordinator()
    _ = subject.recordBackpressure(for: latest)

    subject.clearPending(for: SemanticRevision(rawValue: 11))
    #expect(subject.pendingIntent?.semanticRevision == latest)
    subject.clearPending(for: latest)
    #expect(subject.pendingIntent == nil)
}
