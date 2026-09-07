import Testing

@testable import GiftUIExecution

private struct WakeRecorder: ExecutionWakeRequester {
    var reasons: ExecutionWakeReasons = []
    var requestCount: UInt8 = 0

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        self.reasons.formUnion(reasons)
        requestCount &+= 1
    }
}

private struct PendingIntentFixtureOwner {
    let maximumRetryableRefusals: UInt8
    var intent: PresentationPendingIntent?

    mutating func observeBackpressure(for revision: SemanticRevision) {
        guard intent?.semanticRevision != revision else { return }
        intent = PresentationPendingIntent(
            semanticRevision: revision,
            retryableRefusalCount: 0
        )
    }

    mutating func observeRetryableRefusal(for revision: SemanticRevision) {
        let previous =
            intent?.semanticRevision == revision
            ? intent?.retryableRefusalCount ?? 0
            : 0
        let (next, overflow) = previous.addingReportingOverflow(1)
        guard !overflow, next < maximumRetryableRefusals
        else {
            intent = nil
            return
        }
        intent = PresentationPendingIntent(
            semanticRevision: revision,
            retryableRefusalCount: next
        )
    }
}

@Test
func executionWakeReasonsMaskUnknownBitsAndKeepExactKnownValues() {
    #expect(ExecutionWakeReasons.admittedWork.rawValue == 0x01)
    #expect(ExecutionWakeReasons.semanticDirty.rawValue == 0x02)
    #expect(ExecutionWakeReasons.presentationPending.rawValue == 0x04)
    #expect(ExecutionWakeReasons(rawValue: 0xFF).rawValue == 0x07)
    #expect(ExecutionWakeReasons(rawValue: 0xF8).isEmpty)
    #expect(MemoryLayout<ExecutionWakeReasons>.size == 1)

    var requester = WakeRecorder()
    requester.requestWake(for: [.admittedWork, .semanticDirty])
    #expect(requester.reasons.rawValue == 0x03)
    #expect(requester.requestCount == 1)
}

@Test
func presentationPendingIntentPreservesOnlyRevisionAndRetryCount() {
    let intent = PresentationPendingIntent(
        semanticRevision: SemanticRevision(rawValue: 42),
        retryableRefusalCount: 7
    )

    #expect(intent.semanticRevision == SemanticRevision(rawValue: 42))
    #expect(intent.retryableRefusalCount == 7)
    #expect(MemoryLayout<PresentationPendingIntent>.size <= 8)
}

@Test
func pendingIntentFixtureOwnerAppliesBackpressureAndRetryTransitions() {
    let first = SemanticRevision(rawValue: 1)
    let second = SemanticRevision(rawValue: 2)
    var owner = PendingIntentFixtureOwner(maximumRetryableRefusals: 3)

    owner.observeBackpressure(for: first)
    #expect(
        owner.intent
            == PresentationPendingIntent(
                semanticRevision: first,
                retryableRefusalCount: 0
            ))
    owner.observeBackpressure(for: first)
    #expect(owner.intent?.retryableRefusalCount == 0)

    owner.observeRetryableRefusal(for: first)
    #expect(owner.intent?.retryableRefusalCount == 1)
    owner.observeRetryableRefusal(for: first)
    #expect(owner.intent?.retryableRefusalCount == 2)
    owner.observeRetryableRefusal(for: first)
    #expect(owner.intent == nil)

    owner.observeRetryableRefusal(for: second)
    #expect(
        owner.intent
            == PresentationPendingIntent(
                semanticRevision: second,
                retryableRefusalCount: 1
            ))
    owner.observeBackpressure(for: first)
    #expect(
        owner.intent
            == PresentationPendingIntent(
                semanticRevision: first,
                retryableRefusalCount: 0
            ))
}
