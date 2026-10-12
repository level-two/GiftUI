import GiftUI

@testable import GiftUIExecution

private struct AdmissionFact: Equatable, Sendable {
    let rawValue: UInt8
}

private struct AdmissionCompletion: Equatable, Sendable {
    let rawValue: UInt8
}

private struct AdmissionWakeRequester: ExecutionWakeRequester, Sendable {
    var requestCount: UInt16 = 0

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
    }
}

private struct TwoSlotAdmissionStorage: ExecutionPendingAdmissionStorage {
    var firstPointer: NormalizedPointerEvent?
    var secondPointer: NormalizedPointerEvent?
    var firstStateChange: AdmissionFact?
    var secondStateChange: AdmissionFact?
    var completion: AdmissionCompletion?
    var cancellationCount: UInt16 = 0

    var pointerCount: UInt16 {
        (firstPointer == nil ? 0 : 1) + (secondPointer == nil ? 0 : 1)
    }

    var stateChangeCount: UInt16 {
        (firstStateChange == nil ? 0 : 1)
            + (secondStateChange == nil ? 0 : 1)
    }

    var completionCount: UInt16 {
        completion == nil ? 0 : 1
    }

    func isValid(stateChange: borrowing AdmissionFact) -> Bool {
        stateChange.rawValue < 10
    }

    func isValid(completion: borrowing AdmissionCompletion) -> Bool {
        completion.rawValue < 10
    }

    mutating func enqueue(pointer: NormalizedPointerEvent) -> Bool {
        if firstPointer == nil {
            firstPointer = pointer
            return true
        }
        if secondPointer == nil {
            secondPointer = pointer
            return true
        }
        return false
    }

    mutating func enqueue(stateChange: AdmissionFact) -> Bool {
        if firstStateChange == nil {
            firstStateChange = stateChange
            return true
        }
        if secondStateChange == nil {
            secondStateChange = stateChange
            return true
        }
        return false
    }

    mutating func enqueue(completion: AdmissionCompletion) -> Bool {
        guard self.completion == nil else { return false }
        self.completion = completion
        return true
    }

    mutating func cancelPointerSequence(
        source: InputSourceID,
        sequence: PointerSequenceID
    ) {
        cancellationCount += 1
        if firstPointer?.source == source,
            firstPointer?.sequence == sequence
        {
            firstPointer = nil
        }
        if secondPointer?.source == source,
            secondPointer?.sequence == sequence
        {
            secondPointer = nil
        }
    }
}

private let admissionLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 1,
    maximumSemanticActions: 2,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

private let completionDisabledLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 0,
    maximumSemanticActions: 2,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

private let admissionContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 5),
    semanticRevision: SemanticRevision(rawValue: 7),
    candidateFrame: nil,
    phase: .mutating
)

private let committedPresentation = PresentationRevision(rawValue: 11)

private func pointer(
    phase: PointerPhase,
    source: UInt16 = 1,
    sequence: UInt32 = 0,
    ordinal: UInt32 = 0,
    revision: UInt32 = 11
) -> NormalizedPointerEvent {
    NormalizedPointerEvent(
        phase: phase,
        position: Point(x: 2, y: 3),
        source: InputSourceID(rawValue: source),
        sequence: PointerSequenceID(rawValue: sequence),
        ordinal: InputOrdinal(rawValue: ordinal),
        presentationRevision: PresentationRevision(rawValue: revision)
    )
}

private func controller(
    limits: ExecutionLimits = admissionLimits,
    revision: PresentationRevision? = committedPresentation,
    quiescent: Bool = false
) -> SingleSourceExecutionAdmissionController<
    TwoSlotAdmissionStorage, AdmissionWakeRequester
> {
    SingleSourceExecutionAdmissionController(
        limits: limits,
        context: admissionContext,
        committedPresentationRevision: revision,
        storage: TwoSlotAdmissionStorage(),
        requester: AdmissionWakeRequester(),
        isQuiescent: quiescent
    )
}

func queuedSubmissionsCopyCompleteValuesAndRequestOneWake() {
    var owner = controller()
    let pointerValue = pointer(phase: .down)
    let stateValue = AdmissionFact(rawValue: 3)
    let completionValue = AdmissionCompletion(rawValue: 4)

    precondition(owner.submit(pointer: pointerValue).result == .queued)
    precondition(owner.submit(stateChange: stateValue).result == .queued)
    precondition(owner.submit(completion: completionValue).result == .queued)
    precondition(owner.storage.firstPointer == pointerValue)
    precondition(owner.storage.firstStateChange == stateValue)
    precondition(owner.storage.completion == completionValue)
    precondition(owner.wakeAccumulator.requester.requestCount == 1)
}

func everyOutcomePreservesTheExactCurrentContext() {
    var queued = controller()
    precondition(queued.submit(stateChange: AdmissionFact(rawValue: 1)).context == admissionContext)

    var invalid = controller()
    precondition(invalid.submit(stateChange: AdmissionFact(rawValue: 99)).context == admissionContext)

    var unavailable = controller(quiescent: true)
    precondition(
        unavailable.submit(completion: AdmissionCompletion(rawValue: 1)).context == admissionContext
    )
}

func invalidAndDisabledFactsRetainNoCopyAndRequestNoWake() {
    var owner = controller(limits: completionDisabledLimits)
    precondition(
        owner.submit(stateChange: AdmissionFact(rawValue: 99)).result
            == .invalidValue
    )
    precondition(
        owner.submit(completion: AdmissionCompletion(rawValue: 1)).result
            == .invalidValue
    )
    precondition(owner.storage.stateChangeCount == 0)
    precondition(owner.storage.completionCount == 0)
    precondition(owner.wakeAccumulator.requester.requestCount == 0)
}

func categoryCapacityRefusalRetainsNoRejectedCopyOrExtraWake() {
    var owner = controller()
    precondition(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .queued)
    precondition(owner.submit(stateChange: AdmissionFact(rawValue: 2)).result == .queued)
    precondition(
        owner.submit(stateChange: AdmissionFact(rawValue: 3)).result
            == .capacityRefused
    )
    precondition(owner.storage.firstStateChange == AdmissionFact(rawValue: 1))
    precondition(owner.storage.secondStateChange == AdmissionFact(rawValue: 2))
    precondition(owner.wakeAccumulator.requester.requestCount == 1)
}

func pointerProvenanceAndSequenceFailureCancelWithoutQueuing() {
    var stale = controller()
    precondition(
        stale.submit(pointer: pointer(phase: .down, revision: 10)).result
            == .invalidProvenance
    )
    precondition(stale.storage.pointerCount == 0)
    precondition(stale.storage.cancellationCount == 1)

    var malformed = controller()
    precondition(
        malformed.submit(pointer: pointer(phase: .down, ordinal: 1)).result
            == .invalidProvenance
    )
    precondition(malformed.storage.pointerCount == 0)
    precondition(malformed.storage.cancellationCount == 1)
    precondition(malformed.wakeAccumulator.requester.requestCount == 0)
}

func pointerCapacityAndNewSourceRefusalPerformMandatoryCancellation() {
    var owner = controller()
    precondition(owner.submit(pointer: pointer(phase: .down)).result == .queued)
    precondition(
        owner.submit(
            pointer: pointer(phase: .down, source: 2, sequence: 0)
        ).result == .capacityRefused
    )
    precondition(owner.storage.cancellationCount == 1)

    precondition(
        owner.submit(
            pointer: pointer(phase: .move, ordinal: 1)
        ).result == .queued
    )
    precondition(
        owner.submit(
            pointer: pointer(phase: .up, ordinal: 2)
        ).result == .capacityRefused
    )
    precondition(owner.storage.pointerCount == 0)
    precondition(owner.storage.cancellationCount == 2)
}

func quiescenceRefusesEveryFamilyAndPointerCancellationIsMandatory() {
    var owner = controller(quiescent: true)
    precondition(owner.submit(pointer: pointer(phase: .down)).result == .unavailable)
    precondition(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .unavailable)
    precondition(owner.submit(completion: AdmissionCompletion(rawValue: 1)).result == .unavailable)
    precondition(owner.storage.pointerCount == 0)
    precondition(owner.storage.stateChangeCount == 0)
    precondition(owner.storage.completionCount == 0)
    precondition(owner.storage.cancellationCount == 1)
    precondition(owner.wakeAccumulator.requester.requestCount == 0)
}

func submissionNeverAppliesFactsOrPromisesCurrentCycleMembership() {
    var owner = controller()
    precondition(owner.context.phase == .mutating)
    precondition(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .queued)
    precondition(owner.context == admissionContext)
    precondition(owner.storage.firstStateChange == AdmissionFact(rawValue: 1))
}

func workArrivingAfterSealIsDeferredAndRequestsFreshWake() {
    var owner = controller()
    precondition(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .queued)
    precondition(owner.takeWakeAtIdleOpportunity() == .admittedWork)
    owner.closeAdmissionSeal()

    precondition(owner.submit(completion: AdmissionCompletion(rawValue: 2)).result == .queued)
    precondition(owner.didDeferAfterSeal)
    precondition(owner.wakeAccumulator.requester.requestCount == 2)
    precondition(owner.wakeAccumulator.accumulatedReasons == .admittedWork)
    precondition(owner.storage.firstStateChange == AdmissionFact(rawValue: 1))
    precondition(owner.storage.completion == AdmissionCompletion(rawValue: 2))
}
