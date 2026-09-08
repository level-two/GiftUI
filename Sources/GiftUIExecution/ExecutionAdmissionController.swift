import GiftUI

protocol ExecutionPendingAdmissionStorage {
    associatedtype StateChangeFact: Sendable
    associatedtype CompletionFact: Sendable

    var pointerCount: UInt16 { get }
    var stateChangeCount: UInt16 { get }
    var completionCount: UInt16 { get }

    func isValid(stateChange: borrowing StateChangeFact) -> Bool
    func isValid(completion: borrowing CompletionFact) -> Bool

    mutating func enqueue(pointer: NormalizedPointerEvent) -> Bool
    mutating func enqueue(stateChange: StateChangeFact) -> Bool
    mutating func enqueue(completion: CompletionFact) -> Bool
    mutating func cancelPointerSequence(
        source: InputSourceID,
        sequence: PointerSequenceID
    )
}

struct SingleSourceExecutionAdmissionController<Storage, Requester>:
    ExecutionAdmissionSink
where
    Storage: ExecutionPendingAdmissionStorage,
    Requester: ExecutionWakeRequester & Sendable
{
    private let limits: ExecutionLimits
    private(set) var context: ExecutionContext
    private(set) var committedPresentationRevision: PresentationRevision?
    private(set) var isQuiescent: Bool
    private(set) var storage: Storage
    private(set) var wakeAccumulator: ExecutionWakeAccumulator<Requester>
    private(set) var isSealClosed: Bool = false
    private(set) var didDeferAfterSeal: Bool = false
    private var trackedSource: InputSourceID?
    private var sourceSequence = InputSourceSequenceState()

    init(
        limits: ExecutionLimits,
        context: ExecutionContext,
        committedPresentationRevision: PresentationRevision?,
        storage: Storage,
        requester: Requester,
        isQuiescent: Bool = false
    ) {
        self.limits = limits
        self.context = context
        self.committedPresentationRevision = committedPresentationRevision
        self.isQuiescent = isQuiescent
        self.storage = storage
        wakeAccumulator = ExecutionWakeAccumulator(requester: requester)
        trackedSource = nil
    }

    mutating func takeWakeAtIdleOpportunity() -> ExecutionWakeReasons {
        wakeAccumulator.takeAtIdleOpportunity(phase: .idle) ?? []
    }

    mutating func closeAdmissionSeal() {
        isSealClosed = true
    }

    mutating func submit(
        pointer: NormalizedPointerEvent
    ) -> ExecutionAdmissionOutcome {
        guard !isQuiescent else {
            cancel(pointer)
            return outcome(.unavailable)
        }
        guard pointer.presentationRevision == committedPresentationRevision else {
            cancel(pointer)
            return outcome(.invalidProvenance)
        }
        guard trackedSource == nil || trackedSource == pointer.source else {
            cancel(pointer)
            return outcome(.capacityRefused)
        }

        var proposedState = sourceSequence
        let validation = proposedState.validate(
            phase: pointer.phase,
            sequence: pointer.sequence,
            ordinal: pointer.ordinal,
            targetGateAllowsResynchronization: true
        )
        switch validation {
        case .invalidProvenance:
            sourceSequence = proposedState
            cancel(pointer)
            return outcome(.invalidProvenance)
        case .unavailable:
            sourceSequence = proposedState
            cancel(pointer)
            return outcome(.unavailable)
        case .accepted, .consumedWhileCancelled:
            break
        }

        guard storage.pointerCount < limits.maximumInputEvents,
            storage.enqueue(pointer: pointer)
        else {
            sourceSequence = proposedState
            cancel(pointer)
            return outcome(.capacityRefused)
        }

        trackedSource = pointer.source
        sourceSequence = proposedState
        recordQueuedWork()
        return outcome(.queued)
    }

    mutating func submit(
        stateChange: Storage.StateChangeFact
    ) -> ExecutionAdmissionOutcome {
        guard !isQuiescent else { return outcome(.unavailable) }
        guard storage.isValid(stateChange: stateChange) else {
            return outcome(.invalidValue)
        }
        guard storage.stateChangeCount < limits.maximumStateChangeFacts,
            storage.enqueue(stateChange: stateChange)
        else {
            return outcome(.capacityRefused)
        }

        recordQueuedWork()
        return outcome(.queued)
    }

    mutating func submit(
        completion: Storage.CompletionFact
    ) -> ExecutionAdmissionOutcome {
        guard !isQuiescent else { return outcome(.unavailable) }
        guard limits.maximumCompletionFacts > 0,
            storage.isValid(completion: completion)
        else {
            return outcome(.invalidValue)
        }
        guard storage.completionCount < limits.maximumCompletionFacts,
            storage.enqueue(completion: completion)
        else {
            return outcome(.capacityRefused)
        }

        recordQueuedWork()
        return outcome(.queued)
    }

    mutating func quiesce() {
        isQuiescent = true
    }

    private mutating func recordQueuedWork() {
        if isSealClosed {
            didDeferAfterSeal = true
        }
        wakeAccumulator.accumulate(.admittedWork)
    }

    private mutating func cancel(_ pointer: NormalizedPointerEvent) {
        if trackedSource == pointer.source {
            sourceSequence.cancelCurrentSequence()
        }
        storage.cancelPointerSequence(
            source: pointer.source,
            sequence: pointer.sequence
        )
    }

    private func outcome(
        _ result: ExecutionAdmissionResult
    ) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: result, context: context)
    }
}
