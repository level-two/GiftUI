import Testing
import GiftUI
import GiftUIBackendRGB565
@testable import GiftUIDisplayILI9341

@Test
func orientationsExposeExpectedLogicalGeometry() {
    #expect(ILI9341DisplayConfiguration(orientation: .degrees0).logicalSize == Size(width: 240, height: 320))
    #expect(ILI9341DisplayConfiguration(orientation: .degrees90).logicalSize == Size(width: 320, height: 240))
    #expect(ILI9341DisplayConfiguration(orientation: .degrees180).logicalSize == Size(width: 240, height: 320))
    #expect(ILI9341DisplayConfiguration(orientation: .degrees270).logicalSize == Size(width: 320, height: 240))
}

@Test
func lifecycleCallsAndFaultsPropagate() throws {
    let faultController = FaultController()
    var display = ILI9341Display(
        configuration: ILI9341DisplayConfiguration(orientation: .degrees90),
        transport: RecordingTransport(faultController: faultController)
    )
    try display.initialize()
    try display.setBlanked(false)

    #expect(display.transport.initializedOrientations == [.degrees90])
    #expect(display.transport.blankingStates == [false])

    faultController.nextFault = .io(code: -5)
    #expect(throws: ILI9341DisplayError.transport(.io(code: -5))) {
        try display.setBlanked(true)
    }
}

@Test
func presentationPreservesMSBFirstBytesAndPitch() throws {
    var display = makeDisplay()
    let bytes: [UInt8] = [0xf8, 0x00, 0x07, 0xe0, 0x00, 0x1f, 0xff, 0xff]

    try bytes.withUnsafeBytes {
        try display.presentRGB565(
            rect: Rect(origin: Point(x: 2, y: 3), size: Size(width: 2, height: 2)),
            bytesPerRow: 4,
            bytes: $0
        )
    }

    #expect(display.transport.writes == [
        CapturedWrite(
            rect: Rect(origin: Point(x: 2, y: 3), size: Size(width: 2, height: 2)),
            bytesPerRow: 4,
            bytes: bytes
        )
    ])
}

@Test
func tileRendererPresentsBoundedRGB565RegionThroughDisplay() throws {
    let rendererConfiguration = try RGB565RendererConfiguration(
        physicalWidth: 240,
        physicalHeight: 320,
        tileHeight: 4,
        rotation: .degrees0,
        byteOrder: .mostSignificantByteFirst
    )
    var renderer = RGB565TileRenderer(configuration: rendererConfiguration)
    var display = makeDisplay()
    let dirtyRegion = Rect(
        origin: Point(x: 7, y: 9),
        size: Size(width: 2, height: 2)
    )

    try renderer.renderTiles(dirtyRegion: dirtyRegion) { backend in
        backend.fill(dirtyRegion, color: Color(red: 255, green: 0, blue: 0))
    } presenting: { tile, bytes in
        try display.presentRGB565(
            rect: Rect(
                origin: Point(x: tile.physicalX, y: tile.physicalY),
                size: Size(width: tile.width, height: tile.height)
            ),
            bytesPerRow: tile.bytesPerRow,
            bytes: bytes
        )
    }

    #expect(display.transport.writes == [
        CapturedWrite(
            rect: dirtyRegion,
            bytesPerRow: 4,
            bytes: [0xf8, 0x00, 0xf8, 0x00, 0xf8, 0x00, 0xf8, 0x00]
        )
    ])
    #expect(renderer.allocatedByteCapacity == 1_920)
}

@Test
func presentationClipsAndAdvancesCallerOwnedBuffer() throws {
    var display = makeDisplay()
    let bytes = Array(UInt8(0)..<UInt8(24))

    try bytes.withUnsafeBytes {
        try display.presentRGB565(
            rect: Rect(origin: Point(x: -1, y: -1), size: Size(width: 3, height: 4)),
            bytesPerRow: 6,
            bytes: $0
        )
    }

    #expect(display.transport.writes == [
        CapturedWrite(
            rect: Rect(origin: Point(x: 0, y: 0), size: Size(width: 2, height: 3)),
            bytesPerRow: 6,
            bytes: Array(UInt8(8)...UInt8(23))
        )
    ])
}

@Test
func invalidRectanglesPitchAndBufferAreRejected() {
    var display = makeDisplay()
    let bytes = [UInt8](repeating: 0, count: 8)

    #expect(throws: ILI9341DisplayError.invalidRectangle) {
        try bytes.withUnsafeBytes {
            try display.presentRGB565(
                rect: Rect(origin: Point(x: 0, y: 0), size: Size(width: 0, height: 1)),
                bytesPerRow: 2,
                bytes: $0
            )
        }
    }
    #expect(throws: ILI9341DisplayError.invalidBytesPerRow) {
        try bytes.withUnsafeBytes {
            try display.presentRGB565(
                rect: Rect(origin: Point(x: 0, y: 0), size: Size(width: 2, height: 1)),
                bytesPerRow: 2,
                bytes: $0
            )
        }
    }
    #expect(throws: ILI9341DisplayError.invalidBufferSize) {
        try bytes.withUnsafeBytes {
            try display.presentRGB565(
                rect: Rect(origin: Point(x: 0, y: 0), size: Size(width: 2, height: 3)),
                bytesPerRow: 4,
                bytes: $0
            )
        }
    }
    #expect(throws: ILI9341DisplayError.invalidRectangle) {
        try bytes.withUnsafeBytes {
            try display.presentRGB565(
                rect: Rect(origin: Point(x: Int.max, y: 0), size: Size(width: 2, height: 1)),
                bytesPerRow: 4,
                bytes: $0
            )
        }
    }
}

@Test
func solidFillClipsAndRetainedWriterCapturesFault() throws {
    let faultController = FaultController()
    var display = ILI9341Display(
        configuration: ILI9341DisplayConfiguration(),
        transport: RecordingTransport(faultController: faultController)
    )
    try display.fill(
        rect: Rect(origin: Point(x: 239, y: 319), size: Size(width: 3, height: 2)),
        pixel: RGB565Pixel(rawValue: 0xf81f)
    )
    #expect(display.transport.fills == [
        CapturedFill(
            rect: Rect(origin: Point(x: 239, y: 319), size: Size(width: 1, height: 1)),
            pixel: 0xf81f
        )
    ])

    faultController.nextFault = .io(code: -12)
    display.writeSolidRect(
        Rect(origin: Point(x: 1, y: 2), size: Size(width: 3, height: 4)),
        pixel: RGB565Pixel(rawValue: 0x07e0)
    )
    #expect(display.retainedWriterFault == .transport(.io(code: -12)))
    let fillCount = display.transport.fills.count
    display.writeSolidRect(
        Rect(origin: Point(x: 5, y: 6), size: Size(width: 1, height: 1)),
        pixel: RGB565Pixel(rawValue: 0xffff)
    )
    #expect(display.transport.fills.count == fillCount)
    display.clearRetainedWriterFault()
    #expect(display.retainedWriterFault == nil)
}

@Test
func readsRequireExplicitCapabilityAndPropagateBytes() throws {
    var writeOnly = makeDisplay()
    var output = [UInt8](repeating: 0, count: 4)
    #expect(throws: ILI9341DisplayError.gramReadUnsupported) {
        try output.withUnsafeMutableBytes {
            try writeOnly.readRGB565(
                rect: Rect(origin: Point(x: 0, y: 0), size: Size(width: 2, height: 1)),
                bytesPerRow: 4,
                bytes: $0
            )
        }
    }

    var readable = ILI9341Display(
        configuration: ILI9341DisplayConfiguration(
            readCapabilities: ILI9341ReadCapabilities(
                registerReads: true,
                gramReads: true
            )
        ),
        transport: RecordingTransport(readBytes: [0xf8, 0x00, 0x07, 0xe0])
    )
    try output.withUnsafeMutableBytes {
        try readable.readRGB565(
            rect: Rect(origin: Point(x: 4, y: 5), size: Size(width: 2, height: 1)),
            bytesPerRow: 4,
            bytes: $0
        )
    }
    #expect(output == [0xf8, 0x00, 0x07, 0xe0])
    #expect(readable.transport.reads == [
        CapturedRead(
            rect: Rect(origin: Point(x: 4, y: 5), size: Size(width: 2, height: 1)),
            bytesPerRow: 4
        )
    ])
}

private func makeDisplay() -> ILI9341Display<RecordingTransport> {
    ILI9341Display(
        configuration: ILI9341DisplayConfiguration(),
        transport: RecordingTransport()
    )
}

private struct CapturedWrite: Equatable {
    let rect: Rect
    let bytesPerRow: Int
    let bytes: [UInt8]
}

private struct CapturedFill: Equatable {
    let rect: Rect
    let pixel: UInt16
}

private struct CapturedRead: Equatable {
    let rect: Rect
    let bytesPerRow: Int
}

private struct RecordingTransport: ILI9341DisplayTransport {
    var initializedOrientations: [ILI9341Orientation] = []
    var blankingStates: [Bool] = []
    var writes: [CapturedWrite] = []
    var fills: [CapturedFill] = []
    var reads: [CapturedRead] = []
    var readBytes: [UInt8] = []
    var faultController: FaultController?

    mutating func initialize(
        configuration: ILI9341DisplayConfiguration
    ) throws(ILI9341TransportFault) {
        try failIfRequested()
        initializedOrientations.append(configuration.orientation)
    }

    mutating func setBlanked(
        _ blanked: Bool
    ) throws(ILI9341TransportFault) {
        try failIfRequested()
        blankingStates.append(blanked)
    }

    mutating func writeRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeRawBufferPointer
    ) throws(ILI9341TransportFault) {
        try failIfRequested()
        writes.append(CapturedWrite(
            rect: rect,
            bytesPerRow: bytesPerRow,
            bytes: Array(bytes)
        ))
    }

    mutating func writeSolidRGB565(
        rect: Rect,
        pixel: UInt16
    ) throws(ILI9341TransportFault) {
        try failIfRequested()
        fills.append(CapturedFill(rect: rect, pixel: pixel))
    }

    mutating func readRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeMutableRawBufferPointer
    ) throws(ILI9341TransportFault) {
        try failIfRequested()
        reads.append(CapturedRead(rect: rect, bytesPerRow: bytesPerRow))
        for index in 0..<min(bytes.count, readBytes.count) {
            bytes[index] = readBytes[index]
        }
    }

    private mutating func failIfRequested() throws(ILI9341TransportFault) {
        if let nextFault = faultController?.nextFault {
            faultController?.nextFault = nil
            throw nextFault
        }
    }
}

private final class FaultController {
    var nextFault: ILI9341TransportFault?
}
