import GiftUI
import GiftUIBackendRGB565
import GiftUIDisplayILI9341
import GiftUIExampleThermostatPortableView
import GiftUIInputADS7846
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

@_silgen_name("giftui_touch_log_sample")
private func giftuiTouchLogSample(
    _ target: Int32,
    _ x: UInt16,
    _ y: UInt16,
    _ z1: UInt16,
    _ z2: UInt16
)

@_silgen_name("xpt2046_initialize")
private func xpt2046Initialize() -> Int32

@_silgen_name("xpt2046_pen_is_down")
private func xpt2046PenIsDown() -> Int32

@_silgen_name("xpt2046_read_raw_values")
private func xpt2046ReadRawValues(
    _ x: UnsafeMutablePointer<UInt16>,
    _ y: UnsafeMutablePointer<UInt16>,
    _ z1: UnsafeMutablePointer<UInt16>,
    _ z2: UnsafeMutablePointer<UInt16>
) -> Int32

private let calibrationTargetInset = 16
private let calibrationTargetSize = 16
private let calibrationPointTimeoutMilliseconds: UInt32 = 15_000
private let releaseTimeoutMilliseconds: UInt32 = 5_000
private let touchPollMilliseconds: UInt32 = 10

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
    let touchInitializationResult = xpt2046Initialize()
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
    do {
        try display.setBlanked(false)
    } catch {
        let code = transportCode(error)
        giftuiDisplayLog(2, code)
        return code
    }

    let calibration: XPT2046Calibration?
    if touchInitializationResult == 0 {
        let initialPenState = xpt2046PenIsDown()
        if initialPenState < 0 {
            giftuiDisplayLog(6, initialPenState)
            calibration = nil
        } else {
            giftuiDisplayLog(4, initialPenState)
            calibration = captureCalibration(
                configuration: rendererConfiguration,
                display: &display
            )
        }
    } else {
        giftuiDisplayLog(5, touchInitializationResult)
        calibration = nil
    }

    var model = ThermostatModel()
    guard var layout = renderThermostat(
        model: model,
        configuration: rendererConfiguration,
        previousLayout: nil,
        display: &display
    ) else {
        return -1
    }
    giftuiDisplayLogStack()

    guard let calibration else {
        while true {
            giftuiDisplaySleep(milliseconds: 60_000)
        }
    }

    var processor = XPT2046TouchProcessor(
        calibration: calibration,
        physicalSize: Size(
            width: displayConfiguration.logicalSize.width,
            height: displayConfiguration.logicalSize.height
        ),
        orientation: .degrees0
    )
    var pressedAction: ActionID?

    while true {
        let penState = xpt2046PenIsDown()
        if penState < 0 {
            giftuiDisplayLog(6, penState)
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
                giftuiDisplayLog(6, readError)
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
                       configuration: rendererConfiguration,
                       previousLayout: layout,
                       display: &display
                   ) {
                    layout = updatedLayout
                    giftuiDisplayLog(10, Int32(model.target))
                    giftuiDisplayLog(
                        11,
                        Int32(bitPattern:
                            giftuiDisplayUptimeMilliseconds() &- updateStartedAt)
                    )
                    giftuiDisplayLogStack()
                }
            }
        }

        giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
    }
}

private func captureCalibration(
    configuration: RGB565RendererConfiguration,
    display: inout ILI9341Display<ZephyrILI9341Transport>
) -> XPT2046Calibration? {
    guard let topLeft = captureCalibrationPoint(
            target: 1,
            x: calibrationTargetInset,
            y: calibrationTargetInset,
            configuration: configuration,
            display: &display
        ),
        let topRight = captureCalibrationPoint(
            target: 2,
            x: configuration.logicalSize.width - 1 - calibrationTargetInset,
            y: calibrationTargetInset,
            configuration: configuration,
            display: &display
        ),
        let bottomLeft = captureCalibrationPoint(
            target: 3,
            x: calibrationTargetInset,
            y: configuration.logicalSize.height - 1 - calibrationTargetInset,
            configuration: configuration,
            display: &display
        ),
        let bottomRight = captureCalibrationPoint(
            target: 4,
            x: configuration.logicalSize.width - 1 - calibrationTargetInset,
            y: configuration.logicalSize.height - 1 - calibrationTargetInset,
            configuration: configuration,
            display: &display
        ),
        let center = captureCalibrationPoint(
            target: 5,
            x: configuration.logicalSize.width / 2,
            y: configuration.logicalSize.height / 2,
            configuration: configuration,
            display: &display
        ) else {
        giftuiDisplayLog(8, -1)
        return nil
    }

    let samples = XPT2046CalibrationSamples(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        center: center
    )
    switch XPT2046Calibration.derive(
        samples: samples,
        targetInset: calibrationTargetInset
    ) {
    case .success(let calibration):
        giftuiDisplayLog(9, 0)
        return calibration
    case .failure:
        giftuiDisplayLog(8, -2)
        return nil
    }
}

private func captureCalibrationPoint(
    target: Int32,
    x: Int,
    y: Int,
    configuration: RGB565RendererConfiguration,
    display: inout ILI9341Display<ZephyrILI9341Transport>
) -> XPT2046RawSample? {
    guard renderCalibrationTarget(
        x: x,
        y: y,
        configuration: configuration,
        display: &display
    ) else {
        return nil
    }
    giftuiDisplayLog(7, target)

    let startedAt = giftuiDisplayUptimeMilliseconds()
    var loggedFirstSample = false
    while giftuiDisplayUptimeMilliseconds() &- startedAt
            < calibrationPointTimeoutMilliseconds {
        let penState = xpt2046PenIsDown()
        if penState < 0 {
            giftuiDisplayLog(6, penState)
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
            giftuiDisplayLog(6, readError)
            return nil
        }
        let sample = XPT2046RawSample.median(first, second, third)
        if !loggedFirstSample {
            giftuiTouchLogSample(
                target,
                sample.x,
                sample.y,
                sample.z1,
                sample.z2
            )
            loggedFirstSample = true
        }
        let threshold = XPT2046PressureThreshold()
        guard threshold.accepts(first),
              threshold.accepts(second),
              threshold.accepts(third) else {
            giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
            continue
        }
        guard waitForPenRelease() else {
            giftuiDisplayLog(8, -3)
            return nil
        }
        return sample
    }
    giftuiDisplayLog(8, -4)
    return nil
}

private func waitForPenRelease() -> Bool {
    let startedAt = giftuiDisplayUptimeMilliseconds()
    while giftuiDisplayUptimeMilliseconds() &- startedAt
            < releaseTimeoutMilliseconds {
        let penState = xpt2046PenIsDown()
        if penState < 0 { return false }
        if penState == 0 { return true }
        giftuiDisplaySleep(milliseconds: touchPollMilliseconds)
    }
    return false
}

private func readRawSample(error: inout Int32) -> XPT2046RawSample? {
    var x: UInt16 = 0
    var y: UInt16 = 0
    var z1: UInt16 = 0
    var z2: UInt16 = 0
    error = xpt2046ReadRawValues(&x, &y, &z1, &z2)
    guard error == 0 else { return nil }
    return XPT2046RawSample(x: x, y: y, z1: z1, z2: z2)
}

private func renderCalibrationTarget(
    x: Int,
    y: Int,
    configuration: RGB565RendererConfiguration,
    display: inout ILI9341Display<ZephyrILI9341Transport>
) -> Bool {
    var renderer = RGB565TileRenderer(configuration: configuration)
    var transportResult: Int32 = 0
    renderer.renderTiles { backend in
        backend.clear(.black)
        backend.fill(
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
        transportResult = present(tile: tile, bytes: bytes, display: &display)
    }
    if transportResult != 0 {
        giftuiDisplayLog(2, transportResult)
        return false
    }
    return true
}

private func renderThermostat(
    model: ThermostatModel,
    configuration: RGB565RendererConfiguration,
    previousLayout: StaticLayout?,
    display: inout ILI9341Display<ZephyrILI9341Transport>
) -> StaticLayout? {
    let layout: StaticLayout
    switch StaticRuntime().layoutResult(
        ThermostatPortableView(target: model.target),
        in: configuration.logicalSize
    ) {
    case .success(let resolvedLayout):
        layout = resolvedLayout
    case .failure:
        giftuiDisplayLog(2, -2)
        return nil
    }

    let startedAt = giftuiDisplayUptimeMilliseconds()
    let background = Color(red: 24, green: 26, blue: 32)
    let transportResult: Int32
    if let previousLayout {
        guard let dirtyRegion = layout.changedRenderBounds(
            comparedTo: previousLayout
        ) else {
            return layout
        }
        var renderer = RGB565RetainedRenderer(
            configuration: configuration,
            clipRegion: dirtyRegion,
            writer: KMRTMSolidRectWriter()
        )
        renderer.clear(background)
        layout.appendRenderOperations(to: &renderer)
        transportResult = renderer.writer.result
    } else {
        var renderer = RGB565TileRenderer(configuration: configuration)
        var initialTransportResult: Int32 = 0
        renderer.renderTiles { backend in
            backend.clear(background)
            layout.appendRenderOperations(to: &backend)
        } presenting: { tile, bytes in
            guard initialTransportResult == 0 else { return }
            initialTransportResult = present(
                tile: tile,
                bytes: bytes,
                display: &display
            )
        }
        transportResult = initialTransportResult
    }
    guard transportResult == 0 else {
        giftuiDisplayLog(2, transportResult)
        return nil
    }
    giftuiDisplayLog(
        previousLayout == nil ? 3 : 12,
        Int32(bitPattern: giftuiDisplayUptimeMilliseconds() &- startedAt)
    )
    return layout
}

private struct KMRTMSolidRectWriter: RGB565SolidRectWriter {
    private(set) var result: Int32 = 0

    mutating func writeSolidRect(_ rect: Rect, pixel: RGB565Pixel) {
        guard result == 0 else { return }
        result = kmrtmDisplayFillRGB565(
            UInt16(rect.origin.x),
            UInt16(rect.origin.y),
            UInt16(rect.size.width),
            UInt16(rect.size.height),
            pixel.rawValue
        )
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
