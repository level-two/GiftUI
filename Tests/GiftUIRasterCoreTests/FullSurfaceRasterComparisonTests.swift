import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

private struct ComparisonRGBAStorage: FullSurfaceRGBA8888Storage {
    private(set) var bytes: [UInt8]
    var capacityBytes: UInt32 { UInt32(bytes.count) }

    init(count: Int) {
        bytes = [UInt8](repeating: 0xA5, count: count)
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

private struct ComparisonRGB565Storage: FullSurfaceRGB565Storage {
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

@Test(arguments: strokeVectors)
func everyStrokeVectorMatchesBothFullSurfaceEncodings(
    _ fixture: StrokeVectorFixture
) {
    let bounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: fixture.width, height: fixture.height)!
    )!
    let rgbaStride = UInt32(fixture.width) * 4 + 3
    let rgb565Stride = UInt32(fixture.width) * 2 + 1
    let rgbaDescriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgba8888,
        bytesPerRow: rgbaStride,
        realization: .fullSurface,
        regionWidth: UInt16(fixture.width),
        regionHeight: UInt16(fixture.height)
    )!
    let rgb565Descriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: rgb565Stride,
        realization: .fullSurface,
        regionWidth: UInt16(fixture.width),
        regionHeight: UInt16(fixture.height)
    )!
    var rgba = FullSurfaceRGBA8888Buffer(
        descriptor: rgbaDescriptor,
        storage: ComparisonRGBAStorage(
            count: Int(rgbaStride) * Int(fixture.height)
        )
    )!
    var rgb565 = FullSurfaceRGB565Framebuffer(
        descriptor: rgb565Descriptor,
        storage: ComparisonRGB565Storage(
            count: Int(rgb565Stride) * Int(fixture.height)
        ),
        workspaceBytes: 0
    )!
    let header = RenderPlanHeader(
        surfaceBounds: bounds,
        damageBounds: bounds,
        operationCount: UInt16(fixture.operations.count),
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 1
    )
    let rgbaBegan = rgba.beginFrame(header)
    let rgb565Began = rgb565.beginFrame(header)
    #expect(rgbaBegan)
    #expect(rgb565Began)

    for operation in fixture.operations {
        let stroke = FixtureStroke(
            header: StraightLineStrokeHeader(
                color: operation.color,
                lineWidth: operation.lineWidth,
                lineCap: operation.cap,
                lineJoin: operation.join,
                surfaceOrigin: operation.origin,
                inheritedClip: operation.clip,
                pointCount: UInt16(operation.points.count),
                subpathCount: UInt16(operation.subpaths.count)
            ),
            points: operation.points,
            subpaths: operation.subpaths
        )
        let rgbaResult = RasterStrokeCoverage.rasterize(
            stroke,
            descriptor: rgbaDescriptor,
            damageBounds: bounds
        ) { point, pixel in
            rgba.replacePixel(at: point, with: pixel)
        }
        let rgb565Result = RasterStrokeCoverage.rasterize(
            stroke,
            descriptor: rgb565Descriptor,
            damageBounds: bounds
        ) { point, pixel in
            rgb565.replacePixel(at: point, with: pixel)
        }
        #expect(rgbaResult != .replacementRefused)
        #expect(rgb565Result != .replacementRefused)
    }
    let rgbaFinished = rgba.finishFrame()
    let rgb565Finished = rgb565.finishFrame()
    #expect(rgbaFinished)
    #expect(rgb565Finished)

    let rgbaBytes = rgba.withBytes { Array($0) }
    let rgb565Bytes = rgb565.withBytes { Array($0) }
    for y in 0 ..< Int(fixture.height) {
        for x in 0 ..< Int(fixture.width) {
            let symbol = fixture.expectedMask[y][
                fixture.expectedMask[y].index(
                    fixture.expectedMask[y].startIndex,
                    offsetBy: x
                )
            ]
            let rgbaOffset = y * Int(rgbaStride) + x * 4
            let rgb565Offset = y * Int(rgb565Stride) + x * 2
            guard symbol != ".",
                let operation = fixture.operations.last(where: {
                    $0.symbol == symbol
                })
            else {
                #expect(
                    Array(rgbaBytes[rgbaOffset ..< (rgbaOffset + 4)]) == [0xA5, 0xA5, 0xA5, 0xA5])
                #expect(Array(rgb565Bytes[rgb565Offset ..< (rgb565Offset + 2)]) == [0xA5, 0xA5])
                continue
            }
            let expectedRGBA = CanonicalEncodedPixel(
                color: operation.color,
                encoding: .rgba8888
            )
            let expectedRGB565 = CanonicalEncodedPixel(
                color: operation.color,
                encoding: .rgb565BigEndian
            )
            #expect(
                Array(rgbaBytes[rgbaOffset ..< (rgbaOffset + 4)])
                    == [
                        expectedRGBA.byte0, expectedRGBA.byte1,
                        expectedRGBA.byte2, expectedRGBA.byte3,
                    ]
            )
            #expect(
                Array(rgb565Bytes[rgb565Offset ..< (rgb565Offset + 2)])
                    == [expectedRGB565.byte0, expectedRGB565.byte1]
            )
        }
        let rgbaPaddingStart = y * Int(rgbaStride) + Int(fixture.width) * 4
        let rgb565PaddingStart = y * Int(rgb565Stride) + Int(fixture.width) * 2
        #expect(
            Array(rgbaBytes[rgbaPaddingStart ..< (rgbaPaddingStart + 3)])
                == [0xA5, 0xA5, 0xA5]
        )
        #expect(rgb565Bytes[rgb565PaddingStart] == 0xA5)
    }
}
