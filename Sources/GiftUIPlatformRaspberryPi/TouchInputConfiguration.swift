public struct TouchInputConfiguration: Equatable, Sendable {
    public var devicePath: String
    public var swapXY: Bool
    public var invertX: Bool
    public var invertY: Bool

    public init(
        devicePath: String = "/dev/input/event0",
        swapXY: Bool = false,
        invertX: Bool = false,
        invertY: Bool = false
    ) {
        precondition(!devicePath.isEmpty, "Touch input path must not be empty")
        self.devicePath = devicePath
        self.swapXY = swapXY
        self.invertX = invertX
        self.invertY = invertY
    }
}
