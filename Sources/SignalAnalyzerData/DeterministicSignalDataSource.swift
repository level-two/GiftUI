import SignalAnalyzerDomain

package struct SignalSourceTimingScale: Equatable, Sendable {
    package let numerator: UInt32
    package let denominator: UInt32

    package init?(numerator: UInt32, denominator: UInt32) {
        guard numerator > 0, denominator > 0 else { return nil }
        self.numerator = numerator
        self.denominator = denominator
    }

    package static let live = SignalSourceTimingScale(numerator: 1, denominator: 1)!

    package func applying(to duration: Duration) -> Duration {
        duration * Int(numerator) / Int(denominator)
    }
}

package struct SignalSourceGenerationError: SignalDataSourceDiagnosticError, Equatable, Sendable {
    package let signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic
}

package final class DeterministicSignalDataSource: SignalDataSource {
    package private(set) var activeGeneration: UInt32?
    package private(set) var lastGeneration: UInt32

    private var generator: DeterministicSignalGenerator
    private let timingScale: SignalSourceTimingScale
    private weak var sink: AnyObject?
    private var lastDeliveredTimestamp = Duration.zero
    private var emittedInitialLevels = false
    private var isShutdown = false

    package init(
        seed: UInt64 = 0x5EED,
        timingScale: SignalSourceTimingScale = .live,
        initialGeneration: UInt32 = 0
    ) {
        generator = DeterministicSignalGenerator(seed: seed)
        self.timingScale = timingScale
        lastGeneration = initialGeneration
    }

    package func start(sink: some SignalTransitionSink) throws {
        guard activeGeneration == nil else { return }
        guard !isShutdown, lastGeneration < .max else {
            throw generationError()
        }

        lastGeneration += 1
        activeGeneration = lastGeneration
        self.sink = sink as AnyObject
        if !emittedInitialLevels {
            for channel in SignalChannel.standard {
                sink.receive(
                    SignalTransition(channelID: channel.id, timestamp: .zero, level: .low)
                )
            }
            emittedInitialLevels = true
        }
    }

    package func stop() {
        activeGeneration = nil
        sink = nil
    }

    package var nextScheduledDelay: Duration? {
        guard activeGeneration != nil else { return nil }
        return timingScale.applying(to: generator.nextTimestamp - lastDeliveredTimestamp)
    }

    @discardableResult
    package func deliverScheduledTransition(generation: UInt32) -> Bool {
        guard generation == activeGeneration,
            let sink = sink as? any SignalTransitionSink
        else {
            return false
        }
        let transition = generator.nextTransition()
        lastDeliveredTimestamp = transition.timestamp
        sink.receive(transition)
        return true
    }

    package func shutdown() {
        isShutdown = true
        stop()
    }

    private func generationError() -> SignalSourceGenerationError {
        SignalSourceGenerationError(
            signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic(
                exactUTF8: Array("signal source generation unavailable".utf8)
            )!
        )
    }
}
