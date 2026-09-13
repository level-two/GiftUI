import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

private struct RGB565Storage: FullSurfaceRGB565Storage {
    private(set) var bytes: [UInt8]

    var capacityBytes: UInt32 { UInt32(bytes.count) }

    init(count: Int, repeating value: UInt8 = 0) {
        bytes = [UInt8](repeating: value, count: count)
    }

    mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        at offset: UInt32
    ) -> Bool {
        guard offset < UInt32(bytes.count), bytes.count - Int(offset) >= 2 else {
            return false
        }
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

private let framebufferBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 3)!
)!
private let framebufferDescriptor = RasterSurfaceDescriptor(
    bounds: framebufferBounds,
    encoding: .rgb565BigEndian,
    bytesPerRow: 11,
    realization: .fullSurface,
    regionWidth: 4,
    regionHeight: 3
)!

private func framebufferHeader() -> RenderPlanHeader {
    RenderPlanHeader(
        surfaceBounds: framebufferBounds,
        damageBounds: framebufferBounds,
        operationCount: 1,
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 0
    )
}

@Test
func fullSurfaceRGB565FramebufferWritesBigEndianAndAccountsStorageSeparately() {
    var framebuffer = FullSurfaceRGB565Framebuffer(
        descriptor: framebufferDescriptor,
        storage: RGB565Storage(count: 33, repeating: 0xA5),
        workspaceBytes: 19
    )!
    #expect(framebuffer.mappedSurfaceBytes == 33)
    #expect(framebuffer.workspaceBytes == 19)
    #expect(framebuffer.accountedBytes == 52)
    let began = framebuffer.beginFrame(framebufferHeader())
    #expect(began)
    let replaced = framebuffer.replacePixel(
        at: Point(x: 3, y: 2),
        with: CanonicalEncodedPixel(
            color: Color(red: 128, green: 254, blue: 127),
            encoding: .rgb565BigEndian
        )
    )
    #expect(replaced)
    let finished = framebuffer.finishFrame()
    #expect(finished)

    let bytes = framebuffer.withBytes { Array($0) }
    #expect(Array(bytes[28 ..< 30]) == [0x87, 0xEF])
    #expect(Array(bytes[8 ..< 11]) == [0xA5, 0xA5, 0xA5])
    #expect(Array(bytes[30 ..< 33]) == [0xA5, 0xA5, 0xA5])
}

@Test
func fullSurfaceRGB565FramebufferRejectsWrongEncodingCapacityAndAccountingOverflow() {
    let rgba = RasterSurfaceDescriptor(
        bounds: framebufferBounds,
        encoding: .rgba8888,
        bytesPerRow: 16,
        realization: .fullSurface,
        regionWidth: 4,
        regionHeight: 3
    )!
    #expect(
        FullSurfaceRGB565Framebuffer(
            descriptor: rgba,
            storage: RGB565Storage(count: 48),
            workspaceBytes: 0
        ) == nil
    )
    #expect(
        FullSurfaceRGB565Framebuffer(
            descriptor: framebufferDescriptor,
            storage: RGB565Storage(count: 32),
            workspaceBytes: 0
        ) == nil
    )
    #expect(
        FullSurfaceRGB565Framebuffer(
            descriptor: framebufferDescriptor,
            storage: RGB565Storage(count: 33),
            workspaceBytes: .max
        ) == nil
    )
}

@Test
func fullSurfaceRGB565FramebufferUsesTheSameFrameAndDrainGrammar() {
    var framebuffer = FullSurfaceRGB565Framebuffer(
        descriptor: framebufferDescriptor,
        storage: RGB565Storage(count: 33),
        workspaceBytes: 0
    )!
    let began = framebuffer.beginFrame(framebufferHeader())
    #expect(began)
    let accepted = framebuffer.acceptPresentationResponsibility()
    #expect(accepted)
    let drained = framebuffer.replacePixel(
        at: Point(x: 4, y: 0),
        with: CanonicalEncodedPixel(color: .red, encoding: .rgb565BigEndian)
    )
    #expect(drained)
    #expect(framebuffer.drainedValidationFailure)
    let finished = framebuffer.finishFrame()
    #expect(finished)
    framebuffer.discardFrame()
    #expect(!framebuffer.presentationResponsibilityAccepted)
}
