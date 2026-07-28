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

    public static func median(
        _ first: ADS7846RawSample,
        _ second: ADS7846RawSample,
        _ third: ADS7846RawSample
    ) -> ADS7846RawSample {
        ADS7846RawSample(
            x: median(first.x, second.x, third.x),
            y: median(first.y, second.y, third.y),
            z1: median(first.z1, second.z1, third.z1),
            z2: median(first.z2, second.z2, third.z2)
        )
    }

    private static func median(
        _ first: UInt16,
        _ second: UInt16,
        _ third: UInt16
    ) -> UInt16 {
        if first < second {
            if second < third { return second }
            return first < third ? third : first
        }
        if first < third { return first }
        return second < third ? third : second
    }
}
