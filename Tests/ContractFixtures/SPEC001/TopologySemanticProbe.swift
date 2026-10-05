// Maintained 42-case semantic corpus over the exact production firmware closure.
import SignalAnalyzerDomain
@main
struct TopologySemanticProbe {
    static func main() {
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: 19_392, alignment: 8)
        defer { pointer.deallocate() }
        pointer.initializeMemory(as: UInt8.self, repeating: 0, count: 19_392)
        var captures = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: pointer, count: 19_392))!
        var cases = 0
        for populated in [false, true] {
            for state in 0..<4 {
                for window in UInt16(3)...UInt16(5) {
                    for diagnostic in [false, true] {
                        if state == 3 && !diagnostic { continue }
                        var model = StaticSignalAnalyzerNRFModelLocation()
                        let generation = model.activate()!
                        precondition(model.beginMutation())
                        let error = SignalAnalyzerDiagnostic(exactUTF8: [UInt8](repeating: 0x0A, count: 96))!
                        let acquisition: AcquisitionState
                        switch state {
                        case 0: acquisition = .idle
                        case 1: acquisition = .running
                        case 2: acquisition = .stopped
                        default: acquisition = .failed(error)
                        }
                        precondition(model.setAcquisitionState(acquisition))
                        precondition(model.setDiagnostic(diagnostic ? error : nil))
                        withUnsafeMutablePointer(to: &model) { location in
                            let handle = StaticSignalAnalyzerNRFModelHandle(location: location, generation: generation)!
                            precondition(handle.dispatch(actionRawValue: window) == .visibleWindowChanged)
                        }
                        var history = StaticSignalAnalyzerNRFCaptureHistory()
                        if populated {
                            for channel in 1...4 {
                                let event = SignalTransition(channelID: SignalChannelID(rawValue: channel),
                                    timestamp: .milliseconds(17_300), level: channel.isMultiple(of: 2) ? .high : .low)
                                guard case .accepted = history.receive(event, in: &captures) else {
                                    preconditionFailure("history fixture failed")
                                }
                            }
                        }
                        let snapshot = history.snapshot(in: &captures)!
                        let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
                            storage: UnsafeMutableRawBufferPointer(start: pointer, count: 19_392),
                            revision: snapshot.revision, count: snapshot.count, duration: snapshot.duration,
                            retainedLowerBound: snapshot.retainedLowerBound, baselineLevels: snapshot.baselineLevels)!
                        precondition(model.installCaptureSnapshot(view, in: &captures))
                        precondition(model.endMutation())
                        var bytes = [UInt8](repeating: 0, count: 3_024)
                        bytes.withUnsafeMutableBytes { region in
                            precondition(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                                variant: diagnostic ? .diagnostic : .normal, model: model,
                                capture: captures, in: region) != nil)
                        }
                        print("case \(populated) \(state) \(window) \(diagnostic)")
                        for byte in bytes { print(byte, terminator: ",") }
                        print()
                        // Exact first-excess/wrong-variant refusal must remain deterministic.
                        var short = [UInt8](repeating: 0, count: 3_023)
                        short.withUnsafeMutableBytes { region in
                            precondition(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                                variant: diagnostic ? .diagnostic : .normal, model: model,
                                capture: captures, in: region) == nil)
                        }
                        bytes.withUnsafeMutableBytes { region in
                            precondition(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                                variant: diagnostic ? .normal : .diagnostic, model: model,
                                capture: captures, in: region) == nil)
                        }
                        model.retire()
                        cases += 1
                    }
                }
            }
        }
        precondition(cases == 42)
        print("cases=42; short-region and wrong-variant refusals=84; retirement=42")
    }
}
