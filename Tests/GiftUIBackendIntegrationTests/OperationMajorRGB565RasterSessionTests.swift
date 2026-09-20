import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIBackendIntegration

private struct SessionRegion: Equatable {
    let origin: Point
    let pixelCount: UInt16
}

private struct SessionPayload: Equatable {
    let bytes: [UInt8]
    let regions: [SessionRegion]
}

private struct SessionWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32
    let regionCapacity: UInt16
    private(set) var writtenBytes: UInt32 = 0
    private(set) var writtenRegionCount: UInt16 = 0
    private(set) var bytes: [UInt8]
    private(set) var regions: [SessionRegion] = []
    private var remainingBytes: UInt32 = 0

    init(capacityBytes: UInt32, regionCapacity: UInt16) {
        self.capacityBytes = capacityBytes
        self.regionCapacity = regionCapacity
        bytes = [UInt8](repeating: 0, count: Int(capacityBytes))
    }

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard remainingBytes == 0, writtenRegionCount < regionCapacity,
            encoding == .rgb565BigEndian
        else { return false }
        let requiredBytes = UInt32(pixelCount) * 2
        guard requiredBytes > 0,
            requiredBytes <= capacityBytes - writtenBytes
        else { return false }
        remainingBytes = requiredBytes
        regions.append(SessionRegion(origin: origin, pixelCount: pixelCount))
        return true
    }

    mutating func write(byte: UInt8) -> Bool {
        guard remainingBytes > 0, writtenBytes < capacityBytes else {
            return false
        }
        bytes[Int(writtenBytes)] = byte
        writtenBytes += 1
        remainingBytes -= 1
        return true
    }

    mutating func endRegion() -> Bool {
        guard remainingBytes == 0 else { return false }
        writtenRegionCount += 1
        return true
    }

    mutating func finish() -> Bool {
        remainingBytes == 0 && writtenRegionCount > 0
    }

    mutating func discard() {
        bytes = [UInt8](repeating: 0, count: Int(capacityBytes))
        regions.removeAll(keepingCapacity: true)
        writtenBytes = 0
        writtenRegionCount = 0
        remainingBytes = 0
    }
}

private struct SessionTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 8
    private(set) var writer = SessionWriter(
        capacityBytes: 8,
        regionCapacity: 4
    )
    private(set) var payloads: [SessionPayload] = []
    private(set) var reserveCount = 0
    private(set) var finishCount = 0
    private(set) var cancelCount = 0

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        reserveCount += 1
        guard descriptor == sessionDescriptor,
            payloadCapacityBytes == 8,
            regionCapacity == 4
        else { return .failure(.invalidDescriptor) }
        return .reserved(DisplayReservationID(rawValue: 17))
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout SessionWriter) -> Result
    ) -> Result? {
        guard reservation.rawValue == 17 else { return nil }
        return body(&writer)
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation.rawValue == 17 else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        payloads.append(
            SessionPayload(
                bytes: Array(writer.bytes.prefix(Int(writer.writtenBytes))),
                regions: writer.regions
            )
        )
        writer.discard()
        return .completed
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation.rawValue == 17 else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        finishCount += 1
        return .completed
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        cancelCount += 1
        writer.discard()
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}

private let sessionDigest = TextResourceDigest(
    word0: 11,
    word1: 12,
    word2: 13,
    word3: 14,
    word4: 15,
    word5: 16,
    word6: 17,
    word7: 18
)
private let sessionResource = FontResourceID(rawValue: sessionDigest)
private let sessionInstance = FontInstanceID(
    resource: sessionResource,
    instanceIndex: 0
)
private let sessionTextDescriptor = TextResourceDescriptor(
    schemaVersion: 1,
    resource: sessionResource,
    instanceCount: 1,
    realizationCount: 1,
    canonicalManifestByteCount: 1
)
private let sessionRealization = RasterRealizationDescriptor(
    id: RasterRealizationID(rawValue: 0),
    instance: sessionInstance,
    kind: .monochromeBitmap1,
    glyphCount: 0,
    payloadByteCount: 0,
    payloadDigest: sessionDigest
)

private struct SessionMetrics: CanonicalTextMetricsView {
    let descriptor = sessionTextDescriptor
    func instance(at index: UInt16) -> FontInstanceDescriptor? { nil }
    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }
    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? { nil }
    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }
}

private struct SessionRaster: TextRasterResourceView {
    let descriptor = sessionTextDescriptor
    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 ? sessionRealization : nil
    }
    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? { nil }
    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        true
    }
    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? { nil }
}

private struct SessionEnvelopeValidator: RasterFrameEnvelopeValidator {
    let expected: FrameProvenance

    borrowing func accepts(_ provenance: FrameProvenance) -> Bool {
        provenance == expected
    }
}

private let sessionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 3)!
)!
private let sessionDescriptor = RasterSurfaceDescriptor(
    bounds: sessionBounds,
    encoding: .rgb565BigEndian,
    bytesPerRow: 8,
    realization: .tiled,
    regionWidth: 4,
    regionHeight: 1
)!
private let sessionLimits = RasterPayloadLimits(
    maximumRasterBytes: 8,
    maximumPayloadBytes: 8,
    maximumRegionsPerPayload: 4,
    maximumRegionSubmissionsPerFrame: 24,
    maximumTileVisitsPerFrame: 6,
    maximumInFlightPayloads: 1,
    maximumGlyphRasterBytes: 1,
    maximumStrokeWorkspaceBytes: 1
)!
private let sessionCapacity = RenderSinkCapacity(
    maximumOperations: 2,
    maximumPositionedGlyphs: 0
)
private let sessionProvenance = FrameProvenance(
    cycle: RunCycleID(rawValue: 1),
    semanticRevision: SemanticRevision(rawValue: 2),
    candidateFrame: CandidateFrameID(rawValue: 3)
)

private func makeProductionSession() -> OperationMajorRGB565RasterSession<
    TileStorage,
    SessionTarget,
    SessionMetrics,
    SessionRaster
> {
    OperationMajorRGB565RasterSession(
        capacity: sessionCapacity,
        descriptor: sessionDescriptor,
        payloadLimits: sessionLimits,
        metrics: SessionMetrics(),
        raster: SessionRaster(),
        realization: sessionRealization.id,
        storage: TileStorage(byteCount: 8, pixelCount: 4),
        target: SessionTarget()
    )!
}

@Test
func productionSessionStreamsPainterOrderThroughOneShotEndpoint() {
    let effectivePresentation = effective(
        operations: [.opaqueRectangles, .clipping, .damage],
        regionExtent: CapabilityExtent(width: 4, height: 1)!,
        rowBytes: 8,
        encoding: .rgb565BigEndian,
        realization: .tiled,
        requiredRasterBytes: 8,
        requiredPayloadBytes: 8,
        requiredInFlightBytes: 8
    )
    var endpoint = OneShotRasterBackendEndpoint(
        effectivePresentation: effectivePresentation,
        descriptor: sessionDescriptor,
        payloadLimits: sessionLimits,
        textMetrics: SessionMetrics(),
        textRaster: SessionRaster(),
        textRasterRealization: sessionRealization.id,
        envelopeValidator: SessionEnvelopeValidator(
            expected: sessionProvenance
        ),
        sink: makeProductionSession(),
        startupFailure: nil
    )!

    let result = endpoint.offer(provenance: sessionProvenance) { sink in
        let header = RenderPlanHeader(
            surfaceBounds: sessionBounds,
            damageBounds: sessionBounds,
            operationCount: 2,
            positionedGlyphCount: 0,
            maximumObservedClipDepth: 1
        )
        guard sink.begin(header),
            sink.fillRect(
                FillRectOperation(
                    bounds: sessionBounds,
                    clip: sessionBounds,
                    color: .red
                )
            ),
            sink.fillRect(
                FillRectOperation(
                    bounds: Rect(
                        origin: Point(x: 1, y: 1),
                        size: Size(width: 2, height: 1)!
                    )!,
                    clip: sessionBounds,
                    color: .blue
                )
            ),
            sink.finish()
        else { return .endpointRefused }
        return .complete
    }

    #expect(result == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(endpoint.sink.isIdleForOffer)
    #expect(endpoint.sink.streamCompleted)
    #expect(endpoint.sink.target.reserveCount == 1)
    #expect(endpoint.sink.target.finishCount == 1)
    #expect(endpoint.sink.target.cancelCount == 0)
    #expect(endpoint.sink.target.payloads.count == 4)
    #expect(
        endpoint.sink.target.payloads.map { $0.regions }
            == [
                [SessionRegion(origin: Point(x: 0, y: 0), pixelCount: 4)],
                [SessionRegion(origin: Point(x: 0, y: 1), pixelCount: 4)],
                [SessionRegion(origin: Point(x: 0, y: 2), pixelCount: 4)],
                [SessionRegion(origin: Point(x: 1, y: 1), pixelCount: 2)],
            ]
    )
    #expect(endpoint.sink.target.payloads[3].bytes == [0x00, 0x1F, 0x00, 0x1F])
}

@Test
func productionSessionCancelsMalformedPretransferStreamExactlyOnce() {
    var session = makeProductionSession()
    let reservation = session.reserveFrame(
        descriptor: sessionDescriptor,
        payloadCapacityBytes: sessionLimits.maximumPayloadBytes,
        regionCapacity: sessionLimits.maximumRegionsPerPayload
    )
    #expect(reservation == .reserved(DisplayReservationID(rawValue: 17)))
    let began = session.begin(
        RenderPlanHeader(
            surfaceBounds: sessionBounds,
            damageBounds: sessionBounds,
            operationCount: 1,
            positionedGlyphCount: 0,
            maximumObservedClipDepth: 1
        )
    )
    #expect(began)
    let finished = session.finish()
    #expect(!finished)
    #expect(session.failure == .malformedStream)
    #expect(session.retainedProducerError == .sinkRefused)
    session.discard()
    session.cancelReservedFrame()
    #expect(session.isIdleForOffer)
    #expect(session.target.cancelCount == 1)
    #expect(session.target.finishCount == 0)
}
