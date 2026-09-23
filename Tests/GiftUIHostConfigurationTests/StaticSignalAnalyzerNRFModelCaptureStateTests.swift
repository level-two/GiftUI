import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFModelCaptureReplaysPortableMutationsInPlace() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { pointer.deallocate() }
    guard
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: pointer, count: 115_392)
        )
    else {
        Issue.record("Exact capture region did not construct")
        return
    }
    var model = StaticSignalAnalyzerNRFModelCaptureState()
    var portable = SignalCaptureStore()

    for index in 0 ..< 2_405 {
        let source = SignalTransition(
            channelID: SignalChannelID(rawValue: index % 4 + 1),
            timestamp: .milliseconds(index),
            level: index.isMultiple(of: 2) ? .high : .low
        )
        let before = portable.capture
        guard case .accepted(.mutation(let revision, let change)) = portable.receive(source)
        else {
            Issue.record("Portable source refused a valid transition")
            return
        }
        let result = model.apply(revision: revision, change: change, in: &regions)
        #expect(result == .applied(changed: before != portable.capture))
        #expect(model.revision == portable.revision)
        #expect(Int(model.count) == portable.capture.transitions.count)
        #expect(model.duration == portable.capture.duration)
        #expect(model.retainedLowerBound == portable.capture.retainedLowerBound)
        #expect(model.baselineLevels == portable.capture.baselineLevels)
    }

    for source in [
        SignalTransition(
            channelID: SignalChannelID(rawValue: 2),
            timestamp: .milliseconds(1_200), level: .high
        ),
        SignalTransition(
            channelID: SignalChannelID(rawValue: 3),
            timestamp: .seconds(35), level: .low
        ),
    ] {
        let before = portable.capture
        guard case .accepted(.mutation(let revision, let change)) = portable.receive(source)
        else {
            Issue.record("Portable source refused a valid insertion or trim")
            return
        }
        let result = model.apply(revision: revision, change: change, in: &regions)
        #expect(result == .applied(changed: before != portable.capture))
        #expect(model.revision == portable.revision)
        #expect(Int(model.count) == portable.capture.transitions.count)
        #expect(model.duration == portable.capture.duration)
        #expect(model.retainedLowerBound == portable.capture.retainedLowerBound)
        #expect(model.baselineLevels == portable.capture.baselineLevels)
    }

    for index in 0 ..< Int(model.count) {
        #expect(
            regions.load(from: .snapshot, at: index)?.transition
                == portable.capture.transitions[index]
        )
    }

    let oldRevision = model.revision
    let oldCount = model.count
    let invalid = model.apply(
        revision: oldRevision,
        change: .reset(baseRevision: oldRevision, baselines: .allLow),
        in: &regions
    )
    #expect(invalid == .rejected)
    #expect(model.revision == oldRevision)
    #expect(model.count == oldCount)

    let beforeClear = portable.capture
    guard case .accepted(.mutation(let clearRevision, let clearChange)) = portable.clear()
    else {
        Issue.record("Portable clear was refused")
        return
    }
    let cleared = model.apply(revision: clearRevision, change: clearChange, in: &regions)
    #expect(cleared == .applied(changed: beforeClear != portable.capture))
    #expect(model.count == 0)
    #expect(model.baselineLevels == portable.capture.baselineLevels)
    #expect(model.visibleRange(window: .seconds(2)) == (.zero ..< .seconds(2)))
}

@Test func staticNRFModelLocationAppliesSnapshotAndMutationInOwnedPhase() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { pointer.deallocate() }
    let storage = UnsafeMutableRawBufferPointer(start: pointer, count: 115_392)
    let first = SignalTransition(
        channelID: SignalChannelID(rawValue: 1),
        timestamp: .milliseconds(125), level: .high
    )
    do {
        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage),
            let record = StaticSignalAnalyzerNRFCaptureRecord(first)
        else {
            Issue.record("Bootstrap snapshot setup failed")
            return
        }
        let stored = regions.store(record, in: .admission, at: 0)
        #expect(stored)
    }

    var model = StaticSignalAnalyzerNRFModelLocation()
    withUnsafeMutablePointer(to: &model) { location in
        let generation = location.pointee.activate()
        let began = location.pointee.beginMutation()
        #expect(generation == 0)
        #expect(began)
        do {
            guard
                let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
                    storage: storage, revision: 1, count: 1,
                    duration: .milliseconds(125), retainedLowerBound: .zero,
                    baselineLevels: .allLow
                )
            else {
                Issue.record("Bootstrap snapshot was refused")
                return
            }
            guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage)
            else {
                Issue.record("Model capture region was refused")
                return
            }
            let installed = location.pointee.installCaptureSnapshot(view, in: &regions)
            #expect(installed)
            let repeated = location.pointee.installCaptureSnapshot(view, in: &regions)
            #expect(!repeated)
            #expect(regions.load(from: .snapshot, at: 0)?.transition == first)
        }
        #expect(location.pointee.capture.revision == 1)
        #expect(location.pointee.capture.count == 1)
        #expect(location.pointee.visibleRange == (.zero ..< .seconds(2)))
        location.pointee.clearDirtyAfterPublication()
        #expect(!location.pointee.isDirty)
        let ended = location.pointee.endMutation()
        #expect(ended)

        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage)
        else {
            Issue.record("Mutation region was refused")
            return
        }
        let nextAdmission = SignalTransition(
            channelID: SignalChannelID(rawValue: 2),
            timestamp: .milliseconds(150), level: .low
        )
        guard let nextAdmissionRecord = StaticSignalAnalyzerNRFCaptureRecord(nextAdmission)
        else {
            Issue.record("Next admission transition was refused")
            return
        }
        let replacedAdmission = regions.store(nextAdmissionRecord, in: .admission, at: 0)
        #expect(replacedAdmission)
        #expect(regions.load(from: .snapshot, at: 0)?.transition == first)
        let second = SignalTransition(
            channelID: SignalChannelID(rawValue: 4),
            timestamp: .milliseconds(200), level: .low
        )
        let change = SignalCaptureChange.insertAndTrim(
            baseRevision: 1, insertionIndex: 1, transition: second,
            evictedPrefixCount: 0, duration: .milliseconds(200),
            retainedLowerBound: .zero, baselines: .allLow
        )
        let outOfPhase = location.pointee.applyCaptureMutation(
            revision: 2, change: change, in: &regions
        )
        #expect(outOfPhase == .rejected)
        #expect(location.pointee.capture.count == 1)
        let restarted = location.pointee.beginMutation()
        #expect(restarted)
        let applied = location.pointee.applyCaptureMutation(
            revision: 2, change: change, in: &regions
        )
        #expect(applied == .applied(changed: true))
        #expect(location.pointee.capture.revision == 2)
        #expect(location.pointee.capture.count == 2)
        #expect(location.pointee.isDirty)
        #expect(regions.load(from: .snapshot, at: 1)?.transition == second)
        let finished = location.pointee.endMutation()
        #expect(finished)
        location.pointee.retire()
    }
}
