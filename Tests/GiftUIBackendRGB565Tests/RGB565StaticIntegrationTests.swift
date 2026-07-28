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
        tileHeight: 16
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
    #expect(presentedTileCount == 20)
    #expect(largestPresentedTile == 15_360)
    #expect(renderer.allocatedByteCapacity == 15_360)
    #expect(rgb565Hash(actual) == 2_896_050_032_511_834_899)
}

private struct FramebufferSink: RenderOperationSink {
    var backend: FramebufferBackend

    mutating func append(_ operation: RenderOperation) {
        backend.execute(operation)
    }
}

private func rgb565Hash(_ pixels: [UInt16]) -> UInt64 {
    pixels.reduce(14_695_981_039_346_656_037) { hash, pixel in
        var hash = (hash ^ UInt64(pixel >> 8)) &* 1_099_511_628_211
        hash = (hash ^ UInt64(pixel & 0xff)) &* 1_099_511_628_211
        return hash
    }
}
