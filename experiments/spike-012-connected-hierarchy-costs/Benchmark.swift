// Disposable Cortex-M4 benchmark. Uses real packed staging and caller-owned regions.
import SignalAnalyzerDomain

@_cdecl("giftui_spike012_packed")
public func spike012Packed(_ profile: UnsafeMutableRawPointer, _ profileBytes: UInt32,
                          _ capture: UnsafeMutableRawPointer, _ captureBytes: UInt32,
                          _ diagnostic: UInt32, _ iterations: UInt32) -> UInt32 {
    guard profileBytes >= 3_024,
          var captures = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: capture, count: Int(captureBytes))) else { return UInt32.max }
    var model = StaticSignalAnalyzerNRFModelLocation()
    guard model.activate() != nil, model.beginMutation(), model.setAcquisitionState(.running) else { return UInt32.max }
    let text: StaticString = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    let error = text.withUTF8Buffer { SignalAnalyzerDiagnostic(exactUTF8: $0)! }
    guard model.setDiagnostic(diagnostic == 0 ? nil : error) else { return UInt32.max }
    var history = StaticSignalAnalyzerNRFCaptureHistory()
    for channel in 1...4 {
        let event = SignalTransition(channelID: SignalChannelID(rawValue: channel),
            timestamp: .milliseconds(17_300), level: channel.isMultiple(of: 2) ? .high : .low)
        guard case .accepted = history.receive(event, in: &captures) else { return UInt32.max }
    }
    guard let snapshot = history.snapshot(in: &captures),
          let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: UnsafeMutableRawBufferPointer(start: capture, count: Int(captureBytes)),
            revision: snapshot.revision, count: snapshot.count, duration: snapshot.duration,
            retainedLowerBound: snapshot.retainedLowerBound, baselineLevels: snapshot.baselineLevels),
          model.installCaptureSnapshot(view, in: &captures), model.endMutation() else { return UInt32.max }
    var sum: UInt32 = 0
    let region = UnsafeMutableRawBufferPointer(start: profile, count: 3_024)
    for _ in 0..<iterations {
        guard let bytes = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
            variant: diagnostic == 0 ? .normal : .diagnostic, model: model, capture: captures, in: region) else {
            model.retire(); return UInt32.max
        }
        sum &+= UInt32(bytes)
    }
    model.retire()
    return sum
}
