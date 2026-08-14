import Foundation
import SignalAnalyzerDomain

@MainActor
package final class MockSignalDataSource: SignalDataSource {
    package struct Configuration {
        var seed: UInt64
        var timeScale: Double

        package init(seed: UInt64 = 0x5EED, timeScale: Double = 1) {
            precondition(timeScale > 0)
            self.seed = seed
            self.timeScale = timeScale
        }

        package static let live = Configuration()
        package static let accelerated = Configuration(seed: 1234, timeScale: 0.01)
    }

    private let configuration: Configuration
    private let clock = ContinuousClock()

    private var generatorTask: Task<Void, Never>?
    private var generation: UInt64 = 0
    private var runStartedAt: ContinuousClock.Instant?
    private var activeElapsed: Duration = .zero
    private var nextEventTimes: [Duration] = []
    private var levels = Array(repeating: DigitalLevel.low, count: 4)
    private var burstIntervalIndex = 0
    private var randomState: UInt64
    private var emittedInitialLevels = false

    package init(configuration: Configuration = .live) {
        self.configuration = configuration
        self.randomState = configuration.seed
    }

    deinit {
        generatorTask?.cancel()
    }

    package func start(sink: some SignalTransitionSink) throws {
        guard generatorTask == nil else { return }

        let initialTransitions = emittedInitialLevels ? [] : makeInitialTransitions()
        generation &+= 1
        let currentGeneration = generation
        let offset = activeElapsed
        runStartedAt = clock.now
        generatorTask = Task { @MainActor [weak self, sink] in
            await self?.generate(
                from: offset,
                generation: currentGeneration,
                sink: sink
            )
        }

        for transition in initialTransitions where generation == currentGeneration {
            sink.receive(transition)
        }
    }

    package func stop() {
        guard let task = generatorTask else { return }

        if let runStartedAt {
            let realElapsed = runStartedAt.duration(to: clock.now)
            activeElapsed += conceptualDuration(forRealDuration: realElapsed)
        }
        self.runStartedAt = nil
        generatorTask = nil
        generation &+= 1
        task.cancel()
    }

    private func makeInitialTransitions() -> [SignalTransition] {
        nextEventTimes = [
            .milliseconds(250),
            .milliseconds(400),
            .milliseconds(120),
            .milliseconds(310)
        ]
        emittedInitialLevels = true

        return levels.indices.map { index in
            SignalTransition(
                channelID: SignalChannelID(rawValue: index + 1),
                timestamp: .zero,
                level: .low
            )
        }
    }

    private func generate(
        from offset: Duration,
        generation expectedGeneration: UInt64,
        sink: some SignalTransitionSink
    ) async {
        var conceptualNow = offset

        while !Task.isCancelled {
            guard generation == expectedGeneration,
                  let nextTimestamp = nextEventTimes.min(),
                  let channelIndex = nextEventTimes.firstIndex(of: nextTimestamp) else {
                return
            }
            let remaining = max(.zero, nextTimestamp - conceptualNow)

            do {
                try await Task.sleep(for: realDuration(forConceptualDuration: remaining))
            } catch {
                return
            }

            guard generation == expectedGeneration, !Task.isCancelled else { return }
            levels[channelIndex].toggle()
            sink.receive(
                SignalTransition(
                    channelID: SignalChannelID(rawValue: channelIndex + 1),
                    timestamp: nextTimestamp,
                    level: levels[channelIndex]
                )
            )
            scheduleNextEvent(for: channelIndex, after: nextTimestamp)
            conceptualNow = nextTimestamp
        }
    }

    private func scheduleNextEvent(for channelIndex: Int, after timestamp: Duration) {
        let interval: Duration
        switch channelIndex {
        case 0:
            interval = .milliseconds(250)
        case 1:
            interval = .milliseconds(400)
        case 2:
            let burstIntervals = [80, 80, 80, 1_200, 75, 75, 900]
            interval = .milliseconds(burstIntervals[burstIntervalIndex % burstIntervals.count])
            burstIntervalIndex += 1
        default:
            randomState = randomState &* 6_364_136_223_846_793_005 &+ 1
            interval = .milliseconds(180 + Int(randomState % 420))
        }
        nextEventTimes[channelIndex] = timestamp + interval
    }

    private func realDuration(forConceptualDuration duration: Duration) -> Duration {
        durationFromSeconds(duration.secondsValue * configuration.timeScale)
    }

    private func conceptualDuration(forRealDuration duration: Duration) -> Duration {
        durationFromSeconds(duration.secondsValue / configuration.timeScale)
    }

    private func durationFromSeconds(_ seconds: Double) -> Duration {
        .nanoseconds(Int64(max(0, seconds) * 1_000_000_000))
    }
}
