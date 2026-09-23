import GiftUI
import GiftUIBackendIntegration
import GiftUIDisplayCore
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIReferenceTextResources
import GiftUIRenderCore

/// Streams one preflighted generated Static candidate into the validated nRF
/// raster endpoint. The physical surface is taken from the endpoint rather
/// than from the narrower layout root.
package enum StaticSignalAnalyzerNRFRenderOffer {
    package static func offer<Target: DisplayTarget>(
        semantic: borrowing StaticSignalAnalyzerNRFUTF8RenderView,
        layout: borrowing StaticSignalAnalyzerNRFResolvedLayoutView,
        drawingPlan: borrowing StaticSignalAnalyzerNRFDrawingWorkspace,
        expectedHeader: RenderPlanHeader,
        workspace: inout StaticSignalAnalyzerNRFRenderWorkspace,
        endpoint: inout StaticSignalAnalyzerNRFEndpoint<Target>,
        provenance: FrameProvenance
    ) -> FrameOfferResult {
        guard expectedHeader.surfaceBounds == endpoint.descriptor.bounds else {
            return FrameOfferResult(
                disposition: .failed,
                failure: .contractViolation
            )!
        }
        let limits = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits
        let surfaceBounds = endpoint.descriptor.bounds
        let semanticView = copy semantic
        let layoutView = copy layout
        let planView = copy drawingPlan
        return endpoint.offer(provenance: provenance) { sink in
            switch CanvasRenderProducer.produce(
                semantic: semanticView,
                layout: layoutView,
                textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
                drawingPlan: planView,
                surfaceBounds: surfaceBounds,
                damageMode: .initializeCompleteSurface,
                rootForeground: .white,
                limits: limits.render,
                expectedHeader: expectedHeader,
                workspace: &workspace,
                sink: &sink
            ) {
            case .success(let header):
                return header == expectedHeader ? .complete : .contractViolation
            case .failure(let error):
                sink.retainProducerError(error)
                switch error {
                case .capacityExhausted: return .insufficientCapacity
                case .sinkRefused: return .endpointRefused
                default: return .producerFailed
                }
            }
        }
    }
}
