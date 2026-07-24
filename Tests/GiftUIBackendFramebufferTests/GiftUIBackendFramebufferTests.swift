import Testing
import GiftUI
@testable import GiftUIBackendFramebuffer

@Test
func clearWritesRGBABytes() {
    let surface = MemoryFramebufferSurface(width: 2, height: 1)
    var backend = FramebufferBackend(surface: surface)

    backend.clear(Color(red: 10, green: 20, blue: 30, alpha: 40))

    let pixels = backend.surface.withUnsafeBytes { Array($0) }
    #expect(pixels == [10, 20, 30, 40, 10, 20, 30, 40])
}

@Test
func fillAndStrokeClipToSurfaceBounds() {
    let surface = MemoryFramebufferSurface(width: 4, height: 4)
    var backend = FramebufferBackend(surface: surface)

    backend.fill(
        Rect(
            origin: Point(x: -2, y: -2),
            size: Size(width: 4, height: 4)
        ),
        color: Color(red: 10, green: 20, blue: 30)
    )
    backend.stroke(
        Rect(
            origin: Point(x: 2, y: 2),
            size: Size(width: 4, height: 4)
        ),
        color: Color(red: 40, green: 50, blue: 60),
        lineWidth: 1
    )

    #expect(pixel(in: backend.surface, x: 0, y: 0) == [10, 20, 30, 255])
    #expect(pixel(in: backend.surface, x: 1, y: 1) == [10, 20, 30, 255])
    #expect(pixel(in: backend.surface, x: 2, y: 2) == [40, 50, 60, 255])
    #expect(pixel(in: backend.surface, x: 3, y: 3) == [0, 0, 0, 0])
}

@Test
func bitmapFontRendersTextAndDegreeSymbol() {
    let surface = MemoryFramebufferSurface(width: 32, height: 12)
    var backend = FramebufferBackend(surface: surface)

    backend.drawText(
        TextRun("A1°", color: Color(red: 7, green: 8, blue: 9)),
        at: Point(x: 0, y: 0)
    )

    let coloredPixelCount = backend.surface.withUnsafeBytes { bytes in
        stride(from: 0, to: bytes.count, by: 4).count { offset in
            bytes[offset] == 7
                && bytes[offset + 1] == 8
                && bytes[offset + 2] == 9
                && bytes[offset + 3] == 255
        }
    }
    #expect(coloredPixelCount > 20)
    #expect(
        pixels(in: backend.surface, rect: Rect(
            origin: Point(x: 16, y: 0),
            size: Size(width: 8, height: 12)
        )).contains(7)
    )
}

@Test
func unsupportedGlyphUsesDeterministicFallbackAndClips() {
    var first = FramebufferBackend(
        surface: MemoryFramebufferSurface(width: 8, height: 12)
    )
    var second = FramebufferBackend(
        surface: MemoryFramebufferSurface(width: 8, height: 12)
    )
    first.drawText(TextRun("🙂"), at: Point(x: 0, y: 0))
    second.drawText(TextRun("♞"), at: Point(x: 0, y: 0))

    #expect(
        first.surface.withUnsafeBytes { Array($0) }
            == second.surface.withUnsafeBytes { Array($0) }
    )

    var clipped = FramebufferBackend(
        surface: MemoryFramebufferSurface(width: 3, height: 3)
    )
    clipped.drawText(TextRun("A"), at: Point(x: -3, y: -2))
    #expect(clipped.surface.withUnsafeBytes { Array($0) }.contains(255))
}

private func pixel(
    in surface: MemoryFramebufferSurface,
    x: Int,
    y: Int
) -> [UInt8] {
    surface.withUnsafeBytes { bytes in
        let offset = y * surface.bytesPerRow + x * 4
        return Array(bytes[offset..<(offset + 4)])
    }
}

private func pixels(
    in surface: MemoryFramebufferSurface,
    rect: Rect
) -> [UInt8] {
    surface.withUnsafeBytes { bytes in
        var result: [UInt8] = []
        for y in rect.origin.y..<(rect.origin.y + rect.size.height) {
            let start = y * surface.bytesPerRow + rect.origin.x * 4
            let end = start + rect.size.width * 4
            result.append(contentsOf: bytes[start..<end])
        }
        return result
    }
}
