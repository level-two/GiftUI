import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFEndpointWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32 = 3_840
    let regionCapacity: UInt16 = 1
    private(set) var writtenBytes: UInt32 = 0
    private(set) var writtenRegionCount: UInt16 = 0
    private var remainingBytes: UInt32 = 0

    mutating func beginRegion(
        origin: Point, pixelCount: UInt16, encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard remainingBytes == 0, writtenRegionCount == 0,
            pixelCount == 1, encoding == .rgb565BigEndian
        else { return false }
        remainingBytes = 2
        return true
    }
    mutating func write(byte: UInt8) -> Bool {
        guard remainingBytes > 0, writtenBytes < capacityBytes else { return false }
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
        remainingBytes == 0 && writtenRegionCount == 1
    }
    mutating func discard() {
        writtenBytes = 0
        writtenRegionCount = 0
        remainingBytes = 0
    }
}

private struct StaticNRFEndpointTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 3_840
    var acceptsOffers = false
    var writer = StaticNRFEndpointWriter()
    private(set) var submittedPayloads = 0
    private(set) var submittedBytes: UInt32 = 0
    private(set) var completedFrames = 0

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        acceptsOffers ? .reserved(DisplayReservationID(rawValue: 7)) : .retryableRefusal
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout StaticNRFEndpointWriter) -> Result
    ) -> Result? {
        guard reservation.rawValue == 7 else { return nil }
        return body(&writer)
    }

    mutating func submitPayload(_ reservation: DisplayReservationID) -> DisplayTransferResult {
        guard reservation.rawValue == 7 else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        submittedPayloads += 1
        submittedBytes += writer.writtenBytes
        writer.discard()
        return .completed
    }
    mutating func finishFrame(_ reservation: DisplayReservationID) -> DisplayTransferResult {
        guard reservation.rawValue == 7 else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        completedFrames += 1
        return .completed
    }
    mutating func cancelFrame(_: DisplayReservationID) {}
    borrowing func health() -> GiftUIOperationalHealth { GiftUIOperationalHealth() }
}

@Test func staticNRFEndpointStreamsOneTouchedPixelThroughSynchronousHandoff() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
        let bounds = StaticSignalAnalyzerNRFAssembly.descriptor()?.bounds
    else {
        Issue.record("Static nRF assembly did not validate")
        return
    }
    let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { raster.deallocate() }
    let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
    defer { coverage.deallocate() }
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 2),
        semanticRevision: SemanticRevision(rawValue: 3),
        candidateFrame: CandidateFrameID(rawValue: 4)
    )
    guard
        var endpoint = StaticSignalAnalyzerNRFEndpointFactory.make(
            target: StaticNRFEndpointTarget(acceptsOffers: true),
            provenance: provenance,
            assemblyReport: report,
            rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
            coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240)
        )
    else {
        Issue.record("Static nRF endpoint did not construct")
        return
    }
    let pixel = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 1, height: 1)!
    )!
    let result = endpoint.offer(provenance: provenance) { sink in
        let header = RenderPlanHeader(
            surfaceBounds: bounds,
            damageBounds: pixel,
            operationCount: 1,
            positionedGlyphCount: 0,
            maximumObservedClipDepth: 1
        )
        guard sink.begin(header),
            sink.fillRect(FillRectOperation(bounds: pixel, clip: pixel, color: .red)),
            sink.finish()
        else { return .endpointRefused }
        return .complete
    }
    #expect(result == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(endpoint.sink.target.submittedPayloads == 1)
    #expect(endpoint.sink.target.submittedBytes == 2)
    #expect(endpoint.sink.target.completedFrames == 1)
}

@Test func staticNRFEndpointAdmitsApprovedWorstCaseWorkAndExactRegions() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
        let descriptor = StaticSignalAnalyzerNRFAssembly.descriptor(),
        let limits = StaticSignalAnalyzerNRFAssembly.payloadLimits()
    else {
        Issue.record("Static nRF assembly did not validate")
        return
    }
    let capacity = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.renderSink
    #expect(capacity.maximumOperations == 150)
    #expect(limits.maximumTileVisitsPerFrame == 12_000)
    #expect(limits.maximumRegionSubmissionsPerFrame == 23_040_000)
    guard
        case .admitted(let work) = RasterFrameWorkCalculator.constructionBounds(
            descriptor: descriptor,
            sinkCapacity: capacity,
            limits: limits
        )
    else {
        Issue.record("Approved Static nRF stream did not fit raster work limits")
        return
    }
    #expect(work.tileVisits == 12_000)
    #expect(work.regionSubmissions == 23_040_000)

    let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { raster.deallocate() }
    let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
    defer { coverage.deallocate() }
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: SemanticRevision(rawValue: 1),
        candidateFrame: CandidateFrameID(rawValue: 1)
    )
    let endpoint = StaticSignalAnalyzerNRFEndpointFactory.make(
        target: StaticNRFEndpointTarget(),
        provenance: provenance,
        assemblyReport: report,
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240)
    )
    #expect(endpoint != nil)
    let invalidEndpoint = StaticSignalAnalyzerNRFEndpointFactory.make(
        target: StaticNRFEndpointTarget(),
        provenance: provenance,
        assemblyReport: report,
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 239)
    )
    #expect(invalidEndpoint == nil)
}
