import GiftUI

@usableFromInline
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

@usableFromInline
struct SingleSourceExecutionAdmissionState<Storage>: ExecutionAdmissionSink
where Storage: ExecutionPendingAdmissionStorage {
    @usableFromInline
    internal let limits: ExecutionLimits
    @usableFromInline
    internal var context: ExecutionContext
    @usableFromInline
    internal var committedPresentationRevision: PresentationRevision?
    @usableFromInline
    internal var isQuiescent: Bool
    @usableFromInline
    internal var storage: Storage
    @usableFromInline
    internal var isSealClosed: Bool = false
    @usableFromInline
    internal var didDeferAfterSeal: Bool = false
    @usableFromInline
    internal var trackedSource: InputSourceID?
    @usableFromInline
    internal var sourceSequence = InputSourceSequenceState()

    @inlinable
    @inline(__always)
    static var pointerStateStorageBytes: Int {
        MemoryLayout<InputSourceID?>.size + MemoryLayout<InputSourceSequenceState>.size
    }

    @inlinable
    init(
        limits: ExecutionLimits,
        context: ExecutionContext,
        committedPresentationRevision: PresentationRevision?,
        storage: Storage,
        isQuiescent: Bool = false
    ) {
        self.limits = limits
        self.context = context
        self.committedPresentationRevision = committedPresentationRevision
        self.isQuiescent = isQuiescent
        self.storage = storage
        trackedSource = nil
    }

    // The serialized containing coordinator supplies its current publication and
    // phase before producer admission; pointer-order state remains owned here.
    @inlinable
    mutating func synchronize(
        context: ExecutionContext,
        committedPresentationRevision: PresentationRevision?,
        sealClosed: Bool,
        quiescent: Bool
    ) {
        if self.context.cycle != context.cycle { didDeferAfterSeal = false }
        self.context = context
        self.committedPresentationRevision = committedPresentationRevision
        isSealClosed = sealClosed
        isQuiescent = isQuiescent || quiescent
    }

    @inlinable
    mutating func closeAdmissionSeal() {
        isSealClosed = true
    }

    @inlinable
    @inline(__always)
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

    @inlinable
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

    @inlinable
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

    @inlinable
    mutating func quiesce() {
        isQuiescent = true
    }

    @inlinable
    internal mutating func recordQueuedWork() {
        if isSealClosed {
            didDeferAfterSeal = true
        }
    }

    @inlinable
    @inline(__always)
    internal mutating func cancel(_ pointer: NormalizedPointerEvent) {
        if trackedSource == pointer.source {
            sourceSequence.cancelCurrentSequence()
        }
        storage.cancelPointerSequence(
            source: pointer.source,
            sequence: pointer.sequence
        )
    }

    @inlinable
    internal func outcome(
        _ result: ExecutionAdmissionResult
    ) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: result, context: context)
    }
}

// Existing callers retain the same wake-owning controller. The state is also
// usable inside a containing runtime with one canonical wake owner.
@usableFromInline
struct SingleSourceExecutionAdmissionController<Storage, Requester>: ExecutionAdmissionSink
where Storage: ExecutionPendingAdmissionStorage, Requester: ExecutionWakeRequester & Sendable {
    private var state: SingleSourceExecutionAdmissionState<Storage>
    private(set) var wakeAccumulator: ExecutionWakeAccumulator<Requester>
    var context: ExecutionContext { state.context }
    var committedPresentationRevision: PresentationRevision? { state.committedPresentationRevision }
    var isQuiescent: Bool { state.isQuiescent }
    var storage: Storage { state.storage }
    var isSealClosed: Bool { state.isSealClosed }
    var didDeferAfterSeal: Bool { state.didDeferAfterSeal }
    @inlinable
    @inline(__always)
    static var pointerStateStorageBytes: Int {
        SingleSourceExecutionAdmissionState<Storage>.pointerStateStorageBytes
    }
    init(
        limits: ExecutionLimits, context: ExecutionContext,
        committedPresentationRevision: PresentationRevision?, storage: Storage,
        requester: Requester, isQuiescent: Bool = false
    ) {
        state = SingleSourceExecutionAdmissionState(
            limits: limits, context: context,
            committedPresentationRevision: committedPresentationRevision, storage: storage,
            isQuiescent: isQuiescent)
        wakeAccumulator = ExecutionWakeAccumulator(requester: requester)
    }
    mutating func synchronize(
        context: ExecutionContext, committedPresentationRevision: PresentationRevision?,
        sealClosed: Bool, quiescent: Bool
    ) {
        state.synchronize(
            context: context, committedPresentationRevision: committedPresentationRevision,
            sealClosed: sealClosed, quiescent: quiescent)
    }
    mutating func takeWakeAtIdleOpportunity() -> ExecutionWakeReasons {
        wakeAccumulator.takeAtIdleOpportunity(phase: .idle) ?? []
    }
    mutating func closeAdmissionSeal() { state.closeAdmissionSeal() }
    @usableFromInline
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        record(state.submit(pointer: pointer))
    }
    @usableFromInline
    mutating func submit(stateChange: Storage.StateChangeFact) -> ExecutionAdmissionOutcome {
        record(state.submit(stateChange: stateChange))
    }
    @usableFromInline
    mutating func submit(completion: Storage.CompletionFact) -> ExecutionAdmissionOutcome {
        record(state.submit(completion: completion))
    }
    mutating func quiesce() { state.quiesce() }
    private mutating func record(_ outcome: ExecutionAdmissionOutcome) -> ExecutionAdmissionOutcome
    {
        if outcome.result == .queued { wakeAccumulator.accumulate(.admittedWork) }
        return outcome
    }
}
