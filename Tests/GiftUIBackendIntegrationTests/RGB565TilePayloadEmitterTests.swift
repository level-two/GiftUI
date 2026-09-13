import Foundation
import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources
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

private struct ParsedStrokeOperation {
    let symbol: Character
    let color: Color
    let lineWidth: Int32
    let cap: LineCap
    let join: LineJoin
    let surfaceOrigin: Point
    let clip: Rect
    let points: [Point]
    let subpaths: [SubpathRange]
}

private struct ParsedStrokeVector {
    let name: String
    let width: Int32
    let height: Int32
    let operations: [ParsedStrokeOperation]
    let expectedMask: [String]
}

private struct ParsedStroke: StraightLineStrokeView {
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]

    func point(at index: UInt16) -> Point? {
        guard index < points.count else { return nil }
        return points[Int(index)]
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        guard index < subpaths.count else { return nil }
        return subpaths[Int(index)]
    }
}

@Test
func everyCanonicalStrokeMatchesTiledRGB565AcrossPartialTiles() throws {
    for fixture in try loadSPEC012StrokeVectors() {
        let bounds = Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: fixture.width, height: fixture.height)!
        )!
        let rowBytes = UInt32(fixture.width) * 2
        let tileHeight = UInt16(min(2, fixture.height))
        let descriptor = RasterSurfaceDescriptor(
            bounds: bounds,
            encoding: .rgb565BigEndian,
            bytesPerRow: rowBytes,
            realization: .tiled,
            regionWidth: UInt16(fixture.width),
            regionHeight: tileHeight
        )!
        var workspace = RGB565TileWorkspace(
            descriptor: descriptor,
            storage: TileStorage(
                byteCount: Int(rowBytes) * Int(tileHeight),
                pixelCount: Int(fixture.width) * Int(tileHeight)
            )
        )!
        var target = TileTarget(capacityBytes: rowBytes, regionCapacity: 2)
        let maximumVisits =
            UInt32(fixture.operations.count)
            * UInt32((fixture.height + Int32(tileHeight) - 1) / Int32(tileHeight))
        var work = RasterWorkTracker(
            limits: RasterPayloadLimits(
                maximumRasterBytes: rowBytes * UInt32(tileHeight),
                maximumPayloadBytes: rowBytes,
                maximumRegionsPerPayload: 2,
                maximumRegionSubmissionsPerFrame: UInt32(fixture.width)
                    * UInt32(fixture.height)
                    * UInt32(fixture.operations.count),
                maximumTileVisitsPerFrame: max(1, maximumVisits),
                maximumInFlightPayloads: 1,
                maximumGlyphRasterBytes: 1,
                maximumStrokeWorkspaceBytes: 1
            )!
        )

        for operation in fixture.operations {
            let stroke = ParsedStroke(
                header: StraightLineStrokeHeader(
                    color: operation.color,
                    lineWidth: operation.lineWidth,
                    lineCap: operation.cap,
                    lineJoin: operation.join,
                    surfaceOrigin: operation.surfaceOrigin,
                    inheritedClip: operation.clip,
                    pointCount: UInt16(operation.points.count),
                    subpathCount: UInt16(operation.subpaths.count)
                ),
                points: operation.points,
                subpaths: operation.subpaths
            )
            let traversal = OperationMajorTileTraversal.visit(
                operationClip: operation.clip,
                damageBounds: bounds,
                workspace: &workspace,
                { tileDamage, replace in
                    if case .completed = RasterStrokeCoverage.rasterize(
                        stroke,
                        descriptor: descriptor,
                        damageBounds: tileDamage,
                        replace
                    ) {
                        return true
                    }
                    return false
                },
                { activeWorkspace in
                    if case .completed = RGB565TilePayloadEmitter.submit(
                        &activeWorkspace,
                        reservation: DisplayReservationID(rawValue: 11),
                        target: &target,
                        work: &work
                    ) {
                        return true
                    }
                    return false
                }
            )
            guard case .completed = traversal else {
                Issue.record("\(fixture.name): unexpected \(traversal)")
                continue
            }
        }

        var actual = [UInt8](
            repeating: 0xA5,
            count: Int(rowBytes) * Int(fixture.height)
        )
        apply(target.payloads, rowBytes: rowBytes, to: &actual)
        var palette: [Character: [UInt8]] = [:]
        for operation in fixture.operations {
            let pixel = CanonicalEncodedPixel(
                color: operation.color,
                encoding: .rgb565BigEndian
            )
            palette[operation.symbol] = [pixel.byte0, pixel.byte1]
        }
        var expected = [UInt8](
            repeating: 0xA5,
            count: Int(rowBytes) * Int(fixture.height)
        )
        for (y, row) in fixture.expectedMask.enumerated() {
            for (x, symbol) in row.enumerated() where symbol != "." {
                let bytes = palette[symbol]!
                expected[y * Int(rowBytes) + x * 2] = bytes[0]
                expected[y * Int(rowBytes) + x * 2 + 1] = bytes[1]
            }
        }
        #expect(actual == expected, Comment(rawValue: fixture.name))
    }
}

private func apply(
    _ payloads: [TilePayload],
    rowBytes: UInt32,
    to image: inout [UInt8]
) {
    for payload in payloads {
        var byteIndex = 0
        for region in payload.regions {
            let destination =
                Int(region.origin.y) * Int(rowBytes)
                + Int(region.origin.x) * 2
            let count = Int(region.pixels) * 2
            for offset in 0 ..< count {
                image[destination + offset] = payload.bytes[byteIndex + offset]
            }
            byteIndex += count
        }
    }
}

private func loadSPEC012StrokeVectors() throws -> [ParsedStrokeVector] {
    let tests = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let path =
        tests
        .appendingPathComponent("ContractFixtures/SPEC012/raster-vectors.yaml")
        .path
    let source = try String(contentsOfFile: path, encoding: .utf8)
    return try source.components(separatedBy: "\n  - name: ").dropFirst().map {
        try parseStrokeVector(String($0))
    }
}

private func parseStrokeVector(_ block: String) throws -> ParsedStrokeVector {
    let lines = block.components(separatedBy: .newlines)
    let name = lines[0].trimmingCharacters(in: .whitespaces)
    let surface = try integerArray(field: "surface", in: block)
    guard surface.count == 4 else { throw StrokeFixtureError.malformed(name) }
    let operationSection = try section(
        after: "    operations:",
        before: "    palette:",
        in: block
    )
    let operationObjects = braceObjects(in: operationSection)
    let surfaceOrigin = Point(x: Int32(-surface[0]), y: Int32(-surface[1]))
    let operations = try operationObjects.map {
        try parseStrokeOperation($0, surfaceOrigin: surfaceOrigin)
    }
    let maskText = try lineValue(field: "expectedMask", in: block)
    let expectedMask = quotedStrings(in: maskText)
    return ParsedStrokeVector(
        name: name,
        width: Int32(surface[2]),
        height: Int32(surface[3]),
        operations: operations,
        expectedMask: expectedMask
    )
}

private func parseStrokeOperation(
    _ object: String,
    surfaceOrigin: Point
) throws
    -> ParsedStrokeOperation
{
    let symbolText = try scalar(field: "symbol", in: object)
    let color = try integerArray(field: "color", in: object)
    let width = try integerScalar(field: "lineWidth", in: object)
    let cap = try scalar(field: "cap", in: object)
    let join = try scalar(field: "join", in: object)
    let clip = try integerArray(field: "clip", in: object)
    let points = try integerArray(field: "points", in: object)
    let subpaths = try integerArray(field: "subpaths", in: object)
    guard let symbol = symbolText.first,
        color.count == 3,
        clip.count == 4,
        points.count.isMultiple(of: 2),
        subpaths.count.isMultiple(of: 2),
        let clipSize = Size(width: Int32(clip[2] - clip[0]), height: Int32(clip[3] - clip[1])),
        let clipRect = Rect(
            origin: Point(
                x: Int32(clip[0]) + surfaceOrigin.x,
                y: Int32(clip[1]) + surfaceOrigin.y
            ),
            size: clipSize
        )
    else { throw StrokeFixtureError.malformed(object) }
    return ParsedStrokeOperation(
        symbol: symbol,
        color: Color(
            red: UInt8(color[0]),
            green: UInt8(color[1]),
            blue: UInt8(color[2])
        ),
        lineWidth: Int32(width),
        cap: cap == "round" ? .round : .butt,
        join: join == "round" ? .round : .miter,
        surfaceOrigin: surfaceOrigin,
        clip: clipRect,
        points: stride(from: 0, to: points.count, by: 2).map {
            Point(x: Int32(points[$0]), y: Int32(points[$0 + 1]))
        },
        subpaths: try stride(from: 0, to: subpaths.count, by: 2).map {
            guard
                let range = SubpathRange(
                    firstPoint: UInt16(subpaths[$0]),
                    pointCount: UInt16(subpaths[$0 + 1])
                )
            else { throw StrokeFixtureError.malformed(object) }
            return range
        }
    )
}

private enum StrokeFixtureError: Error {
    case malformed(String)
}

private func section(after start: String, before end: String, in text: String) throws
    -> String
{
    guard let startRange = text.range(of: start),
        let endRange = text.range(of: end, range: startRange.upperBound ..< text.endIndex)
    else { throw StrokeFixtureError.malformed(text) }
    return String(text[startRange.upperBound ..< endRange.lowerBound])
}

private func lineValue(field: String, in text: String) throws -> String {
    guard
        let line = text.components(separatedBy: .newlines).first(where: {
            $0.trimmingCharacters(in: .whitespaces).hasPrefix("\(field):")
        }), let colon = line.firstIndex(of: ":")
    else { throw StrokeFixtureError.malformed(field) }
    return String(line[line.index(after: colon)...])
}

private func scalar(field: String, in text: String) throws -> String {
    guard let fieldRange = text.range(of: "\(field):") else {
        throw StrokeFixtureError.malformed(field)
    }
    let suffix = text[fieldRange.upperBound...]
    let end =
        suffix.firstIndex(where: { $0 == "," || $0 == "}" })
        ?? suffix.endIndex
    return suffix[..<end].trimmingCharacters(in: .whitespacesAndNewlines)
}

private func integerScalar(field: String, in text: String) throws -> Int {
    guard let value = Int(try scalar(field: field, in: text)) else {
        throw StrokeFixtureError.malformed(field)
    }
    return value
}

private func integerArray(field: String, in text: String) throws -> [Int] {
    guard let fieldRange = text.range(of: "\(field):"),
        let start = text[fieldRange.upperBound...].firstIndex(of: "[")
    else { throw StrokeFixtureError.malformed(field) }
    var depth = 0
    var end: String.Index?
    var index = start
    while index < text.endIndex {
        if text[index] == "[" { depth += 1 }
        if text[index] == "]" {
            depth -= 1
            if depth == 0 {
                end = index
                break
            }
        }
        index = text.index(after: index)
    }
    guard let end else { throw StrokeFixtureError.malformed(field) }
    return text[start ... end].split {
        !$0.isNumber && $0 != "-"
    }.compactMap { Int($0) }
}

private func braceObjects(in text: String) -> [String] {
    var objects: [String] = []
    var depth = 0
    var start: String.Index?
    var index = text.startIndex
    while index < text.endIndex {
        if text[index] == "{" {
            if depth == 0 { start = index }
            depth += 1
        } else if text[index] == "}" {
            depth -= 1
            if depth == 0, let start {
                objects.append(String(text[start ... index]))
            }
        }
        index = text.index(after: index)
    }
    return objects
}

private func quotedStrings(in text: String) -> [String] {
    var strings: [String] = []
    var start: String.Index?
    var index = text.startIndex
    while index < text.endIndex {
        if text[index] == "\"" {
            if let currentStart = start {
                strings.append(String(text[currentStart ..< index]))
                start = nil
            } else {
                start = text.index(after: index)
            }
        }
        index = text.index(after: index)
    }
    return strings
}

private let tiledGlyphDigest = TextResourceDigest(
    word0: 1,
    word1: 2,
    word2: 3,
    word3: 4,
    word4: 5,
    word5: 6,
    word6: 7,
    word7: 8
)
private let tiledGlyphResource = FontResourceID(rawValue: tiledGlyphDigest)
private let tiledGlyphInstance = FontInstanceID(
    resource: tiledGlyphResource,
    instanceIndex: 0
)
private let tiledGlyphDescriptor = TextResourceDescriptor(
    schemaVersion: 1,
    resource: tiledGlyphResource,
    instanceCount: 1,
    realizationCount: 1,
    canonicalManifestByteCount: 1
)
private let tiledGlyphRecord = GlyphRasterRecord(
    glyph: GlyphID(rawValue: 0),
    offset: 0,
    byteCount: 3,
    rowByteCount: 1,
    pixelWidth: 3,
    pixelHeight: 3
)
private let tiledGlyphRealization = RasterRealizationDescriptor(
    id: RasterRealizationID(rawValue: 0),
    instance: tiledGlyphInstance,
    kind: .monochromeBitmap1,
    glyphCount: 1,
    payloadByteCount: 3,
    payloadDigest: tiledGlyphDigest
)

private struct TiledGlyphMetrics: CanonicalTextMetricsView {
    let descriptor = tiledGlyphDescriptor

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
    ) -> GlyphMetrics? {
        guard glyph == tiledGlyphRecord.glyph,
            instance == tiledGlyphInstance
        else { return nil }
        return GlyphMetrics(
            advanceX: 4,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 3, height: 3)!
        )
    }
}

private struct TiledGlyphRaster: TextRasterResourceView {
    let descriptor = tiledGlyphDescriptor

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 ? tiledGlyphRealization : nil
    }
    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        glyph == tiledGlyphRecord.glyph && realization.rawValue == 0
            ? tiledGlyphRecord : nil
    }
    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization.rawValue == 0
    }
    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard record == tiledGlyphRecord, realization.rawValue == 0 else {
            return nil
        }
        let bytes: [UInt8] = [0xA0, 0x40, 0xE0]
        return try bytes.withUnsafeBytes(body)
    }
}

private struct TiledComparisonStorage: FullSurfaceRGB565Storage {
    private(set) var bytes: [UInt8]
    var capacityBytes: UInt32 { UInt32(bytes.count) }

    init(count: Int) {
        bytes = [UInt8](repeating: 0xA5, count: count)
    }
    mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        at offset: UInt32
    ) -> Bool {
        guard Int(offset) + 2 <= bytes.count else { return false }
        bytes[Int(offset)] = mostSignificantByte
        bytes[Int(offset) + 1] = leastSignificantByte
        return true
    }
    borrowing func withBytes<Result>(
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        try bytes.withUnsafeBytes(body)
    }
}

@Test
func tiledFillAndExactGlyphMatchFullSurfaceWithPainterOverwrite() {
    let bounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 8, height: 5)!
    )!
    let tiledDescriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 16,
        realization: .tiled,
        regionWidth: 8,
        regionHeight: 2
    )!
    let fullDescriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 16,
        realization: .fullSurface,
        regionWidth: 8,
        regionHeight: 5
    )!
    let fill = FillRectOperation(
        bounds: Rect(
            origin: Point(x: 1, y: 1),
            size: Size(width: 6, height: 4)!
        )!,
        clip: bounds,
        color: .red
    )
    let glyphOperation = PositionedGlyphOperationHeader(
        instance: tiledGlyphInstance,
        clip: Rect(
            origin: Point(x: 2, y: 1),
            size: Size(width: 3, height: 3)!
        )!,
        color: .blue,
        glyphCount: 1
    )
    let glyph = PositionedGlyph(
        glyph: GlyphID(rawValue: 0),
        baseline: Point(x: 2, y: 1)
    )

    var workspace = RGB565TileWorkspace(
        descriptor: tiledDescriptor,
        storage: TileStorage(byteCount: 32, pixelCount: 16)
    )!
    var target = TileTarget(capacityBytes: 16, regionCapacity: 2)
    var work = RasterWorkTracker(
        limits: RasterPayloadLimits(
            maximumRasterBytes: 32,
            maximumPayloadBytes: 16,
            maximumRegionsPerPayload: 2,
            maximumRegionSubmissionsPerFrame: 40,
            maximumTileVisitsPerFrame: 6,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 3,
            maximumStrokeWorkspaceBytes: 1
        )!
    )
    let fillTraversal = OperationMajorTileTraversal.visit(
        operationClip: fill.clip,
        damageBounds: bounds,
        workspace: &workspace,
        { damage, replace in
            if case .completed = RasterFillCoverage.rasterize(
                fill,
                descriptor: tiledDescriptor,
                damageBounds: damage,
                replace
            ) {
                return true
            }
            return false
        },
        { tile in
            if case .completed = RGB565TilePayloadEmitter.submit(
                &tile,
                reservation: DisplayReservationID(rawValue: 11),
                target: &target,
                work: &work
            ) {
                return true
            }
            return false
        }
    )
    let glyphTraversal = OperationMajorTileTraversal.visit(
        operationClip: glyphOperation.clip,
        damageBounds: bounds,
        workspace: &workspace,
        { damage, replace in
            if case .completed = RasterGlyphCoverage.rasterize(
                glyph,
                operation: glyphOperation,
                metrics: TiledGlyphMetrics(),
                raster: TiledGlyphRaster(),
                realization: tiledGlyphRealization,
                descriptor: tiledDescriptor,
                damageBounds: damage,
                replace
            ) {
                return true
            }
            return false
        },
        { tile in
            if case .completed = RGB565TilePayloadEmitter.submit(
                &tile,
                reservation: DisplayReservationID(rawValue: 11),
                target: &target,
                work: &work
            ) {
                return true
            }
            return false
        }
    )
    #expect(fillTraversal == .completed(tileVisits: 3))
    #expect(glyphTraversal == .completed(tileVisits: 2))

    var tiledBytes = [UInt8](repeating: 0xA5, count: 80)
    apply(target.payloads, rowBytes: 16, to: &tiledBytes)

    var full = FullSurfaceRGB565Framebuffer(
        descriptor: fullDescriptor,
        storage: TiledComparisonStorage(count: 80),
        workspaceBytes: 0
    )!
    let header = RenderPlanHeader(
        surfaceBounds: bounds,
        damageBounds: bounds,
        operationCount: 2,
        positionedGlyphCount: 1,
        maximumObservedClipDepth: 1
    )
    let fullBegan = full.beginFrame(header)
    #expect(fullBegan)
    let fullFill = RasterFillCoverage.rasterize(
        fill,
        descriptor: fullDescriptor,
        damageBounds: bounds
    ) { full.replacePixel(at: $0, with: $1) }
    let fullGlyph = RasterGlyphCoverage.rasterize(
        glyph,
        operation: glyphOperation,
        metrics: TiledGlyphMetrics(),
        raster: TiledGlyphRaster(),
        realization: tiledGlyphRealization,
        descriptor: fullDescriptor,
        damageBounds: bounds
    ) { full.replacePixel(at: $0, with: $1) }
    #expect(fullFill == .completed(pixelCount: 24))
    #expect(fullGlyph == .completed(pixelCount: 6, payloadBytes: 3))
    let fullFinished = full.finishFrame()
    #expect(fullFinished)
    let fullBytes = full.withBytes { Array($0) }
    #expect(tiledBytes == fullBytes)
}
