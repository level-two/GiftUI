struct RecordingSelectedFailure<OwnerFailure>: Equatable, Sendable
where OwnerFailure: Equatable & Sendable {
    let context: ExecutionContext
    let failure: RunCycleFailure<OwnerFailure>
}

struct RecordingCycleFinalizer<OwnerFailure>: Equatable, Sendable
where OwnerFailure: Equatable & Sendable {
    private(set) var operationalEvents: ExecutionOperationalEvents = []
    private(set) var selectedFailure: RecordingSelectedFailure<OwnerFailure>?
    private(set) var scratchHeld = true
    private(set) var borrowHeld = true
    private(set) var finalizingCount: UInt8 = 0
    private(set) var finalContext: ExecutionContext?
    private(set) var didFinalize = false

    mutating func recordOperational(
        _ events: ExecutionOperationalEvents
    ) {
        operationalEvents.formUnion(events)
    }

    mutating func captureFirstFailure(
        _ failure: RunCycleFailure<OwnerFailure>,
        context: ExecutionContext
    ) {
        guard selectedFailure == nil else { return }
        selectedFailure = RecordingSelectedFailure(
            context: context,
            failure: failure
        )
    }

    mutating func finalize(
        summary base: RunCycleSummary,
        phases: inout ExecutionPhaseMachine
    ) -> RunCycleResult<OwnerFailure>? {
        guard !didFinalize else { return nil }
        guard
            let summary = RunCycleSummary(
                cycle: base.cycle,
                admission: base.admission,
                semanticRevision: base.semanticRevision,
                semanticDisposition: base.semanticDisposition,
                logicalFrameDisposition: base.logicalFrameDisposition,
                committedPresentationRevision: base.committedPresentationRevision,
                presentationIntentState: base.presentationIntentState,
                presentationPending: base.presentationPending,
                operationalEvents: operationalEvents
            ),
            phases.transition(to: .finalizing) == nil
        else { return nil }

        finalizingCount += 1
        scratchHeld = false
        borrowHeld = false
        didFinalize = true

        guard phases.transition(to: .idle) == nil else { return nil }
        finalContext = phases.context

        if let selectedFailure {
            return .failure(
                selectedFailure.context,
                selectedFailure.failure,
                summary
            )
        }
        if let primary = primaryOperationalEvent() {
            return .operational(primary, summary)
        }
        return .success(summary)
    }

    private func primaryOperationalEvent() -> ExecutionOperational? {
        if operationalEvents.contains(.retryableRefusal) {
            return .retryableRefusal
        }
        if operationalEvents.contains(.backpressured) {
            return .backpressured
        }
        if operationalEvents.contains(.superseded) {
            return .superseded
        }
        if operationalEvents.contains(.deferredToLaterAdmission) {
            return .deferredToLaterAdmission
        }
        if operationalEvents.contains(.noChange) {
            return .noChange
        }
        return nil
    }
}
