import GiftUI
import GiftUIBackendIntegration
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

package struct DynamicSignalAnalyzerPiTileStorage: RGB565TileStorage {
    private var bytes = [UInt8](repeating: 0, count: 7_680)
    private var affected = [Bool](repeating: false, count: 3_840)

    package var byteCapacity: UInt32 { UInt32(bytes.count) }
    package var pixelCapacity: UInt32 { UInt32(affected.count) }

    package mutating func reset(byteCount: UInt32, pixelCount: UInt32) -> Bool {
        guard byteCount <= byteCapacity, pixelCount <= pixelCapacity else {
            return false
        }
        for index in 0 ..< Int(byteCount) { bytes[index] = 0 }
        for index in 0 ..< Int(pixelCount) { affected[index] = false }
        return true
    }

    package mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        byteOffset: UInt32,
        pixelIndex: UInt32
    ) -> Bool {
        guard byteOffset < byteCapacity,
            byteCapacity - byteOffset >= 2,
            pixelIndex < pixelCapacity
        else {
            return false
        }
        bytes[Int(byteOffset)] = mostSignificantByte
        bytes[Int(byteOffset) + 1] = leastSignificantByte
        affected[Int(pixelIndex)] = true
        return true
    }

    package borrowing func isAffected(pixelIndex: UInt32) -> Bool {
        pixelIndex < pixelCapacity && affected[Int(pixelIndex)]
    }

    package borrowing func byte(at offset: UInt32) -> UInt8? {
        offset < byteCapacity ? bytes[Int(offset)] : nil
    }
}

package struct DynamicSignalAnalyzerFrameEnvelopeValidator:
    RasterFrameEnvelopeValidator
{
    package let expected: FrameProvenance

    package borrowing func accepts(_ provenance: FrameProvenance) -> Bool {
        provenance == expected
    }
}

package typealias DynamicSignalAnalyzerPiSession<Target: DisplayTarget> =
    OperationMajorRGB565RasterSession<
        DynamicSignalAnalyzerPiTileStorage,
        Target,
        GiftUIReferenceTextMetricsView,
        GiftUIReferenceTextRasterView
    >

package typealias DynamicSignalAnalyzerPiEndpoint<Target: DisplayTarget> =
    OneShotRasterBackendEndpoint<
        DynamicSignalAnalyzerPiSession<Target>,
        GiftUIReferenceTextMetricsView,
        GiftUIReferenceTextRasterView,
        DynamicSignalAnalyzerFrameEnvelopeValidator
    >

package enum DynamicSignalAnalyzerPiEndpointFactory {
    package static func make<Target: DisplayTarget>(
        target: consuming Target,
        provenance: FrameProvenance,
        effectivePresentation: EffectiveRasterPresentation
    ) -> DynamicSignalAnalyzerPiEndpoint<Target>? {
        let bounds = Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 240, height: 240)!
        )!
        let descriptor = RasterSurfaceDescriptor(
            bounds: bounds,
            encoding: .rgb565BigEndian,
            bytesPerRow: 480,
            realization: .tiled,
            regionWidth: 240,
            regionHeight: 16
        )!
        let limits = RasterPayloadLimits(
            maximumRasterBytes: 7_680,
            maximumPayloadBytes: 7_680,
            maximumRegionsPerPayload: 16,
            maximumRegionSubmissionsPerFrame: 2_016_000,
            maximumTileVisitsPerFrame: 525,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 7_680,
            maximumStrokeWorkspaceBytes: 1
        )!
        let resources = GiftUIReferenceTextResources.targetPackage
        guard
            let session = DynamicSignalAnalyzerPiSession(
                capacity: RenderSinkCapacity(
                    maximumOperations: 35,
                    maximumPositionedGlyphs: 139
                ),
                descriptor: descriptor,
                payloadLimits: limits,
                metrics: resources.metrics,
                raster: resources.raster,
                realization: RasterRealizationID(rawValue: 0),
                storage: DynamicSignalAnalyzerPiTileStorage(),
                target: target
            )
        else { return nil }
        return DynamicSignalAnalyzerPiEndpoint(
            effectivePresentation: effectivePresentation,
            descriptor: descriptor,
            payloadLimits: limits,
            textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
            textRaster: GiftUIReferenceTextResources.targetPackage.raster,
            textRasterRealization: RasterRealizationID(rawValue: 0),
            envelopeValidator: DynamicSignalAnalyzerFrameEnvelopeValidator(
                expected: provenance
            ),
            sink: session,
            startupFailure: nil
        )
    }
}
