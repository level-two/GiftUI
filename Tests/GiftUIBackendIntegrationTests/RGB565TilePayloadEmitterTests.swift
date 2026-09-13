import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIBackendIntegration

private struct TileRegion: Equatable {
    let origin: Point
    let pixels: UInt16
}

private struct TilePayload: Equatable {
    let bytes: [UInt8]
    let regions: [TileRegion]
}

private struct TileWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32
    let regionCapacity: UInt16
    private(set) var writtenBytes: UInt32 = 0
    private(set) var writtenRegionCount: UInt16 = 0
    private(set) var storage: [UInt8]
    private(set) var regions: [TileRegion] = []
    private var remainingRegionBytes: UInt32 = 0
    private var finished = false

    init(capacityBytes: UInt32, regionCapacity: UInt16) {
        self.capacityBytes = capacityBytes
        self.regionCapacity = regionCapacity
        storage = [UInt8](repeating: 0, count: Int(capacityBytes))
    }

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard !finished, remainingRegionBytes == 0,
            writtenRegionCount < regionCapacity,
            encoding == .rgb565BigEndian,
            pixelCount > 0
        else { return false }
        let bytes = UInt32(pixelCount) * 2
        guard bytes <= capacityBytes - writtenBytes else { return false }
        remainingRegionBytes = bytes
        regions.append(TileRegion(origin: origin, pixels: pixelCount))
        return true
    }

    mutating func write(byte: UInt8) -> Bool {
        guard !finished, remainingRegionBytes > 0,
            writtenBytes < capacityBytes
        else { return false }
        storage[Int(writtenBytes)] = byte
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
        for index in storage.indices { storage[index] = 0 }
        writtenBytes = 0
        writtenRegionCount = 0
        regions.removeAll(keepingCapacity: true)
        remainingRegionBytes = 0
        finished = false
    }
}

private struct TileTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32
    private(set) var writer: TileWriter
    private(set) var payloads: [TilePayload] = []

    init(capacityBytes: UInt32, regionCapacity: UInt16) {
        maximumInFlightBytes = capacityBytes
        writer = TileWriter(
            capacityBytes: capacityBytes,
            regionCapacity: regionCapacity
        )
    }

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        .reserved(DisplayReservationID(rawValue: 11))
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout TileWriter) -> Result
    ) -> Result? {
        guard reservation.rawValue == 11 else { return nil }
        return body(&writer)
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation.rawValue == 11 else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        payloads.append(
            TilePayload(
                bytes: Array(writer.storage.prefix(Int(writer.writtenBytes))),
                regions: writer.regions
            )
        )
        writer.discard()
        return .completed
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        .completed
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        writer.discard()
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}

private func tileWork(maximumPayloadBytes: UInt32) -> RasterWorkTracker {
    RasterWorkTracker(
        limits: RasterPayloadLimits(
            maximumRasterBytes: 32,
            maximumPayloadBytes: maximumPayloadBytes,
            maximumRegionsPerPayload: 2,
            maximumRegionSubmissionsPerFrame: 8,
            maximumTileVisitsPerFrame: 4,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 32,
            maximumStrokeWorkspaceBytes: 32
        )!
    )
}

private func patternedWorkspace() -> RGB565TileWorkspace<TileStorage> {
    var workspace = makeTileWorkspace()!
    let tile = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 8, height: 2)!
    )!
    precondition(workspace.beginTile(tile))
    let colors = [
        (Point(x: 0, y: 0), Color(red: 255, green: 0, blue: 0)),
        (Point(x: 1, y: 0), Color(red: 0, green: 255, blue: 0)),
        (Point(x: 2, y: 0), Color(red: 0, green: 0, blue: 255)),
        (Point(x: 4, y: 0), Color(red: 255, green: 255, blue: 255)),
        (Point(x: 5, y: 0), Color(red: 0, green: 0, blue: 0)),
        (Point(x: 1, y: 1), Color(red: 255, green: 0, blue: 0)),
        (Point(x: 2, y: 1), Color(red: 255, green: 0, blue: 0)),
        (Point(x: 3, y: 1), Color(red: 255, green: 0, blue: 0)),
        (Point(x: 4, y: 1), Color(red: 255, green: 0, blue: 0)),
    ]
    for (point, color) in colors {
        precondition(
            workspace.replacePixel(
                at: point,
                with: CanonicalEncodedPixel(
                    color: color,
                    encoding: .rgb565BigEndian
                )
            )
        )
    }
    return workspace
}

@Test
func tileEmitterFormsMaximalRunsAndFlushesBeforeCapacity() {
    var workspace = patternedWorkspace()
    var target = TileTarget(capacityBytes: 10, regionCapacity: 2)
    var work = tileWork(maximumPayloadBytes: 10)
    let result = RGB565TilePayloadEmitter.submit(
        &workspace,
        reservation: DisplayReservationID(rawValue: 11),
        target: &target,
        work: &work
    )

    #expect(
        result
            == .completed(
                TilePayloadEmissionSummary(
                    payloads: 2,
                    regions: 3,
                    bytes: 18,
                    responsibilityTransferred: true
                )
            )
    )
    #expect(
        target.payloads
            == [
                TilePayload(
                    bytes: [0xF8, 0, 0x07, 0xE0, 0, 0x1F, 0xFF, 0xFF, 0, 0],
                    regions: [
                        TileRegion(origin: Point(x: 0, y: 0), pixels: 3),
                        TileRegion(origin: Point(x: 4, y: 0), pixels: 2),
                    ]
                ),
                TilePayload(
                    bytes: [0xF8, 0, 0xF8, 0, 0xF8, 0, 0xF8, 0],
                    regions: [
                        TileRegion(origin: Point(x: 1, y: 1), pixels: 4)
                    ]
                ),
            ]
    )
    #expect(work.highWater.rasterBytes == 32)
    #expect(work.highWater.payloadBytes == 10)
    #expect(work.highWater.inFlightBytes == 10)
    #expect(work.highWater.payloads == 2)
    #expect(work.highWater.regionSubmissions == 3)
    #expect(work.highWater.tileVisits == 1)
    #expect(target.writer.storage.allSatisfy { $0 == 0 })
}

@Test
func tileEmitterOutputIsInvariantAcrossByteSegmentation() {
    var workspace = patternedWorkspace()
    var target = TileTarget(capacityBytes: 8, regionCapacity: 2)
    var work = tileWork(maximumPayloadBytes: 8)
    let result = RGB565TilePayloadEmitter.submit(
        &workspace,
        reservation: DisplayReservationID(rawValue: 11),
        target: &target,
        work: &work
    )
    #expect(
        result
            == .completed(
                TilePayloadEmissionSummary(
                    payloads: 3,
                    regions: 3,
                    bytes: 18,
                    responsibilityTransferred: true
                )
            )
    )
    #expect(target.payloads.map(\.bytes.count) == [6, 4, 8])
    #expect(
        target.payloads.flatMap(\.regions).map(\.origin) == [
            Point(x: 0, y: 0),
            Point(x: 4, y: 0),
            Point(x: 1, y: 1),
        ])
}

@Test
func tileEmitterSkipsEmptyWorkspaceAndRejectsOversizedRun() {
    var empty = makeTileWorkspace()!
    let tile = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 8, height: 2)!
    )!
    precondition(empty.beginTile(tile))
    var emptyTarget = TileTarget(capacityBytes: 8, regionCapacity: 2)
    var emptyWork = tileWork(maximumPayloadBytes: 8)
    let emptyResult = RGB565TilePayloadEmitter.submit(
        &empty,
        reservation: DisplayReservationID(rawValue: 11),
        target: &emptyTarget,
        work: &emptyWork
    )
    #expect(
        emptyResult
            == .completed(
                TilePayloadEmissionSummary(
                    payloads: 0,
                    regions: 0,
                    bytes: 0,
                    responsibilityTransferred: false
                )
            )
    )
    #expect(emptyTarget.payloads.isEmpty)

    var patterned = patternedWorkspace()
    var shortTarget = TileTarget(capacityBytes: 4, regionCapacity: 2)
    var shortWork = tileWork(maximumPayloadBytes: 4)
    let shortResult = RGB565TilePayloadEmitter.submit(
        &patterned,
        reservation: DisplayReservationID(rawValue: 11),
        target: &shortTarget,
        work: &shortWork
    )
    #expect(shortResult == .writerFailure)
    #expect(shortTarget.payloads.isEmpty)
    #expect(shortTarget.writer.storage.allSatisfy { $0 == 0 })
}
