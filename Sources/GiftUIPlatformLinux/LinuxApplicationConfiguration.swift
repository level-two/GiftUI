public struct LinuxApplicationConfiguration: Equatable, Sendable {
    public var idleSleepMilliseconds: UInt32
    public var exitAfterInitialFrame: Bool

    public init(
        idleSleepMilliseconds: UInt32 = 20,
        exitAfterInitialFrame: Bool = false
    ) {
        precondition(
            idleSleepMilliseconds > 0,
            "Idle sleep duration must be positive"
        )
        self.idleSleepMilliseconds = idleSleepMilliseconds
        self.exitAfterInitialFrame = exitAfterInitialFrame
    }
}
