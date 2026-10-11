import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUIRuntimeCore

struct ScopedOwner<Model: ~Copyable, Schema>: ~Copyable, ~Escapable, RuntimeCompletePipelineOwner {
    var hasAllocatedCandidateFrame: Bool { false }
    var presentationIntentState: PresentationIntentState { .satisfied }
    let models: ObservableModelScope<Model, Schema>
    @_lifetime(copy models)
    init(models: consuming ObservableModelScope<Model, Schema>) { self.models = consume models }
    mutating func admitAndSeal() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .failure(.execution(.invalidPhase)) }
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<RuntimeOwnerFailure> { .applied(false) }
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func resolveLayout() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<RuntimeOwnerFailure> { .failure(.execution(.invalidPhase)) }
    mutating func allocateCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> { .advanced }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<RuntimeOwnerFailure> { .noChange }
    mutating func cleanup(_ action: RuntimeCleanupAction) {}
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {}
    mutating func finalizePipeline() {}
}
func run<Model: ~Copyable, Schema>(_ models: borrowing ObservableModelScope<Model, Schema>) {
    var owner = ScopedOwner(models: models.borrowedScope())
    _ = RuntimeCompletePipeline.run(owner: &owner)
}
