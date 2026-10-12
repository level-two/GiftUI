import GiftUI
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import GiftUISemanticCore
import P08CounterSchema

extension CounterPipelineOwner: ExecutionOpportunityRunner, RuntimeOpportunityQuiescence {
    var isOpportunityQuiescent: Bool { presentationTeardownComplete }
    mutating func quiesceOpportunity() {
        quiescent = true
        control.pointee.unavailable = true
        if phase.context.phase == .idle { terminatePresentation() }
    }
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        guard phase.context.phase == .idle else {
            return .failure(phase.context, .execution(.reentrancyViolation), nil)
        }
        guard !control.pointee.unavailable else {
            return .failure(phase.context, .execution(.requiredFacilityUnavailable), nil)
        }
        let priorIntent = recovery.pendingIntent
        _ = recovery.acknowledgeWakeAtIdleOpportunity()
        let result = runTracedPipeline()
        control.pointee.result = result
        let disposition: RuntimePipelineDisposition
        let operational: ExecutionOperational?
        let failure: RunCycleFailure<RuntimeOwnerFailure>?
        switch result {
        case .completed(let completion):
            disposition = completion.disposition; operational = completion.operational; failure = nil
            if let revision = completion.committedPresentationRevision { committedPresentation = revision }
        case .failed(let stopped):
            disposition = stopped.disposition; operational = nil; failure = stopped.failure
        }
        guard let counter = completedContext.cycle, let admission = sealedAdmission else {
            return .failure(completedContext, failure ?? .execution(.invariantViolation), nil)
        }
        var events: ExecutionOperationalEvents = []
        if disposition.semanticDisposition == .published,
            let priorIntent, priorIntent.semanticRevision != phase.context.semanticRevision {
            events.insert(.superseded)
        }
        var intent: PresentationPendingIntent?
        var terminal = false
        if operational == .backpressured {
            let transition = recovery.recordBackpressure(for: phase.context.semanticRevision!)
            events.formUnion(transition.operationalEvents); intent = transition.intent
        } else if operational == .retryableRefusal {
            let transition = recovery.recordRetryableRefusal(for: phase.context.semanticRevision!)
            events.formUnion(transition.operationalEvents); intent = transition.intent; terminal = transition.exhausted
        } else if disposition.presentationIntentState == .pending {
            intent = priorIntent
        } else if let priorIntent {
            // Accepted/newer publication or a post-publication failure satisfies
            // the obligation even when its stored revision is older.
            recovery.clearPending(for: priorIntent.semanticRevision)
        }
        if case .nonRetryableRefusal = failure { terminal = true }
        if failure == .execution(.requiredFacilityUnavailable) { terminal = true }
        if terminal {
            if let retained = recovery.pendingIntent { recovery.clearPending(for: retained.semanticRevision) }
            intent = nil
            terminatePresentation()
        }
        counterTrace("recovery", (recovery.pendingIntent, recovery.wakes.wakeOutstanding, recovery.wakes.requester.requestCount))
        let summary = RunCycleSummary(cycle: counter, admission: admission, semanticRevision: phase.context.semanticRevision, semanticDisposition: disposition.semanticDisposition, logicalFrameDisposition: disposition.logicalFrameDisposition, committedPresentationRevision: committedPresentation, presentationIntentState: terminal ? .unavailable : disposition.presentationIntentState, presentationPending: intent, operationalEvents: events)!
        counterTrace("summary", summary)
        if let failure { return .failure(completedContext, failure, summary) }
        if let operational { return .operational(operational, summary) }
        if events.contains(.superseded) { return .operational(.superseded, summary) }
        return .success(summary)
    }
}

// These finite assembly adapters carry real scoped owners and queued facts into
// the existing concrete coordinator; they do not replace a focused algorithm.
struct CounterExecutionBinding: ~Copyable, ~Escapable, StaticExecutionProfileBinding, RuntimeAuditedExecutionProfileBinding {
    typealias Endpoint = CounterEndpoint
    let storageAudit: RuntimeStorageAudit
    let models: ObservableModelScope<CounterOwnedModel, CounterModelSchema>
    let root: ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>
    let control: UnsafeMutablePointer<CounterControl>
    @_lifetime(copy models, copy root, borrow control)
    init?(models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: borrowing UnsafeMutablePointer<CounterControl>, audit: RuntimeStorageAudit) {
        guard root.belongs(to: models) else { return nil }
        storageAudit = audit
        self.models = consume models; self.root = consume root; self.control = copy control
    }
    var executionContext: ExecutionContext { control.pointee.context }
    var isQuiescent: Bool { control.pointee.unavailable }
    mutating func quiesce() {
        guard !isQuiescent else { return }
        control.pointee.unavailable = true
        control.pointee.admission.resetAll()
    }
}
#if !hasFeature(Embedded)
extension CounterExecutionBinding: DynamicExecutionProfileBinding {}
#endif
struct CounterQueuedFacts: ExecutionPendingAdmissionStorage {
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    let control: UnsafeMutablePointer<CounterControl>
    var pointerCount: UInt16 { control.pointee.admission.pointerCount }
    var stateChangeCount: UInt16 { control.pointee.admission.pendingStateCount }
    var completionCount: UInt16 { control.pointee.admission.pendingCompletion == nil ? 0 : 1 }
    func isValid(stateChange: borrowing UInt8) -> Bool { stateChange <= 9 }
    func isValid(completion: borrowing UInt16) -> Bool { completion == 0 }
    mutating func enqueue(pointer: NormalizedPointerEvent) -> Bool { control.pointee.admission.enqueue(pointer) }
    mutating func enqueue(stateChange: UInt8) -> Bool { control.pointee.admission.enqueue(state: stateChange) }
    mutating func enqueue(completion: UInt16) -> Bool { control.pointee.admission.enqueue(completion: completion) }
    mutating func cancelPointerSequence(source: InputSourceID, sequence: PointerSequenceID) {
        control.pointee.cancelPointerSequence(source: source, sequence: sequence)
    }
}
// One actual admission controller survives all probes and is moved into the
// concrete coordinator. Its context is synchronized from the scoped owner.
struct CounterAdmission: ExecutionAdmissionSink {
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias Controller = SingleSourceExecutionAdmissionController<CounterQueuedFacts, CounterWake>
    var controller: Controller {
        get { control.pointee.admissionController! }
        set { control.pointee.admissionController = newValue }
        _modify { yield &control.pointee.admissionController! }
    }
    let control: UnsafeMutablePointer<CounterControl>
    static var pointerStateStorageBytes: Int { Controller.pointerStateStorageBytes }
    init(control: UnsafeMutablePointer<CounterControl>, limits: ExecutionLimits) {
        self.control = control
        precondition(control.pointee.admissionController == nil)
        control.pointee.admissionController = Controller(limits: limits, context: control.pointee.context, committedPresentationRevision: control.pointee.runtime.committedPresentation, storage: CounterQueuedFacts(control: control), requester: CounterWake())
    }
    init(borrowing control: UnsafeMutablePointer<CounterControl>) {
        precondition(control.pointee.admissionController != nil)
        self.control = control
    }
    mutating func synchronize() {
        controller.synchronize(context: control.pointee.context, committedPresentationRevision: control.pointee.runtime.committedPresentation, sealClosed: control.pointee.admission.sealActive, quiescent: control.pointee.unavailable)
    }
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        synchronize(); let outcome = controller.submit(pointer: pointer); counterTrace("admission.pointer", outcome); return outcome
    }
    mutating func submit(stateChange: UInt8) -> ExecutionAdmissionOutcome {
        synchronize(); let outcome = controller.submit(stateChange: stateChange); counterTrace("admission.state", outcome); return outcome
    }
    mutating func submit(completion: UInt16) -> ExecutionAdmissionOutcome {
        synchronize(); let outcome = controller.submit(completion: completion); counterTrace("admission.completion", outcome); return outcome
    }
}
struct CounterPointerState {
    var source: InputSourceID?
    var sequence = InputSourceSequenceState()
    var capture = PointerActionCapture<SemanticCompleteIdentity>()
    mutating func cancel(source: InputSourceID) {
        guard self.source == source else { return }
        capture.cancel(); sequence.cancelCurrentSequence()
    }
}
struct CounterWake: ExecutionWakeRequester, Sendable {
    var reasons: ExecutionWakeReasons = []
    var requestCount: UInt32 = 0
    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        let next = requestCount.addingReportingOverflow(1)
        precondition(!next.overflow)
        requestCount = next.partialValue
        self.reasons.formUnion(reasons)
    }
}


struct CounterAdmissionBacking {
    var pendingPointers: InlineArray<2, NormalizedPointerEvent?> = .init(repeating: nil)
    var pendingStates: InlineArray<34, UInt8> = .init(repeating: 0)
    var pendingStateCount: UInt16 = 0
    var pendingCompletion: UInt16?
    var sealedPointers: InlineArray<2, NormalizedPointerEvent?> = .init(repeating: nil)
    var sealedStates: InlineArray<34, UInt8> = .init(repeating: 0)
    var sealedStateCount: UInt16 = 0
    var sealedStateCursor: UInt16 = 0
    var sealedCompletion: UInt16?
    var sealedAction: CapturedAction<SemanticCompleteIdentity>?
    var sealedPointerCount: UInt16 = 0
    var sealActive = false
    var pointerCount: UInt16 { var count: UInt16 = 0; for i in 0..<2 where pendingPointers[i] != nil { count += 1 }; return count }
    var pendingState: UInt8? {
        get { pendingStateCount == 0 ? nil : pendingStates[0] }
        set { pendingStateCount = 0; if let newValue { _ = enqueue(state: newValue) } }
    }
    mutating func enqueue(state: UInt8) -> Bool {
        guard state <= 9, pendingStateCount < 34 else { return false }
        pendingStates[Int(pendingStateCount)] = state; pendingStateCount += 1; return true
    }
    mutating func enqueue(completion: UInt16) -> Bool {
        guard completion == 0, pendingCompletion == nil else { return false }
        pendingCompletion = completion; return true
    }
    mutating func enqueue(_ pointer: NormalizedPointerEvent) -> Bool {
        for i in 0..<2 where pendingPointers[i] == nil { pendingPointers[i] = pointer; return true }; return false
    }
    mutating func cancel(source: InputSourceID, sequence: PointerSequenceID) {
        for i in 0..<2 { if let event = pendingPointers[i], event.source == source && event.sequence == sequence { pendingPointers[i] = nil } }
    }
    mutating func seal(_ summary: AdmissionSummary) -> Bool {
        guard !sealActive, summary.inputEventCount <= pointerCount, summary.stateChangeFactCount <= pendingStateCount,
              summary.completionFactCount <= (pendingCompletion == nil ? 0 : 1), summary.semanticActionCount <= 2 else { return false }
        sealedPointerCount = 0
        for i in 0..<2 where sealedPointerCount < summary.inputEventCount {
            if let event = pendingPointers[i] { sealedPointers[Int(sealedPointerCount)] = event; pendingPointers[i] = nil; sealedPointerCount += 1 }
        }
        sealedStateCount = summary.stateChangeFactCount; sealedStateCursor = 0
        for i in 0..<Int(sealedStateCount) { sealedStates[i] = pendingStates[i] }
        let remaining = pendingStateCount - sealedStateCount
        for i in 0..<Int(remaining) { pendingStates[i] = pendingStates[Int(sealedStateCount) + i] }
        pendingStateCount = remaining
        sealedCompletion = summary.completionFactCount == 0 ? nil : pendingCompletion.take()
        sealActive = true; return true
    }
    mutating func takeState() -> UInt8? {
        guard sealedStateCursor < sealedStateCount else { return nil }
        let value = sealedStates[Int(sealedStateCursor)]; sealedStateCursor += 1; return value
    }
    mutating func finishAttempt() {
        sealedPointers = .init(repeating: nil); sealedPointerCount = 0
        sealedStateCount = 0; sealedStateCursor = 0; sealedCompletion = nil; sealedAction = nil; sealActive = false
    }
    mutating func resetAll() { finishAttempt(); pendingPointers = .init(repeating: nil); pendingStateCount = 0; pendingCompletion = nil }
}
