import GiftUIExecution
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore

package enum RasterFrameWorkAdmission {
    package static func constructionFailure(
        descriptor: RasterSurfaceDescriptor,
        sinkCapacity: RenderSinkCapacity,
        limits: RasterPayloadLimits
    ) -> RasterBackendError? {
        switch RasterFrameWorkCalculator.constructionBounds(
            descriptor: descriptor,
            sinkCapacity: sinkCapacity,
            limits: limits
        ) {
        case .admitted:
            nil
        case .arithmeticOverflow:
            .arithmeticOverflow
        case .capacityExceeded:
            .capacityExhausted
        case .invalidHeader:
            .invariantViolation
        }
    }

    package static func headerFailure(
        _ header: RenderPlanHeader,
        descriptor: RasterSurfaceDescriptor,
        sinkCapacity: RenderSinkCapacity,
        limits: RasterPayloadLimits
    ) -> FrameStreamResult? {
        switch RasterFrameWorkCalculator.headerBounds(
            header,
            descriptor: descriptor,
            sinkCapacity: sinkCapacity,
            limits: limits
        ) {
        case .admitted:
            nil
        case .arithmeticOverflow, .capacityExceeded, .invalidHeader:
            .contractViolation
        }
    }
}
