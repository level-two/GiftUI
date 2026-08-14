package enum DigitalLevel: Equatable, Sendable {
    case low
    case high

    package mutating func toggle() {
        self = self == .low ? .high : .low
    }
}
