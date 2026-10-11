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
import CycleSchema

extension CyclePipelineOwner: ExecutionOpportunityRunner {
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
        guard let cycle = completedContext.cycle, let admission = sealedAdmission else {
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
        cycleTrace("recovery", (recovery.pendingIntent, recovery.wakes.wakeOutstanding, recovery.wakes.requester.requestCount))
        let summary = RunCycleSummary(cycle: cycle, admission: admission, semanticRevision: phase.context.semanticRevision, semanticDisposition: disposition.semanticDisposition, logicalFrameDisposition: disposition.logicalFrameDisposition, committedPresentationRevision: committedPresentation, presentationIntentState: terminal ? .unavailable : disposition.presentationIntentState, presentationPending: intent, operationalEvents: events)!
        cycleTrace("summary", summary)
        if let failure { return .failure(completedContext, failure, summary) }
        if let operational { return .operational(operational, summary) }
        if events.contains(.superseded) { return .operational(.superseded, summary) }
        return .success(summary)
    }
}

// These finite assembly adapters carry real scoped owners and queued facts into
// the existing concrete coordinator; they do not replace a focused algorithm.
struct CycleExecutionBinding: ~Copyable, ~Escapable, StaticExecutionProfileBinding, RuntimeAuditedExecutionProfileBinding {
    typealias Endpoint = CycleEndpoint
    let storageAudit: RuntimeStorageAudit
    let models: ObservableModelScope<CycleOwnedModel, CycleModelSchema>
    let root: ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>
    let control: UnsafeMutablePointer<CycleControl>
    @_lifetime(copy models, copy root, borrow control)
    init?(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, control: borrowing UnsafeMutablePointer<CycleControl>, audit: RuntimeStorageAudit) {
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
        do throws(ObservableStateError) { try root.shutdown() }
        catch { models.requireStop() }
    }
}
#if !hasFeature(Embedded)
extension CycleExecutionBinding: DynamicExecutionProfileBinding {}
#endif
struct CycleQueuedFacts: ExecutionPendingAdmissionStorage {
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    let control: UnsafeMutablePointer<CycleControl>
    var pointerCount: UInt16 { control.pointee.admission.pointerCount }
    var stateChangeCount: UInt16 { control.pointee.mutate ? 1 : 0 }
    var completionCount: UInt16 { 0 }
    func isValid(stateChange: borrowing UInt8) -> Bool { stateChange == 1 }
    func isValid(completion: borrowing UInt16) -> Bool { false }
    mutating func enqueue(pointer: NormalizedPointerEvent) -> Bool { control.pointee.admission.enqueue(pointer) }
    mutating func enqueue(stateChange: UInt8) -> Bool { guard !control.pointee.mutate else { return false }; control.pointee.mutate = true; return true }
    mutating func enqueue(completion: UInt16) -> Bool { false }
    mutating func cancelPointerSequence(source: InputSourceID, sequence: PointerSequenceID) {
        control.pointee.cancelPointerSequence(source: source, sequence: sequence)
    }
}
// One actual admission controller survives all probes and is moved into the
// concrete coordinator. Its context is synchronized from the scoped owner.
struct CycleAdmission: ExecutionAdmissionSink {
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias Controller = SingleSourceExecutionAdmissionController<CycleQueuedFacts, CycleWake>
    var controller: Controller
    let control: UnsafeMutablePointer<CycleControl>
    static var pointerStateStorageBytes: Int { Controller.pointerStateStorageBytes }
    init(control: UnsafeMutablePointer<CycleControl>, limits: ExecutionLimits) {
        self.control = control
        controller = Controller(limits: limits, context: control.pointee.context, committedPresentationRevision: control.pointee.runtime.committedPresentation, storage: CycleQueuedFacts(control: control), requester: CycleWake())
    }
    mutating func synchronize() {
        controller.synchronize(context: control.pointee.context, committedPresentationRevision: control.pointee.runtime.committedPresentation, sealClosed: control.pointee.admission.sealActive, quiescent: control.pointee.unavailable)
    }
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        synchronize(); let outcome = controller.submit(pointer: pointer); cycleTrace("admission.pointer", outcome); return outcome
    }
    mutating func submit(stateChange: UInt8) -> ExecutionAdmissionOutcome {
        synchronize(); let outcome = controller.submit(stateChange: stateChange); cycleTrace("admission.state", outcome); return outcome
    }
    mutating func submit(completion: UInt16) -> ExecutionAdmissionOutcome {
        synchronize(); let outcome = controller.submit(completion: completion); cycleTrace("admission.completion", outcome); return outcome
    }
}
struct CyclePointerState {
    var source: InputSourceID?
    var sequence = InputSourceSequenceState()
    var capture = PointerActionCapture<SemanticCompleteIdentity>()
    mutating func cancel(source: InputSourceID) {
        guard self.source == source else { return }
        capture.cancel(); sequence.cancelCurrentSequence()
    }
}
struct CycleWake: ExecutionWakeRequester, Sendable {
    var reasons: ExecutionWakeReasons = []
    var requestCount: UInt32 = 0
    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        let next = requestCount.addingReportingOverflow(1)
        precondition(!next.overflow)
        requestCount = next.partialValue
        self.reasons.formUnion(reasons)
    }
}

func cycleConcreteCoordinator<G, C, R, H>(owner: consuming CyclePipelineOwner<G, C, R, H>, dynamic: Bool, control: UnsafeMutablePointer<CycleControl>, audit: RuntimeStorageAudit, admission: consuming CycleAdmission, stopAfterFailure: Bool = false) -> CycleReturnedWorkspaces<G, C, R, H> where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    precondition(owner.limits == audit.limits)
    let geometryBefore = owner.geometry.storageMeasurement()
    let interactionBefore = cycleMeasureInteraction(owner.interaction)
    let binding = CycleExecutionBinding(models: owner.models.borrowedScope(), root: owner.root.borrowedRoot(), control: control, audit: audit)!
    #if !hasFeature(Embedded)
    if dynamic {
        var coordinator = DynamicRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
        verifyCommonCoordinator(&coordinator, audit: audit)
        if stopAfterFailure {
            coordinator.quiesce()
            let returned = coordinator.takeQuiescedOpportunity()!
            return returned.returnWorkspaces(checks: 1)
        }
        precondition(coordinator.opportunity.geometry.storageMeasurement() == geometryBefore)
        precondition(cycleMeasureInteraction(coordinator.opportunity.interaction) == interactionBefore)
        let lifecycleChecks = exerciseConcreteLifecycle(&coordinator, control: control)
        var returned = coordinator.takeQuiescedOpportunity()!
        precondition(returned.geometry.storageMeasurement() == geometryBefore)
        precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
        returned.geometry.reset()
        returned.interaction.resetAllStorage()
        precondition(returned.interaction.committedRecordCount == 0 && returned.interaction.committedComponents == 0)
        precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
        precondition(returned.geometry.storageMeasurement() == geometryBefore)
        return returned.returnWorkspaces(checks: lifecycleChecks + 8)
    }
    #endif
    var coordinator = StaticRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
    verifyCommonCoordinator(&coordinator, audit: audit)
    if stopAfterFailure {
        coordinator.quiesce()
        let returned = coordinator.takeQuiescedOpportunity()!
        return returned.returnWorkspaces(checks: 1)
    }
    precondition(coordinator.opportunity.geometry.storageMeasurement() == geometryBefore)
    precondition(cycleMeasureInteraction(coordinator.opportunity.interaction) == interactionBefore)
    let lifecycleChecks = exerciseConcreteLifecycle(&coordinator, control: control)
    var returned = coordinator.takeQuiescedOpportunity()!
    precondition(returned.geometry.storageMeasurement() == geometryBefore)
    precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
    returned.geometry.reset()
        returned.interaction.resetAllStorage()
        precondition(returned.interaction.committedRecordCount == 0 && returned.interaction.committedComponents == 0)
        precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
    precondition(returned.geometry.storageMeasurement() == geometryBefore)
    return returned.returnWorkspaces(checks: lifecycleChecks + 8)
}

// Actual disjoint finite stores used by admission and sealing. Completion capacity
// is zero, so it owns no completion entries. Later arrivals remain in pending.
struct CycleAdmissionBacking {
    var pendingPointers: InlineArray<2, NormalizedPointerEvent?> = .init(repeating: nil)
    var pendingState: UInt8?
    var sealedPointers: InlineArray<2, NormalizedPointerEvent?> = .init(repeating: nil)
    var sealedState: UInt8?
    var sealedAction: CapturedAction<SemanticCompleteIdentity>?
    var sealedPointerCount: UInt16 = 0
    var sealActive = false
    var pointerCount: UInt16 {
        var count: UInt16 = 0
        for i in 0..<2 where pendingPointers[i] != nil { count += 1 }
        return count
    }
    mutating func enqueue(_ pointer: NormalizedPointerEvent) -> Bool {
        for i in 0..<2 where pendingPointers[i] == nil { pendingPointers[i] = pointer; return true }
        return false
    }
    mutating func cancel(source: InputSourceID, sequence: PointerSequenceID) {
        for i in 0..<2 {
            if let event = pendingPointers[i], event.source == source && event.sequence == sequence { pendingPointers[i] = nil }
        }
    }
    mutating func seal(_ summary: AdmissionSummary) -> Bool {
        guard !sealActive, summary.inputEventCount <= pointerCount,
            summary.stateChangeFactCount <= (pendingState == nil ? 0 : 1), summary.completionFactCount == 0,
            summary.semanticActionCount <= 1 else { return false }
        sealedPointerCount = 0
        for i in 0..<2 where sealedPointerCount < summary.inputEventCount {
            if let event = pendingPointers[i] {
                sealedPointers[Int(sealedPointerCount)] = event
                pendingPointers[i] = nil; sealedPointerCount += 1
            }
        }
        sealedState = summary.stateChangeFactCount == 0 ? nil : pendingState.take()
        sealActive = true
        return true
    }
    mutating func takeState() -> UInt8? { sealedState.take() }
    mutating func finishAttempt() {
        sealedPointers = .init(repeating: nil); sealedPointerCount = 0
        sealedState = nil; sealedAction = nil; sealActive = false
    }
    mutating func resetAll() { finishAttempt(); pendingPointers = .init(repeating: nil); pendingState = nil }
}

func cycleAdmissionBackingProbe() -> Int {
    var backing = CycleAdmissionBacking()
    var checks = 0
    func expect(_ okay: Bool) { checks += 1; precondition(okay) }
    expect(CycleExtent.elements(SemanticCompleteIdentity.self, count: 6).bytes == UInt64(6 * MemoryLayout<SemanticCompleteIdentity>.stride))
    expect(CycleExtent(count: -1, stride: 1, alignment: 1).bytes == nil)
    expect(CycleExtent(count: Int.max, stride: Int.max, alignment: 1).bytes == nil)
    let event = NormalizedPointerEvent(phase: .down, position: Point(x: 0, y: 0), source: .init(rawValue: 1), sequence: .init(rawValue: 1), ordinal: .init(rawValue: 0), presentationRevision: .init(rawValue: 1))
    expect(backing.enqueue(event)); expect(backing.enqueue(event)); expect(!backing.enqueue(event))
    backing.pendingState = 1
    let limits = ExecutionLimits(maximumInputEvents: 2, maximumStateChangeFacts: 1, maximumCompletionFacts: 0, maximumSemanticActions: 1, maximumActiveInputSources: 1, maximumCommittedActions: 6)!
    let summary = ExecutionAdmissionSealer.select(pendingInputEvents: 2, pendingStateChangeFacts: 1, pendingCompletionFacts: 0, sameCycleActivationCandidates: 0, includesDirtyRederivation: false, includesPresentationRecovery: false, limits: limits)!.summary
    expect(backing.seal(summary)); expect(!backing.seal(summary))
    expect(backing.pointerCount == 0 && backing.sealedPointerCount == 2)
    expect(backing.enqueue(event)); backing.pendingState = 1
    expect(backing.takeState() == 1); expect(backing.takeState() == nil)
    backing.finishAttempt()
    expect(backing.pointerCount == 1 && backing.pendingState == 1 && backing.sealedPointerCount == 0)
    backing.cancel(source: event.source, sequence: event.sequence)
    expect(backing.pointerCount == 0 && backing.pendingState == 1)
    backing.resetAll()
    expect(backing.pendingState == nil && !backing.sealActive)
    return checks
}

func verifyCommonCoordinator<C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable>(_ coordinator: inout C, audit: RuntimeStorageAudit) {
    precondition(coordinator.profile == audit.profile)
    precondition(coordinator.storageAudit == audit)
    precondition(!coordinator.isQuiescent)
}

func exerciseConcreteLifecycle<C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable>(_ coordinator: inout C, control: UnsafeMutablePointer<CycleControl>) -> Int where C.StateChangeFact == UInt8, C.CompletionFact == UInt16, C.OwnerFailure == RuntimeOwnerFailure {
    var checks = 0
    func expect(_ value: Bool) { checks += 1; precondition(value) }
    guard case .success = coordinator.runOpportunity() else { preconditionFailure("concrete coordinator") }
    expect(coordinator.submit(stateChange: 1).result == .queued)
    expect(coordinator.submit(stateChange: 1).result == .capacityRefused)
    guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("admitted mutation") }
    expect(summary.admission.stateChangeFactCount == 1)
    let beforePointer = control.pointee.applied
    let revision = summary.committedPresentationRevision!
    let inputLimit = coordinator.storageAudit.limits.execution.maximumInputEvents
    let firstSequence: UInt32 = inputLimit == 2 ? 1 : 0
    var releaseRevision = revision
    func event(_ phase: PointerPhase, sequence: UInt32, ordinal: UInt32, revision: PresentationRevision) -> NormalizedPointerEvent {
        .init(phase: phase, position: control.pointee.actionPoint, source: .init(rawValue: 0), sequence: .init(rawValue: sequence), ordinal: .init(rawValue: ordinal), presentationRevision: revision)
    }
    let down = coordinator.submit(pointer: event(.down, sequence: firstSequence, ordinal: 0, revision: revision))
    expect(down.result == .queued && down.context == coordinator.executionContext)
    expect(down.context.phase == .idle && down.context.cycle == nil && down.context.semanticRevision == summary.semanticRevision)
    if inputLimit == 1 {
        guard case .success(let captured) = coordinator.runOpportunity() else { preconditionFailure("single-input down") }
        expect(captured.admission.inputEventCount == 1 && captured.admission.semanticActionCount == 0)
        expect(control.pointee.applied == beforePointer)
        releaseRevision = captured.committedPresentationRevision!
    }
    expect(coordinator.submit(pointer: event(.up, sequence: firstSequence, ordinal: 1, revision: releaseRevision)).result == .queued)
    guard case .success(let activated) = coordinator.runOpportunity() else { preconditionFailure("sealed pointer activation") }
    expect(activated.admission.inputEventCount == inputLimit && activated.admission.semanticActionCount == 1 && activated.admission.stateChangeFactCount == 0)
    expect(control.pointee.applied == beforePointer + 1)
    let latest = activated.committedPresentationRevision!
    expect(coordinator.submit(pointer: event(.down, sequence: firstSequence + 1, ordinal: 0, revision: latest)).result == .queued)
    let rejected = coordinator.submit(pointer: event(.up, sequence: firstSequence + 1, ordinal: 1, revision: revision))
    expect(rejected.result == .invalidProvenance && rejected.context == coordinator.executionContext)
    expect(control.pointee.admission.pointerCount == 0 && control.pointee.runtime.pointer.capture.current == nil)
    // The cancelled, but admitted, down consumed its sequence. Its successor may
    // resynchronize; dropping it again must never dispatch the abandoned action.
    expect(coordinator.submit(pointer: event(.down, sequence: firstSequence + 2, ordinal: 0, revision: latest)).result == .queued)
    expect(coordinator.submit(pointer: event(.up, sequence: firstSequence + 2, ordinal: 1, revision: revision)).result == .invalidProvenance)
    expect(control.pointee.admission.pointerCount == 0 && control.pointee.applied == beforePointer + 1)
    let applied = control.pointee.applied, streams = control.pointee.streams
    if control.pointee.terminalRetry {
        control.pointee.offer = .retryableRefusal
        for count: UInt8 in 1...3 {
            guard case .operational(.retryableRefusal, let refused) = coordinator.runOpportunity() else { preconditionFailure("bounded refusal") }
            expect(refused.presentationIntentState == (count < 3 ? .pending : .unavailable))
            expect(refused.presentationPending?.retryableRefusalCount == (count < 3 ? count : nil))
            expect(coordinator.isQuiescent == (count == 3))
        }
    } else {
        control.pointee.offer = .nonRetryableRefusal
        guard case .failure(_, .nonRetryableRefusal(.endpoint), let stopped) = coordinator.runOpportunity() else { preconditionFailure("nonretryable terminal") }
        expect(stopped?.presentationIntentState == .unavailable && stopped?.presentationPending == nil)
    }
    expect(coordinator.isQuiescent && control.pointee.committedRecords == 0)
    expect(control.pointee.admission.pointerCount == 0 && !control.pointee.mutate)
    expect(control.pointee.applied == applied && control.pointee.streams == streams)
    let finalized = control.pointee.finalized
    coordinator.quiesce(); coordinator.quiesce()
    expect(coordinator.submit(stateChange: 1).result == .unavailable)
    guard case .failure(_, .execution(.requiredFacilityUnavailable), nil) = coordinator.runOpportunity() else { preconditionFailure("terminal entry") }
    expect(control.pointee.finalized == finalized && control.pointee.applied == applied)
    return checks
}


func exercisePendingSupersession<G, C, R, H>(_ owner: inout CyclePipelineOwner<G, C, R, H>, admission: inout CycleAdmission) -> Int {
    var checks = 0
    func expect(_ value: Bool) { checks += 1; precondition(value, "actual pending supersession") }
    guard case .success = owner.runOpportunity() else { preconditionFailure("supersession baseline") }
    let applied = owner.control.pointee.applied
    let wakeCount = owner.recovery.wakes.requester.requestCount
    owner.control.pointee.offer = .retryableRefusal
    guard case .operational(.retryableRefusal, let old) = owner.runOpportunity() else { preconditionFailure("old refusal") }
    expect(old.operationalEvents == [.retryableRefusal] && old.presentationPending?.retryableRefusalCount == 1)
    expect(owner.recovery.pendingIntent == old.presentationPending)
    expect(owner.recovery.wakes.wakeOutstanding && owner.recovery.wakes.requester.requestCount == wakeCount + 1)
    owner.control.pointee.fault = .layout
    guard case .failure(_, _, let failed) = owner.runOpportunity() else { preconditionFailure("pending prepublication failure") }
    expect(failed?.presentationPending == old.presentationPending && failed?.operationalEvents == [])
    expect(owner.recovery.pendingIntent == old.presentationPending && !owner.recovery.wakes.wakeOutstanding)
    expect(owner.recovery.wakes.requester.requestCount == wakeCount + 1 && owner.control.pointee.applied == applied)
    owner.control.pointee.fault = nil
    expect(admission.submit(stateChange: 1).result == .queued)
    guard case .operational(.retryableRefusal, let newer) = owner.runOpportunity() else { preconditionFailure("new refusal") }
    expect(newer.semanticRevision != old.semanticRevision && newer.semanticDisposition == .published)
    expect(newer.operationalEvents == [.retryableRefusal, .superseded] && newer.presentationPending?.retryableRefusalCount == 1)
    expect(owner.recovery.pendingIntent == newer.presentationPending && owner.control.pointee.applied == applied + 1)
    expect(owner.recovery.wakes.wakeOutstanding && owner.recovery.wakes.requester.requestCount == wakeCount + 2)
    owner.control.pointee.offer = .backpressured
    guard case .operational(.backpressured, let same) = owner.runOpportunity() else { preconditionFailure("same backpressure") }
    expect(same.semanticRevision == newer.semanticRevision && same.operationalEvents == [.backpressured])
    expect(same.presentationPending?.retryableRefusalCount == 1 && owner.control.pointee.applied == applied + 1)
    expect(owner.recovery.wakes.requester.requestCount == wakeCount + 3)
    expect(admission.submit(stateChange: 1).result == .queued)
    guard case .operational(.backpressured, let latest) = owner.runOpportunity() else { preconditionFailure("new backpressure") }
    expect(latest.semanticRevision != newer.semanticRevision && latest.operationalEvents == [.backpressured, .superseded])
    expect(latest.presentationPending?.retryableRefusalCount == 0 && owner.control.pointee.applied == applied + 2)
    expect(owner.recovery.pendingIntent == latest.presentationPending && owner.recovery.wakes.requester.requestCount == wakeCount + 4)
    expect(admission.submit(stateChange: 1).result == .queued)
    owner.control.pointee.offer = .accepted
    guard case .operational(.superseded, let accepted) = owner.runOpportunity() else { preconditionFailure("new acceptance supersedes") }
    expect(accepted.semanticRevision != latest.semanticRevision && accepted.operationalEvents == [.superseded])
    expect(accepted.logicalFrameDisposition == .committed && accepted.presentationIntentState == .satisfied && accepted.presentationPending == nil)
    expect(owner.recovery.pendingIntent == nil && !owner.recovery.wakes.wakeOutstanding && !owner.pending)
    expect(owner.recovery.wakes.requester.requestCount == wakeCount + 4 && owner.control.pointee.applied == applied + 3)
    guard case .success(let after) = owner.runOpportunity() else { preconditionFailure("after supersession") }
    expect(after.semanticRevision == accepted.semanticRevision && after.operationalEvents == [] && after.presentationPending == nil)
    expect(owner.control.pointee.applied == applied + 3 && owner.recovery.wakes.requester.requestCount == wakeCount + 4)
    return checks
}


// SPEC-009 exhaustive outcome table: ordinary postpublication failures clear
// recovery without making presentation unavailable. Allocation identity failure
// and presentation identity failure differ by actual acquired candidate state.
func exerciseOrdinaryFailureRecovery<G, C, R, H>(_ owner: inout CyclePipelineOwner<G, C, R, H>) -> Int {
    var checks = 0
    func expect(_ value: Bool) { checks += 1; precondition(value, "ordinary failure disposition") }
    owner.control.pointee.offer = .retryableRefusal
    guard case .operational(.retryableRefusal, _) = owner.runOpportunity() else { preconditionFailure("pending before failure") }
    let applied = owner.control.pointee.applied
    let routing = owner.interaction.committedRevision
    let candidates = owner.candidates
    owner.candidates = CandidateFrameIDAllocator(nextRawValue: nil)
    guard case .failure(_, .execution(.identityExhausted), let candidateFailure) = owner.runOpportunity() else { preconditionFailure("candidate ID exhaustion") }
    expect(candidateFailure?.logicalFrameDisposition == .notProduced && candidateFailure?.presentationIntentState == .satisfied)
    expect(candidateFailure?.presentationPending == nil && owner.recovery.pendingIntent == nil && !owner.pending)
    expect(!owner.recovery.wakes.wakeOutstanding && owner.interaction.committedRevision == routing)
    owner.candidates = candidates
    owner.control.pointee.offer = .backpressured
    guard case .operational(.backpressured, _) = owner.runOpportunity() else { preconditionFailure("pending before presentation failure") }
    let presentations = owner.presentations
    owner.presentations = PresentationRevisionAllocator(nextRawValue: nil)
    guard case .failure(_, .execution(.identityExhausted), let presentationFailure) = owner.runOpportunity() else { preconditionFailure("presentation ID exhaustion") }
    expect(presentationFailure?.logicalFrameDisposition == .aborted && presentationFailure?.presentationIntentState == .satisfied)
    expect(presentationFailure?.presentationPending == nil && owner.recovery.pendingIntent == nil && !owner.pending)
    expect(!owner.recovery.wakes.wakeOutstanding && owner.interaction.committedRevision == routing)
    owner.presentations = presentations
    guard case .operational(.backpressured, _) = owner.runOpportunity() else { preconditionFailure("pending before offer failure") }
    owner.control.pointee.offer = .failed
    guard case .failure(_, .frameOffer(.invalidEnvelope), let offerFailure) = owner.runOpportunity() else { preconditionFailure("real endpoint failure") }
    expect(offerFailure?.logicalFrameDisposition == .aborted && offerFailure?.presentationIntentState == .satisfied)
    expect(offerFailure?.presentationPending == nil && owner.recovery.pendingIntent == nil && !owner.pending)
    expect(!owner.recovery.wakes.wakeOutstanding && owner.interaction.committedRevision == routing)
    expect(owner.control.pointee.applied == applied && !owner.control.pointee.unavailable)
    // Direct common-pipeline controls stop before the outer terminal policy, so
    // both facility-loss rows can be inspected on this still-owned composition.
    owner.control.pointee.boundaryFailure = .execution(.requiredFacilityUnavailable)
    for stage: RuntimeCompletePipelineStage in [.candidateAllocation, .offerAndProduction] {
        owner.control.pointee.fault = stage
        guard case .failed(let failure) = owner.runTracedPipeline() else { preconditionFailure("facility loss") }
        expect(failure.failure == .execution(.requiredFacilityUnavailable))
        expect(failure.disposition.logicalFrameDisposition == (stage == .candidateAllocation ? .notProduced : .aborted))
        expect(failure.disposition.presentationIntentState == .unavailable && failure.disposition.preservesPublishedSemanticRevision)
        expect(failure.disposition.wakeReasons == [] && !failure.disposition.commitsInteractionCandidate)
    }
    owner.control.pointee.fault = nil
    owner.control.pointee.boundaryFailure = .execution(.capacityExhausted)
    owner.control.pointee.offer = .accepted
    guard case .success = owner.runOpportunity() else { preconditionFailure("normal operation after ordinary failures") }
    expect(owner.control.pointee.applied == applied && owner.recovery.pendingIntent == nil)
    return checks
}
