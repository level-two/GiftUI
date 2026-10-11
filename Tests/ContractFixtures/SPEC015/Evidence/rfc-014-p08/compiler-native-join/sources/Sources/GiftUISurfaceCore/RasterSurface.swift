import GiftUI
import GiftUIRenderCore

package protocol RasterSurface {
    var descriptor: RasterSurfaceDescriptor { get }
    var writableCapacityBytes: UInt32 { get }
    var presentationResponsibilityAccepted: Bool { get }

    mutating func beginFrame(_ header: RenderPlanHeader) -> Bool
    mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool
    mutating func finishFrame() -> Bool
    mutating func discardFrame()
}
