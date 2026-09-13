import GiftUI
import GiftUICapabilities
import GiftUIRasterCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIBackendIntegration

struct TileStorage: RGB565TileStorage {
    private(set) var bytes: [UInt8]
    private(set) var affected: [Bool]
    private(set) var resetCount = 0

    var byteCapacity: UInt32 { UInt32(bytes.count) }
    var pixelCapacity: UInt32 { UInt32(affected.count) }

    init(byteCount: Int, pixelCount: Int) {
        bytes = [UInt8](repeating: 0xA5, count: byteCount)
        affected = [Bool](repeating: true, count: pixelCount)
    }

    mutating func reset(byteCount: UInt32, pixelCount: UInt32) -> Bool {
        guard Int(byteCount) <= bytes.count,
            Int(pixelCount) <= affected.count
        else { return false }
        resetCount += 1
        for index in 0 ..< Int(byteCount) {
            bytes[index] = 0
        }
        for index in 0 ..< Int(pixelCount) {
            affected[index] = false
        }
        return true
    }

    mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        byteOffset: UInt32,
        pixelIndex: UInt32
    ) -> Bool {
        guard Int(byteOffset) + 2 <= bytes.count,
            Int(pixelIndex) < affected.count
        else { return false }
        bytes[Int(byteOffset)] = mostSignificantByte
        bytes[Int(byteOffset) + 1] = leastSignificantByte
        affected[Int(pixelIndex)] = true
        return true
    }

    borrowing func isAffected(pixelIndex: UInt32) -> Bool {
        guard Int(pixelIndex) < affected.count else { return false }
        return affected[Int(pixelIndex)]
    }

    borrowing func byte(at offset: UInt32) -> UInt8? {
        guard Int(offset) < bytes.count else { return nil }
        return bytes[Int(offset)]
    }
}

private let tileBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 8, height: 5)!
)!

private let tileDescriptor = RasterSurfaceDescriptor(
    bounds: tileBounds,
    encoding: .rgb565BigEndian,
    bytesPerRow: 16,
    realization: .tiled,
    regionWidth: 8,
    regionHeight: 2
)!

func makeTileWorkspace(
    byteCount: Int = 32,
    pixelCount: Int = 16
) -> RGB565TileWorkspace<TileStorage>? {
    RGB565TileWorkspace(
        descriptor: tileDescriptor,
        storage: TileStorage(byteCount: byteCount, pixelCount: pixelCount)
    )
}

@Test
func operationMajorTraversalVisitsEachIntersectingTileExactlyOnce() {
    var workspace = makeTileWorkspace()!
    let clip = Rect(
        origin: Point(x: 1, y: 1),
        size: Size(width: 6, height: 4)!
    )!
    var rasterDamage: [Rect] = []
    var consumedTiles: [Rect] = []
    var storedBytes: [[UInt8]] = []
    var affectedPixels: [[Bool]] = []
    var operationCalls = 0

    operationCalls += 1
    let result = OperationMajorTileTraversal.visit(
        operationClip: clip,
        damageBounds: tileBounds,
        workspace: &workspace,
        { damage, replace in
            rasterDamage.append(damage)
            return replace(
                Point(x: 1, y: max(clip.minY, damage.minY)),
                CanonicalEncodedPixel(
                    color: Color(red: 255, green: 0, blue: 0),
                    encoding: .rgb565BigEndian
                )
            )
        },
        { borrowedWorkspace in
            consumedTiles.append(borrowedWorkspace.activeTile!)
            storedBytes.append(
                (0 ..< Int(borrowedWorkspace.storage.byteCapacity)).compactMap {
                    borrowedWorkspace.storage.byte(at: UInt32($0))
                }
            )
            affectedPixels.append(
                (0 ..< Int(borrowedWorkspace.storage.pixelCapacity)).map {
                    borrowedWorkspace.storage.isAffected(pixelIndex: UInt32($0))
                }
            )
            return true
        }
    )

    #expect(result == .completed(tileVisits: 3))
    #expect(operationCalls == 1)
    #expect(workspace.storage.resetCount == 3)
    #expect(workspace.activeTile == nil)
    #expect(consumedTiles.map(\.minY) == [0, 2, 4])
    #expect(consumedTiles.map(\.size.height) == [2, 2, 1])
    #expect(rasterDamage.map(\.minY) == [0, 2, 4])
    #expect(rasterDamage.map(\.size.height) == [2, 2, 1])
    #expect(storedBytes[0][18] == 0xF8 && storedBytes[0][19] == 0x00)
    #expect(storedBytes[1][2] == 0xF8 && storedBytes[1][3] == 0x00)
    #expect(storedBytes[2][2] == 0xF8 && storedBytes[2][3] == 0x00)
    #expect(affectedPixels[0][9])
    #expect(affectedPixels[1][1])
    #expect(affectedPixels[2][1])
}

@Test
func tileWorkspaceRejectsWrongShapeEncodingAndCapacity() {
    #expect(makeTileWorkspace(byteCount: 31) == nil)
    #expect(makeTileWorkspace(pixelCount: 15) == nil)

    let fullSurface = RasterSurfaceDescriptor(
        bounds: tileBounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 16,
        realization: .fullSurface,
        regionWidth: 8,
        regionHeight: 5
    )!
    #expect(
        RGB565TileWorkspace(
            descriptor: fullSurface,
            storage: TileStorage(byteCount: 80, pixelCount: 40)
        ) == nil
    )

    let rgba = RasterSurfaceDescriptor(
        bounds: tileBounds,
        encoding: .rgba8888,
        bytesPerRow: 32,
        realization: .tiled,
        regionWidth: 8,
        regionHeight: 2
    )!
    #expect(
        RGB565TileWorkspace(
            descriptor: rgba,
            storage: TileStorage(byteCount: 64, pixelCount: 16)
        ) == nil
    )
}

@Test
func traversalSkipsEmptyCoverageAndRestoresIdleAfterFailures() {
    var emptyWorkspace = makeTileWorkspace()!
    let emptyClip = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 0, height: 0)!
    )!
    var rasterCalls = 0
    var consumeCalls = 0
    let emptyResult = OperationMajorTileTraversal.visit(
        operationClip: emptyClip,
        damageBounds: tileBounds,
        workspace: &emptyWorkspace,
        { _, _ in
            rasterCalls += 1
            return true
        },
        { _ in
            consumeCalls += 1
            return true
        }
    )
    #expect(emptyResult == .completed(tileVisits: 0))
    #expect(rasterCalls == 0)
    #expect(consumeCalls == 0)
    #expect(emptyWorkspace.storage.resetCount == 0)

    var rasterFailureWorkspace = makeTileWorkspace()!
    let rasterFailure = OperationMajorTileTraversal.visit(
        operationClip: tileBounds,
        damageBounds: tileBounds,
        workspace: &rasterFailureWorkspace,
        { _, _ in false },
        { _ in true }
    )
    #expect(rasterFailure == .rasterFailure)
    #expect(rasterFailureWorkspace.activeTile == nil)
    #expect(rasterFailureWorkspace.storage.resetCount == 1)

    var consumeFailureWorkspace = makeTileWorkspace()!
    let consumeFailure = OperationMajorTileTraversal.visit(
        operationClip: tileBounds,
        damageBounds: tileBounds,
        workspace: &consumeFailureWorkspace,
        { _, _ in true },
        { _ in false }
    )
    #expect(consumeFailure == .consumeFailure)
    #expect(consumeFailureWorkspace.activeTile == nil)
    #expect(consumeFailureWorkspace.storage.resetCount == 1)
}

@Test
func tileWorkspaceRejectsInvalidUseWithoutMutation() {
    var workspace = makeTileWorkspace()!
    let pixel = CanonicalEncodedPixel(
        color: Color(red: 1, green: 2, blue: 3),
        encoding: .rgb565BigEndian
    )
    let inactiveReplace = workspace.replacePixel(
        at: Point(x: 0, y: 0),
        with: pixel
    )
    #expect(!inactiveReplace)

    let shortTile = Rect(
        origin: Point(x: 0, y: 4),
        size: Size(width: 8, height: 1)!
    )!
    let began = workspace.beginTile(shortTile)
    let doubleBegin = workspace.beginTile(shortTile)
    let outsideReplace = workspace.replacePixel(
        at: Point(x: 0, y: 3),
        with: pixel
    )
    let insideReplace = workspace.replacePixel(
        at: Point(x: 7, y: 4),
        with: pixel
    )
    let finished = workspace.finishTile()
    let doubleFinish = workspace.finishTile()
    #expect(began)
    #expect(!doubleBegin)
    #expect(!outsideReplace)
    #expect(insideReplace)
    #expect(finished)
    #expect(!doubleFinish)
}
