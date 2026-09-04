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
        generatorTask = Task { @MainActor [weak self, weak sink] in
            var conceptualNow = offset

            while !Task.isCancelled {
                guard
                    let plan = self?.makeEventPlan(
                        conceptualNow: conceptualNow,
                        generation: currentGeneration
                    )
                else {
                    return
                }

                do {
                    try await Task.sleep(for: plan.realDelay)
                } catch {
                    return
                }

                guard let source = self,
                    let sink,
                    source.generation == currentGeneration,
                    !Task.isCancelled
                else {
                    return
                }
                source.levels[plan.channelIndex].toggle()
                sink.receive(
                    SignalTransition(
                        channelID: SignalChannelID(rawValue: plan.channelIndex + 1),
                        timestamp: plan.timestamp,
                        level: source.levels[plan.channelIndex]
                    )
                )
                source.scheduleNextEvent(for: plan.channelIndex, after: plan.timestamp)
                conceptualNow = plan.timestamp
            }
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
            nextBurstInterval(),
            nextRandomInterval(),
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

    private struct EventPlan {
        let timestamp: Duration
        let channelIndex: Int
        let realDelay: Duration
    }

    private func makeEventPlan(
        conceptualNow: Duration,
        generation expectedGeneration: UInt64
    ) -> EventPlan? {
        guard generation == expectedGeneration,
            let nextTimestamp = nextEventTimes.min(),
            let channelIndex = nextEventTimes.firstIndex(of: nextTimestamp)
        else {
            return nil
        }
        let remaining = max(.zero, nextTimestamp - conceptualNow)
        return EventPlan(
            timestamp: nextTimestamp,
            channelIndex: channelIndex,
            realDelay: realDuration(forConceptualDuration: remaining)
        )
    }

    private func scheduleNextEvent(for channelIndex: Int, after timestamp: Duration) {
        let interval: Duration
        switch channelIndex {
        case 0:
            interval = .milliseconds(250)
        case 1:
            interval = .milliseconds(400)
        case 2:
            interval = nextBurstInterval()
        default:
            interval = nextRandomInterval()
        }
        nextEventTimes[channelIndex] = timestamp + interval
    }

    private func nextBurstInterval() -> Duration {
        let burstIntervals = [80, 80, 80, 1_200, 75, 75, 900]
        defer { burstIntervalIndex += 1 }
        return .milliseconds(burstIntervals[burstIntervalIndex % burstIntervals.count])
    }

    private func nextRandomInterval() -> Duration {
        randomState = randomState &* 6_364_136_223_846_793_005 &+ 1
        return .milliseconds(180 + Int(randomState % 420))
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
