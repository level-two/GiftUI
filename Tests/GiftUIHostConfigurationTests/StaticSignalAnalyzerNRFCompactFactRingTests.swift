import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func nRFCompactFactRingsSealInSequenceWithinExactRegions() {
    let byteCount = StaticSignalAnalyzerNRFCompactFactRing.requiredByteCount
    let activeStorage = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 8)
    let sealedStorage = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 8)
    defer {
        activeStorage.deallocate()
        sealedStorage.deallocate()
    }
    guard
        var active = StaticSignalAnalyzerNRFCompactFactRing(
            storage: UnsafeMutableRawBufferPointer(start: activeStorage, count: byteCount)
        ),
        var sealed = StaticSignalAnalyzerNRFCompactFactRing(
            storage: UnsafeMutableRawBufferPointer(start: sealedStorage, count: byteCount)
        )
    else {
        Issue.record("Exact ring regions refused")
        return
    }
    for index in 0 ..< 32 {
        let change = SignalCaptureChange.reset(
            baseRevision: UInt32(index), baselines: .allLow
        )
        let fact = StaticSignalAnalyzerNRFCompactCaptureFact(
            sequence: UInt32(index + 1), revision: UInt32(index + 1), change: change
        )!
        let accepted = active.append(fact)
        #expect(accepted)
    }
    #expect(active.count == 32)
    let excess = StaticSignalAnalyzerNRFCompactCaptureFact(
        sequence: 33, revision: 33,
        change: .reset(baseRevision: 32, baselines: .allLow)
    )!
    let acceptedExcess = active.append(excess)
    #expect(!acceptedExcess)
    let didSeal = active.seal(into: &sealed)
    #expect(didSeal)
    #expect(active.count == 0)
    #expect(sealed.count == 32)
    let sealedAgain = active.seal(into: &sealed)
    #expect(!sealedAgain)
    for expected in 1 ... 32 {
        let taken = sealed.takeFirst()
        #expect(taken?.sequence == UInt32(expected))
    }
    #expect(sealed.count == 0)
    let empty = sealed.takeFirst()
    #expect(empty == nil)
    let next = StaticSignalAnalyzerNRFCompactCaptureFact(
        sequence: 33, revision: 33,
        change: .reset(baseRevision: 32, baselines: .allLow)
    )!
    let acceptedNext = active.append(next)
    #expect(acceptedNext)
    let didSealNext = active.seal(into: &sealed)
    #expect(didSealNext)
    let takenNext = sealed.takeFirst()
    #expect(takenNext?.sequence == 33)
}
