import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func nRFCaptureAdmissionOwnsProducerLimitsAndSequences() {
    let bytes = 2_176
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
    let bytes = 2_176
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
