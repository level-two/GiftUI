import GiftUI
import GiftUIBackendRGB565
import GiftUIExampleThermostatPortableView
import GiftUIRuntimeStatic

@_silgen_name("ili9486_initialize")
func ili9486Initialize() -> Int32

@_silgen_name("ili9486_render_color_bars")
func ili9486RenderColorBars() -> Int32

@_silgen_name("ili9486_write_rgb565")
func ili9486WriteRGB565(
    _ x: UInt16,
    _ y: UInt16,
    _ width: UInt16,
    _ height: UInt16,
    _ pixels: UnsafeRawPointer?,
    _ byteCount: UInt
) -> Int32

@_silgen_name("giftui_display_uptime_ms")
func giftuiDisplayUptimeMilliseconds() -> UInt32

@_silgen_name("giftui_display_sleep_ms")
func giftuiDisplaySleep(milliseconds: UInt32)

@_silgen_name("giftui_display_log")
func giftuiDisplayLog(_ event: Int32, _ value: Int32)

@_cdecl("giftui_swift_display_application_run")
public func giftuiSwiftDisplayApplicationRun() -> Int32 {
    let initializationResult = ili9486Initialize()
    guard initializationResult == 0 else {
        giftuiDisplayLog(1, initializationResult)
        return initializationResult
    }

    var startedAt = giftuiDisplayUptimeMilliseconds()
    let colorBarResult = ili9486RenderColorBars()
    guard colorBarResult == 0 else {
        giftuiDisplayLog(2, colorBarResult)
        return colorBarResult
    }
    giftuiDisplayLog(
        3,
        Int32(bitPattern: giftuiDisplayUptimeMilliseconds() &- startedAt)
    )
    giftuiDisplaySleep(milliseconds: 2_000)

    guard let configuration = RGB565RendererConfiguration(
            validatingPhysicalWidth: 480,
            physicalHeight: 320,
            tileHeight: 16,
            rotation: .degrees0,
            byteOrder: .mostSignificantByteFirst
        ) else {
        giftuiDisplayLog(6, -1)
        return -1
    }
    let layout: StaticLayout
    switch StaticRuntime().layoutResult(
            ThermostatPortableView(target: 21),
            in: configuration.logicalSize
        ) {
    case .success(let resolvedLayout):
        layout = resolvedLayout
    case .failure:
        giftuiDisplayLog(6, -1)
        return -1
    }
    var renderer = RGB565TileRenderer(configuration: configuration)
    var transportResult: Int32 = 0
    startedAt = giftuiDisplayUptimeMilliseconds()
    renderer.renderTiles { tileBackend in
        tileBackend.clear(Color(red: 24, green: 26, blue: 32))
        layout.appendRenderOperations(to: &tileBackend)
    } presenting: { tile, bytes in
        guard transportResult == 0 else { return }
        transportResult = ili9486WriteRGB565(
            0,
            UInt16(tile.physicalY),
            UInt16(tile.width),
            UInt16(tile.height),
            bytes.baseAddress,
            UInt(bytes.count)
        )
    }
    guard transportResult == 0 else {
        giftuiDisplayLog(5, transportResult)
        return transportResult
    }
    giftuiDisplayLog(
        4,
        Int32(bitPattern: giftuiDisplayUptimeMilliseconds() &- startedAt)
    )

    while true {
        giftuiDisplaySleep(milliseconds: 60_000)
    }
}
