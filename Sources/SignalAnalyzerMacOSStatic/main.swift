import SignalAnalyzerPresetHarness

do {
    let report = try HardwareFreePresetRunner.run(.macOSStatic)
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("macOS Static hardware-free preset failed")
}
