import SignalAnalyzerData
import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer checked capture store")
struct SignalCaptureStoreTests {
    @Test("empty store starts at revision zero")
    func emptyStore() {
        let store = SignalCaptureStore()

        #expect(store.revision == 0)
        #expect(store.capture == .empty())
        #expect(store.currentLevels == .allLow)
    }

    @Test("equal timestamps retain arrival order and out-of-order values insert stably")
    func stableInsertion() {
        var store = SignalCaptureStore()

        _ = store.receive(transition(20, channel: 1, level: .high))
        _ = store.receive(transition(10, channel: 2, level: .high))
        _ = store.receive(transition(20, channel: 3, level: .high))

        #expect(
            store.capture.transitions.map(\.timestamp) == [
                .milliseconds(10), .milliseconds(20), .milliseconds(20),
            ])
        #expect(store.capture.transitions.map(\.channelID.rawValue) == [2, 1, 3])
        #expect(store.capture.duration == .milliseconds(20))
        #expect(store.revision == 3)
    }

    @Test("thirty-second cutoff trims oldest entries and reconstructs baselines")
    func timeRetention() {
        var store = SignalCaptureStore()

        _ = store.receive(transition(0, channel: 1, level: .high))
        _ = store.receive(transition(1_000, channel: 2, level: .high))
        let preceding = SignalCaptureRevisionState(revision: store.revision, capture: store.capture)
        let result = store.receive(transition(31_000, channel: 3, level: .high))

        #expect(store.capture.retainedLowerBound == .seconds(1))
        #expect(store.capture.transitions.map(\.timestamp) == [.seconds(1), .seconds(31)])
        #expect(store.capture.baselineLevel(for: SignalChannelID(rawValue: 1)) == .high)
        #expect(replays(result, from: preceding, to: store))
    }

    @Test("capacity eviction removes the oldest entry after insertion")
    func capacityRetention() {
        var store = SignalCaptureStore()
        for timestamp in 0 ..< SignalCapture.maximumTransitionCount {
            _ = store.receive(transition(timestamp, channel: 1, level: .high))
        }

        let preceding = SignalCaptureRevisionState(revision: store.revision, capture: store.capture)
        let result = store.receive(
            transition(SignalCapture.maximumTransitionCount, channel: 2, level: .high)
        )

        #expect(store.capture.transitions.count == SignalCapture.maximumTransitionCount)
        #expect(store.capture.transitions.first?.timestamp == .milliseconds(1))
        #expect(store.capture.retainedLowerBound == .zero)
        #expect(store.capture.baselineLevel(for: SignalChannelID(rawValue: 1)) == .high)
        #expect(replays(result, from: preceding, to: store))
    }

    @Test("clear preserves current levels and rebases later source time")
    func clearAndRebase() {
        var store = SignalCaptureStore()
        _ = store.receive(transition(100, channel: 1, level: .high))
        _ = store.receive(transition(200, channel: 2, level: .high))

        let preceding = SignalCaptureRevisionState(revision: store.revision, capture: store.capture)
        let clear = store.clear()
        #expect(store.capture.transitions.isEmpty)
        #expect(store.capture.duration == .zero)
        #expect(store.capture.baselineLevel(for: SignalChannelID(rawValue: 1)) == .high)
        #expect(store.capture.baselineLevel(for: SignalChannelID(rawValue: 2)) == .high)
        #expect(replays(clear, from: preceding, to: store))

        _ = store.receive(transition(250, channel: 3, level: .high))
        #expect(store.capture.transitions.first?.timestamp == .milliseconds(50))
        #expect(store.capture.duration == .milliseconds(50))
    }

    @Test("invalid and out-of-horizon transitions do not mutate capture")
    func rejectedTransitions() {
        var store = SignalCaptureStore()
        _ = store.receive(transition(31_000, channel: 1, level: .high))
        let retained = store.capture
        let revision = store.revision

        #expect(
            store.receive(transition(-1, channel: 1, level: .low)) == .rejected(.invalidTransition))
        #expect(
            store.receive(transition(500, channel: 5, level: .low)) == .rejected(.invalidTransition)
        )
        #expect(
            store.receive(transition(500, channel: 1, level: .low))
                == .rejected(.outsideRetainedHistory))
        #expect(store.capture == retained)
        #expect(store.revision == revision)
    }
}

private func replays(
    _ result: SignalCaptureStoreResult,
    from preceding: SignalCaptureRevisionState,
    to store: SignalCaptureStore
) -> Bool {
    guard case .accepted(let publication) = result else { return false }
    return publication.replay(on: preceding)
        == .applied(
            SignalCaptureRevisionState(revision: store.revision, capture: store.capture)
        )
}

private func transition(
    _ milliseconds: Int,
    channel: Int,
    level: DigitalLevel
) -> SignalTransition {
    SignalTransition(
        channelID: SignalChannelID(rawValue: channel),
        timestamp: .milliseconds(milliseconds),
        level: level
    )
}
