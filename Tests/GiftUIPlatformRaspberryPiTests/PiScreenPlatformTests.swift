import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIPlatformRaspberryPi

private struct PresentedRegion: Equatable {
    let bytes: [UInt8]
    let origin: Point
    let pixelCount: UInt16
    let physicalBounds: Rect
}

private struct RecordingSink: PiScreenFramebufferSink {
    var accepts = true
    private(set) var presented: [PresentedRegion] = []

    mutating func presentRGB565BigEndian(
        bytes: UnsafeRawBufferPointer,
        regions: [PiScreenPayloadRegion],
        transform: PiScreenAspectFitTransform
    ) -> Bool {
        guard accepts else { return false }
        for region in regions {
            let count = Int(region.pixelCount) * 2
            guard
                let bounds = transform.physicalBounds(
                    origin: region.origin,
                    pixelCount: region.pixelCount
                )
            else { return false }
            presented.append(
                PresentedRegion(
                    bytes: Array(bytes[Int(region.byteOffset) ..< Int(region.byteOffset) + count]),
                    origin: region.origin,
                    pixelCount: region.pixelCount,
                    physicalBounds: bounds
                )
            )
        }
        return true
    }
}

private final class ConsoleTransportProbe {
    var mode: PiScreenConsoleMode?
    var acceptsWrites = true
    var writtenModes: [PiScreenConsoleMode] = []
    var closeCount = 0

    init(mode: PiScreenConsoleMode?) {
        self.mode = mode
    }
}

private struct RecordingConsoleTransport: PiScreenConsoleModeTransport {
    let probe: ConsoleTransportProbe

    mutating func readMode() -> PiScreenConsoleMode? {
        probe.mode
    }

    mutating func writeMode(_ mode: PiScreenConsoleMode) -> Bool {
        probe.writtenModes.append(mode)
        guard probe.acceptsWrites else { return false }
        probe.mode = mode
        return true
    }

    mutating func close() {
        probe.closeCount += 1
    }
}

@Test func consoleOwnerAcquiresGraphicsAndRestoresPriorModeOnce() {
    let probe = ConsoleTransportProbe(mode: .text)
    var owner = PiScreenConsoleModeOwner(transport: RecordingConsoleTransport(probe: probe))

    #expect(owner.acquire() == .acquired(previousMode: .text, changedMode: true))
    #expect(probe.mode == .graphics)
    #expect(probe.closeCount == 0)
    #expect(owner.restore() == .restored(changedMode: true))
    #expect(probe.mode == .text)
    #expect(probe.closeCount == 1)
    #expect(owner.restore() == .restored(changedMode: false))
    #expect(probe.closeCount == 1)
}

@Test func consoleOwnerPreservesPreexistingGraphicsMode() {
    let probe = ConsoleTransportProbe(mode: .graphics)
    var owner = PiScreenConsoleModeOwner(transport: RecordingConsoleTransport(probe: probe))

    #expect(owner.acquire() == .acquired(previousMode: .graphics, changedMode: false))
    #expect(probe.writtenModes.isEmpty)
    #expect(owner.restore() == .restored(changedMode: false))
    #expect(probe.writtenModes.isEmpty)
    #expect(probe.closeCount == 1)
}

@Test func consoleOwnerClosesAfterAcquisitionFailures() {
    let unreadableProbe = ConsoleTransportProbe(mode: nil)
    var unreadable = PiScreenConsoleModeOwner(
        transport: RecordingConsoleTransport(probe: unreadableProbe)
    )
    #expect(unreadable.acquire() == .failure(.modeReadFailed))
    #expect(unreadableProbe.closeCount == 1)
    #expect(unreadable.restore() == .restored(changedMode: false))
    #expect(unreadableProbe.closeCount == 1)

    let unwritableProbe = ConsoleTransportProbe(mode: .text)
    unwritableProbe.acceptsWrites = false
    var unwritable = PiScreenConsoleModeOwner(
        transport: RecordingConsoleTransport(probe: unwritableProbe)
    )
    #expect(unwritable.acquire() == .failure(.graphicsModeFailed))
    #expect(unwritableProbe.writtenModes == [.graphics])
    #expect(unwritableProbe.closeCount == 1)
}

@Test func consoleOwnerClosesWhenPriorModeRestorationFails() {
    let probe = ConsoleTransportProbe(mode: .text)
    var owner = PiScreenConsoleModeOwner(transport: RecordingConsoleTransport(probe: probe))
    #expect(owner.acquire() == .acquired(previousMode: .text, changedMode: true))
    probe.acceptsWrites = false

    #expect(owner.restore() == .failure(.restoreModeFailed))
    #expect(probe.closeCount == 1)
    #expect(owner.restore() == .restored(changedMode: false))
    #expect(probe.closeCount == 1)
}

@Test func framebufferLayoutRejectsWrongFormatStrideAndMapping() {
    #expect(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        ) != nil
    )
    #expect(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 32,
            bytesPerRow: 1_920,
            mappedBytes: 614_400
        ) == nil
    )
    #expect(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 959,
            mappedBytes: 307_200
        ) == nil
    )
    #expect(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_199
        ) == nil
    )
}

@Test func aspectFitMapsTouchAndRejectsLetterbox() throws {
    let transform = try #require(
        PiScreenAspectFitTransform(
            physicalWidth: 480,
            physicalHeight: 320,
            logicalWidth: 240,
            logicalHeight: 240
        )
    )
    let calibration = try #require(
        PiScreenTouchCalibration(
            minimumX: 0,
            maximumX: 4_095,
            minimumY: 0,
            maximumY: 4_095
        )
    )
    #expect(transform.contentOriginX == 80)
    #expect(transform.contentOriginY == 0)
    #expect(transform.contentWidth == 320)
    #expect(transform.contentHeight == 320)
    #expect(
        transform.logicalPoint(rawX: 2_048, rawY: 2_048, calibration: calibration)
            == Point(x: 119, y: 119))
    #expect(transform.logicalPoint(rawX: 0, rawY: 2_048, calibration: calibration) == nil)
}

@Test func contactDecoderProducesOneOrderedSequenceAndCancelsOutside() {
    var decoder = PiScreenContactDecoder()
    #expect(
        decoder.update(point: Point(x: 10, y: 20), touching: true)
            == PiScreenContactEvent(phase: .down, point: Point(x: 10, y: 20))
    )
    #expect(
        decoder.update(point: Point(x: 11, y: 21), touching: true)
            == PiScreenContactEvent(phase: .move, point: Point(x: 11, y: 21))
    )
    #expect(
        decoder.update(point: nil, touching: true)
            == PiScreenContactEvent(phase: .up, point: Point(x: 11, y: 21))
    )
    #expect(decoder.update(point: nil, touching: false) == nil)
}

@Test func displayTargetPreservesCanonicalBytesAndPhysicalProjection() throws {
    let layout = try #require(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        )
    )
    var target = try #require(PiScreenDisplayTarget(sink: RecordingSink(), layout: layout))
    let descriptor = try #require(
        RasterSurfaceDescriptor(
            bounds: Rect(origin: Point(x: 0, y: 0), size: Size(width: 240, height: 240)!)!,
            encoding: .rgb565BigEndian,
            bytesPerRow: 480,
            realization: .tiled,
            regionWidth: 240,
            regionHeight: 16
        )
    )
    guard
        case .reserved(let reservation) = target.reserveFrame(
            descriptor: descriptor,
            payloadCapacityBytes: 8,
            regionCapacity: 1
        )
    else {
        Issue.record("valid PiScreen descriptor must reserve")
        return
    }
    let wrote = target.withWriter(for: reservation) { writer in
        guard
            writer.beginRegion(
                origin: Point(x: 0, y: 0),
                pixelCount: 2,
                encoding: .rgb565BigEndian
            )
        else { return false }
        for byte in [UInt8(0xF8), 0, 0x07, 0xE0] where !writer.write(byte: byte) {
            return false
        }
        return writer.endRegion() && writer.finish()
    }
    #expect(wrote == true)
    #expect(target.submitPayload(reservation) == .completed)
    #expect(target.finishFrame(reservation) == .completed)
    #expect(target.sink.presented.count == 1)
    #expect(target.sink.presented.first?.bytes == [0xF8, 0, 0x07, 0xE0])
    #expect(
        target.sink.presented.first?.physicalBounds == Rect(
            origin: Point(x: 80, y: 0), size: Size(width: 3, height: 2)!)!)
}

@Test func displayTargetRejectsWrongDescriptorAndTransportFailure() throws {
    let layout = try #require(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        )
    )
    var target = try #require(
        PiScreenDisplayTarget(sink: RecordingSink(accepts: false), layout: layout)
    )
    let wrong = try #require(
        RasterSurfaceDescriptor(
            bounds: Rect(origin: Point(x: 0, y: 0), size: Size(width: 240, height: 240)!)!,
            encoding: .rgba8888,
            bytesPerRow: 960,
            realization: .tiled,
            regionWidth: 240,
            regionHeight: 16
        )
    )
    #expect(
        target.reserveFrame(
            descriptor: wrong,
            payloadCapacityBytes: 8,
            regionCapacity: 1
        ) == .failure(.invalidDescriptor)
    )
}
