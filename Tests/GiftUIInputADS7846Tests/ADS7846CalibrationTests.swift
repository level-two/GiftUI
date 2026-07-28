import GiftUI
import GiftUIInputADS7846
import Testing

@Test
func calibrationDerivesAxesAndMapsFiveCapturedPoints() throws {
    let calibration = try ADS7846Calibration(samples: samples())

    #expect(calibration.rawXAtLeft == 202)
    #expect(calibration.rawXAtRight == 3802)
    #expect(calibration.rawYAtTop == 302)
    #expect(calibration.rawYAtBottom == 3702)
    #expect(calibration.map(raw(x: 202, y: 302), to: displaySize)
        == Point(x: 0, y: 0))
    #expect(calibration.map(raw(x: 3802, y: 3702), to: displaySize)
        == Point(x: 479, y: 319))
    #expect(calibration.map(raw(x: 2002, y: 2002), to: displaySize)
        == Point(x: 239, y: 159))
}

@Test
func calibrationHandlesInvertedAxesAndClampsOutsideSamples() throws {
    let calibration = try ADS7846Calibration(
        samples: samples(invertX: true, invertY: true)
    )

    #expect(calibration.map(raw(x: 4000, y: 4000), to: displaySize)
        == Point(x: 0, y: 0))
    #expect(calibration.map(raw(x: 0, y: 0), to: displaySize)
        == Point(x: 479, y: 319))
}

@Test
func calibrationRejectsWeakHorizontalSpan() {
    #expect(throws: ADS7846CalibrationError.insufficientHorizontalSpan(
        minimum: 256,
        actual: 10
    )) {
        _ = try ADS7846Calibration(samples: ADS7846CalibrationSamples(
            topLeft: raw(x: 1000, y: 300),
            topRight: raw(x: 1010, y: 300),
            bottomLeft: raw(x: 1000, y: 3700),
            bottomRight: raw(x: 1010, y: 3700),
            center: raw(x: 1005, y: 2000)
        ))
    }
}

@Test
func calibrationRejectsInconsistentCenterCapture() {
    #expect(throws: ADS7846CalibrationError.inconsistentCenter) {
        _ = try ADS7846Calibration(samples: ADS7846CalibrationSamples(
            topLeft: raw(x: 200, y: 300),
            topRight: raw(x: 3800, y: 300),
            bottomLeft: raw(x: 200, y: 3700),
            bottomRight: raw(x: 3800, y: 3700),
            center: raw(x: 300, y: 3500)
        ))
    }
}

private let displaySize = Size(width: 480, height: 320)

private func raw(x: UInt16, y: UInt16) -> ADS7846RawSample {
    ADS7846RawSample(x: x, y: y, z1: 900, z2: 1_800)
}

private func samples(
    invertX: Bool = false,
    invertY: Bool = false
) -> ADS7846CalibrationSamples {
    func x(_ value: UInt16) -> UInt16 { invertX ? 4_004 - value : value }
    func y(_ value: UInt16) -> UInt16 { invertY ? 4_004 - value : value }
    return ADS7846CalibrationSamples(
        topLeft: raw(x: x(200), y: y(300)),
        topRight: raw(x: x(3_800), y: y(304)),
        bottomLeft: raw(x: x(204), y: y(3_700)),
        bottomRight: raw(x: x(3_804), y: y(3_704)),
        center: raw(x: x(2_002), y: y(2_002))
    )
}
