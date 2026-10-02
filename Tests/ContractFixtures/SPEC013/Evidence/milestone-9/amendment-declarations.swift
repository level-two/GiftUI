// Review-only declaration feasibility; no runtime runner implementation.
import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
import SignalAnalyzerPresentation

package enum RuntimePipelineStepResult<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable {
    case advanced
    case failure(RunCycleFailure<OwnerFailure>)
}

package enum RuntimePipelineMutationResult<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable {
    case applied(Bool)
    case failure(RunCycleFailure<OwnerFailure>, mutationApplied: Bool)
}

package enum RuntimePipelinePublicationResult<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable {
    case published(RuntimePipelinePublication)
    case failure(RunCycleFailure<OwnerFailure>)
}

package enum RuntimePipelineOfferResult<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable {
    case accepted(PresentationRevision)
    case noChange
    case backpressured
    case retryableRefusal
    case nonRetryableRefusal(FrameRefusalOrigin)
    case failure(RunCycleFailure<OwnerFailure>)
}

package struct RuntimePipelineFailureRecord<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable {
    package let stage: RuntimeCompletePipelineStage
    package let failure: RunCycleFailure<OwnerFailure>
    package let publication: RuntimePipelinePublication?
    package let disposition: RuntimePipelineDisposition
}

package enum RuntimeCompletePipelineResult<OwnerFailure: Equatable & Sendable>:
    Equatable, Sendable {
    case completed(RuntimePipelineCompletion)
    case failed(RuntimePipelineFailureRecord<OwnerFailure>)
}

package enum ProbeCycleOwnerFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case application(SignalAnalyzerRuntimeCondition)
}

package protocol ProbePipelineOwner: ~Copyable {
    associatedtype OwnerFailure: Equatable & Sendable = RuntimeOwnerFailure
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<OwnerFailure>
}

package enum HostOpportunityResult<OwnerFailure: Equatable & Sendable>: Equatable, Sendable {
    case cycle(RunCycleResult<OwnerFailure>)
    case invalidLifecycle
}

package let partial: RuntimePipelineMutationResult<ProbeCycleOwnerFailure> =
    .failure(.focusedOwner(.application(.captureRevisionMismatch)), mutationApplied: true)
package let unchanged: RuntimePipelineMutationResult<RuntimeOwnerFailure> =
    .failure(.execution(.invariantViolation), mutationApplied: false)
package let capacity: RunCycleFailure<ProbeCycleOwnerFailure> =
    .focusedOwner(.application(.reservedFailureCapacityExhausted))
