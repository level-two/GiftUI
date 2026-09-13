import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore

package protocol FullSurfaceRGBA8888Storage {
    var capacityBytes: UInt32 { get }

    mutating func store(
        byte0: UInt8,
        byte1: UInt8,
        byte2: UInt8,
        byte3: UInt8,
        at offset: UInt32
    ) -> Bool

    borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result
}

package protocol FullSurfaceReadableRaster: RasterSurface {
    mutating func acceptPresentationResponsibility() -> Bool
    borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result
}

package struct FullSurfaceRGBA8888Buffer<Storage>: FullSurfaceReadableRaster
where Storage: FullSurfaceRGBA8888Storage {
    package let descriptor: RasterSurfaceDescriptor
    package private(set) var storage: Storage
    package private(set) var presentationResponsibilityAccepted = false
    package private(set) var drainedValidationFailure = false

    private var activeHeader: RenderPlanHeader?

    package var writableCapacityBytes: UInt32 { storage.capacityBytes }

    package init?(
        descriptor: RasterSurfaceDescriptor,
        storage: consuming Storage
    ) {
        let requiredBytes = descriptor.bytesPerRow.multipliedReportingOverflow(
            by: UInt32(descriptor.regionHeight)
        )
        guard descriptor.encoding == .rgba8888,
            descriptor.realization == .fullSurface,
            descriptor.regionHeight == UInt16(descriptor.bounds.size.height),
            !requiredBytes.overflow,
            storage.capacityBytes >= requiredBytes.partialValue
        else { return nil }
        self.descriptor = descriptor
        self.storage = storage
    }

    package mutating func beginFrame(_ header: RenderPlanHeader) -> Bool {
        guard activeHeader == nil,
            header.surfaceBounds == descriptor.bounds,
            contains(descriptor.bounds, header.damageBounds)
        else { return false }
        activeHeader = header
        presentationResponsibilityAccepted = false
        drainedValidationFailure = false
        return true
    }

    package mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool {
        guard let activeHeader else { return false }
        let valid =
            descriptor.bounds.contains(point)
            && activeHeader.damageBounds.contains(point)
            && pixel.encoding == .rgba8888
            && pixel.byteCount == 4
        guard valid else { return handleValidationFailure() }
        if drainedValidationFailure { return true }

        let rowOffset = UInt32(point.y).multipliedReportingOverflow(
            by: descriptor.bytesPerRow
        )
        let pixelOffset = UInt32(point.x).multipliedReportingOverflow(by: 4)
        guard !rowOffset.overflow, !pixelOffset.overflow else {
            return handleValidationFailure()
        }
        let offset = rowOffset.partialValue.addingReportingOverflow(
            pixelOffset.partialValue
        )
        guard !offset.overflow,
            storage.store(
                byte0: pixel.byte0,
                byte1: pixel.byte1,
                byte2: pixel.byte2,
                byte3: pixel.byte3,
                at: offset.partialValue
            )
        else { return handleValidationFailure() }
        return true
    }

    package mutating func finishFrame() -> Bool {
        guard activeHeader != nil else { return false }
        activeHeader = nil
        presentationResponsibilityAccepted = false
        return true
    }

    package mutating func discardFrame() {
        guard activeHeader != nil else { return }
        activeHeader = nil
        presentationResponsibilityAccepted = false
        drainedValidationFailure = false
    }

    package mutating func acceptPresentationResponsibility() -> Bool {
        guard activeHeader != nil else { return false }
        presentationResponsibilityAccepted = true
        return true
    }

    package borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        try storage.withBytes(body)
    }

    private mutating func handleValidationFailure() -> Bool {
        guard presentationResponsibilityAccepted else { return false }
        drainedValidationFailure = true
        return true
    }

    private func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
