import Testing
import GiftUI
@testable import GiftUIBackendRGB565

@Test
func rendererPresentsConsecutiveBoundedTiles() throws {
    let configuration = try RGB565RendererConfiguration(
        physicalWidth: 5,
        physicalHeight: 5,
        tileHeight: 2
    )
    var renderer = RGB565TileRenderer(configuration: configuration)
    var tiles: [RGB565Tile] = []
    var byteCounts: [Int] = []

    renderer.renderTiles { backend in
        backend.clear(.white)
    } presenting: { tile, bytes in
        tiles.append(tile)
        byteCounts.append(bytes.count)
        #expect(bytes.allSatisfy { $0 == 0xff })
    }

    #expect(tiles.map(\.physicalY) == [0, 2, 4])
    #expect(tiles.map(\.height) == [2, 2, 1])
    #expect(byteCounts == [20, 20, 10])
    #expect(renderer.allocatedByteCapacity == 20)
}

@Test
func rendererWritesConfiguredByteOrder() throws {
    let configuration = try RGB565RendererConfiguration(
        physicalWidth: 1,
        physicalHeight: 1,
        tileHeight: 1,
        byteOrder: .leastSignificantByteFirst
    )
    var renderer = RGB565TileRenderer(configuration: configuration)
    var presented: [UInt8] = []

    renderer.renderTiles { backend in
        backend.clear(Color(red: 255, green: 0, blue: 0))
    } presenting: { _, bytes in
        presented.append(contentsOf: bytes)
    }

    #expect(presented == [0x00, 0xf8])
}

@Test
func fillClipsOddRectangleAcrossTileBoundaries() throws {
    let pixels = try renderPhysicalPixels(width: 5, height: 3, tileHeight: 2) { backend in
        backend.clear(.black)
        backend.fill(
            Rect(
                origin: Point(x: -1, y: 1),
                size: Size(width: 3, height: 3)
            ),
            color: Color(red: 255, green: 0, blue: 0)
        )
    }

    for y in 0..<3 {
        for x in 0..<5 {
            let expected: UInt16 = y >= 1 && x < 2 ? 0xf800 : 0x0000
            #expect(pixels[y * 5 + x] == expected)
        }
    }
}

@Test
func strokeHandlesOddDimensions() throws {
    let pixels = try renderPhysicalPixels(width: 5, height: 3, tileHeight: 2) { backend in
        backend.clear(.black)
        backend.stroke(
            Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 5, height: 3)
            ),
            color: .white,
            lineWidth: 1
        )
    }

    for y in 0..<3 {
        for x in 0..<5 {
            let expected: UInt16 = x == 0 || x == 4 || y == 0 || y == 2
                ? 0xffff
                : 0x0000
            #expect(pixels[y * 5 + x] == expected)
        }
    }
}

@Test(arguments: [
    (RGB565Rotation.degrees0, 0),
    (RGB565Rotation.degrees90, 2),
    (RGB565Rotation.degrees180, 5),
    (RGB565Rotation.degrees270, 3),
])
func rotationMapsLogicalOriginToExpectedPhysicalCorner(
    rotation: RGB565Rotation,
    expectedPixelIndex: Int
) throws {
    let pixels = try renderPhysicalPixels(
        width: 3,
        height: 2,
        tileHeight: 1,
        rotation: rotation
    ) { backend in
        backend.clear(.black)
        backend.fill(
            Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 1, height: 1)
            ),
            color: .white
        )
    }

    #expect(pixels.enumerated().filter { $0.element == 0xffff }.map(\.offset) == [expectedPixelIndex])
}

@Test
func laterOperationsReplaceEarlierPixels() throws {
    let pixels = try renderPhysicalPixels(width: 3, height: 1, tileHeight: 1) { backend in
        backend.clear(.black)
        backend.fill(
            Rect(origin: Point(x: 0, y: 0), size: Size(width: 3, height: 1)),
            color: Color(red: 255, green: 0, blue: 0)
        )
        backend.fill(
            Rect(origin: Point(x: 1, y: 0), size: Size(width: 1, height: 1)),
            color: Color(red: 0, green: 255, blue: 0)
        )
    }

    #expect(pixels == [0xf800, 0x07e0, 0xf800])
}

@Test
func textRendersASCIIBoundedIntegerAndDegreeGlyphs() throws {
    let pixels = try renderPhysicalPixels(width: 32, height: 12, tileHeight: 5) { backend in
        backend.clear(.black)
        backend.drawText(
            TextRun(integer: -1, suffix: "°", color: .white),
            at: Point(x: 0, y: 0)
        )
    }

    let litCount = pixels.count { $0 == 0xffff }
    #expect(litCount > 20)
    #expect(pixels[16..<(24 * 12)].contains(0xffff))
}

private func renderPhysicalPixels(
    width: Int,
    height: Int,
    tileHeight: Int,
    rotation: RGB565Rotation = .degrees0,
    draw: (inout RGB565TileRenderer) -> Void
) throws -> [UInt16] {
    let configuration = try RGB565RendererConfiguration(
        physicalWidth: width,
        physicalHeight: height,
        tileHeight: tileHeight,
        rotation: rotation
    )
    var renderer = RGB565TileRenderer(configuration: configuration)
    var result = [UInt16](repeating: 0, count: width * height)

    renderer.renderTiles(drawing: draw) { tile, bytes in
        for tileY in 0..<tile.height {
            for x in 0..<tile.width {
                let byteOffset = tileY * tile.bytesPerRow + x * 2
                result[(tile.physicalY + tileY) * width + x] =
                    UInt16(bytes[byteOffset]) << 8 | UInt16(bytes[byteOffset + 1])
            }
        }
    }
    return result
}
