import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward<Owner: RuntimeCompletePipelineOwner & ~Copyable & ~Escapable>(_ owner: inout Owner, stage: RuntimeCoordinatorStage, acquired: RuntimeCleanupActions) { RuntimeCompletePipeline.cleanup(after: stage, acquired: acquired, owner: &owner) }
