import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUISemanticCore
import Testing

@testable import GiftUIRuntimeCore

private struct CompletePipelineRecorder: RuntimeCompletePipelineOwner {
    var failureStage: RuntimeCompletePipelineStage?
    var injectedFailure: RunCycleFailure<RuntimeOwnerFailure>?
    var mutationApplied = true
    var publication = RuntimePipelinePublication(
        semanticRevision: SemanticRevision(rawValue: 7),
        changed: true
    )
    var offer: RuntimePipelineOfferResult = .accepted(
        PresentationRevision(rawValue: 9)
    )
    private(set) var stages: [RuntimeCompletePipelineStage] = []
    private(set) var cleanups: [RuntimeCleanupAction] = []
    private(set) var dispositions: [RuntimePipelineDisposition] = []
    private(set) var finalizationCount = 0

    mutating func admitAndSeal() -> RuntimePipelineStepResult {
        step(.admissionAndSeal)
    }

    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult {
        stages.append(.applyAdmittedWork)
        return failureStage == .applyAdmittedWork
            ? .failure(failure(for: .applyAdmittedWork))
            : .applied(mutationApplied)
    }

    mutating func freezeObservableMutation() -> RuntimePipelineStepResult {
        step(.freezeObservableMutation)
    }

    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult {
        step(.observableCandidateAndSemanticExpansion)
    }

    mutating func resolveLayout() -> RuntimePipelineStepResult {
        step(.layout)
    }

    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult {
        step(.canvasInvocationAndPlan)
    }

    mutating func preflightCombinedRender() -> RuntimePipelineStepResult {
        step(.combinedRenderPreflight)
    }

    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult {
        step(.interactionCandidate)
    }

    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult {
        stages.append(.semanticAndObservablePublication)
        return failureStage == .semanticAndObservablePublication
            ? .failure(failure(for: .semanticAndObservablePublication))
            : .published(publication)
    }

    mutating func allocateCandidate() -> RuntimePipelineStepResult {
        step(.candidateAllocation)
    }

    mutating func offerAndProduce() -> RuntimePipelineOfferResult {
        stages.append(.offerAndProduction)
        if failureStage == .offerAndProduction {
            return .failure(failure(for: .offerAndProduction))
        }
        return offer
    }

    mutating func cleanup(_ action: RuntimeCleanupAction) {
        cleanups.append(action)
    }

    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        dispositions.append(disposition)
    }

    mutating func finalizePipeline() {
        finalizationCount += 1
    }

    private mutating func step(
        _ stage: RuntimeCompletePipelineStage
    ) -> RuntimePipelineStepResult {
        stages.append(stage)
        guard failureStage != stage else {
            return .failure(failure(for: stage))
        }
        return .advanced
    }

    private func failure(
        for stage: RuntimeCompletePipelineStage
    ) -> RunCycleFailure<RuntimeOwnerFailure> {
        if let injectedFailure { return injectedFailure }
        return switch stage {
        case .layout:
            .focusedOwner(.layout(.capacityExhausted))
        case .canvasInvocationAndPlan:
            .focusedOwner(.drawing(.invalidValue))
        case .combinedRenderPreflight, .offerAndProduction:
            .renderProduction(.invariantViolation)
        default:
            .execution(.invariantViolation)
        }
    }
}

private let exactPipelineOrder: [RuntimeCompletePipelineStage] = [
    .admissionAndSeal,
    .applyAdmittedWork,
    .freezeObservableMutation,
    .observableCandidateAndSemanticExpansion,
    .layout,
    .canvasInvocationAndPlan,
    .combinedRenderPreflight,
    .interactionCandidate,
    .semanticAndObservablePublication,
    .candidateAllocation,
    .offerAndProduction,
]

private let everyFocusedOwnerFailure: [RunCycleFailure<RuntimeOwnerFailure>] = [
    .focusedOwner(.semantic(.invalidIdentity)),
    .focusedOwner(.layout(.arithmeticOverflow)),
    .focusedOwner(.observableState(.replacementStagingCapacityExhausted)),
    .focusedOwner(.interaction(.invalidGeometry)),
    .focusedOwner(.drawing(.invalidPathState)),
]

private func expectedFailureCleanups(
    at stage: RuntimeCompletePipelineStage
) -> [RuntimeCleanupAction] {
    switch stage {
    case .admissionAndSeal, .applyAdmittedWork, .freezeObservableMutation,
        .observableCandidateAndSemanticExpansion:
        []
    case .layout:
        [.discardSemanticCandidate, .discardObservableCandidate, .resetAttemptStorage]
    case .canvasInvocationAndPlan:
        [
            .releaseCanvasCallable,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    case .combinedRenderPreflight:
        [
            .resetDrawingPlan,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    case .interactionCandidate:
        [
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    case .semanticAndObservablePublication:
        [
            .discardInteractionCandidate,
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    case .candidateAllocation, .offerAndProduction:
        [
            .discardInteractionCandidate,
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetAttemptStorage,
        ]
    }
}

@Test func inactivePipelineIsRejectedBeforeOwnerWorkAndFinalizedOnce() {
    var owner = CompletePipelineRecorder()
    let result = RuntimeCompletePipeline.rejectInactive(owner: &owner)
    guard case .failed(let failure) = result else {
        Issue.record("expected inactive pipeline rejection")
        return
    }
    #expect(failure.stage == .admissionAndSeal)
    #expect(failure.failure == .execution(.invalidPhase))
    #expect(owner.stages.isEmpty)
    #expect(owner.cleanups.isEmpty)
    #expect(owner.finalizationCount == 1)
}

@Test func completePipelineAcceptsInExactOrderAndCommitsRouting() {
    var owner = CompletePipelineRecorder()
    let result = RuntimeCompletePipeline.run(owner: &owner)
    guard case .completed(let completion) = result else {
        Issue.record("expected completed accepted pipeline")
        return
    }
    #expect(owner.stages == exactPipelineOrder)
    #expect(owner.cleanups == [.commitInteractionCandidate, .resetAttemptStorage])
    #expect(owner.finalizationCount == 1)
    #expect(completion.publication.semanticRevision == SemanticRevision(rawValue: 7))
    #expect(completion.committedPresentationRevision == PresentationRevision(rawValue: 9))
    #expect(completion.operational == nil)
    #expect(completion.disposition.semanticDisposition == .published)
    #expect(completion.disposition.logicalFrameDisposition == .committed)
    #expect(completion.disposition.commitsInteractionCandidate)
    #expect(completion.disposition.wakeReasons.isEmpty)
}

@Test func drawingFailureStopsThePipelineDirtiesAppliedMutationAndCleansOnce() {
    var owner = CompletePipelineRecorder(failureStage: .canvasInvocationAndPlan)
    let result = RuntimeCompletePipeline.run(owner: &owner)
    guard case .failed(let failure) = result else {
        Issue.record("expected drawing failure")
        return
    }
    #expect(failure.stage == .canvasInvocationAndPlan)
    #expect(failure.failure == .focusedOwner(.drawing(.invalidValue)))
    #expect(owner.stages == Array(exactPipelineOrder.prefix(6)))
    #expect(
        owner.cleanups == [
            .releaseCanvasCallable,
            .resetLayoutCandidate,
            .discardSemanticCandidate,
            .discardObservableCandidate,
            .resetAttemptStorage,
        ]
    )
    #expect(failure.disposition.semanticDisposition == .dirty)
    #expect(failure.disposition.logicalFrameDisposition == .notProduced)
    #expect(failure.disposition.wakeReasons == [.semanticDirty])
    #expect(!failure.disposition.preservesPublishedSemanticRevision)
    #expect(owner.finalizationCount == 1)
}

@Test func publishedRefusalNeverRollsBackAndRetainsOnlyPresentationIntent() {
    var owner = CompletePipelineRecorder(offer: .backpressured)
    let result = RuntimeCompletePipeline.run(owner: &owner)
    guard case .completed(let completion) = result else {
        Issue.record("expected bounded backpressure completion")
        return
    }
    #expect(owner.stages == exactPipelineOrder)
    #expect(
        owner.cleanups == [
            .discardInteractionCandidate,
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetAttemptStorage,
        ]
    )
    #expect(completion.operational == .backpressured)
    #expect(completion.disposition.semanticDisposition == .published)
    #expect(completion.disposition.logicalFrameDisposition == .aborted)
    #expect(completion.disposition.presentationIntentState == .pending)
    #expect(completion.disposition.wakeReasons == [.presentationPending])
    #expect(!completion.disposition.commitsInteractionCandidate)
    #expect(completion.disposition.preservesPublishedSemanticRevision)
    #expect(owner.finalizationCount == 1)
}

@Test func everyInjectedStageFailureSkipsLaterFallibleWorkAndFinalizesOnce() {
    for stage in exactPipelineOrder.dropLast() {
        var owner = CompletePipelineRecorder(failureStage: stage)
        let result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .failed(let failure) = result else {
            Issue.record("expected injected failure at \(stage)")
            continue
        }
        #expect(failure.stage == stage)
        let expectedCount = Int(stage.rawValue) + 1
        #expect(owner.stages == Array(exactPipelineOrder.prefix(expectedCount)))
        #expect(owner.finalizationCount == 1)
        #expect(owner.dispositions.count == 1)
    }
}

@Test func profileEquivalentOwnersProduceEqualCompletePipelineTranscripts() {
    var dynamicOwner = CompletePipelineRecorder()
    var staticOwner = CompletePipelineRecorder()
    let dynamicResult = RuntimeCompletePipeline.run(owner: &dynamicOwner)
    let staticResult = RuntimeCompletePipeline.run(owner: &staticOwner)
    #expect(dynamicResult == staticResult)
    #expect(dynamicOwner.stages == staticOwner.stages)
    #expect(dynamicOwner.cleanups == staticOwner.cleanups)
    #expect(dynamicOwner.dispositions == staticOwner.dispositions)
    #expect(dynamicOwner.finalizationCount == staticOwner.finalizationCount)
}

@Test func exactFocusedOwnerFailuresSurvivePipelineWithoutCollapsing() {
    let rows: [(RuntimeCompletePipelineStage, RunCycleFailure<RuntimeOwnerFailure>)] = [
        (.observableCandidateAndSemanticExpansion, .focusedOwner(.semantic(.invalidIdentity))),
        (.layout, .focusedOwner(.layout(.arithmeticOverflow))),
        (
            .semanticAndObservablePublication,
            .focusedOwner(.observableState(.replacementStagingCapacityExhausted))
        ),
        (.interactionCandidate, .focusedOwner(.interaction(.invalidGeometry))),
        (.canvasInvocationAndPlan, .focusedOwner(.drawing(.invalidPathState))),
    ]
    for (stage, expected) in rows {
        var owner = CompletePipelineRecorder(
            failureStage: stage,
            injectedFailure: expected
        )
        let result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .failed(let record) = result else {
            Issue.record("expected focused failure at \(stage)")
            continue
        }
        #expect(record.failure == expected)
        #expect(record.stage == stage)
        #expect(owner.finalizationCount == 1)
    }
}

@Test func everyFocusedOwnerFailureAtEveryStageHasExactCleanupAndDisposition() {
    for stage in exactPipelineOrder {
        for injectedFailure in everyFocusedOwnerFailure {
            var owner = CompletePipelineRecorder(
                failureStage: stage,
                injectedFailure: injectedFailure
            )
            let result = RuntimeCompletePipeline.run(owner: &owner)
            guard case .failed(let record) = result else {
                Issue.record("expected focused failure at \(stage)")
                continue
            }

            #expect(record.stage == stage)
            #expect(record.failure == injectedFailure)
            #expect(owner.stages == Array(exactPipelineOrder.prefix(Int(stage.rawValue) + 1)))
            #expect(owner.cleanups == expectedFailureCleanups(at: stage))
            #expect(owner.dispositions == [record.disposition])
            #expect(owner.finalizationCount == 1)
            for action in owner.cleanups {
                #expect(owner.cleanups.count(where: { $0 == action }) == 1)
            }

            let wasPublished = stage == .candidateAllocation || stage == .offerAndProduction
            let mutationWasApplied =
                stage.rawValue
                >= RuntimeCompletePipelineStage
                .freezeObservableMutation.rawValue
            #expect(
                record.disposition.semanticDisposition
                    == (wasPublished ? .published : (mutationWasApplied ? .dirty : .unchanged))
            )
            #expect(
                record.disposition.logicalFrameDisposition
                    == (wasPublished ? .aborted : .notProduced))
            #expect(
                record.disposition.presentationIntentState
                    == (wasPublished ? .unavailable : .satisfied))
            #expect(
                record.disposition.wakeReasons
                    == (mutationWasApplied && !wasPublished ? [.semanticDirty] : []))
            #expect(!record.disposition.commitsInteractionCandidate)
            #expect(record.disposition.preservesPublishedSemanticRevision == wasPublished)
        }
    }
}

@Test func unchangedPublicationAndPostPublicationFailureKeepExactDisposition() {
    var unchanged = CompletePipelineRecorder(
        publication: RuntimePipelinePublication(
            semanticRevision: SemanticRevision(rawValue: 7),
            changed: false
        )
    )
    let unchangedResult = RuntimeCompletePipeline.run(owner: &unchanged)
    guard case .completed(let unchangedCompletion) = unchangedResult else {
        Issue.record("expected unchanged accepted completion")
        return
    }
    #expect(unchangedCompletion.disposition.semanticDisposition == .unchanged)

    var failed = CompletePipelineRecorder(
        offer: .nonRetryableRefusal(.renderProducer)
    )
    let failedResult = RuntimeCompletePipeline.run(owner: &failed)
    guard case .failed(let failure) = failedResult else {
        Issue.record("expected post-publication nonretryable refusal")
        return
    }
    #expect(failure.failure == .nonRetryableRefusal(.renderProducer))
    #expect(failure.disposition.semanticDisposition == .published)
    #expect(failure.disposition.logicalFrameDisposition == .aborted)
    #expect(failure.disposition.presentationIntentState == .unavailable)
    #expect(failure.disposition.wakeReasons.isEmpty)
    #expect(failure.disposition.preservesPublishedSemanticRevision)
    #expect(!failure.disposition.commitsInteractionCandidate)
    #expect(failed.finalizationCount == 1)
}

@Test func noChangeAndRetryableRefusalRemainDistinctBoundedOutcomes() {
    let unchangedPublication = RuntimePipelinePublication(
        semanticRevision: SemanticRevision(rawValue: 7),
        changed: false
    )
    var noChange = CompletePipelineRecorder(
        publication: unchangedPublication,
        offer: .noChange
    )
    let noChangeResult = RuntimeCompletePipeline.run(owner: &noChange)
    guard case .completed(let noChangeCompletion) = noChangeResult else {
        Issue.record("expected no-change completion")
        return
    }
    #expect(noChangeCompletion.operational == .noChange)
    #expect(noChangeCompletion.disposition.logicalFrameDisposition == .notProduced)
    #expect(noChangeCompletion.disposition.presentationIntentState == .satisfied)
    #expect(noChangeCompletion.disposition.wakeReasons.isEmpty)

    var retryable = CompletePipelineRecorder(offer: .retryableRefusal)
    let retryableResult = RuntimeCompletePipeline.run(owner: &retryable)
    guard case .completed(let retryableCompletion) = retryableResult else {
        Issue.record("expected retryable-refusal completion")
        return
    }
    #expect(retryableCompletion.operational == .retryableRefusal)
    #expect(retryableCompletion.disposition.logicalFrameDisposition == .aborted)
    #expect(retryableCompletion.disposition.presentationIntentState == .pending)
    #expect(retryableCompletion.disposition.wakeReasons == [.presentationPending])
}

@Test func failedEndpointPreservesPublicationAndDiscardsCandidateRouting() {
    let endpointFailure = RunCycleFailure<RuntimeOwnerFailure>.frameOffer(.producerFailed)
    var owner = CompletePipelineRecorder(
        failureStage: .offerAndProduction,
        injectedFailure: endpointFailure
    )
    let result = RuntimeCompletePipeline.run(owner: &owner)
    guard case .failed(let failure) = result else {
        Issue.record("expected endpoint failure")
        return
    }

    #expect(failure.failure == endpointFailure)
    #expect(failure.publication?.semanticRevision == SemanticRevision(rawValue: 7))
    #expect(failure.disposition.semanticDisposition == .published)
    #expect(failure.disposition.logicalFrameDisposition == .aborted)
    #expect(failure.disposition.presentationIntentState == .unavailable)
    #expect(failure.disposition.wakeReasons.isEmpty)
    #expect(!failure.disposition.commitsInteractionCandidate)
    #expect(failure.disposition.preservesPublishedSemanticRevision)
    #expect(
        owner.cleanups == [
            .discardInteractionCandidate,
            .resetRenderWorkspace,
            .resetDrawingPlan,
            .resetAttemptStorage,
        ]
    )
    #expect(owner.finalizationCount == 1)
}
