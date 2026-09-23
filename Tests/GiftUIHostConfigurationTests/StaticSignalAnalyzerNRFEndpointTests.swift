import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUISurfaceCore
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFEndpointWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32 = 3_840
    let regionCapacity: UInt16 = 1
    let writtenBytes: UInt32 = 0
    let writtenRegionCount: UInt16 = 0

    mutating func beginRegion(
        origin: Point, pixelCount: UInt16, encoding: CanonicalPixelEncoding
    ) -> Bool { false }
    mutating func write(byte: UInt8) -> Bool { false }
    mutating func endRegion() -> Bool { false }
    mutating func finish() -> Bool { false }
    mutating func discard() {}
}

private struct StaticNRFEndpointTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 3_840
    var writer = StaticNRFEndpointWriter()

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult { .retryableRefusal }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout StaticNRFEndpointWriter) -> Result
    ) -> Result? { nil }

    mutating func submitPayload(_: DisplayReservationID) -> DisplayTransferResult {
        .failureBeforeAcceptance(.invalidReservation)
    }
    mutating func finishFrame(_: DisplayReservationID) -> DisplayTransferResult {
        .failureBeforeAcceptance(.invalidReservation)
    }
    mutating func cancelFrame(_: DisplayReservationID) {}
    borrowing func health() -> GiftUIOperationalHealth { GiftUIOperationalHealth() }
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
