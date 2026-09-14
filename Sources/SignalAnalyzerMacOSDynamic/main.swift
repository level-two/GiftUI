import SignalAnalyzerPresetHarness

do {
    let report = try HardwareFreePresetRunner.run(.macOSDynamic)
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("macOS Dynamic hardware-free preset failed")
}
