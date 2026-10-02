import GiftUIRuntimeStatic
import SignalAnalyzerPresetHarness

do {
    let report = try HardwareFreePresetRunner.run(.macOSStatic)
    // Exercise the selected profile's actual bounded candidate storage alongside
    // the deterministic preset corpus; a closure with neither profile is invalid.
    var candidates = StaticInteractionCandidateStorage<UInt32>(capacity: report.actionCount)!
    precondition(candidates.capacity == report.actionCount && candidates.count == 0)
    candidates.reset()
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("macOS Static hardware-free preset failed")
}
