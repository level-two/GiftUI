import GiftUI
import GiftUIExecution

package enum RuntimeCompletePipelineStage: UInt8, Equatable, Sendable {
    case admissionAndSeal = 0
    case applyAdmittedWork = 1
    case freezeObservableMutation = 2
    case observableCandidateAndSemanticExpansion = 3
    case layout = 4
    case canvasInvocationAndPlan = 5
    case combinedRenderPreflight = 6
    case interactionCandidate = 7
    case semanticAndObservablePublication = 8
    case candidateAllocation = 9
    case offerAndProduction = 10
}

package enum RuntimePipelineStepResult: Equatable, Sendable {
    case advanced
    case failure(RunCycleFailure<RuntimeOwnerFailure>)
}

package enum RuntimePipelineMutationResult: Equatable, Sendable {
    case applied(Bool)
    case failure(RunCycleFailure<RuntimeOwnerFailure>)
}

package struct RuntimePipelinePublication: Equatable, Sendable {
    package let semanticRevision: SemanticRevision
    package let changed: Bool

    package init(semanticRevision: SemanticRevision, changed: Bool) {
        self.semanticRevision = semanticRevision
        self.changed = changed
    }
}

package enum RuntimePipelinePublicationResult: Equatable, Sendable {
    case published(RuntimePipelinePublication)
    case failure(RunCycleFailure<RuntimeOwnerFailure>)
}

package enum RuntimePipelineOfferResult: Equatable, Sendable {
    case accepted(PresentationRevision)
    case noChange
    case backpressured
    case retryableRefusal
    case nonRetryableRefusal(FrameRefusalOrigin)
    case failure(RunCycleFailure<RuntimeOwnerFailure>)
}

package struct RuntimePipelineDisposition: Equatable, Sendable {
    package let semanticDisposition: SemanticCycleDisposition
    package let logicalFrameDisposition: LogicalFrameDisposition
    package let presentationIntentState: PresentationIntentState
    package let wakeReasons: ExecutionWakeReasons
    package let commitsInteractionCandidate: Bool
    package let preservesPublishedSemanticRevision: Bool
}

package struct RuntimePipelineCompletion: Equatable, Sendable {
    package let publication: RuntimePipelinePublication
    package let committedPresentationRevision: PresentationRevision?
    package let operational: ExecutionOperational?
    package let disposition: RuntimePipelineDisposition
}

package struct RuntimePipelineFailureRecord: Equatable, Sendable {
    package let stage: RuntimeCompletePipelineStage
    package let failure: RunCycleFailure<RuntimeOwnerFailure>
    package let publication: RuntimePipelinePublication?
    package let disposition: RuntimePipelineDisposition
}

package enum RuntimeCompletePipelineResult: Equatable, Sendable {
    case completed(RuntimePipelineCompletion)
    case failed(RuntimePipelineFailureRecord)
}

package protocol RuntimeCompletePipelineOwner: ~Copyable {
    mutating func admitAndSeal() -> RuntimePipelineStepResult
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult
    mutating func resolveLayout() -> RuntimePipelineStepResult
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult
    mutating func allocateCandidate() -> RuntimePipelineStepResult
    mutating func offerAndProduce() -> RuntimePipelineOfferResult
    mutating func cleanup(_ action: RuntimeCleanupAction)
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition)
    mutating func finalizePipeline()
}

package enum RuntimeCompletePipeline {
    package static func rejectInactive<Owner>(
        owner: inout Owner
    ) -> RuntimeCompletePipelineResult
    where Owner: RuntimeCompletePipelineOwner & ~Copyable {
        fail(
            at: .admissionAndSeal,
            failure: .execution(.invalidPhase),
            mutationApplied: false,
            publication: nil,
            acquired: [],
            owner: &owner
        )
    }

    package static func run<Owner>(
        owner: inout Owner
    ) -> RuntimeCompletePipelineResult
    where Owner: RuntimeCompletePipelineOwner & ~Copyable {
        var acquired: RuntimeCleanupActions = []
        var mutationApplied = false
        var publication: RuntimePipelinePublication?

        if case .failure(let failure) = owner.admitAndSeal() {
            return fail(
                at: .admissionAndSeal,
                failure: failure,
                mutationApplied: false,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        switch owner.applyAdmittedWork() {
        case .applied(let applied):
            mutationApplied = applied
        case .failure(let failure):
            return fail(
                at: .applyAdmittedWork,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        if case .failure(let failure) = owner.freezeObservableMutation() {
            return fail(
                at: .freezeObservableMutation,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }

        if case .failure(let failure) = owner.beginObservableCandidateAndExpandSemantics() {
            return fail(
                at: .observableCandidateAndSemanticExpansion,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        acquired.formUnion([
            .releaseCanvasCallable,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ])

        if case .failure(let failure) = owner.resolveLayout() {
            return fail(
                at: .layout,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        acquired.insert(.resetLayoutCandidate)

        if case .failure(let failure) = owner.invokeCanvasesAndDerivePlan() {
            return fail(
                at: .canvasInvocationAndPlan,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        acquired.remove(.releaseCanvasCallable)
        acquired.insert(.resetDrawingPlan)

        if case .failure(let failure) = owner.preflightCombinedRender() {
            return fail(
                at: .combinedRenderPreflight,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        acquired.insert(.resetRenderWorkspace)

        if case .failure(let failure) = owner.buildInteractionCandidate() {
            return fail(
                at: .interactionCandidate,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        acquired.insert(.discardInteractionCandidate)

        switch owner.publishSemanticAndObservableCandidate() {
        case .published(let value):
            publication = value
        case .failure(let failure):
            return fail(
                at: .semanticAndObservablePublication,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: nil,
                acquired: acquired,
                owner: &owner
            )
        }
        acquired.remove([
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
        ])

        if case .failure(let failure) = owner.allocateCandidate() {
            return fail(
                at: .candidateAllocation,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: publication,
                acquired: acquired,
                owner: &owner
            )
        }

        let offer = owner.offerAndProduce()
        let result: RuntimeCompletePipelineResult
        switch offer {
        case .accepted(let revision):
            let disposition = RuntimePipelineDisposition(
                semanticDisposition: publication!.changed ? .published : .unchanged,
                logicalFrameDisposition: .committed,
                presentationIntentState: .satisfied,
                wakeReasons: [],
                commitsInteractionCandidate: true,
                preservesPublishedSemanticRevision: true
            )
            var acceptedAcquired = acquired
            acceptedAcquired.remove(.discardInteractionCandidate)
            acceptedAcquired.insert(.commitInteractionCandidate)
            cleanup(
                after: .acceptedOffer,
                acquired: acceptedAcquired,
                owner: &owner
            )
            owner.applyDisposition(disposition)
            owner.finalizePipeline()
            result = .completed(
                RuntimePipelineCompletion(
                    publication: publication!,
                    committedPresentationRevision: revision,
                    operational: nil,
                    disposition: disposition
                )
            )
        case .noChange:
            guard !publication!.changed else {
                return fail(
                    at: .offerAndProduction,
                    failure: .execution(.invariantViolation),
                    mutationApplied: mutationApplied,
                    publication: publication,
                    acquired: acquired,
                    owner: &owner
                )
            }
            result = finishOfferWithoutCommit(
                operational: .noChange,
                state: .satisfied,
                wakeReasons: [],
                frameDisposition: .notProduced,
                publication: publication!,
                acquired: acquired,
                owner: &owner
            )
        case .backpressured:
            result = finishOfferWithoutCommit(
                operational: .backpressured,
                state: .pending,
                wakeReasons: [.presentationPending],
                frameDisposition: .aborted,
                publication: publication!,
                acquired: acquired,
                owner: &owner
            )
        case .retryableRefusal:
            result = finishOfferWithoutCommit(
                operational: .retryableRefusal,
                state: .pending,
                wakeReasons: [.presentationPending],
                frameDisposition: .aborted,
                publication: publication!,
                acquired: acquired,
                owner: &owner
            )
        case .nonRetryableRefusal(let origin):
            result = fail(
                at: .offerAndProduction,
                failure: .nonRetryableRefusal(origin),
                mutationApplied: mutationApplied,
                publication: publication,
                acquired: acquired,
                owner: &owner
            )
        case .failure(let failure):
            result = fail(
                at: .offerAndProduction,
                failure: failure,
                mutationApplied: mutationApplied,
                publication: publication,
                acquired: acquired,
                owner: &owner
            )
        }
        return result
    }

    private static func finishOfferWithoutCommit<Owner>(
        operational: ExecutionOperational,
        state: PresentationIntentState,
        wakeReasons: ExecutionWakeReasons,
        frameDisposition: LogicalFrameDisposition,
        publication: RuntimePipelinePublication,
        acquired: RuntimeCleanupActions,
        owner: inout Owner
    ) -> RuntimeCompletePipelineResult
    where Owner: RuntimeCompletePipelineOwner & ~Copyable {
        let disposition = RuntimePipelineDisposition(
            semanticDisposition: publication.changed ? .published : .unchanged,
            logicalFrameDisposition: frameDisposition,
            presentationIntentState: state,
            wakeReasons: wakeReasons,
            commitsInteractionCandidate: false,
            preservesPublishedSemanticRevision: true
        )
        cleanup(after: .offerProductionOrEndpoint, acquired: acquired, owner: &owner)
        owner.applyDisposition(disposition)
        owner.finalizePipeline()
        return .completed(
            RuntimePipelineCompletion(
                publication: publication,
                committedPresentationRevision: nil,
                operational: operational,
                disposition: disposition
            )
        )
    }

    private static func fail<Owner>(
        at stage: RuntimeCompletePipelineStage,
        failure: RunCycleFailure<RuntimeOwnerFailure>,
        mutationApplied: Bool,
        publication: RuntimePipelinePublication?,
        acquired: RuntimeCleanupActions,
        owner: inout Owner
    ) -> RuntimeCompletePipelineResult
    where Owner: RuntimeCompletePipelineOwner & ~Copyable {
        let wasPublished = publication != nil
        let disposition = RuntimePipelineDisposition(
            semanticDisposition: publication.map { $0.changed ? .published : .unchanged }
                ?? (mutationApplied ? .dirty : .unchanged),
            logicalFrameDisposition: wasPublished ? .aborted : .notProduced,
            presentationIntentState: wasPublished ? .unavailable : .satisfied,
            wakeReasons: !wasPublished && mutationApplied ? [.semanticDirty] : [],
            commitsInteractionCandidate: false,
            preservesPublishedSemanticRevision: wasPublished
        )
        cleanup(
            after: cleanupStage(for: stage, wasPublished: wasPublished),
            acquired: acquired,
            owner: &owner
        )
        owner.applyDisposition(disposition)
        owner.finalizePipeline()
        return .failed(
            RuntimePipelineFailureRecord(
                stage: stage,
                failure: failure,
                publication: publication,
                disposition: disposition
            )
        )
    }

    private static func cleanup<Owner>(
        after stage: RuntimeCoordinatorStage,
        acquired: RuntimeCleanupActions,
        owner: inout Owner
    ) where Owner: RuntimeCompletePipelineOwner & ~Copyable {
        var tracker = RuntimeCleanupTracker(
            plan: RuntimeCoordinatorCleanupOracle.plan(after: stage),
            acquired: acquired
        )
        while let action = tracker.takeNext() {
            owner.cleanup(action)
        }
    }

    private static func cleanupStage(
        for stage: RuntimeCompletePipelineStage,
        wasPublished: Bool
    ) -> RuntimeCoordinatorStage {
        if wasPublished { return .offerProductionOrEndpoint }
        return switch stage {
        case .admissionAndSeal, .applyAdmittedWork, .freezeObservableMutation,
            .observableCandidateAndSemanticExpansion:
            .observableBindingOrSemanticExpansion
        case .layout:
            .layout
        case .canvasInvocationAndPlan:
            .canvasInvocationOrPlan
        case .combinedRenderPreflight:
            .combinedRenderPreflight
        case .interactionCandidate, .semanticAndObservablePublication:
            .interactionBuildOrGeneration
        case .candidateAllocation, .offerAndProduction:
            .offerProductionOrEndpoint
        }
    }
}
