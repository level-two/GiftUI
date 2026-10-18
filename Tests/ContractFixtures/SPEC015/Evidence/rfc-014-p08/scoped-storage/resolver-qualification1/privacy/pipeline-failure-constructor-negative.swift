import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward<Failure: Equatable & Sendable>(stage: RuntimeCompletePipelineStage, failure: RunCycleFailure<Failure>, publication: RuntimePipelinePublication?, disposition: RuntimePipelineDisposition) -> RuntimePipelineFailureRecord<Failure> { RuntimePipelineFailureRecord<Failure>(stage: stage, failure: failure, publication: publication, disposition: disposition) }
