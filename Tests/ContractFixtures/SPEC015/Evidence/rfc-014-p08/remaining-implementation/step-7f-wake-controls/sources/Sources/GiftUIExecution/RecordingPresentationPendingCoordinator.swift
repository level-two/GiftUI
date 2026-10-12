import GiftUI

struct RecordingPendingTransition: Equatable, Sendable {
    let intent: PresentationPendingIntent?
    let operationalEvents: ExecutionOperationalEvents
    let exhausted: Bool
}

struct PresentationPendingState: Sendable {
    let maximumRetryableRefusals: UInt8
    private(set) var pendingIntent: PresentationPendingIntent?

    init?(
        maximumRetryableRefusals: UInt8,
        pendingIntent: PresentationPendingIntent? = nil
    ) {
        guard maximumRetryableRefusals > 0 else { return nil }
        self.maximumRetryableRefusals = maximumRetryableRefusals
        self.pendingIntent = pendingIntent
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

}

// Recording callers keep their existing wake behavior around the same policy.
struct RecordingPresentationPendingCoordinator<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    private var state: PresentationPendingState
    private(set) var wakes: ExecutionWakeAccumulator<Requester>
    var maximumRetryableRefusals: UInt8 { state.maximumRetryableRefusals }
    var pendingIntent: PresentationPendingIntent? { state.pendingIntent }
    init?(
        maximumRetryableRefusals: UInt8, pendingIntent: PresentationPendingIntent? = nil,
        requester: Requester
    ) {
        guard
            let state = PresentationPendingState(
                maximumRetryableRefusals: maximumRetryableRefusals, pendingIntent: pendingIntent)
        else { return nil }
        self.state = state
        wakes = ExecutionWakeAccumulator(requester: requester)
    }
    mutating func recordBackpressure(for latestRevision: SemanticRevision)
        -> RecordingPendingTransition
    {
        let transition = state.recordBackpressure(for: latestRevision)
        wakes.accumulate(.presentationPending)
        return transition
    }
    mutating func recordRetryableRefusal(for latestRevision: SemanticRevision)
        -> RecordingPendingTransition
    {
        let transition = state.recordRetryableRefusal(for: latestRevision)
        if !transition.exhausted { wakes.accumulate(.presentationPending) }
        return transition
    }
    mutating func clearPending(for revision: SemanticRevision) { state.clearPending(for: revision) }
    mutating func acknowledgeWakeAtIdleOpportunity() -> ExecutionWakeReasons {
        wakes.takeAtIdleOpportunity(phase: .idle) ?? []
    }
}
