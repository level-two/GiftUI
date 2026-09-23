import SignalAnalyzerData
import SignalAnalyzerDomain

/// Fixed-value lowering of the portable deterministic data source. It uses
/// the exact shared generator and yields one value per synchronous poll.
package struct StaticSignalAnalyzerNRFDeterministicSource {
    private var generator: DeterministicSignalGenerator
    package private(set) var activeGeneration: UInt32?
    package private(set) var lastGeneration: UInt32 = 0
    private var lastDeliveredTimestamp: Duration = .zero
    private var initialEmissionCount: UInt8 = 0
    private var isShutdown = false

    package init(seed: UInt64 = 0x5EED) {
        generator = DeterministicSignalGenerator(seed: seed)
    }

    package mutating func start() -> UInt32? {
        if let activeGeneration { return activeGeneration }
        guard !isShutdown, lastGeneration < .max else { return nil }
        lastGeneration += 1
        activeGeneration = lastGeneration
        return lastGeneration
    }

    package mutating func takeInitialTransition() -> SignalTransition? {
        guard activeGeneration != nil, initialEmissionCount < 4 else { return nil }
        initialEmissionCount += 1
        return SignalTransition(
            channelID: SignalChannelID(rawValue: Int(initialEmissionCount)),
            timestamp: .zero,
            level: .low
        )
    }

    package var nextScheduledDelay: Duration? {
        guard activeGeneration != nil, initialEmissionCount == 4 else { return nil }
        return generator.nextTimestamp - lastDeliveredTimestamp
    }

    package mutating func deliverScheduledTransition(
        generation: UInt32
    ) -> SignalTransition? {
        guard activeGeneration == generation, initialEmissionCount == 4 else { return nil }
        let transition = generator.nextTransition()
        lastDeliveredTimestamp = transition.timestamp
        return transition
    }

    package mutating func stop() {
        activeGeneration = nil
    }

    package mutating func shutdown() {
        isShutdown = true
        stop()
    }
}
