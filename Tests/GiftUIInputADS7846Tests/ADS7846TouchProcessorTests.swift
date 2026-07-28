import GiftUI
import GiftUIInputADS7846
import Testing

@Test
func pressureThresholdRejectsNoiseAndExcessResistance() {
    let threshold = ADS7846PressureThreshold(
        minimumZ1: 100,
        maximumResistance: 2_000
    )

    #expect(!threshold.accepts(raw(x: 2_000, y: 2_000, z1: 99, z2: 1_000)))
    #expect(!threshold.accepts(raw(x: 2_000, y: 2_000, z1: 500, z2: 400)))
    #expect(!threshold.accepts(raw(x: 2_000, y: 2_000, z1: 500, z2: 1_100)))
    #expect(threshold.accepts(raw(x: 2_000, y: 2_000, z1: 500, z2: 900)))
}

@Test
func processorFiltersOutlierAndEmitsOneRelease() throws {
    var processor = ADS7846TouchProcessor(
        calibration: try calibration(),
        physicalSize: physicalSize
    )

    let down = processor.process(
        penIsDown: true,
        first: raw(x: 2_000, y: 2_000),
        second: raw(x: 4_000, y: 100),
        third: raw(x: 2_004, y: 2_004)
    )
    #expect(down == .pointerDown(Point(x: 240, y: 159)))
    #expect(processor.process(penIsDown: false)
        == .pointerUp(Point(x: 240, y: 159)))
    #expect(processor.process(penIsDown: false) == nil)
}

@Test
func processorIgnoresInvalidPressureWithoutSynthesizingRelease() throws {
    var processor = ADS7846TouchProcessor(
        calibration: try calibration(),
        physicalSize: physicalSize
    )
    let valid = raw(x: 2_000, y: 2_000)
    #expect(processor.process(
        penIsDown: true,
        first: valid,
        second: valid,
        third: valid
    ) != nil)

    let invalid = raw(x: 2_000, y: 2_000, z1: 20, z2: 21)
    #expect(processor.process(
        penIsDown: true,
        first: invalid,
        second: invalid,
        third: invalid
    ) == nil)
    #expect(processor.process(penIsDown: false) != nil)
}

@Test(arguments: [
    (ADS7846Orientation.degrees0, Point(x: 0, y: 0)),
    (ADS7846Orientation.degrees90, Point(x: 0, y: 479)),
    (ADS7846Orientation.degrees180, Point(x: 479, y: 319)),
    (ADS7846Orientation.degrees270, Point(x: 319, y: 0)),
])
func processorMapsPhysicalOriginIntoRendererOrientation(
    orientation: ADS7846Orientation,
    expected: Point
) throws {
    var processor = ADS7846TouchProcessor(
        calibration: try calibration(),
        physicalSize: physicalSize,
        orientation: orientation
    )
    let sample = raw(x: 200, y: 300)

    #expect(processor.process(
        penIsDown: true,
        first: sample,
        second: sample,
        third: sample
    ) == .pointerDown(expected))
}

private let physicalSize = Size(width: 480, height: 320)

private func raw(
    x: UInt16,
    y: UInt16,
    z1: UInt16 = 500,
    z2: UInt16 = 900
) -> ADS7846RawSample {
    ADS7846RawSample(x: x, y: y, z1: z1, z2: z2)
}

private func calibration() throws -> ADS7846Calibration {
    try ADS7846Calibration(samples: ADS7846CalibrationSamples(
        topLeft: raw(x: 200, y: 300),
        topRight: raw(x: 3_800, y: 300),
        bottomLeft: raw(x: 200, y: 3_700),
        bottomRight: raw(x: 3_800, y: 3_700),
        center: raw(x: 2_000, y: 2_000)
    ))
}
