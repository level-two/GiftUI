import GiftUIExecution
import Testing

@testable import GiftUIHostConfiguration

private let firstRecoveryRevision = SemanticRevision(rawValue: 11)
private let secondRecoveryRevision = SemanticRevision(rawValue: 12)

@Test func backpressureRetainsIntentWithoutIncrementingRefusalCount() {
    var recovery = HostPresentationRecovery(maximumRetryableRefusals: 3)!
    let first = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)
    let backpressured = recovery.recordBackpressure(revision: firstRecoveryRevision)

    #expect(first.pendingIntent?.retryableRefusalCount == 1)
    #expect(backpressured.disposition == .pendingBackpressure)
    #expect(backpressured.pendingIntent?.retryableRefusalCount == 1)
    #expect(backpressured.policyContext == .presentationBackpressure)
    #expect(backpressured.policyAttemptOrdinal == 0)
    #expect(backpressured.policyAttemptLimit == 3)
    #expect(
        backpressured.completedEffects
            == [.discardCandidate, .retainPendingIntent, .preserveRefusalCount]
    )
}

@Test func retryableRefusalsUseOrdinalsZeroAndOneThenThirdTerminates() {
    var recovery = HostPresentationRecovery(maximumRetryableRefusals: 3)!
    let first = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)
    let second = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)
    let third = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)
    let fourth = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)

    #expect(first.policyAttemptOrdinal == 0)
    #expect(first.pendingIntent?.retryableRefusalCount == 1)
    #expect(second.policyAttemptOrdinal == 1)
    #expect(second.pendingIntent?.retryableRefusalCount == 2)
    #expect(third.disposition == .unavailable)
    #expect(third.pendingIntent == nil)
    #expect(third.policyContext == .presentationUnavailable)
    #expect(!third.inputIsEligible)
    #expect(fourth == third)
}

@Test func newerRevisionSupersedesOldIntentInConstantSpace() {
    var recovery = HostPresentationRecovery(maximumRetryableRefusals: 3)!
    _ = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)
    _ = recovery.recordRetryableRefusal(revision: firstRecoveryRevision)
    let superseding = recovery.recordBackpressure(revision: secondRecoveryRevision)

    #expect(
        superseding.pendingIntent
            == PresentationPendingIntent(
                semanticRevision: secondRecoveryRevision,
                retryableRefusalCount: 0
            )
    )
    #expect(MemoryLayout<HostPresentationRecovery>.stride <= 16)
}

@Test func nonRetryableRefusalClearsIntentAndQuiescesInputImmediately() {
    var recovery = HostPresentationRecovery(maximumRetryableRefusals: 3)!
    _ = recovery.recordBackpressure(revision: firstRecoveryRevision)
    let terminal = recovery.recordNonRetryableRefusal()

    #expect(terminal.disposition == .unavailable)
    #expect(terminal.pendingIntent == nil)
    #expect(terminal.completedEffects == [.clearPendingIntent, .quiesceInput])
    #expect(!recovery.isAvailable)
    #expect(!recovery.inputIsEligible)
}

@Test func acceptanceClearsOnlyTheMatchingIntentWithoutReplayState() {
    var recovery = HostPresentationRecovery(maximumRetryableRefusals: 3)!
    _ = recovery.recordBackpressure(revision: firstRecoveryRevision)
    let unrelated = recovery.recordAccepted(revision: secondRecoveryRevision)
    #expect(unrelated.pendingIntent?.semanticRevision == firstRecoveryRevision)

    let accepted = recovery.recordAccepted(revision: firstRecoveryRevision)
    #expect(accepted.disposition == .satisfied)
    #expect(accepted.pendingIntent == nil)
    #expect(accepted.policyContext == nil)
    #expect(accepted.completedEffects.isEmpty)
}

@Test func zeroRetryLimitIsRejected() {
    #expect(HostPresentationRecovery(maximumRetryableRefusals: 0) == nil)
}
