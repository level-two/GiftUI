import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIExecution
@testable import GiftUIRuntimeCore

private struct TransactionMutationOwner: RecordingMutationOwner {
    typealias StateChange = UInt8
    typealias Completion = UInt8
    typealias ActionIdentity = UInt8

    private(set) var appliedStateChanges: [UInt8] = []
    private(set) var appliedCompletions: [UInt8] = []
    private(set) var dispatchedActions: [UInt8] = []

    mutating func apply(stateChange: borrowing UInt8) {
        appliedStateChanges.append(copy stateChange)
    }

    mutating func apply(completion: borrowing UInt8) {
        appliedCompletions.append(copy completion)
    }

    func actionGeneration(for identity: borrowing UInt8) -> ActionGeneration? {
        ActionGeneration(rawValue: UInt32(copy identity))
    }

    func isActionEnabled(_ identity: borrowing UInt8) -> Bool? {
        true
    }

    func targetGeneration(for identity: borrowing UInt8) -> ObservableTargetGeneration? {
        ObservableTargetGeneration(rawValue: UInt32(copy identity))
    }

    mutating func dispatch(_ identity: borrowing UInt8) {
        dispatchedActions.append(copy identity)
    }
}

private struct TransactionWakeRequester: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt8 = 0
    private(set) var reasons: ExecutionWakeReasons = []

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
        self.reasons.formUnion(reasons)
    }
}

private let transactionRect = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 2, height: 2)!
)!

private let transactionHeader = RenderPlanHeader(
    surfaceBounds: transactionRect,
    damageBounds: transactionRect,
    operationCount: 0,
    positionedGlyphCount: 0,
    maximumObservedClipDepth: 1
)

private func completeTransactionBody(
    _ sink: inout RecordingFrameSink
) -> FrameStreamResult {
    guard sink.begin(transactionHeader), sink.finish() else {
        return .contractViolation
    }
    return .complete
}

private func makeTransactionEndpoint() -> RecordingSynchronousFrameEndpoint {
    RecordingSynchronousFrameEndpoint(
        maximumDownstreamSlots: 1,
        sinkCapacity: RenderSinkCapacity(maximumOperations: 1, maximumPositionedGlyphs: 1)
    )!
}

@Test
func commonTransactionAppliesOnceOffersOnceAndCommitsRoutingOnlyOnAcceptance() {
    var lifecycle = makeIdleRuntimeCoordinatorLifecycle()
    var phases = ExecutionPhaseMachine()
    var cycles = RunCycleIDAllocator()
    #expect(phases.beginCycle(reservingFrom: &cycles) == nil)
    #expect(lifecycle.beginOpportunity(context: phases.context) == nil)

    #expect(phases.transition(to: .mutating) == nil)
    #expect(lifecycle.recordActiveContext(phases.context) == nil)
    var mutationOwner = TransactionMutationOwner()
    var mutation = RecordingMutationBatch<UInt8, UInt8, UInt8>(
        firstStateChange: 3,
        firstCompletion: 5,
        firstAction: RecordingSemanticAction(
            identity: 7,
            actionGeneration: ActionGeneration(rawValue: 7),
            targetGeneration: ObservableTargetGeneration(rawValue: 7)
        )
    )!
    #expect(mutation.apply(phase: .mutating, to: &mutationOwner) == nil)
    #expect(
        mutation.apply(phase: .mutating, to: &mutationOwner) == .reentrancyViolation
    )
    #expect(mutationOwner.appliedStateChanges == [3])
    #expect(mutationOwner.appliedCompletions == [5])
    #expect(mutationOwner.dispatchedActions == [7])

    #expect(phases.transition(to: .deriving) == nil)
    var semanticRevisions = SemanticRevisionAllocator()
    let semantic = semanticRevisions.reserve()!
    #expect(phases.transition(to: .publishing) == nil)
    #expect(phases.recordPublishedSemanticRevision(semantic) == nil)

    var offer = RecordingCandidateOfferCoordinator(endpoint: makeTransactionEndpoint())
    let outcome = offer.prepareAndOffer(
        origin: .newPublication,
        cycle: phases.context.cycle!,
        semanticRevision: semantic,
        body: completeTransactionBody
    )
    guard case .offered(let reservation, let endpointResult) = outcome else {
        Issue.record("expected accepted candidate offer")
        return
    }
    #expect(endpointResult.disposition == .accepted)
    #expect(offer.offerCallCount == 1)
    #expect(offer.endpoint.bodyCallCount == 1)

    let state = RecordingPresentationState(
        presentationRevision: reservation.presentationRevision,
        logicalFrameToken: 11,
        hitGeometryToken: 12,
        actionTableToken: 13,
        routingToken: 14
    )
    var commit = RecordingFrameCommitTransaction(
        publishedSemanticRevision: semantic,
        committedState: nil
    )
    #expect(commit.stage(candidate: reservation.provenance.candidateFrame, state: state) == nil)
    let observation = RecordingFrameBodyObservation(
        wasCalled: true,
        streamResult: .complete,
        retainedError: nil
    )!
    let normalized = RecordingFrameOfferNormalizer.normalize(
        observation: observation,
        endpointResult: endpointResult
    )
    let commitOutcome = commit.finish(
        normalizedOffer: normalized,
        completeConsumptionAndReservation: true,
        irreversibleOutputObserved: false
    )
    #expect(commitOutcome == .committed(state))
    #expect(commit.committedState == state)
    #expect(!commit.candidateAborted)

    let repeatedOffer = offer.prepareAndOffer(
        origin: .newPublication,
        cycle: phases.context.cycle!,
        semanticRevision: semantic,
        body: completeTransactionBody
    )
    guard case .failure(_, .execution(.reentrancyViolation), .notProduced) = repeatedOffer else {
        Issue.record("expected one-shot offer reentry failure")
        return
    }
    #expect(offer.offerCallCount == 1)

    #expect(phases.transition(to: .offering) == nil)
    #expect(lifecycle.recordActiveContext(phases.context) == nil)
    #expect(phases.transition(to: .finalizing) == nil)
    #expect(phases.transition(to: .idle) == nil)
    #expect(lifecycle.finishOpportunity(context: phases.context) == nil)
    #expect(lifecycle.state == .idle)
}

@Test
func refusedCandidateAbortsRoutingAndRetainsOnlyBoundedLatestRevisionIntent() {
    var occupiedEndpoint = makeTransactionEndpoint()
    let occupied = occupiedEndpoint.offer(
        provenance: FrameProvenance(
            cycle: RunCycleID(rawValue: 90),
            semanticRevision: SemanticRevision(rawValue: 91),
            candidateFrame: CandidateFrameID(rawValue: 92)
        ),
        body: completeTransactionBody
    )
    #expect(occupied.disposition == .accepted)

    let semantic = SemanticRevision(rawValue: 10)
    var offer = RecordingCandidateOfferCoordinator(endpoint: occupiedEndpoint)
    let outcome = offer.prepareAndOffer(
        origin: .newPublication,
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: semantic,
        body: completeTransactionBody
    )
    guard case .offered(let reservation, let endpointResult) = outcome else {
        Issue.record("expected backpressured candidate result")
        return
    }
    #expect(endpointResult.disposition == .backpressured)
    #expect(offer.offerCallCount == 1)
    #expect(offer.endpoint.bodyCallCount == 1)

    let staged = RecordingPresentationState(
        presentationRevision: reservation.presentationRevision,
        logicalFrameToken: 1,
        hitGeometryToken: 2,
        actionTableToken: 3,
        routingToken: 4
    )
    var commit = RecordingFrameCommitTransaction(
        publishedSemanticRevision: semantic,
        committedState: nil
    )
    #expect(commit.stage(candidate: reservation.provenance.candidateFrame, state: staged) == nil)
    let normalized = RecordingFrameOfferNormalizer.normalize(
        observation: .notCalled,
        endpointResult: endpointResult
    )
    let commitOutcome = commit.finish(
        normalizedOffer: normalized,
        completeConsumptionAndReservation: false,
        irreversibleOutputObserved: false
    )
    #expect(commitOutcome == .aborted(.operational(.backpressured)))
    #expect(commit.committedState == nil)
    #expect(commit.candidateAborted)

    var pending = RecordingPresentationPendingCoordinator(
        maximumRetryableRefusals: 2,
        requester: TransactionWakeRequester()
    )!
    let first = pending.recordBackpressure(for: semantic)
    #expect(first.intent?.semanticRevision == semantic)
    #expect(first.intent?.retryableRefusalCount == 0)
    #expect(first.operationalEvents == .backpressured)
    #expect(pending.wakes.requester.requestCount == 1)

    let newer = SemanticRevision(rawValue: 11)
    let superseding = pending.recordRetryableRefusal(for: newer)
    #expect(superseding.intent?.semanticRevision == newer)
    #expect(superseding.intent?.retryableRefusalCount == 1)
    #expect(superseding.operationalEvents == [.retryableRefusal, .superseded])
    let exhausted = pending.recordRetryableRefusal(for: newer)
    #expect(exhausted.exhausted)
    #expect(exhausted.intent == nil)
    #expect(pending.pendingIntent == nil)
}
