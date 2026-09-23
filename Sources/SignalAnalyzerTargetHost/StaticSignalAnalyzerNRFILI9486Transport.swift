import GiftUI

/// Matches `ili9486_write_rgb565(x, y, width, height, pixels, byte_count)`.
/// Firmware supplies that C symbol when constructing the Static host.
package typealias StaticSignalAnalyzerNRFILI9486Write =
    @convention(c) (
        UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
    ) -> Int32

/// Keeps the hardware call synchronous and allocation-free. The ILI9486 C
/// driver owns controller state and reports transport errors through its
/// return code and fault counters.
package struct StaticSignalAnalyzerNRFILI9486Transport:
    StaticSignalAnalyzerNRFDisplayTransport
{
    private let write: StaticSignalAnalyzerNRFILI9486Write

    package init(write: @escaping StaticSignalAnalyzerNRFILI9486Write) {
        self.write = write
    }

    package mutating func presentRGB565BigEndian(
        x: UInt16,
        y: UInt16,
        pixelCount: UInt16,
        bytes: UnsafeRawBufferPointer
    ) -> Bool {
        guard pixelCount > 0,
            x < 480, y < 320,
            UInt32(x) + UInt32(pixelCount) <= 480,
            bytes.count == Int(pixelCount) * 2,
            let baseAddress = bytes.baseAddress
        else { return false }
        return write(
            x, y, pixelCount, 1,
            baseAddress.assumingMemoryBound(to: UInt8.self),
            bytes.count
        ) == 0
    }
}
