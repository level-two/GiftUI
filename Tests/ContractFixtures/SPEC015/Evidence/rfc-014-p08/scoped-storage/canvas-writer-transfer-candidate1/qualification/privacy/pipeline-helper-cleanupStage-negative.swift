import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward(stage: RuntimeCompletePipelineStage, wasPublished: Bool) -> RuntimeCoordinatorStage { RuntimeCompletePipeline.cleanupStage(for: stage, wasPublished: wasPublished) }
