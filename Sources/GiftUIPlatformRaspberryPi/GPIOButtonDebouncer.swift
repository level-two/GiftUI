public struct GPIOButtonDebouncer: Sendable {
    public let debounceNanoseconds: UInt64

    private var lastAcceptedTimestamps: [UInt64?]

    public init(debounceMilliseconds: UInt32) {
        precondition(
            debounceMilliseconds > 0,
            "GPIO debounce duration must be positive"
        )
        debounceNanoseconds = UInt64(debounceMilliseconds) * 1_000_000
        lastAcceptedTimestamps = Array(
            repeating: nil,
            count: GPIOButton.allCases.count
        )
    }

    public mutating func accepts(
        _ button: GPIOButton,
        timestampNanoseconds: UInt64
    ) -> Bool {
        let index = button.rawValue
        guard let previous = lastAcceptedTimestamps[index] else {
            lastAcceptedTimestamps[index] = timestampNanoseconds
            return true
        }

        if timestampNanoseconds < previous {
            lastAcceptedTimestamps[index] = timestampNanoseconds
            return true
        }
        guard timestampNanoseconds - previous >= debounceNanoseconds else {
            return false
        }

        lastAcceptedTimestamps[index] = timestampNanoseconds
        return true
    }
}
