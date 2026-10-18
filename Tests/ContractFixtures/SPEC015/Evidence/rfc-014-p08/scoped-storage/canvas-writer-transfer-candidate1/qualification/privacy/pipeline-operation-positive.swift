import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward<Owner: RuntimeCompletePipelineOwner & ~Copyable & ~Escapable>(_ owner: inout Owner) -> RuntimeCompletePipelineResult<Owner.OwnerFailure> { RuntimeCompletePipeline.run(owner: &owner) }
