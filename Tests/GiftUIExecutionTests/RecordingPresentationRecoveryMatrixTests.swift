import Testing

@testable import GiftUIExecution

private struct RecoveryWakeRequester: ExecutionWakeRequester, Equatable, Sendable {
    mutating func requestWake(for reasons: ExecutionWakeReasons) {}
}

private struct RecoveryIdentity: Equatable, Sendable {
    let rawValue: UInt8
}

private let recoveryRevision = SemanticRevision(rawValue: 42)
private let recoveryCapture = CapturedAction(
    identity: RecoveryIdentity(rawValue: 3),
    generation: ActionGeneration(rawValue: 8)
)

@Test
func everyConfiguredMaximumRetainsBelowAndExhaustsAtExactLimit() {
    for rawMaximum in UInt16(1) ... UInt16(255) {
        let maximum = UInt8(rawMaximum)
        var subject = RecordingPresentationPendingCoordinator(
            maximumRetryableRefusals: maximum,
            requester: RecoveryWakeRequester()
        )!

        for expected in UInt16(1) ... rawMaximum {
            let transition = subject.recordRetryableRefusal(
                for: recoveryRevision
            )
            if expected < rawMaximum {
                #expect(!transition.exhausted)
                #expect(
                    transition.intent?.retryableRefusalCount
                        == UInt8(expected)
                )
            } else {
                #expect(transition.exhausted)
                #expect(transition.intent == nil)
                #expect(subject.pendingIntent == nil)
            }
        }
    }
}

@Test
func checkedIncrementFailureNeverWrapsOrRequestsRetry() {
    let impossibleStoredIntent = PresentationPendingIntent(
        semanticRevision: recoveryRevision,
        retryableRefusalCount: .max
    )
    var subject = RecordingPresentationPendingCoordinator(
        maximumRetryableRefusals: .max,
        pendingIntent: impossibleStoredIntent,
        requester: RecoveryWakeRequester()
    )!

    let transition = subject.recordRetryableRefusal(for: recoveryRevision)

    #expect(transition.exhausted)
    #expect(transition.intent == nil)
    #expect(subject.pendingIntent == nil)
    #expect(subject.wakes.requester == RecoveryWakeRequester())
}

@Test
func terminalReasonsClearPendingCaptureAndQuiesceInput() {
    let reasons: [RecordingPresentationTerminalReason] = [
        .retryableRefusalExhausted,
        .nonRetryableRefusal(.renderProducer),
        .nonRetryableRefusal(.endpoint),
        .requiredFacilityLost,
    ]

    for reason in reasons {
        var subject = makeTerminalRecovery()
        let outcome = subject.terminate(for: reason, candidateAllocated: true)

        #expect(subject.pendingIntent == nil)
        #expect(subject.capturedAction == nil)
        #expect(subject.presentationInputQuiescent)
        #expect(!subject.canAdmitPresentationInput)
        #expect(subject.reassemblyRequired)
        #expect(outcome.logicalFrameDisposition == .aborted)
        #expect(outcome.presentationIntentState == .unavailable)
        #expect(!outcome.residualAllowsPacedRetry)
    }
}

@Test
func facilityLossDistinguishesBeforeAndAfterCandidateAllocation() {
    for candidateAllocated in [false, true] {
        var subject = makeTerminalRecovery()
        let outcome = subject.terminate(
            for: .requiredFacilityLost,
            candidateAllocated: candidateAllocated
        )

        #expect(
            outcome.logicalFrameDisposition
                == (candidateAllocated ? .aborted : .notProduced)
        )
        #expect(outcome.executionFailure == .requiredFacilityUnavailable)
    }
}

@Test
func onlyExplicitReassemblyReopensPresentationAdmission() {
    var subject = makeTerminalRecovery()
    _ = subject.terminate(
        for: .nonRetryableRefusal(.endpoint),
        candidateAllocated: false
    )

    #expect(!subject.canAdmitPresentationInput)
    subject.reassembleRequiredFacility()
    #expect(subject.canAdmitPresentationInput)
    #expect(!subject.reassemblyRequired)
    #expect(subject.capturedAction == nil)
    #expect(subject.pendingIntent == nil)
}

private func makeTerminalRecovery()
    -> RecordingPresentationTerminalRecovery<RecoveryIdentity>
{
    RecordingPresentationTerminalRecovery(
        pendingIntent: PresentationPendingIntent(
            semanticRevision: recoveryRevision,
            retryableRefusalCount: 2
        ),
        capturedAction: recoveryCapture
    )
}
