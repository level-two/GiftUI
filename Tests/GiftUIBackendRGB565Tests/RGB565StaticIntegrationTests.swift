import Testing
import GiftUI
import GiftUIBackendFramebuffer
@testable import GiftUIBackendRGB565
import GiftUIExampleThermostatPortableView
import GiftUIRuntimeStatic

@Test
func staticThermostatMatchesQuantizedRGBAFramebuffer() throws {
    let width = 480
    let height = 320
    let background = Color(red: 24, green: 26, blue: 32)
    let layout = try StaticRuntime().layout(
        ThermostatPortableView(target: 21),
        in: Size(width: width, height: height)
    )

    var rgbaSink = FramebufferSink(
        backend: FramebufferBackend(
            surface: MemoryFramebufferSurface(width: width, height: height)
        )
    )
    rgbaSink.backend.clear(background)
    layout.appendRenderOperations(to: &rgbaSink)
    let expected = rgbaSink.backend.surface.withUnsafeBytes { bytes in
        stride(from: 0, to: bytes.count, by: 4).map { offset in
            RGB565Pixel(
                Color(
                    red: bytes[offset],
                    green: bytes[offset + 1],
                    blue: bytes[offset + 2],
                    alpha: bytes[offset + 3]
                )
            ).rawValue
        }
    }

    let configuration = try RGB565RendererConfiguration(
        physicalWidth: width,
        physicalHeight: height,
        tileHeight: 4
    )
    var renderer = RGB565TileRenderer(configuration: configuration)
    var actual: [UInt16] = []
    var presentedTileCount = 0
    var largestPresentedTile = 0

    renderer.renderTiles { tileBackend in
        tileBackend.clear(background)
        layout.appendRenderOperations(to: &tileBackend)
    } presenting: { tile, bytes in
        presentedTileCount += 1
        largestPresentedTile = max(largestPresentedTile, bytes.count)
        #expect(bytes.count == tile.byteCount)
        for offset in stride(from: 0, to: bytes.count, by: 2) {
            actual.append(UInt16(bytes[offset]) << 8 | UInt16(bytes[offset + 1]))
        }
    }

    #expect(actual == expected)
    #expect(presentedTileCount == 80)
    #expect(largestPresentedTile == 3_840)
    #expect(renderer.allocatedByteCapacity == 3_840)
    #expect(rgb565Hash(actual) == 2_896_050_032_511_834_899)
}

@Test
func retainedThermostatUpdateMatchesFullRerenderWithNarrowDamage() throws {
    let width = 480
    let height = 320
    let background = Color(red: 24, green: 26, blue: 32)
    let runtime = StaticRuntime()
    let oldLayout = try runtime.layout(
        ThermostatPortableView(target: 21),
        in: Size(width: width, height: height)
    )
    let newLayout = try runtime.layout(
        ThermostatPortableView(target: 22),
        in: Size(width: width, height: height)
    )
    let configuration = try RGB565RendererConfiguration(
        physicalWidth: width,
        physicalHeight: height,
        tileHeight: 4
    )
    let oldPixels = render(
        oldLayout,
        background: background,
        configuration: configuration
    )
    let expected = render(
        newLayout,
        background: background,
        configuration: configuration
    )
    let dirtyRegion = try #require(
        newLayout.changedRenderBounds(comparedTo: oldLayout)
    )
    var retained = RGB565RetainedRenderer(
        configuration: configuration,
        clipRegion: dirtyRegion,
        writer: RetainedFramebufferWriter(
            width: width,
            pixels: oldPixels
        )
    )

    retained.clear(background)
    newLayout.appendRenderOperations(to: &retained)

    #expect(dirtyRegion.size == Size(width: 24, height: 12))
    #expect(retained.writer.pixels == expected)
    #expect(retained.writer.pixelWriteCount == 324)
    #expect(retained.writer.rectangleWriteCount == 23)
}

private struct FramebufferSink: RenderOperationSink {
    var backend: FramebufferBackend

    mutating func append(_ operation: RenderOperation) {
        backend.execute(operation)
    }
}

private struct RetainedFramebufferWriter: RGB565SolidRectWriter {
    let width: Int
    var pixels: [UInt16]
    var pixelWriteCount = 0
    var rectangleWriteCount = 0

    mutating func writeSolidRect(_ rect: Rect, pixel: RGB565Pixel) {
        rectangleWriteCount += 1
        pixelWriteCount += rect.size.width * rect.size.height
        for y in rect.origin.y..<(rect.origin.y + rect.size.height) {
            for x in rect.origin.x..<(rect.origin.x + rect.size.width) {
                pixels[y * width + x] = pixel.rawValue
            }
        }
    }
}

private func render(
    _ layout: StaticLayout,
    background: Color,
    configuration: RGB565RendererConfiguration
) -> [UInt16] {
    var renderer = RGB565TileRenderer(configuration: configuration)
    var pixels = [UInt16](
        repeating: 0,
        count: configuration.physicalWidth * configuration.physicalHeight
    )
    renderer.renderTiles { backend in
        backend.clear(background)
        layout.appendRenderOperations(to: &backend)
    } presenting: { tile, bytes in
        for tileY in 0..<tile.height {
            for x in 0..<tile.width {
                let byteOffset = tileY * tile.bytesPerRow + x * 2
                pixels[
                    (tile.physicalY + tileY) * configuration.physicalWidth
                        + tile.physicalX + x
                ] = UInt16(bytes[byteOffset]) << 8
                    | UInt16(bytes[byteOffset + 1])
            }
        }
    }
    return pixels
}

private func rgb565Hash(_ pixels: [UInt16]) -> UInt64 {
    pixels.reduce(14_695_981_039_346_656_037) { hash, pixel in
        var hash = (hash ^ UInt64(pixel >> 8)) &* 1_099_511_628_211
        hash = (hash ^ UInt64(pixel & 0xff)) &* 1_099_511_628_211
        return hash
    }
}
