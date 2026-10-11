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
        let result = RuntimeCompletePipeline.run(owner: &self)
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
        if operational == .backpressured { events = .backpressured }
        if operational == .retryableRefusal { events = .retryableRefusal; retryCount += 1 }
        let pending = disposition.presentationIntentState == .pending
            ? PresentationPendingIntent(semanticRevision: phase.context.semanticRevision!, retryableRefusalCount: retryCount) : nil
        let summary = RunCycleSummary(cycle: cycle, admission: admission, semanticRevision: phase.context.semanticRevision, semanticDisposition: disposition.semanticDisposition, logicalFrameDisposition: disposition.logicalFrameDisposition, committedPresentationRevision: committedPresentation, presentationIntentState: disposition.presentationIntentState, presentationPending: pending, operationalEvents: events)!
        if let failure { return .failure(completedContext, failure, summary) }
        if let operational { return .operational(operational, summary) }
        return .success(summary)
    }
}

// These finite assembly adapters carry real scoped owners and queued facts into
// the existing concrete coordinator; they do not replace a focused algorithm.
struct CycleExecutionBinding: ~Copyable, ~Escapable, StaticExecutionProfileBinding {
    let models: ObservableModelScope<CycleOwnedModel, CycleModelSchema>
    let root: ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>
    let control: UnsafeMutablePointer<CycleControl>
    @_lifetime(copy models, copy root, borrow control)
    init(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, control: borrowing UnsafeMutablePointer<CycleControl>) {
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
    mutating func cancelPointerSequence(source: InputSourceID, sequence: PointerSequenceID) { control.pointee.admission.cancel(source: source, sequence: sequence) }
}
struct CycleWake: ExecutionWakeRequester, Sendable {
    var reasons: ExecutionWakeReasons = []
    mutating func requestWake(for reasons: ExecutionWakeReasons) { self.reasons.formUnion(reasons) }
}

func cycleConcreteCoordinator<G, C, R, H>(owner: consuming CyclePipelineOwner<G, C, R, H>, dynamic: Bool, control: UnsafeMutablePointer<CycleControl>) -> CycleReturnedWorkspaces<G, C, R, H> where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    let geometryBefore = owner.geometry.storageMeasurement()
    let interactionBefore = cycleMeasureInteraction(owner.interaction)
    let binding = CycleExecutionBinding(models: owner.models.borrowedScope(), root: owner.root.borrowedRoot(), control: control)
    let admission = SingleSourceExecutionAdmissionController(limits: ExecutionLimits(maximumInputEvents: 2, maximumStateChangeFacts: 1, maximumCompletionFacts: 0, maximumSemanticActions: 1, maximumActiveInputSources: 1, maximumCommittedActions: 6)!, context: control.pointee.context, committedPresentationRevision: nil, storage: CycleQueuedFacts(control: control), requester: CycleWake())
    #if !hasFeature(Embedded)
    if dynamic {
        var coordinator = DynamicRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
        precondition(coordinator.opportunity.geometry.storageMeasurement() == geometryBefore)
        precondition(cycleMeasureInteraction(coordinator.opportunity.interaction) == interactionBefore)
        guard case .success = coordinator.runOpportunity() else { preconditionFailure("Dynamic concrete coordinator") }
        precondition(coordinator.submit(stateChange: 1).result == .queued)
        precondition(coordinator.submit(stateChange: 1).result == .capacityRefused)
        guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("Dynamic admitted mutation") }
        precondition(summary.admission.stateChangeFactCount == 1)
        coordinator.quiesce(); coordinator.quiesce()
        precondition(coordinator.opportunity.geometry.storageMeasurement() == geometryBefore)
        precondition(cycleMeasureInteraction(coordinator.opportunity.interaction) == interactionBefore)
        precondition(coordinator.submit(stateChange: 1).result == .unavailable)
        guard case .failure(_, .execution(.requiredFacilityUnavailable), nil) = coordinator.runOpportunity() else { preconditionFailure("Dynamic stopped entry") }
        var returned = coordinator.takeQuiescedOpportunity()!
        precondition(returned.geometry.storageMeasurement() == geometryBefore)
        precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
        returned.geometry.reset()
        returned.interaction.resetAllStorage()
        precondition(returned.interaction.committedRecordCount == 0 && returned.interaction.committedComponents == 0)
        precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
        precondition(returned.geometry.storageMeasurement() == geometryBefore)
        return returned.returnWorkspaces(checks: 16)
    }
    #endif
    var coordinator = StaticRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
    precondition(coordinator.opportunity.geometry.storageMeasurement() == geometryBefore)
    precondition(cycleMeasureInteraction(coordinator.opportunity.interaction) == interactionBefore)
    guard case .success = coordinator.runOpportunity() else { preconditionFailure("Static concrete coordinator") }
    precondition(coordinator.submit(stateChange: 1).result == .queued)
    precondition(coordinator.submit(stateChange: 1).result == .capacityRefused)
    guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("Static admitted mutation") }
    precondition(summary.admission.stateChangeFactCount == 1)
    coordinator.quiesce(); coordinator.quiesce()
        precondition(coordinator.opportunity.geometry.storageMeasurement() == geometryBefore)
        precondition(cycleMeasureInteraction(coordinator.opportunity.interaction) == interactionBefore)
    precondition(coordinator.submit(stateChange: 1).result == .unavailable)
    guard case .failure(_, .execution(.requiredFacilityUnavailable), nil) = coordinator.runOpportunity() else { preconditionFailure("Static stopped entry") }
    var returned = coordinator.takeQuiescedOpportunity()!
    precondition(returned.geometry.storageMeasurement() == geometryBefore)
    precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
    returned.geometry.reset()
        returned.interaction.resetAllStorage()
        precondition(returned.interaction.committedRecordCount == 0 && returned.interaction.committedComponents == 0)
        precondition(cycleMeasureInteraction(returned.interaction) == interactionBefore)
    precondition(returned.geometry.storageMeasurement() == geometryBefore)
    return returned.returnWorkspaces(checks: 16)
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
