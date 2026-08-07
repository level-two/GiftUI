import GiftUI
import GiftUIInputADS7846
import Testing

@Test func xpt2046NamesUseTheCompatibleSampleProcessor() throws {
    let samples = XPT2046CalibrationSamples(
        topLeft: raw(x: 300, y: 400),
        topRight: raw(x: 3_700, y: 400),
        bottomLeft: raw(x: 300, y: 3_600),
        bottomRight: raw(x: 3_700, y: 3_600),
        center: raw(x: 2_000, y: 2_000)
    )
    let calibration = try XPT2046Calibration(samples: samples)
    var processor = XPT2046TouchProcessor(
        calibration: calibration,
        physicalSize: Size(width: 240, height: 320)
    )

    let sample = raw(x: 2_000, y: 2_000)
    #expect(processor.process(
        penIsDown: true,
        first: sample,
        second: sample,
        third: sample
    ) == .pointerDown(Point(x: 119, y: 159)))
    #expect(processor.process(penIsDown: false)
        == .pointerUp(Point(x: 119, y: 159)))
}

private func raw(x: UInt16, y: UInt16) -> XPT2046RawSample {
    XPT2046RawSample(x: x, y: y, z1: 500, z2: 700)
}
