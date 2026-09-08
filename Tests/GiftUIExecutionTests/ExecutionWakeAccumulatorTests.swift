import Testing

@testable import GiftUIExecution

private struct FixtureWakeRequester: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt16 = 0
    private(set) var requestedReasons: ExecutionWakeReasons = []

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
        requestedReasons.formUnion(reasons)
    }
}

@Test
func emptyToNonemptyRequestsOnceAndDuplicatesCoalesce() {
    var accumulator = ExecutionWakeAccumulator(
        requester: FixtureWakeRequester()
    )

    accumulator.accumulate([])
    accumulator.accumulate(.admittedWork)
    accumulator.accumulate(.admittedWork)
    accumulator.accumulate(.semanticDirty)

    #expect(accumulator.wakeOutstanding)
    #expect(
        accumulator.accumulatedReasons
            == [.admittedWork, .semanticDirty]
    )
    #expect(accumulator.requester.requestCount == 1)
    #expect(accumulator.requester.requestedReasons == .admittedWork)
}

@Test
func rawReasonsAreMaskedBeforeAccumulationAndForwarding() {
    var accumulator = ExecutionWakeAccumulator(
        requester: FixtureWakeRequester()
    )

    accumulator.accumulate(ExecutionWakeReasons(rawValue: 0xF9))
    #expect(accumulator.accumulatedReasons == .admittedWork)
    #expect(accumulator.requester.requestedReasons == .admittedWork)

    let taken = accumulator.takeAtIdleOpportunity(phase: .idle)
    #expect(taken == .admittedWork)
    accumulator.accumulate(ExecutionWakeReasons(rawValue: 0xF8))
    #expect(accumulator.requester.requestCount == 1)
    #expect(!accumulator.wakeOutstanding)
}

@Test
func idleTakeAtomicallyAcknowledgesReasonsBeforeLaterWake() {
    var accumulator = ExecutionWakeAccumulator(
        requester: FixtureWakeRequester()
    )
    accumulator.accumulate([.admittedWork, .semanticDirty])

    let taken = accumulator.takeAtIdleOpportunity(phase: .idle)
    #expect(taken == [.admittedWork, .semanticDirty])
    #expect(accumulator.accumulatedReasons.isEmpty)
    #expect(!accumulator.wakeOutstanding)

    accumulator.accumulate(.presentationPending)
    #expect(accumulator.accumulatedReasons == .presentationPending)
    #expect(accumulator.wakeOutstanding)
    #expect(accumulator.requester.requestCount == 2)
}

@Test
func laterReasonCreatesOneTransitionDuringEveryActivePhase() {
    let laterPhases: [ExecutionPhase] = [
        .admitting,
        .mutating,
        .deriving,
        .publishing,
        .offering,
        .finalizing,
    ]

    for phase in laterPhases {
        var accumulator = ExecutionWakeAccumulator(
            requester: FixtureWakeRequester()
        )
        accumulator.accumulate(.admittedWork)
        #expect(
            accumulator.takeAtIdleOpportunity(phase: .idle)
                == .admittedWork
        )

        accumulator.accumulate(.semanticDirty)
        #expect(accumulator.requester.requestCount == 2, Comment("phase: \(phase)"))
        #expect(accumulator.wakeOutstanding)
        #expect(accumulator.accumulatedReasons == .semanticDirty)
    }
}

@Test
func nonidleTakeCannotAcknowledgeOutstandingWake() {
    for phase in ExecutionPhase.fixtureCases where phase != .idle {
        var accumulator = ExecutionWakeAccumulator(
            requester: FixtureWakeRequester()
        )
        accumulator.accumulate(.admittedWork)
        #expect(accumulator.takeAtIdleOpportunity(phase: phase) == nil)
        #expect(accumulator.wakeOutstanding)
        #expect(accumulator.accumulatedReasons == .admittedWork)
        #expect(accumulator.requester.requestCount == 1)
    }
}

@Test
func redundantIdleOpportunityTakesEmptyWithoutRequest() {
    var accumulator = ExecutionWakeAccumulator(
        requester: FixtureWakeRequester()
    )
    #expect(
        accumulator.takeAtIdleOpportunity(phase: .idle)
            == ExecutionWakeReasons()
    )
    #expect(accumulator.requester.requestCount == 0)
}

extension ExecutionPhase {
    fileprivate static let fixtureCases: [ExecutionPhase] = [
        .idle,
        .admitting,
        .mutating,
        .deriving,
        .publishing,
        .offering,
        .finalizing,
    ]
}
