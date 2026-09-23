import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func nRFSealedFactsApplyInOneModelMutationPhase() {
    let factBytes = 3_840
    let captureBytes = 115_392
    let active = UnsafeMutableRawPointer.allocate(byteCount: factBytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: factBytes, alignment: 8)
    let capture = UnsafeMutableRawPointer.allocate(byteCount: captureBytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
        capture.deallocate()
    }
    let captureStorage = UnsafeMutableRawBufferPointer(start: capture, count: captureBytes)
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: factBytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: factBytes)
        ),
        let snapshot = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: captureStorage, revision: 0, count: 0,
            duration: .zero, retainedLowerBound: .zero, baselineLevels: .allLow
        ),
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array(repeating: 0x45, count: 96)
        )
    else {
        Issue.record("Sealed application setup failed")
        return
    }
    let beganBootstrap = admission.beginProducer(.bootstrap)
    #expect(beganBootstrap)
    let admittedSnapshot = admission.admitSnapshot(snapshot)
    #expect(admittedSnapshot == .accepted(sequence: 1))
    let admittedState = admission.admitAcquisitionState(.running)
    #expect(admittedState == .accepted(sequence: 2))
    admission.endProducer()
    let beganAction = admission.beginProducer(.action)
    #expect(beganAction)
    let reset = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    let admittedMutation = admission.admitCaptureMutation(revision: 1, change: reset)
    #expect(admittedMutation == .accepted(sequence: 3))
    admission.endProducer()
    let admittedFailure = admission.admitOperationalFailure(
        conditionRawValue: 5, originRawValue: 9,
        affectedScopeRawValue: 4, containmentRawValue: 1,
        diagnostic: diagnostic
    )
    #expect(admittedFailure == .accepted(sequence: 4))
    let didSeal = admission.seal()
    #expect(didSeal)

    var model = StaticSignalAnalyzerNRFModelLocation()
    let generation = model.activate()
    #expect(generation == 0)
    let outOfPhase = admission.takeNextSealed()
    #expect(outOfPhase?.sequence == 1)
    if let outOfPhase {
        let rejected = model.applySealedFact(outOfPhase, captureStorage: captureStorage)
        #expect(rejected == .rejected)
    }
    let beganMutation = model.beginMutation()
    #expect(beganMutation)
    // The first fact was intentionally removed above; install its retained
    // value before applying the rest of the sealed sequence.
    if let outOfPhase {
        let applied = model.applySealedFact(outOfPhase, captureStorage: captureStorage)
        #expect(applied == .applied)
    }
    for expected in 2 ... 4 {
        guard let fact = admission.takeNextSealed() else {
            Issue.record("Missing sealed fact")
            return
        }
        #expect(fact.sequence == expected)
        let applied = model.applySealedFact(fact, captureStorage: captureStorage)
        #expect(applied == .applied)
    }
    #expect(model.capture.revision == 1)
    #expect(model.acquisitionState == .failed(diagnostic))
    #expect(model.errorMessage == diagnostic)
    #expect(model.isDirty)
    let endedMutation = model.endMutation()
    #expect(endedMutation)
}
