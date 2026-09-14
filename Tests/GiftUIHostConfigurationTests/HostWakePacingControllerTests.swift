import GiftUIExecution
import Testing

@testable import GiftUIHostConfiguration

private let analyzerPacing = HostPacingPolicy(
    minimumFrameIntervalMicroseconds: 250_000,
    maximumFactServiceLatencyMicroseconds: 250_000,
    minimumAcceptedTransitionSpacingMicroseconds: 50_000,
    maximumTransitionFactsPerServiceWindow: 20,
    maximumBootstrapFactsPerServiceWindow: 2,
    maximumActionInducedFactsPerServiceWindow: 6,
    maximumRetryableRefusals: 3
)!

@Test func firstFactRequestsOneWakeAndLaterReasonsCoalesce() {
    var pacing = HostWakePacingController(
        policy: analyzerPacing,
        initialFrameOriginMicroseconds: 0
    )

    #expect(pacing.recordAcceptedFact(at: 1) == .success(.requestWake))
    #expect(pacing.recordAcceptedFact(at: 2) == .success(.coalesced))
    #expect(pacing.record(.semanticDirty, at: 3) == .success(.coalesced))
    #expect(pacing.record(.presentationPending, at: 4) == .success(.coalesced))
    #expect(
        pacing.accumulatedReasons
            == [.admittedWork, .semanticDirty, .presentationPending]
    )
    #expect(pacing.wakeIsOutstanding)
    #expect(!pacing.opportunityIsActive)
}

@Test func frameBoundaryAndFactDeadlineAreExactAndInclusive() {
    var before = makePacingWithFirstFact(at: 1)
    #expect(before.schedule(at: 249_999) == .wait(untilMicroseconds: 250_000))
    #expect(before.beginOpportunity(at: 249_999) == .rejected(.tooEarly))

    var atBoundary = makePacingWithFirstFact(at: 1)
    #expect(atBoundary.schedule(at: 250_000) == .run)
    #expect(atBoundary.beginOpportunity(at: 250_000) == .began(.admittedWork))
    #expect(atBoundary.completeOpportunity(at: 250_001) == nil)

    var atDeadline = makePacingWithFirstFact(at: 1)
    #expect(atDeadline.schedule(at: 250_001) == .run)

    var afterDeadline = makePacingWithFirstFact(at: 1)
    #expect(afterDeadline.schedule(at: 250_002) == .invalid(.serviceDeadlineMissed))
    #expect(
        afterDeadline.beginOpportunity(at: 250_002)
            == .rejected(.serviceDeadlineMissed)
    )
}

@Test func factAfterSealStartsASeparateServiceWindowAndWake() {
    var pacing = makePacingWithFirstFact(at: 1)
    #expect(pacing.beginOpportunity(at: 250_000) == .began(.admittedWork))

    #expect(pacing.recordAcceptedFact(at: 250_001) == .success(.requestWake))
    #expect(pacing.completeOpportunity(at: 250_002) == nil)
    #expect(pacing.schedule(at: 499_999) == .wait(untilMicroseconds: 500_000))
    #expect(pacing.schedule(at: 500_000) == .run)
    #expect(pacing.beginOpportunity(at: 500_000) == .began(.admittedWork))
}

@Test func opportunityEntryIsNonReentrantAndQuiescenceIsTerminal() {
    var pacing = makePacingWithFirstFact(at: 1)
    #expect(pacing.beginOpportunity(at: 250_000) == .began(.admittedWork))
    #expect(pacing.beginOpportunity(at: 250_000) == .rejected(.reentrant))
    #expect(pacing.quiesce() == .reentrant)
    #expect(pacing.completeOpportunity(at: 250_000) == nil)
    #expect(pacing.quiesce() == nil)
    #expect(pacing.quiesce() == nil)
    #expect(pacing.recordAcceptedFact(at: 250_001) == .failure(.unavailable))
    #expect(pacing.schedule(at: 250_001) == .invalid(.unavailable))
}

@Test func checkedTimeAndMonotonicityFailuresAreFailClosed() {
    var overflow = HostWakePacingController(
        policy: analyzerPacing,
        initialFrameOriginMicroseconds: UInt64.max - 249_999
    )
    #expect(
        overflow.record(.semanticDirty, at: UInt64.max - 249_999)
            == .success(.requestWake)
    )
    #expect(
        overflow.schedule(at: UInt64.max - 249_999)
            == .invalid(.arithmeticOverflow)
    )

    var regression = makePacingWithFirstFact(at: 10)
    #expect(regression.recordAcceptedFact(at: 9) == .failure(.timeRegression))
    #expect(regression.schedule(at: 9) == .invalid(.timeRegression))
}

@Test func sustainedEightyFactsPerSecondProducesFourPacedOpportunities() {
    var pacing = HostWakePacingController(
        policy: analyzerPacing,
        initialFrameOriginMicroseconds: 0
    )
    var opportunityCount = 0
    var wakeRequestCount = 0

    for factIndex in 1 ... 80 {
        let timestamp = UInt64(factIndex) * 12_500
        if pacing.recordAcceptedFact(at: timestamp) == .success(.requestWake) {
            wakeRequestCount += 1
        }
        if timestamp.isMultiple(of: 250_000) {
            #expect(pacing.beginOpportunity(at: timestamp) == .began(.admittedWork))
            #expect(pacing.completeOpportunity(at: timestamp) == nil)
            opportunityCount += 1
        }
    }

    #expect(opportunityCount == 4)
    #expect(wakeRequestCount == 4)
    #expect(!pacing.wakeIsOutstanding)
}

private func makePacingWithFirstFact(at timestamp: UInt64) -> HostWakePacingController {
    var pacing = HostWakePacingController(
        policy: analyzerPacing,
        initialFrameOriginMicroseconds: 0
    )
    #expect(pacing.recordAcceptedFact(at: timestamp) == .success(.requestWake))
    return pacing
}
