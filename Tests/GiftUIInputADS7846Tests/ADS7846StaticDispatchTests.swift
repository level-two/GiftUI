import GiftUI
import GiftUIExampleThermostatPortableView
import GiftUIInputADS7846
import GiftUIRuntimeStatic
import Testing

@Test
func completedFilteredTapDispatchesStaticThermostatActionOnce() throws {
    let surfaceSize = Size(width: 480, height: 320)
    let layout = try StaticRuntime().layout(
        ThermostatPortableView(target: 21),
        in: surfaceSize
    )
    let incrementPoint = try #require(point(
        for: ThermostatAction.increment,
        in: layout,
        surfaceSize: surfaceSize
    ))
    let calibration = try ADS7846Calibration(samples: ADS7846CalibrationSamples(
        topLeft: raw(x: 0, y: 0),
        topRight: raw(x: 4_095, y: 0),
        bottomLeft: raw(x: 0, y: 4_095),
        bottomRight: raw(x: 4_095, y: 4_095),
        center: raw(x: 2_047, y: 2_047)
    ))
    var processor = ADS7846TouchProcessor(
        calibration: calibration,
        physicalSize: surfaceSize
    )
    let touch = raw(
        x: UInt16(incrementPoint.x * 4_095 / (surfaceSize.width - 1)),
        y: UInt16(incrementPoint.y * 4_095 / (surfaceSize.height - 1))
    )
    var model = ThermostatModel()
    var pressedAction: ActionID?

    let down = processor.process(
        penIsDown: true,
        first: touch,
        second: touch,
        third: touch
    )
    if case .pointerDown(let point) = down {
        pressedAction = layout.action(at: point)
    }
    let up = processor.process(penIsDown: false)
    if case .pointerUp(let point) = up,
       let pressedAction,
       layout.action(at: point) == pressedAction {
        _ = model.dispatch(pressedAction)
    }

    #expect(model.target == 22)
    #expect(processor.process(penIsDown: false) == nil)
    #expect(model.target == 22)
}

private func point(
    for action: ActionID,
    in layout: StaticLayout,
    surfaceSize: Size
) -> Point? {
    for y in 0..<surfaceSize.height {
        for x in 0..<surfaceSize.width {
            let candidate = Point(x: x, y: y)
            if layout.action(at: candidate) == action {
                return Point(x: x + 4, y: y + 4)
            }
        }
    }
    return nil
}

private func raw(x: UInt16, y: UInt16) -> ADS7846RawSample {
    ADS7846RawSample(x: x, y: y, z1: 500, z2: 700)
}
