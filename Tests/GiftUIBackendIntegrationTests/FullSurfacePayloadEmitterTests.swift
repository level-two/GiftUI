import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIBackendIntegration

private struct EmitterStorage: FullSurfaceRGBA8888Storage {
    private(set) var bytes: [UInt8]

    var capacityBytes: UInt32 { UInt32(bytes.count) }

    init(count: Int, repeating value: UInt8 = 0) {
        bytes = [UInt8](repeating: value, count: count)
    }

    mutating func store(
        byte0: UInt8,
        byte1: UInt8,
        byte2: UInt8,
        byte3: UInt8,
        at offset: UInt32
    ) -> Bool {
        guard Int(offset) + 4 <= bytes.count else { return false }
        bytes[Int(offset)] = byte0
        bytes[Int(offset) + 1] = byte1
        bytes[Int(offset) + 2] = byte2
        bytes[Int(offset) + 3] = byte3
        return true
    }

    borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        try bytes.withUnsafeBytes(body)
    }
}

private struct EmitterWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32
    let regionCapacity: UInt16
    private(set) var writtenBytes: UInt32 = 0
    private(set) var writtenRegionCount: UInt16 = 0
    private(set) var bytes: [UInt8] = []
    private(set) var origins: [Point] = []

    private var remainingRegionBytes: UInt32 = 0
    private var finished = false

    init(capacityBytes: UInt32, regionCapacity: UInt16) {
        self.capacityBytes = capacityBytes
        self.regionCapacity = regionCapacity
    }

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard !finished, remainingRegionBytes == 0,
            writtenRegionCount < regionCapacity,
            pixelCount > 0
        else { return false }
        let bytesPerPixel: UInt32 = encoding == .rgba8888 ? 4 : 2
        let count = UInt32(pixelCount).multipliedReportingOverflow(
            by: bytesPerPixel
        )
        guard !count.overflow,
            writtenBytes + count.partialValue <= capacityBytes
        else { return false }
        remainingRegionBytes = count.partialValue
        origins.append(origin)
        return true
    }

    mutating func write(byte: UInt8) -> Bool {
        guard !finished, remainingRegionBytes > 0,
            writtenBytes < capacityBytes
        else { return false }
        bytes.append(byte)
        writtenBytes += 1
        remainingRegionBytes -= 1
        return true
    }

    mutating func endRegion() -> Bool {
        guard !finished, remainingRegionBytes == 0 else { return false }
        writtenRegionCount += 1
        return true
    }

    mutating func finish() -> Bool {
        guard !finished, remainingRegionBytes == 0,
            writtenRegionCount > 0
        else { return false }
        finished = true
        return true
    }

    mutating func discard() {
        writtenBytes = 0
        writtenRegionCount = 0
        bytes.removeAll(keepingCapacity: true)
        origins.removeAll(keepingCapacity: true)
        remainingRegionBytes = 0
        finished = false
    }
}

private struct EmitterTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime = .synchronousCopy
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32

    private(set) var writer: EmitterWriter
    private(set) var submittedBytes: [UInt8] = []
    private(set) var submittedOrigins: [Point] = []
    private(set) var submitCount = 0
    private(set) var finishCount = 0
    private(set) var cancelCount = 0
    var submitResult: DisplayTransferResult = .completed
    var finishResult: DisplayTransferResult = .completed

    init(capacityBytes: UInt32, regionCapacity: UInt16) {
        maximumInFlightBytes = capacityBytes
        writer = EmitterWriter(
            capacityBytes: capacityBytes,
            regionCapacity: regionCapacity
        )
    }

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        .reserved(DisplayReservationID(rawValue: 7))
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout EmitterWriter) -> Result
    ) -> Result? {
        guard reservation.rawValue == 7 else { return nil }
        return body(&writer)
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        submitCount += 1
        if submitResult == .completed {
            submittedBytes = writer.bytes
            submittedOrigins = writer.origins
        }
        return submitResult
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        finishCount += 1
        return finishResult
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        cancelCount += 1
        writer.discard()
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}

private let emitterBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 3, height: 2)!
)!
private let emitterDescriptor = RasterSurfaceDescriptor(
    bounds: emitterBounds,
    encoding: .rgba8888,
    bytesPerRow: 15,
    realization: .fullSurface,
    regionWidth: 3,
    regionHeight: 2
)!

private func emitterHeader(damage: Rect = emitterBounds) -> RenderPlanHeader {
    RenderPlanHeader(
        surfaceBounds: emitterBounds,
        damageBounds: damage,
        operationCount: 1,
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 0
    )
}

private func populatedEmitterSurface(
    header: RenderPlanHeader
) -> FullSurfaceRGBA8888Buffer<EmitterStorage> {
    var surface = FullSurfaceRGBA8888Buffer(
        descriptor: emitterDescriptor,
        storage: EmitterStorage(count: 30, repeating: 0xA5)
    )!
    precondition(surface.beginFrame(header))
    var y = header.damageBounds.minY
    while y < header.damageBounds.maxY {
        var x = header.damageBounds.minX
        while x < header.damageBounds.maxX {
            precondition(
                surface.replacePixel(
                    at: Point(x: x, y: y),
                    with: CanonicalEncodedPixel(
                        color: Color(red: UInt8(x + 1), green: UInt8(y + 1), blue: 3),
                        encoding: .rgba8888
                    )
                )
            )
            x += 1
        }
        y += 1
    }
    return surface
}

@Test
func fullSurfaceEmitterSubmitsDamagedRowsPackedInExactlyOnePayload() {
    let damage = Rect(
        origin: Point(x: 1, y: 0),
        size: Size(width: 2, height: 2)!
    )!
    let header = emitterHeader(damage: damage)
    var surface = populatedEmitterSurface(header: header)
    var target = EmitterTarget(capacityBytes: 16, regionCapacity: 2)

    let result = FullSurfacePayloadEmitter.finish(
        surface: &surface,
        header: header,
        reservation: DisplayReservationID(rawValue: 7),
        target: &target
    )

    #expect(result == .completed(responsibilityTransferred: true))
    #expect(target.submitCount == 1)
    #expect(target.finishCount == 1)
    #expect(target.submittedOrigins == [Point(x: 1, y: 0), Point(x: 1, y: 1)])
    #expect(target.submittedBytes.count == 16)
    #expect(target.submittedBytes[0 ..< 4] == [2, 1, 3, 255])
    #expect(!target.submittedBytes.contains(0xA5))
}

@Test
func fullSurfaceEmitterUsesZeroPayloadForEmptyDamage() {
    let emptyDamage = Rect(
        origin: Point(x: 1, y: 1),
        size: Size(width: 0, height: 0)!
    )!
    let header = emitterHeader(damage: emptyDamage)
    var surface = populatedEmitterSurface(header: header)
    var target = EmitterTarget(capacityBytes: 1, regionCapacity: 1)

    let result = FullSurfacePayloadEmitter.finish(
        surface: &surface,
        header: header,
        reservation: DisplayReservationID(rawValue: 7),
        target: &target
    )

    #expect(result == .completed(responsibilityTransferred: false))
    #expect(target.submitCount == 0)
    #expect(target.finishCount == 1)
}

@Test
func fullSurfaceEmitterLeavesPretransferWriterFailureCancellable() {
    let header = emitterHeader()
    var surface = populatedEmitterSurface(header: header)
    var target = EmitterTarget(capacityBytes: 23, regionCapacity: 2)

    let result = FullSurfacePayloadEmitter.finish(
        surface: &surface,
        header: header,
        reservation: DisplayReservationID(rawValue: 7),
        target: &target
    )
    #expect(result == .writerFailure)
    #expect(target.submitCount == 0)
    #expect(!surface.presentationResponsibilityAccepted)
    surface.discardFrame()
    target.cancelFrame(DisplayReservationID(rawValue: 7))
    #expect(target.cancelCount == 1)
}

@Test
func fullSurfaceEmitterPreservesSubmitAndFrameEndFailureStage() {
    let header = emitterHeader()
    var beforeSurface = populatedEmitterSurface(header: header)
    var beforeTarget = EmitterTarget(capacityBytes: 24, regionCapacity: 2)
    beforeTarget.submitResult = .failureBeforeAcceptance(.transportUnavailable)
    let before = FullSurfacePayloadEmitter.finish(
        surface: &beforeSurface,
        header: header,
        reservation: DisplayReservationID(rawValue: 7),
        target: &beforeTarget
    )
    #expect(
        before
            == .payloadTransfer(
                .failureBeforeAcceptance(.transportUnavailable)
            )
    )
    #expect(!beforeSurface.presentationResponsibilityAccepted)

    var afterSurface = populatedEmitterSurface(header: header)
    var afterTarget = EmitterTarget(capacityBytes: 24, regionCapacity: 2)
    afterTarget.finishResult = .failureAfterAcceptance(.transportUnavailable)
    let after = FullSurfacePayloadEmitter.finish(
        surface: &afterSurface,
        header: header,
        reservation: DisplayReservationID(rawValue: 7),
        target: &afterTarget
    )
    #expect(
        after
            == .frameEnd(
                .failureAfterAcceptance(.transportUnavailable)
            )
    )
    #expect(afterTarget.submitCount == 1)
    #expect(afterTarget.finishCount == 1)
}
