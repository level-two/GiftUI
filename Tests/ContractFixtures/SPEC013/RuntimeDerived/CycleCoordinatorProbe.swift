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
        control.pointee.mutate = false
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
    var pointerCount: UInt16 { 0 }
    var stateChangeCount: UInt16 { control.pointee.mutate ? 1 : 0 }
    var completionCount: UInt16 { 0 }
    func isValid(stateChange: borrowing UInt8) -> Bool { stateChange == 1 }
    func isValid(completion: borrowing UInt16) -> Bool { false }
    mutating func enqueue(pointer: NormalizedPointerEvent) -> Bool { false }
    mutating func enqueue(stateChange: UInt8) -> Bool { guard !control.pointee.mutate else { return false }; control.pointee.mutate = true; return true }
    mutating func enqueue(completion: UInt16) -> Bool { false }
    mutating func cancelPointerSequence(source: InputSourceID, sequence: PointerSequenceID) {}
}
struct CycleWake: ExecutionWakeRequester, Sendable {
    var reasons: ExecutionWakeReasons = []
    mutating func requestWake(for reasons: ExecutionWakeReasons) { self.reasons.formUnion(reasons) }
}

func cycleConcreteCoordinator<G, C, R, H>(owner: consuming CyclePipelineOwner<G, C, R, H>, dynamic: Bool, control: UnsafeMutablePointer<CycleControl>) -> Int where G: CycleGeometry, C: InteractionCandidateRecordStorage, R: InteractionCommittedRecordStorage, H: InteractionHitRegionStorage, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    let binding = CycleExecutionBinding(models: owner.models.borrowedScope(), root: owner.root.borrowedRoot(), control: control)
    let admission = SingleSourceExecutionAdmissionController(limits: ExecutionLimits(maximumInputEvents: 2, maximumStateChangeFacts: 1, maximumCompletionFacts: 0, maximumSemanticActions: 1, maximumActiveInputSources: 1, maximumCommittedActions: 6)!, context: control.pointee.context, committedPresentationRevision: nil, storage: CycleQueuedFacts(control: control), requester: CycleWake())
    #if !hasFeature(Embedded)
    if dynamic {
        var coordinator = DynamicRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
        guard case .success = coordinator.runOpportunity() else { preconditionFailure("Dynamic concrete coordinator") }
        precondition(coordinator.submit(stateChange: 1).result == .queued)
        precondition(coordinator.submit(stateChange: 1).result == .capacityRefused)
        guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("Dynamic admitted mutation") }
        precondition(summary.admission.stateChangeFactCount == 1)
        coordinator.quiesce(); coordinator.quiesce()
        precondition(coordinator.submit(stateChange: 1).result == .unavailable)
        guard case .failure(_, .execution(.requiredFacilityUnavailable), nil) = coordinator.runOpportunity() else { preconditionFailure("Dynamic stopped entry") }
        return 7
    }
    #endif
    var coordinator = StaticRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
    guard case .success = coordinator.runOpportunity() else { preconditionFailure("Static concrete coordinator") }
    precondition(coordinator.submit(stateChange: 1).result == .queued)
    precondition(coordinator.submit(stateChange: 1).result == .capacityRefused)
    guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("Static admitted mutation") }
    precondition(summary.admission.stateChangeFactCount == 1)
    coordinator.quiesce(); coordinator.quiesce()
    precondition(coordinator.submit(stateChange: 1).result == .unavailable)
    guard case .failure(_, .execution(.requiredFacilityUnavailable), nil) = coordinator.runOpportunity() else { preconditionFailure("Static stopped entry") }
    return 7
}
