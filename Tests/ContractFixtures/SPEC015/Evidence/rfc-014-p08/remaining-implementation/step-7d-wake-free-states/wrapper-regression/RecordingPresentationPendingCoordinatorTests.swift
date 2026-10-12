
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

func backpressurePreservesSameRevisionCountWithoutConsumingBudget() {
    let revision = SemanticRevision(rawValue: 7)
    var subject = makePendingCoordinator()

    _ = subject.recordRetryableRefusal(for: revision)
    let transition = subject.recordBackpressure(for: revision)

    precondition(transition.intent?.retryableRefusalCount == 1)
    precondition(transition.operationalEvents == .backpressured)
    precondition(!transition.exhausted)
    precondition(subject.wakes.requester.requestCount == 1)
}

func newerBackpressureSupersedesOlderIntentAndStartsAtZero() {
    var subject = makePendingCoordinator()
    _ = subject.recordRetryableRefusal(for: SemanticRevision(rawValue: 1))

    let transition = subject.recordBackpressure(
        for: SemanticRevision(rawValue: 2)
    )

    precondition(transition.intent?.semanticRevision == SemanticRevision(rawValue: 2))
    precondition(transition.intent?.retryableRefusalCount == 0)
    precondition(
        transition.operationalEvents
            == [.backpressured, .superseded]
    )
}

func retryableRefusalStartsAtOneAndCheckedIncrements() {
    let revision = SemanticRevision(rawValue: 9)
    var subject = makePendingCoordinator()

    let first = subject.recordRetryableRefusal(for: revision)
    let second = subject.recordRetryableRefusal(for: revision)

    precondition(first.intent?.retryableRefusalCount == 1)
    precondition(second.intent?.retryableRefusalCount == 2)
    precondition(second.operationalEvents == .retryableRefusal)
    precondition(!second.operationalEvents.contains(.backpressured))
}

func newerRetryableRefusalSupersedesAndRestartsAtOne() {
    var subject = makePendingCoordinator()
    _ = subject.recordRetryableRefusal(for: SemanticRevision(rawValue: 3))
    _ = subject.recordRetryableRefusal(for: SemanticRevision(rawValue: 3))

    let transition = subject.recordRetryableRefusal(
        for: SemanticRevision(rawValue: 4)
    )

    precondition(transition.intent?.retryableRefusalCount == 1)
    precondition(
        transition.operationalEvents
            == [.retryableRefusal, .superseded]
    )
    precondition(!transition.operationalEvents.contains(.backpressured))
}

func pendingWakeCoalescesUntilSeparatelyPacedOpportunity() {
    var subject = makePendingCoordinator()
    _ = subject.recordBackpressure(for: SemanticRevision(rawValue: 1))
    _ = subject.recordBackpressure(for: SemanticRevision(rawValue: 2))
    precondition(subject.wakes.requester.requestCount == 1)

    precondition(subject.acknowledgeWakeAtIdleOpportunity() == .presentationPending)
    _ = subject.recordBackpressure(for: SemanticRevision(rawValue: 2))
    precondition(subject.wakes.requester.requestCount == 2)
}

func clearingOnlyMatchingRevisionCannotDiscardNewerIntent() {
    let latest = SemanticRevision(rawValue: 12)
    var subject = makePendingCoordinator()
    _ = subject.recordBackpressure(for: latest)

    subject.clearPending(for: SemanticRevision(rawValue: 11))
    precondition(subject.pendingIntent?.semanticRevision == latest)
    subject.clearPending(for: latest)
    precondition(subject.pendingIntent == nil)
}

func repeatedBackpressureRetainsOneIntentAndOneOutstandingWake() {
    var subject = makePendingCoordinator()

    for rawValue in 1 ... 100 {
        let transition = subject.recordBackpressure(
            for: SemanticRevision(rawValue: UInt32(rawValue))
        )
        precondition(transition.intent?.semanticRevision == SemanticRevision(rawValue: UInt32(rawValue)))
        precondition(transition.intent?.retryableRefusalCount == 0)
        precondition(!transition.exhausted)
    }

    precondition(subject.pendingIntent?.semanticRevision == SemanticRevision(rawValue: 100))
    precondition(subject.wakes.requester.requestCount == 1)
    precondition(MemoryLayout<PresentationPendingIntent>.stride <= 8)
}
