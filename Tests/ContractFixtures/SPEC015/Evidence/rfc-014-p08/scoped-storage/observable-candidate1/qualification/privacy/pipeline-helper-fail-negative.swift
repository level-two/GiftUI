import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward<Owner: RuntimeCompletePipelineOwner & ~Copyable & ~Escapable>(_ owner: inout Owner, priorIntent: PresentationIntentState, stage: RuntimeCompletePipelineStage, failure: RunCycleFailure<Owner.OwnerFailure>, mutationApplied: Bool, publication: RuntimePipelinePublication?, acquired: RuntimeCleanupActions) -> RuntimeCompletePipelineResult<Owner.OwnerFailure> { RuntimeCompletePipeline.fail(priorIntent: priorIntent, at: stage, failure: failure, mutationApplied: mutationApplied, publication: publication, acquired: acquired, owner: &owner) }
