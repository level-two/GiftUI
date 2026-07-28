import GiftUI
import GiftUIBackendRGB565
import GiftUIDisplayILI9341
import GiftUIExampleThermostatPortableView
import GiftUIRuntimeStatic

@_silgen_name("kmrtm_display_initialize")
private func kmrtmDisplayInitialize(
    _ width: UInt16,
    _ height: UInt16,
    _ orientationDegrees: UInt16
) -> Int32

@_silgen_name("kmrtm_display_set_blanked")
private func kmrtmDisplaySetBlanked(_ blanked: Int32) -> Int32

@_silgen_name("kmrtm_display_write_rgb565")
private func kmrtmDisplayWriteRGB565(
    _ x: UInt16,
    _ y: UInt16,
    _ width: UInt16,
    _ height: UInt16,
    _ pitch: UInt16,
    _ pixels: UnsafeRawPointer?,
    _ byteCount: UInt
) -> Int32

@_silgen_name("kmrtm_display_fill_rgb565")
private func kmrtmDisplayFillRGB565(
    _ x: UInt16,
    _ y: UInt16,
    _ width: UInt16,
    _ height: UInt16,
    _ pixel: UInt16
) -> Int32

@_silgen_name("giftui_display_uptime_ms")
private func giftuiDisplayUptimeMilliseconds() -> UInt32

@_silgen_name("giftui_display_sleep_ms")
private func giftuiDisplaySleep(milliseconds: UInt32)

@_silgen_name("giftui_display_log")
private func giftuiDisplayLog(_ event: Int32, _ value: Int32)

@_silgen_name("giftui_display_log_stack")
private func giftuiDisplayLogStack()

private struct ZephyrILI9341Transport: ILI9341DisplayTransport {
    mutating func initialize(
        configuration: ILI9341DisplayConfiguration
    ) throws(ILI9341TransportFault) {
        let size = configuration.logicalSize
        try check(kmrtmDisplayInitialize(
            UInt16(size.width),
            UInt16(size.height),
            UInt16(configuration.orientation.rawValue)
        ))
    }

    mutating func setBlanked(
        _ blanked: Bool
    ) throws(ILI9341TransportFault) {
        try check(kmrtmDisplaySetBlanked(blanked ? 1 : 0))
    }

    mutating func writeRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeRawBufferPointer
    ) throws(ILI9341TransportFault) {
        try check(kmrtmDisplayWriteRGB565(
            UInt16(rect.origin.x),
            UInt16(rect.origin.y),
            UInt16(rect.size.width),
            UInt16(rect.size.height),
            UInt16(bytesPerRow / ILI9341DisplayConfiguration.bytesPerPixel),
            bytes.baseAddress,
            UInt(bytes.count)
        ))
    }

    mutating func writeSolidRGB565(
        rect: Rect,
        pixel: UInt16
    ) throws(ILI9341TransportFault) {
        try check(kmrtmDisplayFillRGB565(
            UInt16(rect.origin.x),
            UInt16(rect.origin.y),
            UInt16(rect.size.width),
            UInt16(rect.size.height),
            pixel
        ))
    }

    mutating func readRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeMutableRawBufferPointer
    ) throws(ILI9341TransportFault) {
        throw .unavailable
    }

    private func check(_ result: Int32) throws(ILI9341TransportFault) {
        guard result == 0 else { throw .io(code: result) }
    }
}

@_cdecl("giftui_swift_display_application_run")
public func giftuiSwiftDisplayApplicationRun() -> Int32 {
    let displayConfiguration = ILI9341DisplayConfiguration(
        orientation: .degrees0,
        readCapabilities: .writeOnly
    )
    var display = ILI9341Display(
        configuration: displayConfiguration,
        transport: ZephyrILI9341Transport()
    )
    do {
        try display.initialize()
        try display.setBlanked(true)
    } catch {
        let code = transportCode(error)
        giftuiDisplayLog(1, code)
        return code
    }

    guard let rendererConfiguration = RGB565RendererConfiguration(
        validatingPhysicalWidth: displayConfiguration.logicalSize.width,
        physicalHeight: displayConfiguration.logicalSize.height,
        tileHeight: 4,
        rotation: .degrees0,
        byteOrder: .mostSignificantByteFirst
    ) else {
        giftuiDisplayLog(2, -1)
        return -1
    }
    let layout: StaticLayout
    switch StaticRuntime().layoutResult(
        ThermostatPortableView(target: 21),
        in: rendererConfiguration.logicalSize
    ) {
    case .success(let resolved):
        layout = resolved
    case .failure:
        giftuiDisplayLog(2, -2)
        return -2
    }

    let startedAt = giftuiDisplayUptimeMilliseconds()
    var renderer = RGB565TileRenderer(configuration: rendererConfiguration)
    var renderResult: Int32 = 0
    renderer.renderTiles { backend in
        backend.clear(Color(red: 24, green: 26, blue: 32))
        layout.appendRenderOperations(to: &backend)
    } presenting: { tile, bytes in
        guard renderResult == 0 else { return }
        renderResult = present(tile: tile, bytes: bytes, display: &display)
    }
    if renderResult != 0 {
        giftuiDisplayLog(2, renderResult)
        return renderResult
    }
    do {
        try display.setBlanked(false)
    } catch {
        let code = transportCode(error)
        giftuiDisplayLog(2, code)
        return code
    }
    giftuiDisplayLog(
        3,
        Int32(bitPattern: giftuiDisplayUptimeMilliseconds() &- startedAt)
    )
    giftuiDisplayLogStack()

    while true {
        giftuiDisplaySleep(milliseconds: 60_000)
    }
}

private func present(
    tile: RGB565Tile,
    bytes: UnsafeRawBufferPointer,
    display: inout ILI9341Display<ZephyrILI9341Transport>
) -> Int32 {
    do {
        try display.presentRGB565(
            rect: Rect(
                origin: Point(x: tile.physicalX, y: tile.physicalY),
                size: Size(width: tile.width, height: tile.height)
            ),
            bytesPerRow: tile.bytesPerRow,
            bytes: bytes
        )
        return 0
    } catch {
        return transportCode(error)
    }
}

private func transportCode(_ error: ILI9341DisplayError) -> Int32 {
    switch error {
    case .transport(.io(let code)):
        code
    case .transport(.unavailable):
        -38
    case .invalidRectangle:
        -22
    case .invalidBytesPerRow, .invalidBufferSize:
        -90
    case .gramReadUnsupported:
        -95
    }
}
