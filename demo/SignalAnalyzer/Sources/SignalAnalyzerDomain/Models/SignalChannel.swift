package struct SignalChannel: Identifiable, Equatable, Sendable {
    package let id: SignalChannelID
    package let name: String

    package init(id: SignalChannelID, name: String) {
        self.id = id
        self.name = name
    }

    package static let standard: [SignalChannel] = (1 ... 4).map {
        SignalChannel(id: SignalChannelID(rawValue: $0), name: "CH\($0)")
    }
}
