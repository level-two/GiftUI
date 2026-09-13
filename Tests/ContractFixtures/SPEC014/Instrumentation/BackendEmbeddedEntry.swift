import GiftUI
import GiftUICapabilities
import GiftUIBackendIntegration
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore

private struct EmbeddedTileStorage: RGB565TileStorage {
    private var bytes = InlineArray<3840, UInt8>(repeating: 0)
    private var affected = InlineArray<1920, Bool>(repeating: false)

    var byteCapacity: UInt32 { 3_840 }
    var pixelCapacity: UInt32 { 1_920 }

    mutating func reset(byteCount: UInt32, pixelCount: UInt32) -> Bool {
        guard byteCount <= byteCapacity, pixelCount <= pixelCapacity else {
            return false
        }
        for index in 0 ..< Int(pixelCount) { affected[index] = false }
        return true
    }

    mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        byteOffset: UInt32,
        pixelIndex: UInt32
    ) -> Bool {
        guard byteOffset < 3_839, pixelIndex < 1_920 else { return false }
        bytes[Int(byteOffset)] = mostSignificantByte
        bytes[Int(byteOffset) + 1] = leastSignificantByte
        affected[Int(pixelIndex)] = true
        return true
    }

    func isAffected(pixelIndex: UInt32) -> Bool {
        pixelIndex < 1_920 && affected[Int(pixelIndex)]
    }

    func byte(at offset: UInt32) -> UInt8? {
        offset < 3_840 ? bytes[Int(offset)] : nil
    }
}

private struct EmbeddedWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32 = 3_840
    let regionCapacity: UInt16 = 4
    private(set) var writtenBytes: UInt32 = 0
    private(set) var writtenRegionCount: UInt16 = 0
    private var remainingRegionBytes: UInt32 = 0
    private(set) var isFinished = false

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        _ = origin
        let byteCount = UInt32(pixelCount) * 2
        guard !isFinished, remainingRegionBytes == 0, pixelCount > 0,
            encoding == .rgb565BigEndian,
            writtenRegionCount < regionCapacity,
            writtenBytes <= capacityBytes - byteCount
        else { return false }
        remainingRegionBytes = byteCount
        return true
    }

    mutating func write(byte: UInt8) -> Bool {
        _ = byte
        guard !isFinished, remainingRegionBytes > 0,
            writtenBytes < capacityBytes
        else { return false }
        remainingRegionBytes -= 1
        writtenBytes += 1
        return true
    }

    mutating func endRegion() -> Bool {
        guard !isFinished, remainingRegionBytes == 0 else { return false }
        writtenRegionCount += 1
        return true
    }

    mutating func finish() -> Bool {
        guard !isFinished, remainingRegionBytes == 0,
            writtenRegionCount > 0
        else { return false }
        isFinished = true
        return true
    }

    mutating func discard() {
        writtenBytes = 0
        writtenRegionCount = 0
        remainingRegionBytes = 0
        isFinished = false
    }
}

private struct EmbeddedTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime = .synchronousCopy
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 3_840
    var writer = EmbeddedWriter()
    private var reservationActive = false

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        guard !reservationActive,
            descriptor.encoding == .rgb565BigEndian,
            descriptor.realization == .tiled,
            descriptor.regionWidth == 480,
            descriptor.regionHeight == 4,
            payloadCapacityBytes == 3_840,
            regionCapacity == 4
        else { return .failure(.invariantViolation) }
        reservationActive = true
        return .reserved(DisplayReservationID(rawValue: 14))
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout EmbeddedWriter) -> Result
    ) -> Result? {
        guard reservationActive, reservation.rawValue == 14,
            !writer.isFinished
        else { return nil }
        return body(&writer)
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservationActive, reservation.rawValue == 14,
            writer.isFinished
        else { return .failureBeforeAcceptance(.invariantViolation) }
        writer.discard()
        return .completed
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservationActive, reservation.rawValue == 14,
            !writer.isFinished
        else { return .failureAfterAcceptance(.invariantViolation) }
        reservationActive = false
        return .completed
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        if reservation.rawValue == 14 { reservationActive = false }
        writer.discard()
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}

@inline(never)
package func spec014EmbeddedBackendEntry() -> UInt32 {
    guard let size = Size(width: 480, height: 320),
        let bounds = Rect(origin: Point(x: 0, y: 0), size: size),
        let descriptor = RasterSurfaceDescriptor(
            bounds: bounds,
            encoding: .rgb565BigEndian,
            bytesPerRow: 960,
            realization: .tiled,
            regionWidth: 480,
            regionHeight: 4
        ),
        var workspace = RGB565TileWorkspace(
            descriptor: descriptor,
            storage: EmbeddedTileStorage()
        ),
        let limits = RasterPayloadLimits(
            maximumRasterBytes: 3_840,
            maximumPayloadBytes: 3_840,
            maximumRegionsPerPayload: 4,
            maximumRegionSubmissionsPerFrame: 320,
            maximumTileVisitsPerFrame: 80,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 1,
            maximumStrokeWorkspaceBytes: 1
        )
    else { return .max }

    var target = EmbeddedTarget()
    guard case .reserved(let reservation) = target.reserveFrame(
        descriptor: descriptor,
        payloadCapacityBytes: 3_840,
        regionCapacity: 4
    ) else { return .max }
    var work = RasterWorkTracker(limits: limits)
    let fill = FillRectOperation(bounds: bounds, clip: bounds, color: .green)
    let traversal = OperationMajorTileTraversal.visit(
        operationClip: bounds,
        damageBounds: bounds,
        workspace: &workspace,
        { damage, replace in
            if case .completed = RasterFillCoverage.rasterize(
                fill,
                descriptor: descriptor,
                damageBounds: damage,
                replace
            ) { return true }
            return false
        },
        { tile in
            if case .completed = RGB565TilePayloadEmitter.submit(
                &tile,
                reservation: reservation,
                target: &target,
                work: &work
            ) { return true }
            return false
        }
    )
    guard traversal == .completed(tileVisits: 80),
        case .completed = RGB565TilePayloadEmitter.finish(
            reservation: reservation,
            target: &target,
            work: &work
        ),
        work.highWater.rasterBytes == 3_840,
        work.highWater.payloadBytes == 3_840,
        work.highWater.tileVisits == 80,
        work.highWater.regionSubmissions == 320,
        work.highWater.payloads == 80
    else { return .max }
    return work.highWater.rasterBytes &+ work.highWater.regionSubmissions
}
