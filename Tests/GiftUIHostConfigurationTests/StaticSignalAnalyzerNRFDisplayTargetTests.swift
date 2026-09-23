import GiftUI
import GiftUIDisplayCore
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

    mutating func presentRGB565BigEndian(
        x: UInt16, y: UInt16, pixelCount: UInt16,
        bytes: UnsafeRawBufferPointer
    ) -> Bool {
        guard accepts, bytes.count == Int(pixelCount) * 2 else { return false }
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
