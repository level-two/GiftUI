import GiftUI
import GiftUICapabilities
import GiftUIRenderCore

@testable import GiftUISurfaceCore

struct RecordedPixelReplacement: Equatable {
    let point: Point
    let pixel: CanonicalEncodedPixel
}

struct RecordingRasterSurface: RasterSurface {
    let descriptor: RasterSurfaceDescriptor
    let writableCapacityBytes: UInt32
    private(set) var presentationResponsibilityAccepted = false
    private(set) var replacements: [RecordedPixelReplacement] = []
    private(set) var beginCount = 0
    private(set) var finishCount = 0
    private(set) var discardCount = 0
    private(set) var drainedValidationFailure = false

    private var activeHeader: RenderPlanHeader?

    init(
        descriptor: RasterSurfaceDescriptor,
        writableCapacityBytes: UInt32
    ) {
        self.descriptor = descriptor
        self.writableCapacityBytes = writableCapacityBytes
    }

    mutating func beginFrame(_ header: RenderPlanHeader) -> Bool {
        guard activeHeader == nil,
            header.surfaceBounds == descriptor.bounds,
            contains(descriptor.bounds, header.damageBounds),
            admittedRegionBytes() <= writableCapacityBytes
        else {
            return false
        }
        activeHeader = header
        beginCount += 1
        replacements.removeAll(keepingCapacity: true)
        presentationResponsibilityAccepted = false
        drainedValidationFailure = false
        return true
    }

    mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool {
        guard let header = activeHeader else { return false }
        let valid =
            descriptor.bounds.contains(point)
            && header.damageBounds.contains(point)
            && pixel.encoding == descriptor.encoding
        guard valid else {
            if presentationResponsibilityAccepted {
                drainedValidationFailure = true
                return true
            }
            return false
        }
        if !drainedValidationFailure {
            replacements.append(RecordedPixelReplacement(point: point, pixel: pixel))
        }
        return true
    }

    mutating func finishFrame() -> Bool {
        guard activeHeader != nil else { return false }
        finishCount += 1
        resetAttempt()
        return true
    }

    mutating func discardFrame() {
        guard activeHeader != nil else { return }
        discardCount += 1
        replacements.removeAll(keepingCapacity: true)
        resetAttempt()
    }

    mutating func acceptPresentationResponsibility() -> Bool {
        guard activeHeader != nil else { return false }
        presentationResponsibilityAccepted = true
        return true
    }

    private func admittedRegionBytes() -> UInt32 {
        descriptor.bytesPerRow * UInt32(descriptor.regionHeight)
    }

    private func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }

    private mutating func resetAttempt() {
        activeHeader = nil
        presentationResponsibilityAccepted = false
    }
}
