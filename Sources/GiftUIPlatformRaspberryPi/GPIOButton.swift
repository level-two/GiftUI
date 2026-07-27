public enum GPIOButton: Int, CaseIterable, Sendable {
    case previous = 0
    case next = 1
    case activate = 2
}

public enum GPIOBias: String, Sendable {
    case pullUp = "pull-up"
    case disabled
}

public struct GPIOButtonConfiguration: Equatable, Sendable {
    public var chipPath: String
    public var previousLine: UInt32
    public var nextLine: UInt32
    public var activateLine: UInt32
    public var activeLow: Bool
    public var bias: GPIOBias
    public var debounceMilliseconds: UInt32

    public var lineOffsets: [UInt32] {
        [previousLine, nextLine, activateLine]
    }

    public init(
        chipPath: String = "/dev/gpiochip0",
        previousLine: UInt32 = 17,
        nextLine: UInt32 = 27,
        activateLine: UInt32 = 22,
        activeLow: Bool = true,
        bias: GPIOBias = .pullUp,
        debounceMilliseconds: UInt32 = 35
    ) {
        precondition(!chipPath.isEmpty, "GPIO chip path must not be empty")
        precondition(
            Set([previousLine, nextLine, activateLine]).count == 3,
            "GPIO button lines must be distinct"
        )
        precondition(
            debounceMilliseconds > 0,
            "GPIO debounce duration must be positive"
        )
        self.chipPath = chipPath
        self.previousLine = previousLine
        self.nextLine = nextLine
        self.activateLine = activateLine
        self.activeLow = activeLow
        self.bias = bias
        self.debounceMilliseconds = debounceMilliseconds
    }
}
