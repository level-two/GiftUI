import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer capture values")
struct SignalCaptureTests {
    @Test("standard channels have exact stable order and names")
    func standardChannels() {
        #expect(SignalChannel.standard.map(\.id.rawValue) == [1, 2, 3, 4])
        #expect(SignalChannel.standard.map(\.name) == ["CH1", "CH2", "CH3", "CH4"])
    }

    @Test("channel baselines use exact positions and invalid channels are absent")
    func channelBaselines() {
        let levels = SignalChannelLevels(ch1: .high, ch2: .low, ch3: .high, ch4: .low)

        #expect(levels[SignalChannelID(rawValue: 1)] == .high)
        #expect(levels[SignalChannelID(rawValue: 2)] == .low)
        #expect(levels[SignalChannelID(rawValue: 3)] == .high)
        #expect(levels[SignalChannelID(rawValue: 4)] == .low)
        #expect(levels[SignalChannelID(rawValue: 5)] == nil)
    }

    @Test("empty capture has required baselines and bounds")
    func emptyCapture() {
        let empty = SignalCapture.empty()

        #expect(empty.channels == SignalChannel.standard)
        #expect(empty.transitions.isEmpty)
        #expect(empty.duration == .zero)
        #expect(empty.retainedLowerBound == .zero)
        #expect(empty.baselineLevels == .allLow)
    }

    @Test("dynamic and caller-owned static storage preserve equivalent values")
    func equivalentProfileStorage() {
        let transitions = [
            transition(100),
            transition(100, channel: 2),
            transition(500, channel: 3),
        ]
        let baselines = SignalChannelLevels(ch1: .high, ch2: .low, ch3: .high, ch4: .low)
        let dynamic = SignalCapture(
            transitions: transitions,
            duration: .microseconds(900),
            retainedLowerBound: .microseconds(100),
            baselineLevels: baselines
        )!

        let buffer = UnsafeMutableBufferPointer<SignalTransition?>.allocate(
            capacity: SignalCaptureStaticStorage.requiredCapacity
        )
        buffer.initialize(repeating: nil)
        defer {
            buffer.deinitialize()
            buffer.deallocate()
        }
        guard
            let fixed = SignalCaptureStaticStorage(
                buffer: buffer,
                transitions: transitions,
                duration: .microseconds(900),
                retainedLowerBound: .microseconds(100),
                baselineLevels: baselines
            )
        else {
            Issue.record("expected valid static capture storage")
            return
        }

        #expect(fixed.count == dynamic.transitions.count)
        #expect(fixed.duration == dynamic.duration)
        #expect(fixed.retainedLowerBound == dynamic.retainedLowerBound)
        for position in UInt16(0) ..< fixed.count {
            #expect(fixed.element(at: position) == dynamic.transitions.element(at: position))
        }
        for channel in SignalChannel.standard {
            #expect(fixed.baselineLevel(for: channel.id) == dynamic.baselineLevel(for: channel.id))
        }
    }

    @Test("capture rejects invalid bounds, order, and channel IDs")
    func rejectsInvalidCaptures() {
        #expect(
            SignalCapture(
                transitions: [transition(1)],
                duration: .zero
            ) == nil
        )
        #expect(
            SignalCapture(
                transitions: [transition(5), transition(4)],
                duration: .microseconds(5)
            ) == nil
        )
        #expect(
            SignalCapture(
                transitions: [transition(5, channel: 5)],
                duration: .microseconds(5)
            ) == nil
        )
        #expect(
            SignalCapture(
                transitions: [transition(4)],
                duration: .microseconds(5),
                retainedLowerBound: .microseconds(5)
            ) == nil
        )
        #expect(
            SignalCapture(
                transitions: [SignalTransition](),
                duration: .microseconds(4),
                retainedLowerBound: .microseconds(5)
            ) == nil
        )
        #expect(
            SignalCapture(
                transitions: [SignalTransition](),
                duration: .zero,
                retainedLowerBound: .microseconds(-1)
            ) == nil
        )
    }

    @Test("both profiles accept 2404 entries, reject 2405, and check indexing")
    func maximumCapacity() {
        let maximum = (0 ..< SignalCapture.maximumTransitionCount).map { transition($0) }
        let excess = (0 ... SignalCapture.maximumTransitionCount).map { transition($0) }
        let dynamic = SignalCapture(
            transitions: maximum,
            duration: .microseconds(SignalCapture.maximumTransitionCount)
        )!

        #expect(dynamic.transitions.count == 2_404)
        #expect(dynamic.transitions.element(at: 2_403) == maximum[2_403])
        #expect(dynamic.transitions.element(at: 2_404) == nil)
        #expect(
            SignalCapture(
                transitions: excess,
                duration: .microseconds(SignalCapture.maximumTransitionCount)
            ) == nil
        )

        let buffer = UnsafeMutableBufferPointer<SignalTransition?>.allocate(
            capacity: SignalCaptureStaticStorage.requiredCapacity
        )
        buffer.initialize(repeating: nil)
        defer {
            buffer.deinitialize()
            buffer.deallocate()
        }
        guard
            let fixed = SignalCaptureStaticStorage(
                buffer: buffer,
                transitions: maximum,
                duration: .microseconds(SignalCapture.maximumTransitionCount)
            )
        else {
            Issue.record("expected maximum-size static capture storage")
            return
        }

        #expect(fixed.count == 2_404)
        #expect(fixed.element(at: 2_403) == maximum[2_403])
        #expect(fixed.element(at: 2_404) == nil)

        let tooSmall = UnsafeMutableBufferPointer<SignalTransition?>.allocate(capacity: 2_403)
        tooSmall.initialize(repeating: nil)
        defer {
            tooSmall.deinitialize()
            tooSmall.deallocate()
        }
        if SignalCaptureStaticStorage(
            buffer: tooSmall,
            transitions: maximum,
            duration: .microseconds(SignalCapture.maximumTransitionCount)
        ) != nil {
            Issue.record("expected undersized static capture storage to be rejected")
        }
    }
}

private func transition(_ index: Int, channel: Int = 1) -> SignalTransition {
    SignalTransition(
        channelID: SignalChannelID(rawValue: channel),
        timestamp: .microseconds(index),
        level: index.isMultiple(of: 2) ? .low : .high
    )
}
