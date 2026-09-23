import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFSnapshotViewValidatesRecordsAndVisibleRange() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { pointer.deallocate() }
    let storage = UnsafeMutableRawBufferPointer(start: pointer, count: 115_392)
    let first = SignalTransition(
        channelID: SignalChannelID(rawValue: 1), timestamp: .milliseconds(100), level: .high
    )
    let second = SignalTransition(
        channelID: SignalChannelID(rawValue: 4), timestamp: .milliseconds(200), level: .low
    )
    do {
        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage),
            let firstRecord = StaticSignalAnalyzerNRFCaptureRecord(first),
            let secondRecord = StaticSignalAnalyzerNRFCaptureRecord(second)
        else {
            Issue.record("Snapshot storage or records did not construct")
            return
        }
        let storedFirst = regions.store(firstRecord, in: .snapshot, at: 0)
        let storedSecond = regions.store(secondRecord, in: .snapshot, at: 1)
        #expect(storedFirst)
        #expect(storedSecond)
    }

    do {
        guard
            let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
                storage: storage, revision: 2, count: 2, duration: .milliseconds(200),
                retainedLowerBound: .zero, baselineLevels: .allLow
            )
        else {
            Issue.record("Valid snapshot view was refused")
            return
        }
        #expect(view.transition(at: 0) == first)
        #expect(view.transition(at: 1) == second)
        #expect(view.transition(at: 2) == nil)
        #expect(
            view.visibleRange(window: .milliseconds(100))
                == (.milliseconds(100) ..< .milliseconds(200))
        )
    }

    let wrongRevision = StaticSignalAnalyzerNRFCaptureSnapshotView(
        storage: storage, revision: 0, count: 2, duration: .milliseconds(200),
        retainedLowerBound: .zero, baselineLevels: .allLow
    )
    if wrongRevision != nil { Issue.record("Revision-zero nonempty snapshot was accepted") }
    let wrongBound = StaticSignalAnalyzerNRFCaptureSnapshotView(
        storage: storage, revision: 2, count: 2, duration: .milliseconds(200),
        retainedLowerBound: .milliseconds(150), baselineLevels: .allLow
    )
    if wrongBound != nil { Issue.record("Out-of-bound transition was accepted") }

    do {
        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage),
            let unsorted = StaticSignalAnalyzerNRFCaptureRecord(
                SignalTransition(
                    channelID: SignalChannelID(rawValue: 4),
                    timestamp: .milliseconds(50), level: .low
                )
            )
        else {
            Issue.record("Malformed snapshot setup failed")
            return
        }
        let stored = regions.store(unsorted, in: .snapshot, at: 1)
        #expect(stored)
    }
    let wrongOrder = StaticSignalAnalyzerNRFCaptureSnapshotView(
        storage: storage, revision: 2, count: 2, duration: .milliseconds(200),
        retainedLowerBound: .zero, baselineLevels: .allLow
    )
    if wrongOrder != nil { Issue.record("Unsorted snapshot was accepted") }
}
