import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

private struct RGBAStorage: FullSurfaceRGBA8888Storage {
    private(set) var bytes: [UInt8]

    var capacityBytes: UInt32 { UInt32(bytes.count) }

    init(count: Int, repeating value: UInt8 = 0) {
        bytes = [UInt8](repeating: value, count: count)
    }

    mutating func store(
        byte0: UInt8,
        byte1: UInt8,
        byte2: UInt8,
        byte3: UInt8,
        at offset: UInt32
    ) -> Bool {
        guard offset <= UInt32(bytes.count), bytes.count - Int(offset) >= 4 else {
            return false
        }
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

private let rgbaBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 3, height: 2)!
)!
private let rgbaDescriptor = RasterSurfaceDescriptor(
    bounds: rgbaBounds,
    encoding: .rgba8888,
    bytesPerRow: 15,
    realization: .fullSurface,
    regionWidth: 3,
    regionHeight: 2
)!

private func rgbaHeader(damage: Rect = rgbaBounds) -> RenderPlanHeader {
    RenderPlanHeader(
        surfaceBounds: rgbaBounds,
        damageBounds: damage,
        operationCount: 1,
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 0
    )
}

@Test
func fullSurfaceRGBA8888BufferPreservesStridePaddingAndExactPixels() {
    var surface = FullSurfaceRGBA8888Buffer(
        descriptor: rgbaDescriptor,
        storage: RGBAStorage(count: 30, repeating: 0xA5)
    )!
    #expect(surface.writableCapacityBytes == 30)
    let began = surface.beginFrame(rgbaHeader())
    #expect(began)
    let replaced = surface.replacePixel(
        at: Point(x: 2, y: 1),
        with: CanonicalEncodedPixel(color: .blue, encoding: .rgba8888)
    )
    #expect(replaced)
    let finished = surface.finishFrame()
    #expect(finished)

    let bytes = surface.withBytes { Array($0) }
    #expect(Array(bytes[23 ..< 27]) == [0, 0, 255, 255])
    #expect(Array(bytes[12 ..< 15]) == [0xA5, 0xA5, 0xA5])
    #expect(Array(bytes[27 ..< 30]) == [0xA5, 0xA5, 0xA5])
}

@Test
func fullSurfaceRGBA8888BufferValidatesConstructionAndFrameGrammar() {
    let rgb565 = RasterSurfaceDescriptor(
        bounds: rgbaBounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 6,
        realization: .fullSurface,
        regionWidth: 3,
        regionHeight: 2
    )!
    #expect(
        FullSurfaceRGBA8888Buffer(
            descriptor: rgb565,
            storage: RGBAStorage(count: 30)
        ) == nil
    )
    #expect(
        FullSurfaceRGBA8888Buffer(
            descriptor: rgbaDescriptor,
            storage: RGBAStorage(count: 29)
        ) == nil
    )

    var surface = FullSurfaceRGBA8888Buffer(
        descriptor: rgbaDescriptor,
        storage: RGBAStorage(count: 30)
    )!
    let partialDamage = Rect(
        origin: Point(x: 1, y: 0),
        size: Size(width: 2, height: 2)!
    )!
    let prematureFinish = surface.finishFrame()
    #expect(!prematureFinish)
    let began = surface.beginFrame(rgbaHeader(damage: partialDamage))
    #expect(began)
    let duplicateBegin = surface.beginFrame(rgbaHeader())
    #expect(!duplicateBegin)
    let outsideDamage = surface.replacePixel(
        at: Point(x: 0, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgba8888)
    )
    #expect(!outsideDamage)
    surface.discardFrame()
    #expect(!surface.presentationResponsibilityAccepted)
    let finishAfterDiscard = surface.finishFrame()
    #expect(!finishAfterDiscard)
}

@Test
func fullSurfaceRGBA8888BufferDrainsValidationAfterResponsibilityTransfer() {
    var surface = FullSurfaceRGBA8888Buffer(
        descriptor: rgbaDescriptor,
        storage: RGBAStorage(count: 30)
    )!
    let began = surface.beginFrame(rgbaHeader())
    #expect(began)
    let accepted = surface.acceptPresentationResponsibility()
    #expect(accepted)
    let drained = surface.replacePixel(
        at: Point(x: 3, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgba8888)
    )
    #expect(drained)
    #expect(surface.drainedValidationFailure)
    let ignored = surface.replacePixel(
        at: Point(x: 0, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgba8888)
    )
    #expect(ignored)
    let finished = surface.finishFrame()
    #expect(finished)
}
