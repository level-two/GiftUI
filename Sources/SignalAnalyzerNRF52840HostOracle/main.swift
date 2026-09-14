import SignalAnalyzerPresetHarness

do {
    let report = try HardwareFreePresetRunner.run(.nrf52840Static)
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("nRF52840 Static hardware-free semantic oracle failed")
}
