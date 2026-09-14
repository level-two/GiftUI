import SignalAnalyzerPresetHarness

do {
    let report = try HardwareFreePresetRunner.run(.raspberryPiDynamic)
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("Raspberry Pi ARMv6 hardware-free preset failed")
}
