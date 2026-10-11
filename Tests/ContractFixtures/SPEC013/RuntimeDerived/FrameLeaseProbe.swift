import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUISemanticCore
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

private struct LeaseModel: ~Copyable {
    let destructions: UnsafeMutablePointer<UInt32>
    deinit { destructions.pointee += 1 }
}
private enum LeaseSchema {}

// Focused common-pipeline acquisition regression. Later algorithm stages are
// unreachable; this deliberately does not stand in for complete-cycle evidence.
private struct LeaseOwner: ~Copyable, ~Escapable, RuntimeCompletePipelineOwner {
    var hasAllocatedCandidateFrame: Bool { false }
    let presentationIntentState: PresentationIntentState
    let models: ObservableModelScope<LeaseModel, LeaseSchema>
    var ticket: ObservableModelTicket<LeaseSchema>
    var cleaned = 0
    var finalized = 0
    @_lifetime(copy models, copy ticket)
    init(models: consuming ObservableModelScope<LeaseModel, LeaseSchema>, ticket: consuming ObservableModelTicket<LeaseSchema>, presentationIntentState: PresentationIntentState) {
        self.models = consume models
        self.ticket = consume ticket
        self.presentationIntentState = presentationIntentState
    }
    mutating func admitAndSeal() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<RuntimeOwnerFailure> { .applied(true) }
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        do throws(ObservableStateError) {
            try models.beginFrame()
            try models.pin(ticket.key)
            try models.withDiscovery { () throws(ObservableStateError) in
                try models.release(&ticket)
            }
            return .advanced
        } catch { preconditionFailure("frame setup failed") }
    }
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        .failure(.focusedOwner(.semantic(.capacityExhausted)))
    }
    mutating func resolveLayout() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func allocateCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<RuntimeOwnerFailure> { preconditionFailure("later stage") }
    mutating func cleanup(_ action: RuntimeCleanupAction) {
        precondition(action == .resetAttemptStorage)
        do throws(ObservableStateError) { try models.endFrame() }
        catch { preconditionFailure("frame cleanup failed") }
        cleaned += 1
    }
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        precondition(disposition.presentationIntentState == presentationIntentState)
        precondition(disposition.semanticDisposition == .dirty)
        precondition(disposition.wakeReasons.contains(.semanticDirty))
    }
    mutating func finalizePipeline() { finalized += 1 }
}
private func exerciseLease(_ models: borrowing ObservableModelScope<LeaseModel, LeaseSchema>, destructions: UnsafeMutablePointer<UInt32>) throws(ObservableStateError) -> UInt32 {
    for iteration: UInt32 in 0..<3 {
        let prior: PresentationIntentState = iteration == 0 ? .satisfied : iteration == 1 ? .pending : .unavailable
        let ticket = try models.materialize(LeaseModel(destructions: destructions))
        var owner = LeaseOwner(models: models.borrowedScope(), ticket: consume ticket, presentationIntentState: prior)
        let result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .failed(let failure) = result else { preconditionFailure("failure lost") }
        precondition(failure.disposition.presentationIntentState == prior)
        precondition(failure.stage == .observableCandidateAndSemanticExpansion)
        precondition(failure.failure == .focusedOwner(.semantic(.capacityExhausted)))
        precondition(owner.cleaned == 1 && owner.finalized == 1)
        precondition(models.phase == .mutating)
        precondition(destructions.pointee == iteration + 1)
    }
    return 21
}
package func giftuiP07FrameLease() -> UInt32 {
    var namespace = ObservableModelOwnerNamespace()
    var destructions: UInt32 = 0
    var checks: UInt32 = 0
    do throws(ObservableStateError) {
        var fixed = StaticObservableModelStorage<LeaseModel, LeaseSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        checks += try withUnsafeMutablePointer(to: &destructions) { (count) throws(ObservableStateError) in
            try fixed.withLifetime { (models) throws(ObservableStateError) in
                try exerciseLease(models, destructions: count)
            }
        }
        precondition(destructions == 3)
        #if !hasFeature(Embedded)
        destructions = 0
        let dynamic = DynamicObservableModelStorage<LeaseModel, LeaseSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        checks += try withUnsafeMutablePointer(to: &destructions) { (count) throws(ObservableStateError) in
            try dynamic.withLifetime { (models) throws(ObservableStateError) in
                try exerciseLease(models, destructions: count)
            }
        }
        precondition(destructions == 3)
        #endif
    } catch { preconditionFailure("model activation failed") }
    return checks
}
