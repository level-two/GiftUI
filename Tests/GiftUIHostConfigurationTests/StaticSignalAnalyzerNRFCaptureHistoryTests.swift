import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFCaptureHistoryMatchesPortableInsertionTrimAndClear() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 19_392, alignment: 8)
    defer { pointer.deallocate() }
    guard
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: pointer, count: 19_392)
        )
    else {
        Issue.record("Exact capture region did not construct")
        return
    }
    var target = StaticSignalAnalyzerNRFCaptureHistory()
    var portable = SignalCaptureStore()

    func compare(_ source: SignalTransition) {
        let targetResult = target.receive(source, in: &regions)
        let portableResult = portable.receive(source)
        #expect(sameCaptureResult(targetResult, portableResult))
        #expect(target.revision == portable.revision)
        #expect(Int(target.count) == portable.capture.transitions.count)
        #expect(target.duration == portable.capture.duration)
        #expect(target.retainedLowerBound == portable.capture.retainedLowerBound)
        #expect(target.baselineLevels == portable.capture.baselineLevels)
        for index in 0 ..< Int(target.count) {
            let actual = regions.load(from: .live, at: index)?.transition
            #expect(actual == portable.capture.transitions[index])
        }
    }

    // Equal timestamps retain arrival order; an older valid item inserts in
    // front. The sustained run crosses both the five-second and 404 limits.
    compare(transition(channel: 1, milliseconds: 100, level: .high))
    compare(transition(channel: 2, milliseconds: 100, level: .low))
    compare(transition(channel: 3, milliseconds: 50, level: .high))
    for index in 0 ..< 2_450 {
        compare(
            transition(
                channel: index % 4 + 1,
                milliseconds: 200 + index * 12,
                level: index.isMultiple(of: 2) ? .high : .low
            ))
    }
    compare(transition(channel: 2, milliseconds: 25_000, level: .high))
    compare(transition(channel: 3, milliseconds: 60_000, level: .low))
    compare(transition(channel: 4, milliseconds: 1, level: .high))
    let targetClear = target.clear(in: &regions)
    let portableClear = portable.clear()
    #expect(sameCaptureResult(targetClear, portableClear))
    #expect(target.count == 0)
    #expect(target.baselineLevels == portable.capture.baselineLevels)
    compare(transition(channel: 1, milliseconds: 30_000, level: .low))
}

@Test func staticNRFCaptureHistoryRevisionExhaustionIsTerminal() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 19_392, alignment: 8)
    defer { pointer.deallocate() }
    guard
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: pointer, count: 19_392)
        )
    else {
        Issue.record("Exact capture region did not construct")
        return
    }
    var target = StaticSignalAnalyzerNRFCaptureHistory(initialRevision: .max - 1)
    var portable = SignalCaptureStore(initialRevision: .max - 1)
    let first = transition(channel: 1, milliseconds: 1, level: .high)
    #expect(sameCaptureResult(target.receive(first, in: &regions), portable.receive(first)))
    #expect(sameCaptureResult(target.receive(first, in: &regions), portable.receive(first)))
    #expect(sameCaptureResult(target.clear(in: &regions), portable.clear()))
}

@Test func staticNRFCaptureSnapshotSurvivesLiveMutationAndClear() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 19_392, alignment: 8)
    defer { pointer.deallocate() }
    guard
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: pointer, count: 19_392)
        )
    else {
        Issue.record("Exact capture region did not construct")
        return
    }
    var history = StaticSignalAnalyzerNRFCaptureHistory()
    let first = transition(channel: 1, milliseconds: 100, level: .high)
    let second = transition(channel: 2, milliseconds: 200, level: .low)
    _ = history.receive(first, in: &regions)
    _ = history.receive(second, in: &regions)
    let snapshot = history.snapshot(in: &regions)
    #expect(snapshot?.revision == 2)
    #expect(snapshot?.count == 2)
    #expect(snapshot?.duration == .milliseconds(200))
    #expect(snapshot?.retainedLowerBound == .zero)
    #expect(snapshot?.baselineLevels == .allLow)

    _ = history.receive(transition(channel: 4, milliseconds: 300, level: .high), in: &regions)
    _ = history.clear(in: &regions)
    #expect(regions.load(from: .admission, at: 0)?.transition == first)
    #expect(regions.load(from: .admission, at: 1)?.transition == second)
    #expect(history.count == 0)
    let cleared = history.snapshot(in: &regions)
    #expect(cleared?.revision == 4)
    #expect(cleared?.count == 0)
    #expect(cleared?.baselineLevels == history.baselineLevels)
}

private func transition(
    channel: Int, milliseconds: Int, level: DigitalLevel
) -> SignalTransition {
    SignalTransition(
        channelID: SignalChannelID(rawValue: channel),
        timestamp: .milliseconds(milliseconds),
        level: level
    )
}

private func sameCaptureResult(
    _ target: StaticSignalAnalyzerNRFCaptureHistoryResult,
    _ portable: SignalCaptureStoreResult
) -> Bool {
    switch (target, portable) {
    case (
        .accepted(revision: let revision, change: let change),
        .accepted(.mutation(revision: let portableRevision, change: let portableChange))
    ):
        revision == portableRevision && change == portableChange
    case (.rejected(.invalidTransition), .rejected(.invalidTransition)),
        (.rejected(.outsideRetainedHistory), .rejected(.outsideRetainedHistory)),
        (.rejected(.revisionExhausted), .rejected(.revisionExhausted)):
        true
    default:
        false
    }
}

@Test func fiveSecondHistoryMatchesIndependentFullHistoryAtEveryWindowEdge() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 19_392, alignment: 8)
    defer { pointer.deallocate() }
    var regions = StaticSignalAnalyzerNRFCaptureRegions(
        storage: UnsafeMutableRawBufferPointer(start: pointer, count: 19_392)
    )!
    var target = StaticSignalAnalyzerNRFCaptureHistory()
    var portable = SignalCaptureStore()
    var fullHistory: [SignalTransition] = []
    for cycle in 0 ... 600 {
        for channel in 1 ... 4 {
            let event = transition(
                channel: channel, milliseconds: cycle * 50,
                level: (cycle + channel).isMultiple(of: 2) ? .high : .low
            )
            fullHistory.append(event)
            #expect(sameCaptureResult(target.receive(event, in: &regions), portable.receive(event)))
        }
        let cutoff = max(0, cycle * 50 - 5_000)
        let expected = fullHistory.filter { $0.timestamp >= .milliseconds(cutoff) }
        #expect(Array(portable.capture.transitions) == expected)
        #expect(Int(target.count) == expected.count)
        #expect(target.retainedLowerBound == .milliseconds(cutoff))
        for channel in 1 ... 4 {
            let id = SignalChannelID(rawValue: channel)
            let expectedBaseline =
                fullHistory.last {
                    $0.channelID == id && $0.timestamp < .milliseconds(cutoff)
                }?.level ?? .low
            #expect(portable.capture.baselineLevel(for: id) == expectedBaseline)
            #expect(target.baselineLevels[id] == expectedBaseline)
            for seconds in [1, 2, 5] {
                let left = Duration.milliseconds(max(0, cycle * 50 - seconds * 1_000))
                let fullLevel =
                    fullHistory.last { $0.channelID == id && $0.timestamp <= left }?.level ?? .low
                let retainedLevel =
                    expected.last { $0.channelID == id && $0.timestamp <= left }?.level
                    ?? expectedBaseline
                let targetLevel =
                    (0 ..< Int(target.count)).compactMap {
                        regions.load(from: .live, at: $0)?.transition
                    }.last { $0.channelID == id && $0.timestamp <= left }?.level ?? expectedBaseline
                #expect(retainedLevel == fullLevel)
                #expect(targetLevel == fullLevel)
            }
        }
    }
    #expect(target.revision == 2_404)
    #expect(target.count == 404)
    #expect(target.duration == .seconds(30))
    #expect(target.retainedLowerBound == .seconds(25))
}
