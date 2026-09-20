import SignalAnalyzerTargetHost

private func consumeStorage(
    _ storage: consuming StaticSignalAnalyzerNRFFirmwareInputStorage
) {}

private func attemptCopy(
    _ storage: consuming StaticSignalAnalyzerNRFFirmwareInputStorage
) {
    let duplicate = copy storage
    consumeStorage(consume duplicate)
    consumeStorage(consume storage)
}
