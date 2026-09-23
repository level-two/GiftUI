import GiftUIBackendIntegration
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUITextResources

package struct StaticSignalAnalyzerNRFFrameEnvelopeValidator:
    RasterFrameEnvelopeValidator
{
    private let expected: FrameProvenance

    package init(expected: FrameProvenance) { self.expected = expected }

    package borrowing func accepts(_ provenance: FrameProvenance) -> Bool {
        provenance == expected
    }
}

package typealias StaticSignalAnalyzerNRFSession<Target: DisplayTarget> =
    OperationMajorRGB565RasterSession<
        StaticSignalAnalyzerNRFTileStorage,
        Target,
        GiftUIReferenceTextMetricsView,
        GiftUIReferenceTextRasterView
    >

package typealias StaticSignalAnalyzerNRFEndpoint<Target: DisplayTarget> =
    OneShotRasterBackendEndpoint<
        StaticSignalAnalyzerNRFSession<Target>,
        GiftUIReferenceTextMetricsView,
        GiftUIReferenceTextRasterView,
        StaticSignalAnalyzerNRFFrameEnvelopeValidator
    >

/// The caller owns both exact regions until the endpoint and every synchronous
/// display submission have completed. Construction validates the same report
/// and raster limits used by the Static nRF host assembly.
package enum StaticSignalAnalyzerNRFEndpointFactory {
    package static func installExpectedProvenance<Target: DisplayTarget>(
        _ provenance: FrameProvenance,
        endpoint: inout StaticSignalAnalyzerNRFEndpoint<Target>
    ) -> Bool {
        endpoint.replaceEnvelopeValidator(
            StaticSignalAnalyzerNRFFrameEnvelopeValidator(expected: provenance)
        )
    }

    package static func make<Transport: StaticSignalAnalyzerNRFDisplayTransport>(
        transport: consuming Transport,
        provenance: FrameProvenance,
        assemblyReport: HostAssemblyReport,
        rasterRegion: UnsafeMutableRawBufferPointer,
        coverageRegion: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFEndpoint<
        StaticSignalAnalyzerNRFDisplayTarget<Transport>
    >? {
        guard
            let target = StaticSignalAnalyzerNRFDisplayTarget(
                transport: transport,
                rasterRegion: rasterRegion
            )
        else { return nil }
        return make(
            target: target,
            provenance: provenance,
            assemblyReport: assemblyReport,
            rasterRegion: rasterRegion,
            coverageRegion: coverageRegion
        )
    }

    package static func make<Target: DisplayTarget>(
        target: consuming Target,
        provenance: FrameProvenance,
        assemblyReport: HostAssemblyReport,
        rasterRegion: UnsafeMutableRawBufferPointer,
        coverageRegion: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFEndpoint<Target>? {
        guard StaticSignalAnalyzerNRFAssembly.validate() == .valid(assemblyReport),
            let descriptor = StaticSignalAnalyzerNRFAssembly.descriptor(),
            let payloadLimits = StaticSignalAnalyzerNRFAssembly.payloadLimits(),
            let storage = StaticSignalAnalyzerNRFTileStorage(
                region: rasterRegion,
                coverage: coverageRegion
            )
        else { return nil }
        let resources = GiftUIReferenceTextResources.targetPackage
        guard
            let session = StaticSignalAnalyzerNRFSession(
                capacity: GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits
                    .renderSink,
                descriptor: descriptor,
                payloadLimits: payloadLimits,
                metrics: resources.metrics,
                raster: resources.raster,
                realization: RasterRealizationID(rawValue: 0),
                storage: storage,
                target: target
            )
        else { return nil }
        return StaticSignalAnalyzerNRFEndpoint(
            effectivePresentation: assemblyReport.effectivePresentation,
            descriptor: descriptor,
            payloadLimits: payloadLimits,
            textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
            textRaster: GiftUIReferenceTextResources.targetPackage.raster,
            textRasterRealization: RasterRealizationID(rawValue: 0),
            envelopeValidator: StaticSignalAnalyzerNRFFrameEnvelopeValidator(
                expected: provenance
            ),
            sink: session,
            startupFailure: nil
        )
    }
}
