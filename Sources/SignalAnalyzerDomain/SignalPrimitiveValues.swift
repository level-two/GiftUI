package struct SignalChannelID: Hashable, Sendable {
    package let rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package var isStandard: Bool {
        rawValue >= 1 && rawValue <= 4
    }
}

package enum DigitalLevel: Equatable, Sendable {
    case low
    case high
}

package struct SignalTransition: Equatable, Sendable {
    package let channelID: SignalChannelID
    package let timestamp: Duration
    package let level: DigitalLevel

    package init(
        channelID: SignalChannelID,
        timestamp: Duration,
        level: DigitalLevel
    ) {
        self.channelID = channelID
        self.timestamp = timestamp
        self.level = level
    }
}

package struct SignalChannelLevels: Equatable, Sendable {
    package let ch1: DigitalLevel
    package let ch2: DigitalLevel
    package let ch3: DigitalLevel
    package let ch4: DigitalLevel

    package init(
        ch1: DigitalLevel,
        ch2: DigitalLevel,
        ch3: DigitalLevel,
        ch4: DigitalLevel
    ) {
        self.ch1 = ch1
        self.ch2 = ch2
        self.ch3 = ch3
        self.ch4 = ch4
    }

    package static let allLow = SignalChannelLevels(
        ch1: .low,
        ch2: .low,
        ch3: .low,
        ch4: .low
    )

    package subscript(channelID: SignalChannelID) -> DigitalLevel? {
        switch channelID.rawValue {
        case 1: ch1
        case 2: ch2
        case 3: ch3
        case 4: ch4
        default: nil
        }
    }
}
