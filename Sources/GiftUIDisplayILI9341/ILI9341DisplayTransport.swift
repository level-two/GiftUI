import GiftUI

public enum ILI9341TransportFault: Error, Equatable, Sendable {
    case unavailable
    case io(code: Int32)
}

/// A statically dispatched bridge to an already configured ILI9341 driver.
/// Implementations must not retain any buffer passed to these methods.
public protocol ILI9341DisplayTransport {
    mutating func initialize(
        configuration: ILI9341DisplayConfiguration
    ) throws(ILI9341TransportFault)

    mutating func setBlanked(
        _ blanked: Bool
    ) throws(ILI9341TransportFault)

    mutating func writeRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeRawBufferPointer
    ) throws(ILI9341TransportFault)

    mutating func writeSolidRGB565(
        rect: Rect,
        pixel: UInt16
    ) throws(ILI9341TransportFault)

    mutating func readRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeMutableRawBufferPointer
    ) throws(ILI9341TransportFault)
}
