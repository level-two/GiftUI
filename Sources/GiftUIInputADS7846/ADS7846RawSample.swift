public struct ADS7846RawSample: Equatable, Sendable {
    public let x: UInt16
    public let y: UInt16
    public let z1: UInt16
    public let z2: UInt16

    public init(x: UInt16, y: UInt16, z1: UInt16, z2: UInt16) {
        self.x = x
        self.y = y
        self.z1 = z1
        self.z2 = z2
    }
}
