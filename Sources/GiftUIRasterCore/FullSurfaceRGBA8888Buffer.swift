import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore

@usableFromInline
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

@usableFromInline
package protocol FullSurfaceReadableRaster: RasterSurface {
    mutating func acceptPresentationResponsibility() -> Bool
    borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result
}

@usableFromInline
package struct FullSurfaceRGBA8888Buffer<Storage>: FullSurfaceReadableRaster
where Storage: FullSurfaceRGBA8888Storage {
    @usableFromInline
    package let descriptor: RasterSurfaceDescriptor
    @usableFromInline
    package internal(set) var storage: Storage
    @usableFromInline
    package internal(set) var presentationResponsibilityAccepted = false
    @usableFromInline
    package internal(set) var drainedValidationFailure = false

    @usableFromInline
    internal var activeHeader: RenderPlanHeader?

    @inlinable
    package var writableCapacityBytes: UInt32 { storage.capacityBytes }

    @inlinable
    package init?(
        descriptor: RasterSurfaceDescriptor,
        storage: consuming Storage
    ) {
        guard FullSurfaceRGBA8888Operations.validate(descriptor: descriptor, storage: storage)
        else { return nil }
        self.descriptor = descriptor
        self.storage = storage
    }

    @inlinable
    package mutating func beginFrame(_ header: RenderPlanHeader) -> Bool {
        FullSurfaceRGBA8888Operations.beginFrame(
            header, descriptor: descriptor, activeHeader: &activeHeader,
            presentationResponsibilityAccepted: &presentationResponsibilityAccepted,
            drainedValidationFailure: &drainedValidationFailure)
    }

    @inlinable
    package mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool {
        FullSurfaceRGBA8888Operations.replacePixel(
            at: point, with: pixel, descriptor: descriptor, storage: &storage,
            activeHeader: activeHeader,
            presentationResponsibilityAccepted: presentationResponsibilityAccepted,
            drainedValidationFailure: &drainedValidationFailure)
    }

    @inlinable
    package mutating func finishFrame() -> Bool {
        FullSurfaceRGBA8888Operations.finishFrame(
            activeHeader: &activeHeader,
            presentationResponsibilityAccepted: &presentationResponsibilityAccepted)
    }

    @inlinable
    package mutating func discardFrame() {
        FullSurfaceRGBA8888Operations.discardFrame(
            activeHeader: &activeHeader,
            presentationResponsibilityAccepted: &presentationResponsibilityAccepted,
            drainedValidationFailure: &drainedValidationFailure)
    }

    @inlinable
    package mutating func acceptPresentationResponsibility() -> Bool {
        FullSurfaceRGBA8888Operations.acceptPresentationResponsibility(
            activeHeader: activeHeader,
            presentationResponsibilityAccepted: &presentationResponsibilityAccepted)
    }

    @inlinable
    @inline(__always)
    package borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        try storage.withBytes(body)
    }

    @inlinable
    internal mutating func handleValidationFailure() -> Bool {
        FullSurfaceRGBA8888Operations.handleValidationFailure(
            presentationResponsibilityAccepted: presentationResponsibilityAccepted,
            drainedValidationFailure: &drainedValidationFailure)
    }

    @inlinable
    internal func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        FullSurfaceRGBA8888Operations.contains(outer, inner)
    }
}

/// Shared full-surface operations over the owner's stored fields.
@usableFromInline
package enum FullSurfaceRGBA8888Operations {
    @inlinable
    @inline(__always)
    package static func validate<Storage: FullSurfaceRGBA8888Storage>(
        descriptor: RasterSurfaceDescriptor,
        storage: borrowing Storage
    ) -> Bool {
        let requiredBytes = descriptor.bytesPerRow.multipliedReportingOverflow(
            by: UInt32(descriptor.regionHeight)
        )
        guard descriptor.encoding == .rgba8888,
            descriptor.realization == .fullSurface,
            descriptor.regionHeight == UInt16(descriptor.bounds.size.height),
            !requiredBytes.overflow,
            storage.capacityBytes >= requiredBytes.partialValue
        else { return false }
        return true
    }

    @inlinable
    @inline(__always)
    package static func beginFrame(
        _ header: RenderPlanHeader,
        descriptor: RasterSurfaceDescriptor,
        activeHeader: inout RenderPlanHeader?,
        presentationResponsibilityAccepted: inout Bool,
        drainedValidationFailure: inout Bool
    ) -> Bool {
        guard activeHeader == nil,
            header.surfaceBounds == descriptor.bounds,
            contains(descriptor.bounds, header.damageBounds)
        else { return false }
        activeHeader = header
        presentationResponsibilityAccepted = false
        drainedValidationFailure = false
        return true
    }

    @inlinable
    @inline(__always)
    package static func replacePixel<Storage: FullSurfaceRGBA8888Storage>(
        at point: Point,
        with pixel: CanonicalEncodedPixel,
        descriptor: RasterSurfaceDescriptor,
        storage: inout Storage,
        activeHeader: RenderPlanHeader?,
        presentationResponsibilityAccepted: Bool,
        drainedValidationFailure: inout Bool
    ) -> Bool {
        guard let activeHeader else { return false }
        let valid =
            descriptor.bounds.contains(point)
            && activeHeader.damageBounds.contains(point)
            && pixel.encoding == .rgba8888
            && pixel.byteCount == 4
        guard valid else {
            return handleValidationFailure(
                presentationResponsibilityAccepted: presentationResponsibilityAccepted,
                drainedValidationFailure: &drainedValidationFailure)
        }
        if drainedValidationFailure { return true }

        let rowOffset = UInt32(point.y).multipliedReportingOverflow(
            by: descriptor.bytesPerRow
        )
        let pixelOffset = UInt32(point.x).multipliedReportingOverflow(by: 4)
        guard !rowOffset.overflow, !pixelOffset.overflow else {
            return handleValidationFailure(
                presentationResponsibilityAccepted: presentationResponsibilityAccepted,
                drainedValidationFailure: &drainedValidationFailure)
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
        else {
            return handleValidationFailure(
                presentationResponsibilityAccepted: presentationResponsibilityAccepted,
                drainedValidationFailure: &drainedValidationFailure)
        }
        return true
    }

    @inlinable
    @inline(__always)
    package static func finishFrame(
        activeHeader: inout RenderPlanHeader?,
        presentationResponsibilityAccepted: inout Bool
    ) -> Bool {
        guard activeHeader != nil else { return false }
        activeHeader = nil
        presentationResponsibilityAccepted = false
        return true
    }

    @inlinable
    @inline(__always)
    package static func discardFrame(
        activeHeader: inout RenderPlanHeader?,
        presentationResponsibilityAccepted: inout Bool,
        drainedValidationFailure: inout Bool
    ) {
        guard activeHeader != nil else { return }
        activeHeader = nil
        presentationResponsibilityAccepted = false
        drainedValidationFailure = false
    }

    @inlinable
    @inline(__always)
    package static func acceptPresentationResponsibility(
        activeHeader: RenderPlanHeader?,
        presentationResponsibilityAccepted: inout Bool
    ) -> Bool {
        guard activeHeader != nil else { return false }
        presentationResponsibilityAccepted = true
        return true
    }

    @inlinable
    @inline(__always)
    static func handleValidationFailure(
        presentationResponsibilityAccepted: Bool,
        drainedValidationFailure: inout Bool
    ) -> Bool {
        guard presentationResponsibilityAccepted else { return false }
        drainedValidationFailure = true
        return true
    }

    @inlinable
    @inline(__always)
    static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
