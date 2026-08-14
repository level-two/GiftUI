package struct SignalTransition: Equatable, Sendable {
    package let channelID: SignalChannelID
    package let timestamp: Duration
    package let level: DigitalLevel

    package init(channelID: SignalChannelID, timestamp: Duration, level: DigitalLevel) {
        self.channelID = channelID
        self.timestamp = timestamp
        self.level = level
    }
}
