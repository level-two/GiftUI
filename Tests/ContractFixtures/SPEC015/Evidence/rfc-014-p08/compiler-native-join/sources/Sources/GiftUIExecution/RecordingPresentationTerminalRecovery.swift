import GiftUI

enum RecordingPresentationTerminalReason: Equatable, Sendable {
    case retryableRefusalExhausted
    case nonRetryableRefusal(FrameRefusalOrigin)
    case requiredFacilityLost
}

struct RecordingPresentationTerminalOutcome: Equatable, Sendable {
    let reason: RecordingPresentationTerminalReason
    let logicalFrameDisposition: LogicalFrameDisposition
    let presentationIntentState: PresentationIntentState
    let executionFailure: ExecutionError?
    let residualAllowsPacedRetry: Bool
}

struct RecordingPresentationTerminalRecovery<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    private(set) var pendingIntent: PresentationPendingIntent?
    private(set) var capturedAction: CapturedAction<Identity>?
    private(set) var presentationInputQuiescent = false
    private(set) var requiredFacilityAvailable = true
    private(set) var reassemblyRequired = false

    init(
        pendingIntent: PresentationPendingIntent? = nil,
        capturedAction: CapturedAction<Identity>? = nil
    ) {
        self.pendingIntent = pendingIntent
        self.capturedAction = capturedAction
    }

    var canAdmitPresentationInput: Bool {
        requiredFacilityAvailable
            && !reassemblyRequired
            && !presentationInputQuiescent
    }

    mutating func terminate(
        for reason: RecordingPresentationTerminalReason,
        candidateAllocated: Bool
    ) -> RecordingPresentationTerminalOutcome {
        pendingIntent = nil
        capturedAction = nil
        presentationInputQuiescent = true
        requiredFacilityAvailable = false
        reassemblyRequired = true

        return RecordingPresentationTerminalOutcome(
            reason: reason,
            logicalFrameDisposition: candidateAllocated ? .aborted : .notProduced,
            presentationIntentState: .unavailable,
            executionFailure: reason == .requiredFacilityLost
                ? .requiredFacilityUnavailable
                : nil,
            residualAllowsPacedRetry: false
        )
    }

    mutating func reassembleRequiredFacility() {
        guard reassemblyRequired else { return }
        requiredFacilityAvailable = true
        reassemblyRequired = false
        presentationInputQuiescent = false
    }
}
