import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUISurfaceCore

@inline(never)
package func spec014EmbeddedBackendEntry() -> UInt32 {
    UInt32(MemoryLayout<CanonicalEncodedPixel>.size)
        + UInt32(MemoryLayout<RasterSurfaceDescriptor>.size)
        + UInt32(MemoryLayout<RasterPayloadLimits>.size)
        + UInt32(MemoryLayout<DisplayReservationID>.size)
        + UInt32(MemoryLayout<DisplayReservationResult>.size)
        + UInt32(MemoryLayout<DisplayTransferResult>.size)
        + UInt32(MemoryLayout<DisplayTargetError>.size)
        + UInt32(MemoryLayout<RasterBackendError>.size)
}
