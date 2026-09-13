import SignalAnalyzerDomain

package struct DeterministicSignalGenerator: Equatable, Sendable {
    private static let ch3Intervals: SignalIntervalSequence = .init(
        80, 80, 80, 1_200, 75, 75, 900
    )

    private var ch1Level = DigitalLevel.low
    private var ch2Level = DigitalLevel.low
    private var ch3Level = DigitalLevel.low
    private var ch4Level = DigitalLevel.low
    private var ch1Next = Duration.milliseconds(250)
    private var ch2Next = Duration.milliseconds(400)
    private var ch3Next = Duration.milliseconds(80)
    private var ch3IntervalIndex = 1
    private var ch4State: UInt64
    private var ch4Next: Duration

    package init(seed: UInt64) {
        ch4State = seed
        let firstInterval = Self.advanceLCG(&ch4State)
        ch4Next = .milliseconds(firstInterval)
    }

    package mutating func nextTransition() -> SignalTransition {
        let channelID: SignalChannelID
        let timestamp = min(ch1Next, ch2Next, ch3Next, ch4Next)

        if ch1Next == timestamp {
            channelID = SignalChannelID(rawValue: 1)
            ch1Level.toggle()
            ch1Next += .milliseconds(250)
        } else if ch2Next == timestamp {
            channelID = SignalChannelID(rawValue: 2)
            ch2Level.toggle()
            ch2Next += .milliseconds(400)
        } else if ch3Next == timestamp {
            channelID = SignalChannelID(rawValue: 3)
            ch3Level.toggle()
            ch3Next += .milliseconds(Self.ch3Intervals[ch3IntervalIndex])
            ch3IntervalIndex = (ch3IntervalIndex + 1) % Self.ch3Intervals.count
        } else {
            channelID = SignalChannelID(rawValue: 4)
            ch4Level.toggle()
            let interval = Self.advanceLCG(&ch4State)
            ch4Next += .milliseconds(interval)
        }

        return SignalTransition(
            channelID: channelID,
            timestamp: timestamp,
            level: level(for: channelID)
        )
    }

    package var nextTimestamp: Duration {
        min(ch1Next, ch2Next, ch3Next, ch4Next)
    }

    package func level(for channelID: SignalChannelID) -> DigitalLevel {
        switch channelID.rawValue {
        case 1: ch1Level
        case 2: ch2Level
        case 3: ch3Level
        case 4: ch4Level
        default: .low
        }
    }

    package func nextTimestamp(for channelID: SignalChannelID) -> Duration? {
        switch channelID.rawValue {
        case 1: ch1Next
        case 2: ch2Next
        case 3: ch3Next
        case 4: ch4Next
        default: nil
        }
    }

    private static func advanceLCG(_ state: inout UInt64) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return 180 + Int(state % 420)
    }
}

private struct SignalIntervalSequence: Equatable, Sendable {
    let values: (Int, Int, Int, Int, Int, Int, Int)
    let count = 7

    init(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int) {
        values = (a, b, c, d, e, f, g)
    }

    subscript(index: Int) -> Int {
        switch index {
        case 0: values.0
        case 1: values.1
        case 2: values.2
        case 3: values.3
        case 4: values.4
        case 5: values.5
        case 6: values.6
        default: preconditionFailure("signal interval index out of bounds")
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        (0 ..< lhs.count).allSatisfy { lhs[$0] == rhs[$0] }
    }
}

private extension DigitalLevel {
    mutating func toggle() {
        self = self == .low ? .high : .low
    }
}
