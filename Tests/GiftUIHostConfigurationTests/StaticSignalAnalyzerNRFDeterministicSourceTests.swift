import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func nRFDeterministicSourceMatchesPortableGeneratorAndGenerationRules() {
    var source = StaticSignalAnalyzerNRFDeterministicSource()
    var oracle = DeterministicSignalGenerator(seed: 0x5EED)
    let firstGeneration = source.start()
    #expect(firstGeneration == 1)
    #expect(source.nextScheduledDelay == nil)
    for channel in 1 ... 4 {
        let initial = source.takeInitialTransition()
        #expect(initial?.channelID.rawValue == channel)
        #expect(initial?.timestamp == .zero)
        #expect(initial?.level == .low)
    }
    #expect(source.takeInitialTransition() == nil)
    var lastTimestamp = Duration.zero
    for _ in 0 ..< 2_400 {
        #expect(source.nextScheduledDelay == oracle.nextTimestamp - lastTimestamp)
        let delivered = source.deliverScheduledTransition(generation: firstGeneration!)
        let expected = oracle.nextTransition()
        #expect(delivered == expected)
        lastTimestamp = expected.timestamp
    }
    source.stop()
    #expect(source.nextScheduledDelay == nil)
    #expect(source.deliverScheduledTransition(generation: firstGeneration!) == nil)
    let secondGeneration = source.start()
    #expect(secondGeneration == 2)
    #expect(source.takeInitialTransition() == nil)
    #expect(source.deliverScheduledTransition(generation: firstGeneration!) == nil)
    source.shutdown()
    #expect(source.start() == nil)
}
