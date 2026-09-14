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
    #expect(dynamic.profileStorageBytes == 30_416)
    #expect(fixed.profileStorageBytes == 28_016)
}
