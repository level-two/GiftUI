import GiftUI

struct RecordingPendingTransition: Equatable, Sendable {
    let intent: PresentationPendingIntent?
    let operationalEvents: ExecutionOperationalEvents
    let exhausted: Bool
}

struct RecordingPresentationPendingCoordinator<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    let maximumRetryableRefusals: UInt8
    private(set) var pendingIntent: PresentationPendingIntent?
    private(set) var wakes: ExecutionWakeAccumulator<Requester>

    init?(
        maximumRetryableRefusals: UInt8,
        pendingIntent: PresentationPendingIntent? = nil,
        requester: Requester
    ) {
        guard maximumRetryableRefusals > 0 else { return nil }
        self.maximumRetryableRefusals = maximumRetryableRefusals
        self.pendingIntent = pendingIntent
        wakes = ExecutionWakeAccumulator(requester: requester)
    }

    mutating func recordBackpressure(
        for latestRevision: SemanticRevision
    ) -> RecordingPendingTransition {
        var events: ExecutionOperationalEvents = .backpressured
        let count: UInt8
        if let pendingIntent, pendingIntent.semanticRevision == latestRevision {
            count = pendingIntent.retryableRefusalCount
        } else {
            if pendingIntent != nil {
                events.formUnion(.superseded)
            }
            count = 0
        }

        let intent = PresentationPendingIntent(
            semanticRevision: latestRevision,
            retryableRefusalCount: count
        )
        pendingIntent = intent
        wakes.accumulate(.presentationPending)
        return RecordingPendingTransition(
            intent: intent,
            operationalEvents: events,
            exhausted: false
        )
    }

    mutating func recordRetryableRefusal(
        for latestRevision: SemanticRevision
    ) -> RecordingPendingTransition {
        var events: ExecutionOperationalEvents = .retryableRefusal
        let previous: UInt8
        if let pendingIntent, pendingIntent.semanticRevision == latestRevision {
            previous = pendingIntent.retryableRefusalCount
        } else {
            if pendingIntent != nil {
                events.formUnion(.superseded)
            }
            previous = 0
        }

        let (next, overflow) = previous.addingReportingOverflow(1)
        guard !overflow, next < maximumRetryableRefusals else {
            pendingIntent = nil
            return RecordingPendingTransition(
                intent: nil,
                operationalEvents: events,
                exhausted: true
            )
        }

        let intent = PresentationPendingIntent(
            semanticRevision: latestRevision,
            retryableRefusalCount: next
        )
        pendingIntent = intent
        wakes.accumulate(.presentationPending)
        return RecordingPendingTransition(
            intent: intent,
            operationalEvents: events,
            exhausted: false
        )
    }

    mutating func clearPending(for revision: SemanticRevision) {
        guard pendingIntent?.semanticRevision == revision else { return }
        pendingIntent = nil
    }

    mutating func acknowledgeWakeAtIdleOpportunity() -> ExecutionWakeReasons {
        wakes.takeAtIdleOpportunity(phase: .idle) ?? []
    }
}
