import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func nRFCompactCaptureFactRoundTripsWithinFixedSlot() {
    #expect(MemoryLayout<StaticSignalAnalyzerNRFCompactCaptureFact>.stride == 64)
    let transition = SignalTransition(
        channelID: SignalChannelID(rawValue: 4),
        timestamp: .milliseconds(125),
        level: .high
    )
    let levels = SignalChannelLevels(
        ch1: .high, ch2: .low, ch3: .high, ch4: .high
    )
    let mutation = SignalCaptureChange.insertAndTrim(
        baseRevision: 7,
        insertionIndex: 2,
        transition: transition,
        evictedPrefixCount: 1,
        duration: .seconds(35),
        retainedLowerBound: .seconds(5),
        baselines: levels
    )
    let inserted = StaticSignalAnalyzerNRFCompactCaptureFact(
        sequence: 12, revision: 8, change: mutation
    )
    #expect(inserted?.sequence == 12)
    #expect(inserted?.publication?.revision == 8)
    #expect(inserted?.publication?.change == mutation)

    let reset = SignalCaptureChange.reset(baseRevision: 8, baselines: levels)
    let cleared = StaticSignalAnalyzerNRFCompactCaptureFact(
        sequence: 13, revision: 9, change: reset
    )
    #expect(cleared?.publication?.change == reset)
    #expect(
        StaticSignalAnalyzerNRFCompactCaptureFact(
            sequence: 14, revision: 10, change: reset
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFCompactCaptureFact(
            sequence: 0, revision: 9, change: reset
        ) == nil)
}
