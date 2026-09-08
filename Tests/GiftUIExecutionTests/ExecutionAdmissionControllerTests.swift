import GiftUI
import Testing

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

@Test
func queuedSubmissionsCopyCompleteValuesAndRequestOneWake() {
    var owner = controller()
    let pointerValue = pointer(phase: .down)
    let stateValue = AdmissionFact(rawValue: 3)
    let completionValue = AdmissionCompletion(rawValue: 4)

    #expect(owner.submit(pointer: pointerValue).result == .queued)
    #expect(owner.submit(stateChange: stateValue).result == .queued)
    #expect(owner.submit(completion: completionValue).result == .queued)
    #expect(owner.storage.firstPointer == pointerValue)
    #expect(owner.storage.firstStateChange == stateValue)
    #expect(owner.storage.completion == completionValue)
    #expect(owner.wakeAccumulator.requester.requestCount == 1)
}

@Test
func everyOutcomePreservesTheExactCurrentContext() {
    var queued = controller()
    #expect(queued.submit(stateChange: AdmissionFact(rawValue: 1)).context == admissionContext)

    var invalid = controller()
    #expect(invalid.submit(stateChange: AdmissionFact(rawValue: 99)).context == admissionContext)

    var unavailable = controller(quiescent: true)
    #expect(
        unavailable.submit(completion: AdmissionCompletion(rawValue: 1)).context == admissionContext
    )
}

@Test
func invalidAndDisabledFactsRetainNoCopyAndRequestNoWake() {
    var owner = controller(limits: completionDisabledLimits)
    #expect(
        owner.submit(stateChange: AdmissionFact(rawValue: 99)).result
            == .invalidValue
    )
    #expect(
        owner.submit(completion: AdmissionCompletion(rawValue: 1)).result
            == .invalidValue
    )
    #expect(owner.storage.stateChangeCount == 0)
    #expect(owner.storage.completionCount == 0)
    #expect(owner.wakeAccumulator.requester.requestCount == 0)
}

@Test
func categoryCapacityRefusalRetainsNoRejectedCopyOrExtraWake() {
    var owner = controller()
    #expect(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .queued)
    #expect(owner.submit(stateChange: AdmissionFact(rawValue: 2)).result == .queued)
    #expect(
        owner.submit(stateChange: AdmissionFact(rawValue: 3)).result
            == .capacityRefused
    )
    #expect(owner.storage.firstStateChange == AdmissionFact(rawValue: 1))
    #expect(owner.storage.secondStateChange == AdmissionFact(rawValue: 2))
    #expect(owner.wakeAccumulator.requester.requestCount == 1)
}

@Test
func pointerProvenanceAndSequenceFailureCancelWithoutQueuing() {
    var stale = controller()
    #expect(
        stale.submit(pointer: pointer(phase: .down, revision: 10)).result
            == .invalidProvenance
    )
    #expect(stale.storage.pointerCount == 0)
    #expect(stale.storage.cancellationCount == 1)

    var malformed = controller()
    #expect(
        malformed.submit(pointer: pointer(phase: .down, ordinal: 1)).result
            == .invalidProvenance
    )
    #expect(malformed.storage.pointerCount == 0)
    #expect(malformed.storage.cancellationCount == 1)
    #expect(malformed.wakeAccumulator.requester.requestCount == 0)
}

@Test
func pointerCapacityAndNewSourceRefusalPerformMandatoryCancellation() {
    var owner = controller()
    #expect(owner.submit(pointer: pointer(phase: .down)).result == .queued)
    #expect(
        owner.submit(
            pointer: pointer(phase: .down, source: 2, sequence: 0)
        ).result == .capacityRefused
    )
    #expect(owner.storage.cancellationCount == 1)

    #expect(
        owner.submit(
            pointer: pointer(phase: .move, ordinal: 1)
        ).result == .queued
    )
    #expect(
        owner.submit(
            pointer: pointer(phase: .up, ordinal: 2)
        ).result == .capacityRefused
    )
    #expect(owner.storage.pointerCount == 0)
    #expect(owner.storage.cancellationCount == 2)
}

@Test
func quiescenceRefusesEveryFamilyAndPointerCancellationIsMandatory() {
    var owner = controller(quiescent: true)
    #expect(owner.submit(pointer: pointer(phase: .down)).result == .unavailable)
    #expect(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .unavailable)
    #expect(owner.submit(completion: AdmissionCompletion(rawValue: 1)).result == .unavailable)
    #expect(owner.storage.pointerCount == 0)
    #expect(owner.storage.stateChangeCount == 0)
    #expect(owner.storage.completionCount == 0)
    #expect(owner.storage.cancellationCount == 1)
    #expect(owner.wakeAccumulator.requester.requestCount == 0)
}

@Test
func submissionNeverAppliesFactsOrPromisesCurrentCycleMembership() {
    var owner = controller()
    #expect(owner.context.phase == .mutating)
    #expect(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .queued)
    #expect(owner.context == admissionContext)
    #expect(owner.storage.firstStateChange == AdmissionFact(rawValue: 1))
}

@Test
func workArrivingAfterSealIsDeferredAndRequestsFreshWake() {
    var owner = controller()
    #expect(owner.submit(stateChange: AdmissionFact(rawValue: 1)).result == .queued)
    #expect(owner.takeWakeAtIdleOpportunity() == .admittedWork)
    owner.closeAdmissionSeal()

    #expect(owner.submit(completion: AdmissionCompletion(rawValue: 2)).result == .queued)
    #expect(owner.didDeferAfterSeal)
    #expect(owner.wakeAccumulator.requester.requestCount == 2)
    #expect(owner.wakeAccumulator.accumulatedReasons == .admittedWork)
    #expect(owner.storage.firstStateChange == AdmissionFact(rawValue: 1))
    #expect(owner.storage.completion == AdmissionCompletion(rawValue: 2))
}
