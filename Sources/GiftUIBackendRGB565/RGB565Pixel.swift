import GiftUI

public struct RGB565Pixel: Equatable, Sendable {
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    /// Quantizes RGB888 by retaining the most significant 5/6/5 channel bits.
    /// Alpha is intentionally ignored because RGB565 has no alpha channel.
    public init(_ color: Color) {
        rawValue = UInt16(color.red & 0xf8) << 8
            | UInt16(color.green & 0xfc) << 3
            | UInt16(color.blue) >> 3
    }

    public func byte(at index: Int, order: RGB565ByteOrder) -> UInt8 {
        switch (order, index) {
        case (.mostSignificantByteFirst, 0), (.leastSignificantByteFirst, 1):
            UInt8(truncatingIfNeeded: rawValue >> 8)
        case (.mostSignificantByteFirst, 1), (.leastSignificantByteFirst, 0):
            UInt8(truncatingIfNeeded: rawValue)
        default:
            0
        }
    }
}

public enum RGB565ByteOrder: Equatable, Sendable {
    case mostSignificantByteFirst
    case leastSignificantByteFirst
}
