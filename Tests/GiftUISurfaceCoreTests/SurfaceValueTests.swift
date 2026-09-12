import GiftUI
import GiftUICapabilities
import Testing

@testable import GiftUISurfaceCore

private func bounds(
    width: GeometryScalar,
    height: GeometryScalar,
    origin: Point = Point(x: 0, y: 0)
) -> Rect {
    Rect(origin: origin, size: Size(width: width, height: height)!)!
}

@Test
func canonicalEncodedPixelUsesExactOpaqueEncodings() {
    let color = Color(red: 128, green: 127, blue: 1)
    let rgba = CanonicalEncodedPixel(color: color, encoding: .rgba8888)
    let rgb565 = CanonicalEncodedPixel(color: color, encoding: .rgb565BigEndian)

    #expect(rgba.encoding == .rgba8888)
    #expect(rgba.byteCount == 4)
    #expect((rgba.byte0, rgba.byte1, rgba.byte2, rgba.byte3) == (128, 127, 1, 255))
    #expect(rgb565.encoding == .rgb565BigEndian)
    #expect(rgb565.byteCount == 2)
    #expect((rgb565.byte0, rgb565.byte1) == (0x83, 0xE0))
    #expect(rgb565.byte2 == 0)
    #expect(rgb565.byte3 == 0)
}

@Test
func surfaceDescriptorPreservesExactFullSurfaceAndTiledFields() {
    let full = RasterSurfaceDescriptor(
        bounds: bounds(width: 4, height: 3),
        encoding: .rgba8888,
        bytesPerRow: 20,
        realization: .fullSurface,
        regionWidth: 4,
        regionHeight: 3
    )
    let tiled = RasterSurfaceDescriptor(
        bounds: bounds(width: 4, height: 3),
        encoding: .rgb565BigEndian,
        bytesPerRow: 8,
        realization: .tiled,
        regionWidth: 4,
        regionHeight: 2
    )

    #expect(full?.bounds == bounds(width: 4, height: 3))
    #expect(full?.encoding == .rgba8888)
    #expect(full?.bytesPerRow == 20)
    #expect(full?.realization == .fullSurface)
    #expect(full?.regionWidth == 4)
    #expect(full?.regionHeight == 3)
    #expect(tiled?.encoding == .rgb565BigEndian)
    #expect(tiled?.realization == .tiled)
    #expect(tiled?.regionHeight == 2)
    #expect(full == full)
    #expect(full != tiled)
}

@Test
func surfaceDescriptorRejectsInvalidBoundsRegionsAndStride() {
    #expect(
        RasterSurfaceDescriptor(
            bounds: bounds(width: 4, height: 3, origin: Point(x: 1, y: 0)),
            encoding: .rgba8888,
            bytesPerRow: 16,
            realization: .fullSurface,
            regionWidth: 4,
            regionHeight: 3
        ) == nil
    )
    #expect(
        RasterSurfaceDescriptor(
            bounds: bounds(width: 0, height: 3),
            encoding: .rgba8888,
            bytesPerRow: 0,
            realization: .fullSurface,
            regionWidth: 0,
            regionHeight: 3
        ) == nil
    )
    #expect(
        RasterSurfaceDescriptor(
            bounds: bounds(width: 65_536, height: 1),
            encoding: .rgb565BigEndian,
            bytesPerRow: 131_072,
            realization: .fullSurface,
            regionWidth: .max,
            regionHeight: 1
        ) == nil
    )
    #expect(
        RasterSurfaceDescriptor(
            bounds: bounds(width: 4, height: 3),
            encoding: .rgba8888,
            bytesPerRow: 15,
            realization: .fullSurface,
            regionWidth: 4,
            regionHeight: 3
        ) == nil
    )
    #expect(
        RasterSurfaceDescriptor(
            bounds: bounds(width: 4, height: 3),
            encoding: .rgba8888,
            bytesPerRow: 16,
            realization: .fullSurface,
            regionWidth: 4,
            regionHeight: 2
        ) == nil
    )
    #expect(
        RasterSurfaceDescriptor(
            bounds: bounds(width: 4, height: 3),
            encoding: .rgba8888,
            bytesPerRow: 16,
            realization: .tiled,
            regionWidth: 3,
            regionHeight: 2
        ) == nil
    )
}

@Test
func surfaceDescriptorAcceptsExactByteProductAndRejectsFirstOverflow() {
    let maximumProduct = RasterSurfaceDescriptor(
        bounds: bounds(width: 1, height: 65_535),
        encoding: .rgb565BigEndian,
        bytesPerRow: 65_537,
        realization: .fullSurface,
        regionWidth: 1,
        regionHeight: 65_535
    )
    let overflow = RasterSurfaceDescriptor(
        bounds: bounds(width: 1, height: 65_535),
        encoding: .rgb565BigEndian,
        bytesPerRow: 65_538,
        realization: .fullSurface,
        regionWidth: 1,
        regionHeight: 65_535
    )

    #expect(maximumProduct != nil)
    #expect(overflow == nil)
}

@Test
func surfaceValuesMeetNormativeLayoutCeilings() {
    #expect(MemoryLayout<CanonicalEncodedPixel>.size <= 8)
    #expect(MemoryLayout<CanonicalEncodedPixel>.stride <= 8)
    #expect(MemoryLayout<RasterSurfaceDescriptor>.size <= 32)
    #expect(MemoryLayout<RasterSurfaceDescriptor>.stride <= 32)
}
