import GiftUI
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUIRenderCore
import SignalAnalyzerTargetHost
import Testing

struct StaticNRFRecordingDisplayTransport: StaticSignalAnalyzerNRFDisplayTransport {
    private(set) var payloads = 0
    private(set) var bytes: UInt32 = 0
    private(set) var lastX: UInt16 = 0
    private(set) var lastY: UInt16 = 0
    private(set) var lastPixelCount: UInt16 = 0
    private(set) var firstByte: UInt8 = 0
    private(set) var secondByte: UInt8 = 0
    var accepts = true
    var maximumAcceptedPayloads: Int?

    mutating func presentRGB565BigEndian(
        x: UInt16, y: UInt16, pixelCount: UInt16,
        bytes: UnsafeRawBufferPointer
    ) -> Bool {
        guard accepts,
            maximumAcceptedPayloads.map({ payloads < $0 }) ?? true,
            bytes.count == Int(pixelCount) * 2
        else { return false }
        payloads += 1
        self.bytes += UInt32(bytes.count)
        lastX = x
        lastY = y
        lastPixelCount = pixelCount
        firstByte = bytes[0]
        secondByte = bytes[1]
        return true
    }
}

@Test func staticNRFDisplayFailureAfterFirstPayloadPreservesPresentationResponsibility() {
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
        cycle: RunCycleID(rawValue: 8),
        semanticRevision: SemanticRevision(rawValue: 8),
        candidateFrame: CandidateFrameID(rawValue: 8)
    )
    guard
        var endpoint = StaticSignalAnalyzerNRFEndpointFactory.make(
            transport: StaticNRFRecordingDisplayTransport(maximumAcceptedPayloads: 1),
            provenance: provenance,
            assemblyReport: report,
            rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
            coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240)
        )
    else {
        Issue.record("Static nRF endpoint did not construct")
        return
    }
    let first = Rect(
        origin: Point(x: 0, y: 0), size: Size(width: 1, height: 1)!
    )!
    let second = Rect(
        origin: Point(x: 2, y: 0), size: Size(width: 1, height: 1)!
    )!
    let damage = Rect(
        origin: Point(x: 0, y: 0), size: Size(width: 3, height: 1)!
    )!
    let offer = endpoint.offer(provenance: provenance) { sink in
        let header = RenderPlanHeader(
            surfaceBounds: bounds,
            damageBounds: damage,
            operationCount: 2,
            positionedGlyphCount: 0,
            maximumObservedClipDepth: 1
        )
        guard sink.begin(header),
            sink.fillRect(FillRectOperation(bounds: first, clip: damage, color: .red)),
            sink.fillRect(FillRectOperation(bounds: second, clip: damage, color: .blue)),
            sink.finish()
        else { return .endpointRefused }
        return .complete
    }
    #expect(offer == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(endpoint.sink.failure == .displayFailure)
    #expect(endpoint.sink.target.transport.payloads == 1)
    #expect(endpoint.sink.isIdleForOffer)
}

@Test func staticNRFDisplayFailureBeforeFirstPayloadCancelsFrame() {
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
        cycle: RunCycleID(rawValue: 9),
        semanticRevision: SemanticRevision(rawValue: 9),
        candidateFrame: CandidateFrameID(rawValue: 9)
    )
    guard
        var endpoint = StaticSignalAnalyzerNRFEndpointFactory.make(
            transport: StaticNRFRecordingDisplayTransport(maximumAcceptedPayloads: 0),
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
        origin: Point(x: 0, y: 0), size: Size(width: 1, height: 1)!
    )!
    let offer = endpoint.offer(provenance: provenance) { sink in
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
    #expect(offer == FrameOfferResult(disposition: .nonRetryableRefusal, failure: nil)!)
    #expect(endpoint.sink.failure == .displayFailure)
    #expect(endpoint.sink.target.transport.payloads == 0)
    #expect(endpoint.sink.isIdleForOffer)
}

@Test func staticNRFDisplayTargetCompactsSharedRasterWithoutOverwritingUnreadPixels() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { pointer.deallocate() }
    let region = UnsafeMutableRawBufferPointer(start: pointer, count: 3_840)
    region.initializeMemory(as: UInt8.self, repeating: 0)
    region[200] = 0x12
    region[201] = 0x34
    region[2_000] = 0xAB
    region[2_001] = 0xCD
    guard
        var target = StaticSignalAnalyzerNRFDisplayTarget(
            transport: StaticNRFRecordingDisplayTransport(),
            rasterRegion: region
        ), let descriptor = StaticSignalAnalyzerNRFAssembly.descriptor(),
        case .reserved(let reservation) = target.reserveFrame(
            descriptor: descriptor,
            payloadCapacityBytes: 3_840,
            regionCapacity: 1
        )
    else {
        Issue.record("Static display target did not reserve its exact region")
        return
    }
    let firstWritten = target.withWriter(for: reservation) { writer in
        writer.beginRegion(
            origin: Point(x: 100, y: 0), pixelCount: 1,
            encoding: .rgb565BigEndian
        ) && writer.write(byte: region[200])
            && writer.write(byte: region[201])
            && writer.endRegion() && writer.finish()
    }
    #expect(firstWritten == true)
    #expect(target.submitPayload(reservation) == .completed)
    #expect(target.transport.firstByte == 0x12)
    #expect(target.transport.secondByte == 0x34)
    #expect(region[2_000] == 0xAB)
    #expect(region[2_001] == 0xCD)

    let secondWritten = target.withWriter(for: reservation) { writer in
        writer.beginRegion(
            origin: Point(x: 40, y: 2), pixelCount: 1,
            encoding: .rgb565BigEndian
        ) && writer.write(byte: region[2_000])
            && writer.write(byte: region[2_001])
            && writer.endRegion() && writer.finish()
    }
    #expect(secondWritten == true)
    #expect(target.submitPayload(reservation) == .completed)
    #expect(target.transport.firstByte == 0xAB)
    #expect(target.transport.secondByte == 0xCD)
    #expect(target.transport.payloads == 2)
    #expect(target.transport.bytes == 4)
    #expect(target.finishFrame(reservation) == .completed)
}

@Test func staticNRFDisplayTargetRejectsTransportFailureAndInvalidReservation() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { pointer.deallocate() }
    let region = UnsafeMutableRawBufferPointer(start: pointer, count: 3_840)
    guard
        var target = StaticSignalAnalyzerNRFDisplayTarget(
            transport: StaticNRFRecordingDisplayTransport(accepts: false),
            rasterRegion: region
        ), let descriptor = StaticSignalAnalyzerNRFAssembly.descriptor(),
        case .reserved(let reservation) = target.reserveFrame(
            descriptor: descriptor,
            payloadCapacityBytes: 3_840,
            regionCapacity: 1
        )
    else {
        Issue.record("Static display target did not reserve its exact region")
        return
    }
    #expect(
        target.reserveFrame(
            descriptor: descriptor, payloadCapacityBytes: 3_840, regionCapacity: 1
        ) == .failure(.reentrancyViolation))
    #expect(
        target.submitPayload(DisplayReservationID(rawValue: 99))
            == .failureBeforeAcceptance(.invalidReservation))
    let written = target.withWriter(for: reservation) { writer in
        writer.beginRegion(
            origin: Point(x: 0, y: 0), pixelCount: 1,
            encoding: .rgb565BigEndian
        ) && writer.write(byte: 0xFF) && writer.write(byte: 0xFF)
            && writer.endRegion() && writer.finish()
    }
    #expect(written == true)
    #expect(
        target.submitPayload(reservation)
            == .failureBeforeAcceptance(.transportUnavailable))
    target.cancelFrame(reservation)
    #expect(
        target.finishFrame(reservation)
            == .failureBeforeAcceptance(.invalidReservation))
}
