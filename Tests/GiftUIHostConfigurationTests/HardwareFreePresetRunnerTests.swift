import GiftUIRuntimeCore
import Testing

@testable import SignalAnalyzerPresetHarness

@Test func macOSHardwareFreePresetsHaveEqualSemanticsAndExactPhysicalProjection() throws {
    let dynamic = try HardwareFreePresetRunner.run(.macOSDynamic)
    let fixed = try HardwareFreePresetRunner.run(.macOSStatic)

    #expect(dynamic.profile == .dynamic)
    #expect(fixed.profile == .static)
    #expect(dynamic.logicalWidth == 320)
    #expect(dynamic.logicalHeight == 240)
    #expect(dynamic.regionHeight == 240)
    #expect(dynamic.bytesPerRow == 1_280)
    #expect(dynamic.rasterBytes == 307_200)
    #expect(dynamic.semanticChecksum == fixed.semanticChecksum)
    #expect(dynamic.resolverCalls == 1)
    #expect(fixed.resolverCalls == 1)
    #expect(dynamic.actionCount == 6)
    #expect(dynamic.compactFactCapacity == 32)
    #expect(dynamic.canvasCount == 5)
    #expect(dynamic.livePointCount == 202)
    #expect(dynamic.planPointCount == 832)
    #expect(dynamic.profileStorageBytes == 31_632)
    #expect(fixed.profileStorageBytes == 28_928)
    #expect(dynamic.workloadDurationMilliseconds == 30_000)
    #expect(dynamic.workloadEventRate == 80)
    #expect(dynamic.workloadEventCount == 2_400)
    #expect(dynamic.workloadFrameRate == 4)
    #expect(dynamic.workloadFrameCount == 120)
    #expect(dynamic.workloadFactHighWater == 20)
    #expect(dynamic.workloadChecksum == fixed.workloadChecksum)
}

@Test func raspberryPiHardwareFreePresetHasExactDynamicTiledProjection() throws {
    let report = try HardwareFreePresetRunner.run(.raspberryPiDynamic)

    #expect(report.profile == .dynamic)
    #expect(report.logicalWidth == 240)
    #expect(report.logicalHeight == 240)
    #expect(report.regionHeight == 16)
    #expect(report.bytesPerRow == 480)
    #expect(report.rasterBytes == 7_680)
    #expect(report.profileStorageBytes == 31_632)
    #expect(report.semanticChecksum == 360_515_885)
    #expect(report.resolverCalls == 1)
    #expect(report.workloadEventCount == 2_400)
    #expect(report.workloadFrameCount == 120)
}

@Test func nRF52840HardwareFreePresetHasExactStaticTiledProjection() throws {
    let report = try HardwareFreePresetRunner.run(.nrf52840Static)

    #expect(report.profile == .static)
    #expect(report.logicalWidth == 480)
    #expect(report.logicalHeight == 320)
    #expect(report.regionHeight == 4)
    #expect(report.bytesPerRow == 960)
    #expect(report.rasterBytes == 3_840)
    #expect(report.profileStorageBytes == 28_928)
    #expect(report.semanticChecksum == 360_515_885)
    #expect(report.resolverCalls == 1)
    #expect(report.workloadEventCount == 2_400)
    #expect(report.workloadFrameCount == 120)
}
