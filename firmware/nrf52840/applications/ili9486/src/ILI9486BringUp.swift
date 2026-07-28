import GiftUI
import GiftUIBackendRGB565
import GiftUIExampleThermostatPortableView
import GiftUIInputADS7846
import GiftUIRuntimeStatic

@_silgen_name("ili9486_initialize")
func ili9486Initialize() -> Int32

@_silgen_name("ili9486_render_color_bars")
func ili9486RenderColorBars() -> Int32

@_silgen_name("ili9486_tile_height")
func ili9486TileHeight() -> UInt16

@_silgen_name("ili9486_write_rgb565")
func ili9486WriteRGB565(
    _ x: UInt16,
    _ y: UInt16,
    _ width: UInt16,
    _ height: UInt16,
    _ pixels: UnsafeRawPointer?,
    _ byteCount: UInt
) -> Int32

@_silgen_name("ads7846_pen_is_down")
func ads7846PenIsDown() -> Int32

@_silgen_name("ads7846_read_raw_values")
func ads7846ReadRawValues(
    _ x: UnsafeMutablePointer<UInt16>,
    _ y: UnsafeMutablePointer<UInt16>,
    _ z1: UnsafeMutablePointer<UInt16>,
    _ z2: UnsafeMutablePointer<UInt16>
) -> Int32

@_silgen_name("giftui_display_uptime_ms")
func giftuiDisplayUptimeMilliseconds() -> UInt32

@_silgen_name("giftui_display_sleep_ms")
func giftuiDisplaySleep(milliseconds: UInt32)

@_silgen_name("giftui_display_log")
func giftuiDisplayLog(_ event: Int32, _ value: Int32)

@_silgen_name("giftui_display_log_stack")
func giftuiDisplayLogStack()

@_silgen_name("giftui_fault_record")
func giftuiFaultRecord(_ category: Int32, _ detail: Int32)

@_silgen_name("giftui_validation_heartbeat")
func giftuiValidationHeartbeat(_ updateCount: UInt32)

@_silgen_name("giftui_touch_log_sample")
func giftuiTouchLogSample(
    _ target: Int32,
    _ x: UInt16,
    _ y: UInt16,
    _ z1: UInt16,
    _ z2: UInt16
)

private let calibrationTargetInset = 16
private let calibrationTargetSize = 16
private let calibrationPointTimeoutMilliseconds: UInt32 = 15_000
private let releaseTimeoutMilliseconds: UInt32 = 5_000
private let touchPollMilliseconds: UInt32 = 10
private let validationHeartbeatMilliseconds: UInt32 = 60_000
private let capacityFault: Int32 = 0
private let displayControllerFault: Int32 = 1

@_cdecl("giftui_swift_display_application_run")
public func giftuiSwiftDisplayApplicationRun() -> Int32 {
    let initializationResult = ili9486Initialize()
    guard initializationResult == 0 else {
        giftuiFaultRecord(displayControllerFault, initializationResult)
        giftuiDisplayLog(1, initializationResult)
        return initializationResult
    }

    let startedAt = giftuiDisplayUptimeMilliseconds()
    let colorBarResult = ili9486RenderColorBars()
    guard colorBarResult == 0 else {
        giftuiFaultRecord(displayControllerFault, colorBarResult)
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
            tileHeight: Int(ili9486TileHeight()),
            rotation: .degrees0,
            byteOrder: .mostSignificantByteFirst
        ) else {
        giftuiFaultRecord(capacityFault, -1)
        giftuiDisplayLog(6, -1)
        return -1
    }

    let calibration = captureCalibration(configuration: configuration)
    var model = ThermostatModel()
    guard var layout = renderThermostat(
            model: model,
            configuration: configuration,
            previousLayout: nil
        ) else {
        return -1
    }
    giftuiDisplayLogStack()
    guard let calibration else {
        while true {
            giftuiDisplaySleep(milliseconds: 60_000)
        }
    }

    var processor = ADS7846TouchProcessor(
        calibration: calibration,
        physicalSize: Size(width: 480, height: 320),
        orientation: .degrees0
    )
    var pressedAction: ActionID?
    var updateCount: UInt32 = 0
    var heartbeatStartedAt = giftuiDisplayUptimeMilliseconds()

    while true {
        let penState = ads7846PenIsDown()
        if penState < 0 {
            giftuiDisplayLog(7, penState)
            _ = processor.process(penIsDown: false)
            pressedAction = nil
            giftuiDisplaySleep(milliseconds: 100)
            continue
        }

        let event: InputEvent?
        if penState != 0 {
            var readError: Int32 = 0
            guard let first = readRawSample(error: &readError),
                  let second = readRawSample(error: &readError),
                  let third = readRawSample(error: &readError) else {
                giftuiDisplayLog(7, readError)
                giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
                continue
            }
            event = processor.process(
                penIsDown: true,
                first: first,
                second: second,
                third: third
            )
        } else {
            event = processor.process(penIsDown: false)
        }

        if let event {
            switch event {
            case .pointerDown(let point):
                pressedAction = layout.action(at: point)
            case .pointerMove(let point):
                if layout.action(at: point) != pressedAction {
                    pressedAction = nil
                }
            case .pointerUp(let point):
                let updateStartedAt = giftuiDisplayUptimeMilliseconds()
                let completedAction = pressedAction
                pressedAction = nil
                if let completedAction,
                   layout.action(at: point) == completedAction,
                   model.dispatch(completedAction),
                   let updatedLayout = renderThermostat(
                       model: model,
                       configuration: configuration,
                       previousLayout: layout
                   ) {
                    layout = updatedLayout
                    giftuiDisplayLog(11, Int32(model.target))
                    giftuiDisplayLog(
                        12,
                        Int32(bitPattern:
                            giftuiDisplayUptimeMilliseconds() &- updateStartedAt)
                    )
                    giftuiDisplayLogStack()
                    if updateCount < UInt32.max {
                        updateCount += 1
                    }
                }
            }
        }

        let heartbeatNow = giftuiDisplayUptimeMilliseconds()
        if heartbeatNow &- heartbeatStartedAt >= validationHeartbeatMilliseconds {
            giftuiValidationHeartbeat(updateCount)
            heartbeatStartedAt = heartbeatNow
        }

        giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
    }
}

private func captureCalibration(
    configuration: RGB565RendererConfiguration
) -> ADS7846Calibration? {
    guard let topLeft = captureCalibrationPoint(
            target: 1,
            x: calibrationTargetInset,
            y: calibrationTargetInset,
            configuration: configuration
        ),
        let topRight = captureCalibrationPoint(
            target: 2,
            x: configuration.logicalSize.width - 1 - calibrationTargetInset,
            y: calibrationTargetInset,
            configuration: configuration
        ),
        let bottomLeft = captureCalibrationPoint(
            target: 3,
            x: calibrationTargetInset,
            y: configuration.logicalSize.height - 1 - calibrationTargetInset,
            configuration: configuration
        ),
        let bottomRight = captureCalibrationPoint(
            target: 4,
            x: configuration.logicalSize.width - 1 - calibrationTargetInset,
            y: configuration.logicalSize.height - 1 - calibrationTargetInset,
            configuration: configuration
        ),
        let center = captureCalibrationPoint(
            target: 5,
            x: configuration.logicalSize.width / 2,
            y: configuration.logicalSize.height / 2,
            configuration: configuration
        ) else {
        giftuiDisplayLog(9, -1)
        return nil
    }

    let samples = ADS7846CalibrationSamples(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        center: center
    )
    switch ADS7846Calibration.derive(
        samples: samples,
        targetInset: calibrationTargetInset
    ) {
    case .success(let calibration):
        giftuiDisplayLog(10, 0)
        return calibration
    case .failure:
        giftuiDisplayLog(9, -2)
        return nil
    }
}

private func captureCalibrationPoint(
    target: Int32,
    x: Int,
    y: Int,
    configuration: RGB565RendererConfiguration
) -> ADS7846RawSample? {
    guard renderCalibrationTarget(
            x: x,
            y: y,
            configuration: configuration
        ) else {
        return nil
    }
    giftuiDisplayLog(8, target)

    let startedAt = giftuiDisplayUptimeMilliseconds()
    while giftuiDisplayUptimeMilliseconds() &- startedAt
            < calibrationPointTimeoutMilliseconds {
        let penState = ads7846PenIsDown()
        if penState < 0 {
            giftuiDisplayLog(7, penState)
            return nil
        }
        if penState == 0 {
            giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
            continue
        }

        var readError: Int32 = 0
        guard let first = readRawSample(error: &readError),
              let second = readRawSample(error: &readError),
              let third = readRawSample(error: &readError) else {
            giftuiDisplayLog(7, readError)
            return nil
        }
        let threshold = ADS7846PressureThreshold()
        guard threshold.accepts(first),
              threshold.accepts(second),
              threshold.accepts(third) else {
            giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
            continue
        }
        let sample = ADS7846RawSample.median(first, second, third)
        guard waitForPenRelease() else {
            giftuiDisplayLog(9, -3)
            return nil
        }
        giftuiTouchLogSample(
            target,
            sample.x,
            sample.y,
            sample.z1,
            sample.z2
        )
        return sample
    }
    return nil
}

private func waitForPenRelease() -> Bool {
    let startedAt = giftuiDisplayUptimeMilliseconds()
    while giftuiDisplayUptimeMilliseconds() &- startedAt
            < releaseTimeoutMilliseconds {
        let penState = ads7846PenIsDown()
        if penState < 0 { return false }
        if penState == 0 { return true }
        giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
    }
    return false
}

private func readRawSample(error: inout Int32) -> ADS7846RawSample? {
    var x: UInt16 = 0
    var y: UInt16 = 0
    var z1: UInt16 = 0
    var z2: UInt16 = 0
    error = ads7846ReadRawValues(&x, &y, &z1, &z2)
    guard error == 0 else { return nil }
    return ADS7846RawSample(x: x, y: y, z1: z1, z2: z2)
}

private func renderCalibrationTarget(
    x: Int,
    y: Int,
    configuration: RGB565RendererConfiguration
) -> Bool {
    var renderer = RGB565TileRenderer(configuration: configuration)
    var transportResult: Int32 = 0
    renderer.renderTiles { tileBackend in
        tileBackend.clear(.black)
        tileBackend.fill(
            Rect(
                origin: Point(
                    x: x - calibrationTargetSize / 2,
                    y: y - calibrationTargetSize / 2
                ),
                size: Size(
                    width: calibrationTargetSize,
                    height: calibrationTargetSize
                )
            ),
            color: .white
        )
    } presenting: { tile, bytes in
        guard transportResult == 0 else { return }
        transportResult = present(tile: tile, bytes: bytes)
    }
    if transportResult != 0 {
        giftuiDisplayLog(5, transportResult)
        return false
    }
    return true
}

private func renderThermostat(
    model: ThermostatModel,
    configuration: RGB565RendererConfiguration,
    previousLayout: StaticLayout?
) -> StaticLayout? {
    let layout: StaticLayout
    switch StaticRuntime().layoutResult(
        ThermostatPortableView(target: model.target),
        in: configuration.logicalSize
    ) {
    case .success(let resolvedLayout):
        layout = resolvedLayout
    case .failure:
        giftuiFaultRecord(capacityFault, -2)
        giftuiDisplayLog(6, -1)
        return nil
    }

    var renderer = RGB565TileRenderer(configuration: configuration)
    var transportResult: Int32 = 0
    let startedAt = giftuiDisplayUptimeMilliseconds()
    let dirtyRegion = previousLayout.map {
        union($0.rootFrame, layout.rootFrame)
    } ?? Rect(origin: Point(x: 0, y: 0), size: configuration.logicalSize)
    renderer.renderTiles(dirtyRegion: dirtyRegion) { tileBackend in
        tileBackend.clear(Color(red: 24, green: 26, blue: 32))
        layout.appendRenderOperations(to: &tileBackend)
    } presenting: { tile, bytes in
        guard transportResult == 0 else { return }
        transportResult = present(tile: tile, bytes: bytes)
    }
    guard transportResult == 0 else {
        giftuiFaultRecord(displayControllerFault, transportResult)
        giftuiDisplayLog(5, transportResult)
        return nil
    }
    giftuiDisplayLog(
        4,
        Int32(bitPattern: giftuiDisplayUptimeMilliseconds() &- startedAt)
    )
    return layout
}

private func present(
    tile: RGB565Tile,
    bytes: UnsafeRawBufferPointer
) -> Int32 {
    ili9486WriteRGB565(
        UInt16(tile.physicalX),
        UInt16(tile.physicalY),
        UInt16(tile.width),
        UInt16(tile.height),
        bytes.baseAddress,
        UInt(bytes.count)
    )
}

private func union(_ lhs: Rect, _ rhs: Rect) -> Rect {
    let minX = min(lhs.origin.x, rhs.origin.x)
    let minY = min(lhs.origin.y, rhs.origin.y)
    let maxX = max(lhs.origin.x + lhs.size.width, rhs.origin.x + rhs.size.width)
    let maxY = max(lhs.origin.y + lhs.size.height, rhs.origin.y + rhs.size.height)
    return Rect(
        origin: Point(x: minX, y: minY),
        size: Size(width: maxX - minX, height: maxY - minY)
    )
}
