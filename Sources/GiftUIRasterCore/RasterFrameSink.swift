import GiftUIRenderCore
import GiftUISurfaceCore

@usableFromInline
package protocol RasterFrameSink: DrawingOperationSink {
    var descriptor: RasterSurfaceDescriptor { get }
    var payloadLimits: RasterPayloadLimits { get }
    var failure: RasterBackendError? { get }
}
