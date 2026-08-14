package struct SignalCapture: Equatable, Sendable {
    package let channels: [SignalChannel]
    package let transitions: [SignalTransition]
    package let duration: Duration

    package init(
        channels: [SignalChannel],
        transitions: [SignalTransition],
        duration: Duration
    ) {
        self.channels = channels
        self.transitions = transitions
        self.duration = duration
    }

    package static func empty(channels: [SignalChannel] = SignalChannel.standard) -> Self {
        SignalCapture(channels: channels, transitions: [], duration: .zero)
    }
}
