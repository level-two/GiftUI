import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
package func forward(publication: RuntimePipelinePublication, committedPresentationRevision: PresentationRevision?, operational: ExecutionOperational?, disposition: RuntimePipelineDisposition) -> RuntimePipelineCompletion { RuntimePipelineCompletion(publication: publication, committedPresentationRevision: committedPresentationRevision, operational: operational, disposition: disposition) }
