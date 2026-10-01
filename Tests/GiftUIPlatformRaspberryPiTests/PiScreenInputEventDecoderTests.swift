import GiftUI
import Testing

@testable import GiftUIPlatformRaspberryPi

@Test func evdevReportsCalibrateAndEmitOneContactPerPhysicalPhase() throws {
    let transform = try #require(
        PiScreenAspectFitTransform(
            physicalWidth: 480, physicalHeight: 320, logicalWidth: 240, logicalHeight: 240))
    let calibration = try #require(PiScreenTouchCalibration.signalAnalyzerPiScreen)
    var decoder = PiScreenInputEventDecoder(transform: transform, calibration: calibration)
    #expect(decoder.consume(type: 3, code: 0, value: 2048) == nil)
    #expect(decoder.consume(type: 3, code: 1, value: 1843) == nil)
    #expect(decoder.consume(type: 1, code: 330, value: 1) == nil)
    #expect(
        decoder.consume(type: 0, code: 0, value: 0)
            == PiScreenContactEvent(phase: .down, point: Point(x: 119, y: 119)))
    #expect(decoder.consume(type: 0, code: 0, value: 0) == nil)
    #expect(decoder.consume(type: 1, code: 330, value: 1) == nil)
    #expect(decoder.consume(type: 0, code: 0, value: 0) == nil)
    #expect(decoder.consume(type: 3, code: 0, value: 2400) == nil)
    let emittedMove = decoder.consume(type: 0, code: 0, value: 0)
    let move = try #require(emittedMove)
    #expect(move.phase == .move)
    #expect(move.point.x > 119)
    #expect(decoder.consume(type: 1, code: 330, value: 0) == nil)
    #expect(
        decoder.consume(type: 0, code: 0, value: 0)
            == PiScreenContactEvent(phase: .up, point: move.point))
    #expect(decoder.consume(type: 0, code: 0, value: 0) == nil)
    #expect(decoder.consume(type: 1, code: 330, value: 0) == nil)
    #expect(decoder.consume(type: 0, code: 0, value: 0) == nil)
}

@Test func evdevIgnoresUnknownRecordsAndContactsInLetterbox() throws {
    let transform = try #require(
        PiScreenAspectFitTransform(
            physicalWidth: 480, physicalHeight: 320, logicalWidth: 240, logicalHeight: 240))
    let calibration = try #require(PiScreenTouchCalibration.signalAnalyzerPiScreen)
    var decoder = PiScreenInputEventDecoder(transform: transform, calibration: calibration)
    #expect(decoder.consume(type: 3, code: 0, value: 0) == nil)
    #expect(decoder.consume(type: 3, code: 1, value: 2048) == nil)
    #expect(decoder.consume(type: 1, code: 330, value: 1) == nil)
    #expect(decoder.consume(type: 0, code: 0, value: 0) == nil)
    #expect(decoder.consume(type: 3, code: 0, value: 2048) == nil)
    #expect(decoder.consume(type: 9, code: 9, value: 1) == nil)
    #expect(decoder.consume(type: 0, code: 0, value: 0)?.phase == .down)
    #expect(decoder.consume(type: 3, code: 0, value: 0) == nil)
    #expect(decoder.consume(type: 0, code: 0, value: 0)?.phase == .move)
    #expect(decoder.consume(type: 1, code: 330, value: 0) == nil)
    #expect(decoder.consume(type: 0, code: 0, value: 0)?.phase == .up)
}
