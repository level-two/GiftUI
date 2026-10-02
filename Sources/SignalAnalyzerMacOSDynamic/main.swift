import GiftUIRuntimeDynamic
import SignalAnalyzerPresetHarness

do {
    let report = try HardwareFreePresetRunner.run(.macOSDynamic)
    // Exercise the selected profile's actual bounded candidate storage alongside
    // the deterministic preset corpus; a closure with neither profile is invalid.
    var candidates = DynamicInteractionCandidateStorage<UInt32>(capacity: report.actionCount)
    precondition(candidates.capacity == report.actionCount && candidates.count == 0)
    candidates.reset()
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("macOS Dynamic hardware-free preset failed")
}
