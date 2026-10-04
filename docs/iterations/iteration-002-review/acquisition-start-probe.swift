import SignalAnalyzerDomain

private final class CaptureRecorder: SignalCaptureSink {
    var terminalCount = 0

    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome {
        if case .terminalFailure = publication { terminalCount += 1 }
        return .accepted(sequence: 1)
    }
}

private final class StateRecorder: AcquisitionStateSink {
    var runningCount = 0

    func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome {
        if state == .running { runningCount += 1 }
        return .accepted(sequence: 2)
    }
}

@main
private enum AcquisitionStartResearch {
    static func main() throws {
        for revision in [UInt32.max - 1, UInt32.max] {
            let source = DeterministicSignalDataSource()
            let repository = DefaultSignalAcquisitionRepository(
                source: source, initialRevision: revision)
            let captures = CaptureRecorder()
            let states = StateRecorder()
            repository.startObservingCapture(sink: captures)
            repository.startObservingAcquisitionState(sink: states)
            try repository.start()
            print("initialRevision=\(revision)")
            print("terminalPublications=\(captures.terminalCount)")
            print("repositoryRunning=\(repository.acquisitionState == .running)")
            print("sourceActive=\(source.activeGeneration != nil)")
            print("ordinaryRunningPublications=\(states.runningCount)")
            do {
                try repository.start()
                print("secondStart=returned")
            } catch {
                print("secondStart=unavailable")
            }
        }
    }
}
