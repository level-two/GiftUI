import SignalAnalyzerDomain
import SignalAnalyzerPresentation
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
        #expect(rejected == .rejected(.mutationPhaseViolation))
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

@Test func nRFAdmittedBatchSealsAndAppliesWithoutReentry() {
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
        ), let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: [0x45, 0x52, 0x52])
    else {
        Issue.record("Batch setup failed")
        return
    }
    let began = admission.beginProducer(.bootstrap)
    #expect(began)
    let admittedSnapshot = admission.admitSnapshot(snapshot)
    let admittedState = admission.admitAcquisitionState(.running)
    #expect(admittedSnapshot == .accepted(sequence: 1))
    #expect(admittedState == .accepted(sequence: 2))
    admission.endProducer()
    let admittedFailure = admission.admitOperationalFailure(
        conditionRawValue: 5, originRawValue: 9,
        affectedScopeRawValue: 4, containmentRawValue: 1,
        diagnostic: diagnostic
    )
    #expect(admittedFailure == .accepted(sequence: 3))
    var model = StaticSignalAnalyzerNRFModelLocation()
    let generation = model.activate()
    #expect(generation == 0)
    let applied = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(applied == .applied(factCount: 3))
    #expect(model.acquisitionState == .failed(diagnostic))
    #expect(!model.isMutating)
    #expect(admission.sealedCompactCount == 0)
    #expect(admission.sealedSnapshotCount == 0)
    #expect(admission.sealedOperationalFailureCount == 0)
    let empty = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(empty == .applied(factCount: 0))
}

@Test func nRFPartialBatchFailureRetainsExactCauseAndDoesNotReplay() {
    for prefix in [UInt16(0), 1, 3] {
        let active = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
        let sealed = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
        let capture = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
        defer {
            active.deallocate()
            sealed.deallocate()
            capture.deallocate()
        }
        let storage = UnsafeMutableRawBufferPointer(start: capture, count: 115_392)
        guard
            var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
                activeStorage: UnsafeMutableRawBufferPointer(start: active, count: 3_840),
                sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: 3_840)
            ),
            let snapshot = StaticSignalAnalyzerNRFCaptureSnapshotView(
                storage: storage, revision: 0, count: 0, duration: .zero,
                retainedLowerBound: .zero, baselineLevels: .allLow
            )
        else {
            Issue.record("Invalid fixed test regions")
            return
        }
        var model = StaticSignalAnalyzerNRFModelLocation()
        #expect((model.activate() == 0))
        let beganBootstrap = admission.beginProducer(.bootstrap)
        #expect(beganBootstrap)
        #expect((admission.admitSnapshot(snapshot) == .accepted(sequence: 1)))
        admission.endProducer()
        #expect(
            (model.applyAdmittedBatch(from: &admission, captureStorage: storage)
                == .applied(factCount: 1)))
        model.clearDirtyAfterPublication()
        let beganAction = admission.beginProducer(.action)
        #expect(beganAction)
        for index in 0 ..< prefix {
            let state: AcquisitionState = index % 2 == 0 ? .running : .stopped
            #expect(
                (admission.admitAcquisitionState(state)
                    == .accepted(sequence: UInt32(index) + 2)))
        }
        #expect(
            (admission.admitCaptureMutation(
                revision: 2,
                change: .reset(baseRevision: 1, baselines: .allLow))
                == .accepted(sequence: UInt32(prefix) + 2)))
        #expect(
            (admission.admitAcquisitionState(.stopped)
                == .accepted(sequence: UInt32(prefix) + 3)))
        admission.endProducer()
        #expect(
            (model.applyAdmittedBatch(from: &admission, captureStorage: storage)
                == .failure(
                    .captureRevisionMismatch, mutationApplied: prefix > 0,
                    appliedCount: prefix)))
        #expect((model.capture.revision == 0))
        #expect((model.acquisitionState == (prefix == 0 ? .idle : .running)))
        #expect((model.isDirty == (prefix > 0)))
        #expect((!model.isMutating))
        #expect((admission.sealedCompactCount == 0))
        #expect(
            (model.applyAdmittedBatch(from: &admission, captureStorage: storage)
                == .applied(factCount: 0)))
        #expect((model.acquisitionState == (prefix == 0 ? .idle : .running)))
    }
}
