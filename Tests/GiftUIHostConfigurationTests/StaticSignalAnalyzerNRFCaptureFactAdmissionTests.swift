import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@Test func nRFCaptureAdmissionResumesPendingFactsAndSequenceWithoutReset() {
    let bytes = 3_840
    let active = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
    }
    let activeRegion = UnsafeMutableRawBufferPointer(start: active, count: bytes)
    let sealedRegion = UnsafeMutableRawBufferPointer(start: sealed, count: bytes)
    let change = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    do {
        guard
            var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
                activeStorage: activeRegion, sealedStorage: sealedRegion
            )
        else {
            Issue.record("Initial admission regions refused")
            return
        }
        let began = admission.beginProducer(.transition)
        #expect(began)
        let admitted = admission.admitCaptureMutation(revision: 1, change: change)
        #expect(admitted == .accepted(sequence: 1))
        admission.endProducer()
    }
    do {
        guard
            var resumed = StaticSignalAnalyzerNRFCaptureFactAdmission(
                resumingActiveStorage: activeRegion, sealedStorage: sealedRegion
            )
        else {
            Issue.record("Previously initialized admission regions refused")
            return
        }
        #expect(resumed.pendingCompactCount == 1)
        let began = resumed.beginProducer(.action)
        #expect(began)
        let admitted = resumed.admitCaptureMutation(revision: 1, change: change)
        #expect(admitted == .accepted(sequence: 2))
        resumed.endProducer()
        let sealedFacts = resumed.seal()
        #expect(sealedFacts)
        let first = resumed.takeNextSealed()
        let second = resumed.takeNextSealed()
        let empty = resumed.takeNextSealed()
        #expect(first?.sequence == 1)
        #expect(second?.sequence == 2)
        #expect(empty == nil)
    }
}

@Test func nRFCaptureAdmissionOwnsProducerLimitsAndSequences() {
    let bytes = 3_840
    let active = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
    }
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: bytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: bytes)
        )
    else {
        Issue.record("Exact admission regions refused")
        return
    }
    let change = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    let beforeProducer = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(beforeProducer == .producerUnavailable)
    let beganTransition = admission.beginProducer(.transition)
    #expect(beganTransition)
    let nestedProducer = admission.beginProducer(.bootstrap)
    #expect(!nestedProducer)
    for index in 1 ... 20 {
        let admitted = admission.admitCaptureMutation(revision: 1, change: change)
        #expect(admitted == .accepted(sequence: UInt32(index)))
    }
    let excess = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(excess == .producerCapacityExhausted)
    admission.endProducer()
    let beganBootstrap = admission.beginProducer(.bootstrap)
    #expect(beganBootstrap)
    let firstBootstrap = admission.admitCaptureMutation(revision: 1, change: change)
    let secondBootstrap = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(firstBootstrap == .accepted(sequence: 21))
    #expect(secondBootstrap == .accepted(sequence: 22))
    admission.endProducer()
    let didSeal = admission.seal()
    #expect(didSeal)
    #expect(admission.pendingCompactCount == 0)
    #expect(admission.sealedCompactCount == 22)
    for index in 1 ... 22 {
        let taken = admission.takeNextSealed()
        #expect(taken?.sequence == UInt32(index))
    }
    let beganAction = admission.beginProducer(.action)
    #expect(beganAction)
    let afterSeal = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(afterSeal == .accepted(sequence: 23))
    admission.endProducer()
    admission.quiesce()
    let afterQuiesce = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(afterQuiesce == .producerUnavailable)
    admission.discardAll()
    #expect(admission.pendingCompactCount == 0)
}

@Test func nRFCaptureAdmissionStopsBeforeSequenceWrap() {
    let bytes = 3_840
    let active = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
    }
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: bytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: bytes),
            nextSequence: .max
        )
    else {
        Issue.record("Exact admission regions refused")
        return
    }
    let change = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    let began = admission.beginProducer(.transition)
    #expect(began)
    let last = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(last == .accepted(sequence: .max))
    let exhausted = admission.admitCaptureMutation(revision: 1, change: change)
    #expect(exhausted == .sequenceExhausted)
    #expect(admission.pendingCompactCount == 1)
}

@Test func nRFAcquisitionFailurePreservesMaximumDiagnosticThroughSeal() {
    let bytes = 3_840
    let active = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
    }
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: bytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: bytes)
        ),
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array(repeating: 0x57, count: 96)
        )
    else {
        Issue.record("Exact failure admission setup failed")
        return
    }
    let began = admission.beginProducer(.bootstrap)
    #expect(began)
    let state = AcquisitionState.failed(diagnostic)
    let admittedState = admission.admitAcquisitionState(state)
    #expect(admittedState == .accepted(sequence: 1))
    let reset = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    let admittedMutation = admission.admitCaptureMutation(revision: 1, change: reset)
    #expect(admittedMutation == .accepted(sequence: 2))
    admission.endProducer()
    let didSeal = admission.seal()
    #expect(didSeal)
    let first = admission.takeNextSealed()
    #expect(first?.sequence == 1)
    #expect(first?.acquisitionState == state)
    let second = admission.takeNextSealed()
    #expect(second?.sequence == 2)
    #expect(second?.captureMutation?.revision == 1)
    let empty = admission.takeNextSealed()
    #expect(empty == nil)
}

@Test func nRFReservedOperationalFailureHasIndependentCapacityAndOrder() {
    let bytes = 3_840
    let active = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
    }
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: bytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: bytes)
        ),
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array(repeating: 0x46, count: 96)
        )
    else {
        Issue.record("Reserved failure setup failed")
        return
    }
    let began = admission.beginProducer(.action)
    #expect(began)
    let first = admission.admitAcquisitionState(.running)
    #expect(first == .accepted(sequence: 1))
    admission.endProducer()
    let failure = admission.admitOperationalFailure(
        conditionRawValue: 3, originRawValue: 9,
        affectedScopeRawValue: 3, containmentRawValue: 0,
        diagnostic: diagnostic
    )
    #expect(failure == .accepted(sequence: 2))
    #expect(admission.pendingCompactCount == 1)
    #expect(admission.pendingOperationalFailureCount == 1)
    let excess = admission.admitOperationalFailure(
        conditionRawValue: 3, originRawValue: 9,
        affectedScopeRawValue: 3, containmentRawValue: 0,
        diagnostic: diagnostic
    )
    #expect(excess == .reservedFailureCapacityExhausted)
    let didSeal = admission.seal()
    #expect(didSeal)
    #expect(admission.pendingOperationalFailureCount == 0)
    #expect(admission.sealedOperationalFailureCount == 1)
    let beforeFailure = admission.admitOperationalFailure(
        conditionRawValue: 3, originRawValue: 9,
        affectedScopeRawValue: 3, containmentRawValue: 0,
        diagnostic: diagnostic
    )
    #expect(beforeFailure == .reservedFailureCapacityExhausted)
    let takenState = admission.takeNextSealed()
    #expect(takenState?.sequence == 1)
    #expect(takenState?.acquisitionState == .running)
    let takenFailure = admission.takeNextSealed()
    #expect(takenFailure?.sequence == 2)
    #expect(takenFailure?.operationalFailure?.diagnostic == diagnostic)
    #expect(takenFailure?.operationalFailure?.conditionRawValue == 3)
    #expect(admission.sealedOperationalFailureCount == 0)
    let reused = admission.admitOperationalFailure(
        conditionRawValue: 5, originRawValue: 9,
        affectedScopeRawValue: 4, containmentRawValue: 1,
        diagnostic: diagnostic
    )
    #expect(reused == .accepted(sequence: 3))
}

@Test func nRFReservedFailureRoundTripsPortableValue() {
    let bytes = 3_840
    let active = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    let sealed = UnsafeMutableRawPointer.allocate(byteCount: bytes, alignment: 8)
    defer {
        active.deallocate()
        sealed.deallocate()
    }
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: bytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: bytes)
        ),
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: Array(repeating: 0x57, count: 96)
        )
    else {
        Issue.record("Portable failure setup failed")
        return
    }
    let original = SignalAnalyzerOperationalFailure(
        failure: GiftUIFailureFact(
            condition: .invalidProvenance,
            origin: .presentationIntegration,
            affectedScope: .runtime,
            containment: .safetyNotProven
        ),
        diagnostic: diagnostic
    )
    let admitted = admission.admitOperationalFailure(original)
    #expect(admitted == .accepted(sequence: 1))
    let didSeal = admission.seal()
    #expect(didSeal)
    let sealedFact = admission.takeNextSealed()
    #expect(sealedFact?.operationalFailure?.portableValue == original)
}

@Test func nRFSnapshotAdmissionMergesOnePhysicalSlotInSequence() {
    #expect(MemoryLayout<StaticSignalAnalyzerNRFSnapshotFact>.stride <= 48)
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
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(start: active, count: factBytes),
            sealedStorage: UnsafeMutableRawBufferPointer(start: sealed, count: factBytes)
        ),
        let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: UnsafeMutableRawBufferPointer(start: capture, count: captureBytes),
            revision: 1, count: 0, duration: .zero,
            retainedLowerBound: .zero, baselineLevels: .allLow
        )
    else {
        Issue.record("Snapshot admission setup failed")
        return
    }
    let began = admission.beginProducer(.bootstrap)
    #expect(began)
    let reset = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    let mutation = admission.admitCaptureMutation(revision: 1, change: reset)
    #expect(mutation == .accepted(sequence: 1))
    let canAdmitFirst = admission.canAdmitSnapshot
    #expect(canAdmitFirst)
    let snapshot = admission.admitSnapshot(view)
    #expect(snapshot == .accepted(sequence: 2))
    let canAdmitDuplicate = admission.canAdmitSnapshot
    #expect(!canAdmitDuplicate)
    admission.endProducer()
    let didSeal = admission.seal()
    #expect(didSeal)
    #expect(admission.pendingSnapshotCount == 0)
    #expect(admission.sealedSnapshotCount == 1)
    let first = admission.takeNextSealed()
    #expect(first?.sequence == 1)
    #expect(first?.captureMutation?.change == reset)

    let beganAgain = admission.beginProducer(.action)
    #expect(beganAgain)
    let canAdmitWhileSealed = admission.canAdmitSnapshot
    #expect(!canAdmitWhileSealed)
    let duplicate = admission.admitSnapshot(view)
    #expect(duplicate == .snapshotCapacityExhausted)
    admission.endProducer()
    let second = admission.takeNextSealed()
    #expect(second?.sequence == 2)
    if case .snapshot(let fact) = second {
        #expect(fact.revision == 1)
        #expect(fact.count == 0)
    } else {
        Issue.record("Snapshot did not retain its ordered slot")
    }
    #expect(admission.sealedSnapshotCount == 0)

    let beganFinal = admission.beginProducer(.bootstrap)
    #expect(beganFinal)
    let canAdmitAfterDrain = admission.canAdmitSnapshot
    #expect(canAdmitAfterDrain)
    let next = admission.admitSnapshot(view)
    #expect(next == .accepted(sequence: 3))
    admission.endProducer()
    let sealedSnapshotOnly = admission.seal()
    #expect(sealedSnapshotOnly)
    let third = admission.takeNextSealed()
    #expect(third?.sequence == 3)
}
