import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUISurfaceCore

package enum BackendValueLayoutProbe {
    @inline(__always)
    private static func size<T>(of _: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.size)
    }

    @inline(__always)
    private static func stride<T>(of _: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.stride)
    }

    @inline(__always)
    private static func alignment<T>(of _: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.alignment)
    }

    @inline(never) package static func canonicalEncodedPixelSize() -> UInt32 {
        size(of: CanonicalEncodedPixel.self)
    }
    @inline(never) package static func canonicalEncodedPixelStride() -> UInt32 {
        stride(of: CanonicalEncodedPixel.self)
    }
    @inline(never) package static func canonicalEncodedPixelAlignment() -> UInt32 {
        alignment(of: CanonicalEncodedPixel.self)
    }

    @inline(never) package static func rasterSurfaceDescriptorSize() -> UInt32 {
        size(of: RasterSurfaceDescriptor.self)
    }
    @inline(never) package static func rasterSurfaceDescriptorStride() -> UInt32 {
        stride(of: RasterSurfaceDescriptor.self)
    }
    @inline(never) package static func rasterSurfaceDescriptorAlignment() -> UInt32 {
        alignment(of: RasterSurfaceDescriptor.self)
    }

    @inline(never) package static func rasterPayloadLimitsSize() -> UInt32 {
        size(of: RasterPayloadLimits.self)
    }
    @inline(never) package static func rasterPayloadLimitsStride() -> UInt32 {
        stride(of: RasterPayloadLimits.self)
    }
    @inline(never) package static func rasterPayloadLimitsAlignment() -> UInt32 {
        alignment(of: RasterPayloadLimits.self)
    }

    @inline(never) package static func displayReservationIDSize() -> UInt32 {
        size(of: DisplayReservationID.self)
    }
    @inline(never) package static func displayReservationIDStride() -> UInt32 {
        stride(of: DisplayReservationID.self)
    }
    @inline(never) package static func displayReservationIDAlignment() -> UInt32 {
        alignment(of: DisplayReservationID.self)
    }

    @inline(never) package static func displayReservationResultSize() -> UInt32 {
        size(of: DisplayReservationResult.self)
    }
    @inline(never) package static func displayReservationResultStride() -> UInt32 {
        stride(of: DisplayReservationResult.self)
    }
    @inline(never) package static func displayReservationResultAlignment() -> UInt32 {
        alignment(of: DisplayReservationResult.self)
    }

    @inline(never) package static func displayTransferResultSize() -> UInt32 {
        size(of: DisplayTransferResult.self)
    }
    @inline(never) package static func displayTransferResultStride() -> UInt32 {
        stride(of: DisplayTransferResult.self)
    }
    @inline(never) package static func displayTransferResultAlignment() -> UInt32 {
        alignment(of: DisplayTransferResult.self)
    }

    @inline(never) package static func displayTargetErrorSize() -> UInt32 {
        size(of: DisplayTargetError.self)
    }
    @inline(never) package static func displayTargetErrorStride() -> UInt32 {
        stride(of: DisplayTargetError.self)
    }
    @inline(never) package static func displayTargetErrorAlignment() -> UInt32 {
        alignment(of: DisplayTargetError.self)
    }

    @inline(never) package static func rasterFailureCodeSize() -> UInt32 {
        size(of: RasterBackendError.self)
    }
    @inline(never) package static func rasterFailureCodeStride() -> UInt32 {
        stride(of: RasterBackendError.self)
    }
    @inline(never) package static func rasterFailureCodeAlignment() -> UInt32 {
        alignment(of: RasterBackendError.self)
    }
}
