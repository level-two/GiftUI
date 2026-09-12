import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

package protocol RasterBackendEndpoint: SynchronousFrameEndpoint
where Sink: RasterFrameSink {
    associatedtype TextRaster: TextRasterResourceView

    var effectivePresentation: EffectiveRasterPresentation { get }
    var descriptor: RasterSurfaceDescriptor { get }
    var payloadLimits: RasterPayloadLimits { get }
    var textRaster: TextRaster { get }
    var textRasterRealization: RasterRealizationID { get }
    borrowing func health() -> GiftUIOperationalHealth
}
