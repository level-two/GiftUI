import SignalAnalyzerDomain

package extension StaticSignalAnalyzerNRFCaptureRecord {
    init?(_ transition: SignalTransition) {
        let components = transition.timestamp.components
        guard transition.channelID.isStandard,
            transition.timestamp >= .zero,
            components.seconds >= 0,
            components.attoseconds >= 0,
            components.attoseconds < 1_000_000_000_000_000_000
        else { return nil }
        self.init(
            seconds: components.seconds,
            attoseconds: components.attoseconds,
            channelRawValue: UInt32(transition.channelID.rawValue),
            levelRawValue: transition.level == .low ? 0 : 1
        )
    }

    var transition: SignalTransition? {
        guard seconds >= 0, attoseconds >= 0,
            attoseconds < 1_000_000_000_000_000_000,
            channelRawValue >= 1, channelRawValue <= 4,
            levelRawValue <= 1
        else { return nil }
        return SignalTransition(
            channelID: SignalChannelID(rawValue: Int(channelRawValue)),
            timestamp: Duration(
                secondsComponent: seconds,
                attosecondsComponent: attoseconds
            ),
            level: levelRawValue == 0 ? .low : .high
        )
    }
}
