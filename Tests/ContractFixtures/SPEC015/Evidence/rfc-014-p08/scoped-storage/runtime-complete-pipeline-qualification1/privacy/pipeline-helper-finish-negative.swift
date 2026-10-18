import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward<Owner: RuntimeCompletePipelineOwner & ~Copyable & ~Escapable>(_ owner: inout Owner, operational: ExecutionOperational, state: PresentationIntentState, wakeReasons: ExecutionWakeReasons, frameDisposition: LogicalFrameDisposition, publication: RuntimePipelinePublication, acquired: RuntimeCleanupActions) -> RuntimeCompletePipelineResult<Owner.OwnerFailure> { RuntimeCompletePipeline.finishOfferWithoutCommit(operational: operational, state: state, wakeReasons: wakeReasons, frameDisposition: frameDisposition, publication: publication, acquired: acquired, owner: &owner) }
