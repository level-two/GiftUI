import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func nRFRepositoryProducerReplaysPortableInitialAndScheduledCapture() {
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
        )
    else {
        Issue.record("Repository admission setup failed")
        return
    }
    var repository = StaticSignalAnalyzerNRFRepositoryProducer()
    var model = StaticSignalAnalyzerNRFModelLocation()
    var portable = SignalCaptureStore()
    var generator = DeterministicSignalGenerator(seed: 0x5EED)
    let generation = model.activate()
    #expect(generation == 0)

    let observed = repository.startObservation(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(observed == .accepted)
    let bootstrap = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(bootstrap == .applied(factCount: 2))
    #expect(model.capture.revision == 0)
    #expect(model.acquisitionState == .idle)

    let started = repository.start(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(started == .accepted)
    for channel in 1 ... 4 {
        _ = portable.receive(
            SignalTransition(
                channelID: SignalChannelID(rawValue: channel),
                timestamp: .zero, level: .low
            ))
    }
    let firstBatch = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(firstBatch == .applied(factCount: 5))
    #expect(model.acquisitionState == .running)

    for _ in 0 ..< 120 {
        for _ in 0 ..< 20 {
            let produced = repository.pollScheduled(
                admission: &admission, captureStorage: captureStorage
            )
            #expect(produced == .accepted)
            _ = portable.receive(generator.nextTransition())
        }
        let batch = model.applyAdmittedBatch(
            from: &admission, captureStorage: captureStorage
        )
        #expect(batch == .applied(factCount: 20))
    }
    #expect(model.capture.revision == portable.revision)
    #expect(Int(model.capture.count) == portable.capture.transitions.count)
    #expect(model.capture.duration == portable.capture.duration)
    #expect(model.capture.retainedLowerBound == portable.capture.retainedLowerBound)
    guard let regions = StaticSignalAnalyzerNRFCaptureRegions(storage: captureStorage) else {
        Issue.record("Capture records unavailable")
        return
    }
    for index in 0 ..< Int(model.capture.count) {
        #expect(
            regions.load(from: .snapshot, at: index)?.transition
                == portable.capture.transitions[index])
    }

    let stopped = repository.stop(admission: &admission)
    #expect(stopped == .accepted)
    let stopBatch = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(stopBatch == .applied(factCount: 1))
    #expect(model.acquisitionState == .stopped)
    let cleared = repository.clear(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(cleared == .accepted)
    _ = portable.clear()
    let clearBatch = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(clearBatch == .applied(factCount: 1))
    #expect(model.capture.revision == portable.revision)
    #expect(model.capture.count == 0)

    let restarted = repository.start(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(restarted == .accepted)
    let restartBatch = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(restartBatch == .applied(factCount: 1))
    for _ in 0 ..< 20 {
        let produced = repository.pollScheduled(
            admission: &admission, captureStorage: captureStorage
        )
        #expect(produced == .accepted)
        _ = portable.receive(generator.nextTransition())
    }
    let afterRestart = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(afterRestart == .applied(factCount: 20))
    #expect(model.capture.revision == portable.revision)
    #expect(Int(model.capture.count) == portable.capture.transitions.count)
    for index in 0 ..< Int(model.capture.count) {
        #expect(
            regions.load(from: .snapshot, at: index)?.transition
                == portable.capture.transitions[index])
    }
}

@Test func nRFRepositoryRevisionExhaustionAdmitsStateAndReservedFailure() {
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
        let expected = SignalAnalyzerDiagnostic(
            exactUTF8: Array("capture revision exhausted".utf8)
        )
    else {
        Issue.record("Terminal repository setup failed")
        return
    }
    var repository = StaticSignalAnalyzerNRFRepositoryProducer(initialRevision: .max)
    var model = StaticSignalAnalyzerNRFModelLocation()
    let generation = model.activate()
    #expect(generation == 0)
    let observed = repository.startObservation(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(observed == .accepted)
    let bootstrap = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(bootstrap == .applied(factCount: 2))
    let start = repository.start(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(start == .terminalFailureAdmitted)
    #expect(repository.acquisitionState == .failed(expected))
    #expect(admission.pendingCompactCount == 1)
    #expect(admission.pendingOperationalFailureCount == 1)
    let applied = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(applied == .applied(factCount: 2))
    #expect(model.acquisitionState == .failed(expected))
    #expect(model.errorMessage == expected)
    let repeated = repository.start(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(repeated == .rejected)
    #expect(repository.nextScheduledDelay == nil)
}

@Test func nRFRepositoryRevisionFailureRetainsReservedSlotAfterActionQuota() {
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
        )
    else {
        Issue.record("Reserved quota setup failed")
        return
    }
    var repository = StaticSignalAnalyzerNRFRepositoryProducer(initialRevision: .max)
    var model = StaticSignalAnalyzerNRFModelLocation()
    let generation = model.activate()
    #expect(generation == 0)
    let observed = repository.startObservation(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(observed == .accepted)
    let bootstrap = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(bootstrap == .applied(factCount: 2))
    let began = admission.beginProducer(.action)
    #expect(began)
    for _ in 0 ..< 6 {
        let admitted = admission.admitAcquisitionState(.running)
        #expect(admitted != .producerCapacityExhausted)
    }
    admission.endProducer()
    let terminal = repository.start(
        admission: &admission, captureStorage: captureStorage
    )
    #expect(terminal == .terminalFailureAdmitted)
    #expect(admission.pendingCompactCount == 6)
    #expect(admission.pendingOperationalFailureCount == 1)
    let applied = model.applyAdmittedBatch(
        from: &admission, captureStorage: captureStorage
    )
    #expect(applied == .applied(factCount: 7))
    #expect(repository.acquisitionState == model.acquisitionState)
}
