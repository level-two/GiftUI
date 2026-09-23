import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFCaptureRecordFitsThreeExactFirmwareSlots() {
    #expect(MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.size == 16)
    #expect(MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.stride == 16)
    #expect(StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount == 115_392)

    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { pointer.deallocate() }
    let storage = UnsafeMutableRawBufferPointer(start: pointer, count: 115_392)
    guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage) else {
        Issue.record("Exact nRF capture region did not construct")
        return
    }
    let live = SignalTransition(
        channelID: SignalChannelID(rawValue: 1),
        timestamp: .seconds(30) + .microseconds(125),
        level: .high
    )
    let snapshot = SignalTransition(
        channelID: SignalChannelID(rawValue: 4),
        timestamp: .seconds(29) + .microseconds(999_999),
        level: .low
    )
    guard let liveRecord = StaticSignalAnalyzerNRFCaptureRecord(live),
        let snapshotRecord = StaticSignalAnalyzerNRFCaptureRecord(snapshot)
    else {
        Issue.record("Valid transitions did not encode")
        return
    }
    let wroteLive = regions.store(liveRecord, in: .live, at: 2_403)
    let wroteSnapshot = regions.store(snapshotRecord, in: .admission, at: 0)
    let loadedLive = regions.load(from: .live, at: 2_403)?.transition
    let loadedSnapshot = regions.load(from: .admission, at: 0)?.transition
    let pastEnd = regions.load(from: .live, at: 2_404)
    let beforeStart = regions.load(from: .admission, at: -1)
    let wrotePastEnd = regions.store(liveRecord, in: .admission, at: 2_404)
    #expect(wroteLive)
    #expect(wroteSnapshot)
    #expect(loadedLive == live)
    #expect(loadedSnapshot == snapshot)
    #expect(pastEnd == nil)
    #expect(beforeStart == nil)
    #expect(!wrotePastEnd)
}

@Test func staticNRFCaptureRegionsRejectWrongSizeAndAlignment() {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 115_400, alignment: 8)
    defer { pointer.deallocate() }
    let wrongSize = StaticSignalAnalyzerNRFCaptureRegions(
        storage: UnsafeMutableRawBufferPointer(start: pointer, count: 115_391)
    )
    switch consume wrongSize {
    case nil: break
    case .some: Issue.record("Undersized capture region was accepted")
    }
    let misaligned = StaticSignalAnalyzerNRFCaptureRegions(
        storage: UnsafeMutableRawBufferPointer(
            start: pointer.advanced(by: 1), count: 115_392
        )
    )
    switch consume misaligned {
    case nil: break
    case .some: Issue.record("Misaligned capture region was accepted")
    }
}
