import GiftUI
import GiftUICapabilities

@usableFromInline
package struct CanonicalEncodedPixel: Equatable, Sendable {
    @usableFromInline
    package let encoding: CanonicalPixelEncoding
    @usableFromInline
    package let byteCount: UInt8
    @usableFromInline
    package let byte0: UInt8
    @usableFromInline
    package let byte1: UInt8
    @usableFromInline
    package let byte2: UInt8
    @usableFromInline
    package let byte3: UInt8

    @usableFromInline
    package init(color: Color, encoding: CanonicalPixelEncoding) {
        self.encoding = encoding
        switch encoding {
        case .rgb565BigEndian:
            let red = Self.quantizedChannel(color.red, maximum: 31)
            let green = Self.quantizedChannel(color.green, maximum: 63)
            let blue = Self.quantizedChannel(color.blue, maximum: 31)
            let word = UInt16((red << 11) | (green << 5) | blue)
            byteCount = 2
            byte0 = UInt8(truncatingIfNeeded: word >> 8)
            byte1 = UInt8(truncatingIfNeeded: word)
            byte2 = 0
            byte3 = 0
        case .rgba8888:
            byteCount = 4
            byte0 = color.red
            byte1 = color.green
            byte2 = color.blue
            byte3 = 255
        }
    }

    private static func quantizedChannel(
        _ channel: UInt8,
        maximum: UInt32
    ) -> UInt32 {
        let scaled = UInt32(channel).multipliedReportingOverflow(by: maximum)
        precondition(!scaled.overflow)
        let rounded = scaled.partialValue.addingReportingOverflow(127)
        precondition(!rounded.overflow)
        return rounded.partialValue / 255
    }
}

@usableFromInline
package struct RasterSurfaceDescriptor: Equatable, Sendable {
    @usableFromInline
    package let bounds: Rect
    @usableFromInline
    package let encoding: CanonicalPixelEncoding
    @usableFromInline
    package let bytesPerRow: UInt32
    @usableFromInline
    package let realization: RasterRealizationKind
    @usableFromInline
    package let regionWidth: UInt16
    @usableFromInline
    package let regionHeight: UInt16

    #if GIFTUI_STARTUP_QUALIFICATION
        @usableFromInline
        package var capabilityExtent: CapabilityExtent {
            @_noAllocation
            get {
                CapabilityExtent(
                    width: UInt16(bounds.size.width),
                    height: UInt16(bounds.size.height)
                )!
            }
        }
    #else
        @usableFromInline
        package var capabilityExtent: CapabilityExtent {
            CapabilityExtent(
                width: UInt16(bounds.size.width),
                height: UInt16(bounds.size.height)
            )!
        }
    #endif

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    package init?(
        bounds: Rect,
        encoding: CanonicalPixelEncoding,
        bytesPerRow: UInt32,
        realization: RasterRealizationKind,
        regionWidth: UInt16,
        regionHeight: UInt16
    ) {
        guard bounds.origin.x == 0, bounds.origin.y == 0,
            bounds.size.width > 0,
            bounds.size.height > 0,
            let width = UInt16(exactly: bounds.size.width),
            let height = UInt16(exactly: bounds.size.height)
        else { return nil }
        guard case .some = CapabilityExtent(width: width, height: height) else { return nil }
        guard regionWidth == width,
            regionHeight > 0,
            regionHeight <= height
        else {
            return nil
        }

        switch realization {
        case .fullSurface:
            guard regionHeight == height else { return nil }
        case .tiled:
            break
        }

        let bytesPerPixel: UInt32
        switch encoding {
        case .rgb565BigEndian:
            bytesPerPixel = 2
        case .rgba8888:
            bytesPerPixel = 4
        }
        let (packedRowBytes, packedOverflow) = UInt32(width).multipliedReportingOverflow(
            by: bytesPerPixel
        )
        guard !packedOverflow,
            bytesPerRow >= packedRowBytes,
            !bytesPerRow.multipliedReportingOverflow(by: UInt32(regionHeight)).overflow
        else {
            return nil
        }

        self.bounds = bounds
        self.encoding = encoding
        self.bytesPerRow = bytesPerRow
        self.realization = realization
        self.regionWidth = regionWidth
        self.regionHeight = regionHeight
    }
}
