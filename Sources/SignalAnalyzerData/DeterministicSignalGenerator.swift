import SignalAnalyzerDomain

package struct DeterministicSignalGenerator: Equatable, Sendable {
    private static let ch3Intervals: SignalIntervalSequence = .init(
        80, 80, 80, 1_200, 75, 75, 900
    )

    private var ch1Level = DigitalLevel.low
    private var ch2Level = DigitalLevel.low
    private var ch3Level = DigitalLevel.low
    private var ch4Level = DigitalLevel.low
    // The source schedule is defined in whole milliseconds. Keep its state in
    // integers so the embedded realization never needs Duration arithmetic.
    private var ch1NextMilliseconds: Int64 = 250
    private var ch2NextMilliseconds: Int64 = 400
    private var ch3NextMilliseconds: Int64 = 80
    private var ch3IntervalIndex = 1
    private var ch4State: UInt64
    private var ch4NextMilliseconds: Int64

    package init(seed: UInt64) {
        ch4State = seed
        let firstInterval = Self.advanceLCG(&ch4State)
        ch4NextMilliseconds = Int64(firstInterval)
    }

    package mutating func nextTransition() -> SignalTransition {
        let channelID: SignalChannelID
        let timestampMilliseconds = nextTimestampMilliseconds

        if ch1NextMilliseconds == timestampMilliseconds {
            channelID = SignalChannelID(rawValue: 1)
            ch1Level.toggle()
            ch1NextMilliseconds += 250
        } else if ch2NextMilliseconds == timestampMilliseconds {
            channelID = SignalChannelID(rawValue: 2)
            ch2Level.toggle()
            ch2NextMilliseconds += 400
        } else if ch3NextMilliseconds == timestampMilliseconds {
            channelID = SignalChannelID(rawValue: 3)
            ch3Level.toggle()
            ch3NextMilliseconds += Int64(Self.ch3Intervals[ch3IntervalIndex])
            ch3IntervalIndex = (ch3IntervalIndex + 1) % Self.ch3Intervals.count
        } else {
            channelID = SignalChannelID(rawValue: 4)
            ch4Level.toggle()
            let interval = Self.advanceLCG(&ch4State)
            ch4NextMilliseconds += Int64(interval)
        }

        return SignalTransition(
            channelID: channelID,
            timestamp: Self.duration(milliseconds: timestampMilliseconds),
            level: level(for: channelID)
        )
    }

    package var nextTimestampMilliseconds: Int64 {
        var earliest = ch1NextMilliseconds
        if ch2NextMilliseconds < earliest { earliest = ch2NextMilliseconds }
        if ch3NextMilliseconds < earliest { earliest = ch3NextMilliseconds }
        if ch4NextMilliseconds < earliest { earliest = ch4NextMilliseconds }
        return earliest
    }

    package var nextTimestamp: Duration {
        Self.duration(milliseconds: nextTimestampMilliseconds)
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
        case 1: Self.duration(milliseconds: ch1NextMilliseconds)
        case 2: Self.duration(milliseconds: ch2NextMilliseconds)
        case 3: Self.duration(milliseconds: ch3NextMilliseconds)
        case 4: Self.duration(milliseconds: ch4NextMilliseconds)
        default: nil
        }
    }

    private static func advanceLCG(_ state: inout UInt64) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return 180 + Int(state % 420)
    }

    package static func duration(milliseconds: Int64) -> Duration {
        Duration(
            secondsComponent: milliseconds / 1_000,
            attosecondsComponent: (milliseconds % 1_000) * 1_000_000_000_000_000
        )
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
