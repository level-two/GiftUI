package struct SignalCapture: Equatable, Sendable {
    package let channels: [SignalChannel]
    package let transitions: [SignalTransition]
    package let duration: Duration
    package let retainedLowerBound: Duration

    private let baselineLevels: [SignalChannelID: DigitalLevel]

    package init(
        channels: [SignalChannel],
        transitions: [SignalTransition],
        duration: Duration,
        retainedLowerBound: Duration = .zero,
        baselineLevels: [SignalChannelID: DigitalLevel]? = nil
    ) {
        self.channels = channels
        self.transitions = transitions
        self.duration = duration
        self.retainedLowerBound = retainedLowerBound
        self.baselineLevels =
            baselineLevels
            ?? Dictionary(
                uniqueKeysWithValues: channels.map { ($0.id, .low) }
            )
    }

    package func baselineLevel(for channelID: SignalChannelID) -> DigitalLevel {
        baselineLevels[channelID] ?? .low
    }

    package static func empty(channels: [SignalChannel] = SignalChannel.standard) -> Self {
        SignalCapture(
            channels: channels,
            transitions: [],
            duration: .zero,
            retainedLowerBound: .zero
        )
    }
}
